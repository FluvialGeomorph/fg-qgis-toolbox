"""Acquired Survey Event qualification; fixtures are prepared separately by R."""
import json
import os
from pathlib import Path
import shutil
import subprocess


def qualify(a, root, app, algorithm, record, Feedback, digest):
    from qgis.core import QgsProcessingContext
    assert algorithm.parameterDefinition("EVIDENCE").multiLine()
    assert not root.is_relative_to(a.input.resolve().parent)
    sources = {str(p): digest(p) for p in a.input.parent.rglob("*") if p.is_file()}
    folder = root / "Papillion Cr\u00e9ek inputs"
    shutil.copytree(a.input.parent, folder)
    copies = {str(p): digest(p) for p in folder.rglob("*") if p.is_file()}
    fixture = json.loads((folder / "survey-fixture.json").read_text(encoding="utf-8"))
    params = {"INPUT": str(folder / a.input.name), "REACH_ID": fixture["reach_id"],
              "ACQUIRED_DATE": "2006", "SOURCE_REFERENCE": "y2006_R1.gdb", "EVIDENCE": fixture["evidence"],
              "CONTEXT": str(folder / "event 2006.gpkg"), "OUTPUT": str(root / "event 2006.html")}
    (root / "parameters.json").write_text(json.dumps(params, indent=2), encoding="utf-8")
    if a.inspect_dialog_only:
        from qgis.PyQt.QtGui import QFont, QFontDatabase
        from processing.gui.AlgorithmDialog import AlgorithmDialog
        font = QFontDatabase.addApplicationFont(str(Path(os.environ["WINDIR"]) / "Fonts/segoeui.ttf"))
        assert font >= 0
        app.setFont(QFont(QFontDatabase.applicationFontFamilies(font)[0], 10))
        dialog = AlgorithmDialog(algorithm.create())
        dialog.setParameters(params)
        dialog.resize(1100, 780)
        dialog.show()
        app.processEvents()
        returned = dialog.createProcessingParameters()
        for key, value in params.items():
            if key in ("REACH_ID", "ACQUIRED_DATE", "SOURCE_REFERENCE", "EVIDENCE"):
                assert returned[key] == value
            else:
                assert Path(returned[key]).resolve() == Path(value).resolve()
        assert dialog.grab().save(str(root / "parameter-dialog.png"))
        record["dialog_parameters_roundtrip"] = True
        dialog.close()
    else:
        def run(name, overrides=None, success=False):
            supplied = params | (overrides or {})
            targets = [Path(supplied[k]) for k in ("CONTEXT", "OUTPUT")]
            existing = {str(p): digest(p) for p in targets if p.is_file()}
            feedback = Feedback()
            result, ok, error = {}, False, None
            try:
                result, ok = algorithm.createInstance().run(supplied, QgsProcessingContext(), feedback)
            except Exception as exc:
                error = str(exc)
            (root / (name + ".log")).write_text("\n".join(feedback.lines), encoding="utf-8")
            item = {"case": name, "ok": ok, "result": result, "exception": error,
                    "errors": feedback.errors,
                    "existing_outputs_unchanged": all(digest(p) == h for p, h in existing.items())}
            record["cases"].append(item)
            (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
            print(json.dumps(item), flush=True)
            assert item["existing_outputs_unchanged"]
            if success:
                assert ok and not error and not feedback.errors and all(p.is_file() for p in targets)
                assert all(Path(result[k]).resolve() == Path(supplied[k]).resolve() for k in ("CONTEXT", "OUTPUT"))
            else:
                assert not ok and all(not p.exists() for p in targets if str(p) not in existing)

        run("event-2006", success=True)
        second = {"INPUT": params["CONTEXT"], "ACQUIRED_DATE": "2010", "SOURCE_REFERENCE": "y2010_R1.gdb",
                  "CONTEXT": str(folder / "event 2010.gpkg"), "OUTPUT": str(root / "event 2010.html")}
        run("event-2010", second, success=True)
        final = {"INPUT": second["CONTEXT"], "ACQUIRED_DATE": "2016", "SOURCE_REFERENCE": "y2016_R1.gdb",
                 "CONTEXT": str(folder / "events.gpkg"), "OUTPUT": str(root / "define study area.html")}
        run("event-2016", final, success=True)
        (root / "final-parameters.json").write_text(json.dumps(params | final, indent=2), encoding="utf-8")
        fresh = {"CONTEXT": str(folder / "never.gpkg"), "OUTPUT": str(root / "never.html")}
        run("duplicate", fresh | {"INPUT": final["CONTEXT"]})
        run("invalid-date", fresh | {"ACQUIRED_DATE": "2015-02-29"})
        run("future-plan", fresh | {"ACQUIRED_DATE": "9999"})
        run("unknown-reach", fresh | {"REACH_ID": "unknown"})
        run("missing-evidence", fresh | {"EVIDENCE": "   "})
        run("overwrite")
        run("report-collision", {"CONTEXT": str(folder / "never.gpkg")})
        with (root / "direct-evidence.log").open("w", encoding="utf-8") as log:
            subprocess.run([str(a.r_home / "bin/Rscript.exe"), "--vanilla",
                            str(Path(__file__).with_name("qgis-survey-event-evidence.R")),
                            str(a.r_library.resolve()), str(root)],
                           stdout=log, stderr=subprocess.STDOUT, check=True)
        record["direct_comparison_passed"] = True
    record["source_inputs_unchanged"] = all(digest(p) == h for p, h in sources.items())
    record["copied_inputs_unchanged"] = all(digest(p) == h for p, h in copies.items())
    assert record["source_inputs_unchanged"] and record["copied_inputs_unchanged"]
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
