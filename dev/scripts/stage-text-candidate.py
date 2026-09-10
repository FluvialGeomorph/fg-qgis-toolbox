"""Stage a text-escaping correction on a COPY of the FG cancellation candidate.

Arguments: source plugin-parent, NEW destination plugin-parent. Development only;
never modifies an installed profile. The prior cancellation adaptation is retained.
"""
import hashlib
import json
from pathlib import Path
import shutil
import sys

source = Path(sys.argv[1]).resolve() / "processing_r"
parent = Path(sys.argv[2]).resolve()
staging = Path(__file__).resolve().parents[1] / "check-output"
if not parent.is_relative_to(staging.resolve()):
    raise RuntimeError("Destination must be inside this repository's dev/check-output")
template_hash = "385e0def430817a1d61f7c8f6886a4aca0c3f40164ef9ec49c866e67e73ffb23"
if hashlib.sha256((source / "processing/r_templates.py").read_bytes()).hexdigest() != template_hash:
    raise RuntimeError("Unreviewed R template source")
metadata = (source / "metadata.txt").read_text(encoding="utf-8")
if "version=4.1.0-fg-cancel1\n" not in metadata:
    raise RuntimeError("Use the identified cancellation candidate as input")
parent.mkdir(parents=True, exist_ok=False)
target = parent / "processing_r"
shutil.copytree(source, target, ignore=shutil.ignore_patterns("__pycache__", "*.pyc"))
path = target / "processing/r_templates.py"
code = path.read_text(encoding="utf-8")
start = code.index("    def _r_string(self, value: str) -> str:\n")
end = code.index("    def set_variable_string_list(", start)
code = code[:start] + '''    def _r_string(self, value: str) -> str:
        # JSON's quoted Unicode string syntax is compatible with R for these
        # scalar strings. Escape backslashes BEFORE interpreting any R code.
        # Preserve Unicode directly, avoiding JSON surrogate-pair escapes in R.
        import json
        return json.dumps(value, ensure_ascii=False)

''' + code[end:]
path.write_text(code, encoding="utf-8")
(target / "metadata.txt").write_text(metadata.replace(
    "version=4.1.0-fg-cancel1\n", "version=4.1.0-fg-text1\n", 1).replace(
    "FG cancellation experiment", "FG cancellation and text experiment", 1), encoding="utf-8")
files = lambda folder: {f.relative_to(folder).as_posix(): hashlib.sha256(f.read_bytes()).hexdigest()
    for f in sorted(folder.rglob("*")) if f.is_file() and "__pycache__" not in f.parts and f.suffix != ".pyc"}
before, after = files(source), files(target)
changed = [key for key in before if before[key] != after[key]]
assert set(changed) == {"metadata.txt", "processing/r_templates.py"}
(parent / "candidate.json").write_text(json.dumps({
    "status": "development-only-not-deployed", "base": "4.1.0-fg-cancel1",
    "candidate": "4.1.0-fg-text1", "changed_files": changed,
    "source_hashes": before, "candidate_hashes": after,
}, indent=2), encoding="utf-8")
print("Staged development text candidate at " + str(parent))
