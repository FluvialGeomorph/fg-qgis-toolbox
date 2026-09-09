# SPDX-License-Identifier: GPL-3.0-or-later
"""Experimental Windows R Provider runner. Not installed by the fgqgis package.

Keep console output in the provider's own temporary directory and poll the
process independently of its output. No global process-name termination, shell
commands, output deletion or scientific changes. Candidate for upstream review.
"""
import codecs
import os
from pathlib import Path
import subprocess
import tempfile
import time

from qgis.core import QgsProcessingException


def ensure_not_canceled(alg, feedback):
    if feedback.isCanceled():
        alg.results.clear()
        raise QgsProcessingException(
            "Canceled: no outputs are accepted or offered as successful results. "
            "Files already written are retained for inspection; do not use them as completed outputs."
        )


def _stop_tree(proc):
    if proc.poll() is not None:
        return
    # Only this still-owned subprocess PID and its descendants. Keep its process
    # handle open throughout; never kill by image name or inspect unrelated R.
    killer = Path(os.environ["WINDIR"]) / "System32/taskkill.exe"
    result = subprocess.run(
        [str(killer), "/PID", str(proc.pid), "/T", "/F"],
        stdin=subprocess.DEVNULL, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
        creationflags=subprocess.CREATE_NO_WINDOW, timeout=5,
    )
    if result.returncode != 0 and proc.poll() is None:
        raise RuntimeError("Could not stop the owned R process tree; cleanup requires developer review")
    proc.wait(timeout=5)


def execute_cancellable(alg, feedback, command, process_keywords, is_error_line):
    """Return console lines only after a zero exit and uncanceled completion."""
    if os.name != "nt":
        raise QgsProcessingException("This development cancellation candidate is qualified on Windows only")
    ensure_not_canceled(alg, feedback)
    keywords = dict(process_keywords)
    encoding = keywords.pop("encoding", None) or "utf-8"
    console = []
    pending = ""
    decoder = codecs.getincrementaldecoder(encoding)(errors="replace")
    # A regular file avoids blocking readline() and pipe-capacity deadlocks.
    # Reader and child writer use separate file positions. Retain the raw log
    # beside the generated R script, under QGIS's run-owned temporary directory.
    with tempfile.NamedTemporaryFile(mode="wb", prefix="r-console-", suffix=".log",
                                     dir=Path(command[1]).parent, delete=False) as writer:
        log_path = writer.name
        proc = subprocess.Popen(command, stdout=writer, stderr=subprocess.STDOUT,
                                stdin=subprocess.DEVNULL, **keywords)
    try:
        with open(log_path, "rb") as reader:
            def drain(final=False):
                nonlocal pending
                chunk = reader.read(65536)
                pending += decoder.decode(chunk, final=final and not chunk)
                while "\n" in pending:
                    line, pending = pending.split("\n", 1)
                    line = line.strip()
                    if is_error_line(line):
                        feedback.reportError(line)
                    else:
                        feedback.pushConsoleInfo(line)
                    console.append(line)
                return bool(chunk)

            while proc.poll() is None:
                if feedback.isCanceled():
                    _stop_tree(proc)
                    ensure_not_canceled(alg, feedback)
                drain()
                time.sleep(0.05)
            while drain(final=True):
                ensure_not_canceled(alg, feedback)
            if pending:
                console.append(pending.strip())
                if is_error_line(pending):
                    feedback.reportError(pending.strip())
                else:
                    feedback.pushConsoleInfo(pending.strip())
        ensure_not_canceled(alg, feedback)
        if proc.returncode != 0:
            alg.results.clear()
            raise QgsProcessingException("R exited with status {}. No successful outputs were returned.".format(proc.returncode))
        return console
    except Exception:
        alg.results.clear()
        try:
            _stop_tree(proc)
        except Exception as cleanup_error:
            raise QgsProcessingException(str(cleanup_error)) from cleanup_error
        raise
