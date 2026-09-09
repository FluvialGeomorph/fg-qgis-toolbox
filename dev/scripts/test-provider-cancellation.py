"""Development-only real R Provider cancellation test; run with python-qgis-ltr.bat.

Use explicit --osgeo --plugin-parent --r-home --output-root (must be NEW).
No installed plugin/profile is changed. Fixture outputs are disposable evidence.
"""
import argparse
import ctypes
import json
import os
from pathlib import Path
import sys
import threading
import time

p = argparse.ArgumentParser(description=__doc__)
for name in ("osgeo", "plugin-parent", "r-home", "output-root"):
    p.add_argument("--" + name, required=True, type=Path)
p.add_argument("--candidate", action="store_true")
a = p.parse_args()
root = a.output_root.resolve()
root.mkdir(parents=True, exist_ok=False)
os.environ["QT_QPA_PLATFORM"] = "offscreen"
os.environ["QGIS_CUSTOM_CONFIG_PATH"] = str(root / "profile")
os.environ["R_ENVIRON_USER"] = str(root / "absent-Renviron")
os.environ["R_PROFILE_USER"] = str(root / "absent-Rprofile")
os.environ["LC_ALL"] = "English_United States.utf8"
os.environ["LANG"] = "English_United States.utf8"
os.environ["PATH"] = os.pathsep.join(str(a.osgeo / x) for x in
    ("bin", "apps/Qt5/bin", "apps/qgis-ltr/bin")) + os.pathsep + os.environ["WINDIR"] + "/System32"
os.environ["QGIS_PREFIX_PATH"] = str(a.osgeo / "apps/qgis-ltr")
os.environ["QT_PLUGIN_PATH"] = str(a.osgeo / "apps/Qt5/plugins")
dlls = [os.add_dll_directory(str(a.osgeo / x)) for x in
        ("bin", "apps/Qt5/bin", "apps/qgis-ltr/bin")]
sys.path.insert(0, str(a.osgeo / "apps/qgis-ltr/python/plugins"))
sys.path.insert(0, str(a.plugin_parent.resolve()))
from qgis.core import QgsApplication, QgsProcessingContext, QgsProcessingFeedback
from qgis.PyQt.QtCore import QSettings, QCoreApplication
QSettings.setDefaultFormat(QSettings.IniFormat)
QSettings.setPath(QSettings.IniFormat, QSettings.UserScope, str(root / "settings"))
QCoreApplication.setOrganizationName("fgqgis-cancel-test")
QCoreApplication.setApplicationName("isolated")
app = QgsApplication([], False)
app.initQgis()
assert Path(QgsApplication.qgisSettingsDirPath()).resolve().is_relative_to(root)
from processing.core.ProcessingConfig import ProcessingConfig
from processing_r.processing.provider import RAlgorithmProvider
from processing_r.processing.algorithm import RAlgorithm
from processing_r.processing.utils import RUtils
ProcessingConfig.initialize()
provider = RAlgorithmProvider()
QgsApplication.processingRegistry().addProvider(provider)
for key, val in ((RUtils.R_FOLDER, str(a.r_home.resolve())), (RUtils.R_USE64, True)):
    ProcessingConfig.setSettingValue(key, val)

class Feedback(QgsProcessingFeedback):
    def __init__(self, cancel_on=None, on_signal=None):
        super().__init__()
        self.lines = []
        self.errors = []
        self.cancel_on = cancel_on
        self.requested = None
        self.timer = None
        self.on_signal = on_signal

    def request_cancel(self):
        self.requested = time.monotonic()
        self.cancel()

    def pushInfo(self, line):
        self.lines.append(line)

    def pushCommandInfo(self, line):
        self.lines.append(line)

    def pushConsoleInfo(self, line):
        self.lines.append(line)
        if line == self.cancel_on and self.timer is None:
            if self.on_signal:
                self.on_signal()
            self.timer = threading.Timer(0.3, self.request_cancel)
            self.timer.start()

    def reportError(self, line, fatalError=False):
        self.errors.append(line)
        self.lines.append(line)

