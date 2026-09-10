"""Round-trip the candidate's actual scalar text serializer through R.

Arguments: plugin-parent, Rscript executable, NEW evidence directory.
Uses only the extracted pure method (not a substitute implementation), then R.
No QGIS profile or package installation changes. Run R checks sequentially.
"""
import ast
import json
import os
from pathlib import Path
import subprocess
import sys

template = Path(sys.argv[1]) / "processing_r/processing/r_templates.py"
tree = ast.parse(template.read_text(encoding="utf-8"))
cls = next(n for n in tree.body if isinstance(n, ast.ClassDef) and n.name == "RTemplates")
method = next(n for n in cls.body if isinstance(n, ast.FunctionDef) and n.name == "_r_string")
ns = {}
exec(compile(ast.fix_missing_locations(ast.Module(body=[method], type_ignores=[])), str(template), "exec"), ns)
values = ["", "plain text", "Analyst's note", '"quoted"', "two\nlines", "tab\there\rreturn",
          r"C:\terrain\new", r"literal \n and \t", 'backslash then quote: \\"',
          "Cole Cr\u00e9ek — \U0001f30e", '"); stop("must not execute") #', "\b\f\x1b"]
root = Path(sys.argv[3]).resolve()
root.mkdir(parents=True, exist_ok=False)
os.environ["LC_ALL"] = "English_United States.utf8" if os.name == "nt" else "C.UTF-8"
os.environ["LANG"] = os.environ["LC_ALL"]
(root / "expected.json").write_text(json.dumps(values, ensure_ascii=False), encoding="utf-8")
code = "actual <- c(" + ",\n".join(ns['_r_string'](None, x) for x in values) + ")\n"
code += '''expected <- jsonlite::read_json("expected.json", simplifyVector = TRUE)
stopifnot(identical(actual, expected))
jsonlite::write_json(list(passed = length(actual), exact_text = TRUE), "results.json", auto_unbox = TRUE)
'''
(root / "generated.R").write_text(code, encoding="utf-8")
with (root / "check.log").open("w", encoding="utf-8") as log:
    subprocess.run([sys.argv[2], "--vanilla", "-e", 'source("generated.R", encoding="UTF-8")'],
                   cwd=root, stdout=log, stderr=subprocess.STDOUT, check=True)
print("Exact scalar-text round-trip passed for " + str(len(values)) + " cases")
