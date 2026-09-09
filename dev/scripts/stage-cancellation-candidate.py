"""Copy the reviewed R Provider 4.1.0 into NEW development staging and adapt it.

Inputs: source plugin-parent, NEW destination plugin-parent. Never targets an
existing profile. This is not an installer or a general plugin upgrade tool.
"""
import hashlib
import json
from pathlib import Path
import shutil
import sys

source = Path(sys.argv[1]).resolve() / "processing_r"
parent = Path(sys.argv[2]).resolve()
staging_root = Path(__file__).resolve().parents[1] / "check-output"
if not parent.is_relative_to(staging_root.resolve()):
    raise RuntimeError("Candidate destination must be inside this repository's dev/check-output")
expected = {
    "processing/utils.py": "87b940ef704e7a3b1f16fcc144f2ea470a8504417ebff870409ef19df3410746",
    "processing/algorithm.py": "f28ffeb5346fb3f6ceb88ac1aa5fd9e2681a6d848cfcd4c14ca183ad92b944c1",
}
for name, digest in expected.items():
    if hashlib.sha256((source / name).read_bytes()).hexdigest() != digest:
        raise RuntimeError("Unreviewed provider source: " + name)
parent.mkdir(parents=True, exist_ok=False)
target = parent / "processing_r"
shutil.copytree(source, target, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
utils = (target / "processing/utils.py").read_text(encoding="utf-8")
start = utils.index("        console_results = []\n", utils.index("    def execute_r_algorithm("))
end = utils.index("        return console_results\n", start) + len("        return console_results\n")
utils = utils[:start] + """        from processing_r.processing.fg_cancel import execute_cancellable
        return execute_cancellable(alg, feedback, command,
                                   RUtils.get_process_keywords(), RUtils.is_error_line)
""" + utils[end:]
(target / "processing/utils.py").write_text(utils, encoding="utf-8")
algorithm = (target / "processing/algorithm.py").read_text(encoding="utf-8")
algorithm = algorithm.replace("from processing_r.processing.utils import RUtils\n",
    "from processing_r.processing.utils import RUtils\nfrom processing_r.processing.fg_cancel import ensure_not_canceled\n", 1)
algorithm = algorithm.replace("        output = RUtils.execute_r_algorithm(self, parameters, context, feedback)\n",
    "        ensure_not_canceled(self, feedback)\n        output = RUtils.execute_r_algorithm(self, parameters, context, feedback)\n        ensure_not_canceled(self, feedback)\n", 1)
assert algorithm.count("        return self.results\n") == 1
algorithm = algorithm.replace("        return self.results\n", "        ensure_not_canceled(self, feedback)\n        return self.results\n", 1)
(target / "processing/algorithm.py").write_text(algorithm, encoding="utf-8")
helper = Path(__file__).resolve().parents[1] / "patches/r-provider-cancellation/fg_cancel.py"
shutil.copy2(helper, target / "processing/fg_cancel.py")
metadata = (target / "metadata.txt").read_text(encoding="utf-8")
metadata = metadata.replace("version=4.1.0\n", "version=4.1.0-fg-cancel1\n", 1)
metadata = metadata.replace("name=Processing R Provider\n", "name=Processing R Provider (FG cancellation experiment)\n", 1)
(target / "metadata.txt").write_text(metadata, encoding="utf-8")
(parent / "candidate.json").write_text(json.dumps({
    "status": "development-only-not-deployed", "upstream": "4.1.0",
    "source_hashes": expected, "candidate": "4.1.0-fg-cancel1",
    "helper_sha256": hashlib.sha256(helper.read_bytes()).hexdigest(),
}, indent=2), encoding="utf-8")
print("Staged a development-only cancellation candidate at " + str(parent))