records = []
def run_case(name, body, cancel_on=None, precancel=False, on_signal=None, cancel_at_return=False):
    destination = root / (name + ".html")
    script = "##cancel_probe=name\n##dont_load_any_packages\n##OUTPUT=output html\n" + body
    alg = RAlgorithm(None, script=script)
    assert not alg.error, alg.error
    feedback = Feedback(cancel_on, on_signal)
    if cancel_at_return:
        # QgsProcessingAlgorithm.run() clones the algorithm. Patch the class
        # only for this deterministic timing test, then restore it immediately.
        original_parse = RAlgorithm.parse_output_values
        def cancel_after_parse(self, lines):
            result = original_parse(self, lines)
            feedback.request_cancel()
            return result
        RAlgorithm.parse_output_values = cancel_after_parse
    if precancel:
        feedback.request_cancel()
    started = time.monotonic()
    context = QgsProcessingContext()
    try:
        results, ok = alg.run({"OUTPUT": str(destination)}, context, feedback)
    finally:
        if cancel_at_return:
            RAlgorithm.parse_output_values = original_parse
    finished = time.monotonic()
    if feedback.timer:
        feedback.timer.join()
    item = {"case": name, "ok": ok, "results": results,
            "requested_cancel": feedback.requested is not None,
            "elapsed_seconds": finished - started,
            "cancel_return_seconds": None if feedback.requested is None else finished - feedback.requested,
            "output_exists": destination.exists(), "errors": feedback.errors}
    (root / (name + ".log")).write_text("\n".join(feedback.lines), encoding="utf-8")
    records.append(item)
    (root / "results.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
    print(json.dumps(item), flush=True)
    return item

quiet = run_case("quiet-cancel", 'cat("READY\\n"); flush(stdout()); Sys.sleep(4); writeLines("<html>complete</html>", OUTPUT)\n', "READY")
if not a.candidate:
    assert quiet["requested_cancel"] and quiet["cancel_return_seconds"] > 2
    sys.exit(0)
assert quiet["requested_cancel"] and quiet["cancel_return_seconds"] < 2
assert quiet["ok"] is False and not quiet["results"] and not quiet["output_exists"]
assert quiet["errors"] and all(x.startswith("Canceled:") for x in quiet["errors"]), "Cancellation cleanup failed"
success = run_case("success", 'writeLines("<html>complete</html>", OUTPUT)\n')
assert success["ok"] and success["output_exists"]
failure = run_case("nonzero", 'quit(status=7)\n')
assert failure["ok"] is False and not failure["results"] and not failure["output_exists"]
assert not any("processing_values.txt" in x for x in failure["errors"])
before = run_case("precancel", 'writeLines("<html>unexpected</html>", OUTPUT)\n', precancel=True)
assert before["ok"] is False and not before["results"] and not before["output_exists"]
after = run_case("published-cancel", 'writeLines("<html>complete but canceled</html>", OUTPUT); cat("PUBLISHED\\n"); flush(stdout()); Sys.sleep(4)\n', "PUBLISHED")
assert after["ok"] is False and not after["results"] and after["output_exists"]
assert after["cancel_return_seconds"] < 2
assert after["errors"] and all(x.startswith("Canceled:") for x in after["errors"]), "Cancellation cleanup failed"
late = run_case("return-boundary-cancel", 'writeLines("<html>retained not accepted</html>", OUTPUT)\n', cancel_at_return=True)
assert late["requested_cancel"] and late["ok"] is False and not late["results"] and late["output_exists"]
large = run_case("large-console", 'cat(paste(rep("x", 200000), collapse="")); cat("\\n"); writeLines("<html>complete</html>", OUTPUT)\n')
assert large["ok"] and large["output_exists"] and not large["errors"]

# A real R child, not a mocked process. Hold its handle while alive so the
# completion check cannot accidentally observe a recycled process identifier.
child_script = root / "child.R"
child_pid = root / "child.pid"
child_marker = root / "child-completed.txt"
rq = lambda path: json.dumps(Path(path).as_posix())
child_script.write_text(
    'writeLines(as.character(Sys.getpid()), ' + rq(child_pid) + ')\n'
    'Sys.sleep(6)\nwriteLines("unexpected completion", ' + rq(child_marker) + ')\n', encoding="utf-8")
kernel = ctypes.WinDLL("kernel32", use_last_error=True)
kernel.OpenProcess.argtypes = [ctypes.c_uint32, ctypes.c_int, ctypes.c_uint32]
kernel.OpenProcess.restype = ctypes.c_void_p
kernel.WaitForSingleObject.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
kernel.WaitForSingleObject.restype = ctypes.c_uint32
kernel.CloseHandle.argtypes = [ctypes.c_void_p]
handles = []
def capture_child():
    handle = kernel.OpenProcess(0x00100000, False, int(child_pid.read_text().strip()))
    assert handle, "Could not observe owned child process"
    assert kernel.WaitForSingleObject(handle, 0) == 258, "Fixture child was not running"
    handles.append(handle)
body = ('system2(file.path(R.home("bin"), "Rscript.exe"), '
        'c("--vanilla", shQuote(' + rq(child_script) + ')), wait=FALSE, '
        'stdout=' + rq(root / "child.log") + ', stderr=' + rq(root / "child.log") + ')\n'
        'for (i in 1:100) { if (file.exists(' + rq(child_pid) + ')) break; Sys.sleep(0.05) }\n'
        'stopifnot(file.exists(' + rq(child_pid) + '))\n'
        'cat("CHILD\\n"); flush(stdout()); Sys.sleep(10)\n')
try:
    child = run_case("child-cancel", body, "CHILD", on_signal=capture_child)
    assert child["ok"] is False and not child["results"] and child["cancel_return_seconds"] < 2
    assert child["errors"] and all(x.startswith("Canceled:") for x in child["errors"])
    assert len(handles) == 1 and kernel.WaitForSingleObject(handles[0], 1000) == 0
    assert not child_marker.exists()
    child["owned_child_exited"] = True
    (root / "results.json").write_text(json.dumps(records, indent=2), encoding="utf-8")
finally:
    for handle in handles:
        kernel.CloseHandle(handle)
