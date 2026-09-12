"""Actual-provider terrain association, isolated from analyst profiles."""
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
    fixture = json.loads((folder / "terrain-fixture.json").read_text(encoding="utf-8"))
    params = {"INPUT": str(folder / a.input.name), "EVENT_ID": fixture[0]["event_id"],
              "TERRAIN": str(folder / fixture[0]["path"]),
              "EVIDENCE": 'Explicit retained Cole Creek source association; source/copy checks saved separately. Vertical reference remains unknown.',
              "ANALYST": "Developer fixture; not analyst approval",
              "MANIFEST": str(folder / "terrain 2006.json"),
              "CONTEXT": str(folder / "linked 2006.gpkg"), "OUTPUT": str(root / "linked 2006.html")}
    (root / "parameters.json").write_text(json.dumps(params, indent=2), encoding="utf-8")
    if a.inspect_dialog_only:
        from qgis.PyQt.QtGui import QFont, QFontDatabase
        from processing.gui.AlgorithmDialog import AlgorithmDialog
        font = QFontDatabase.addApplicationFont(str(Path(os.environ["WINDIR"]) / "Fonts/segoeui.ttf"))
        assert font >= 0
        app.setFont(QFont(QFontDatabase.applicationFontFamilies(font)[0], 10))
        dialog = AlgorithmDialog(algorithm.create())
        dialog.setParameters(params)
        dialog.resize(1100, 850)
        dialog.show()
        app.processEvents()
        returned = dialog.createProcessingParameters()
        for key, value in params.items():
            if key in ("EVENT_ID", "EVIDENCE", "ANALYST"):
                assert returned[key] == value
            else:
                assert Path(returned[key]).resolve() == Path(value).resolve()
        assert dialog.grab().save(str(root / "parameter-dialog.png"))
        record["dialog_parameters_roundtrip"] = True
        dialog.close()
    else:
        def run(name, overrides=None, success=False):
            supplied = params | (overrides or {})
            targets = [Path(supplied[k]) for k in ("MANIFEST", "CONTEXT", "OUTPUT")]
            existing = {str(p): digest(p) for p in targets if p.is_file()}
            feedback = Feedback()
            result, ok, error = {}, False, None
            try:
                result, ok = algorithm.createInstance().run(supplied, QgsProcessingContext(), feedback)
            except Exception as exc:
                error = str(exc)
            (root / (name + ".log")).write_text("\n".join(feedback.lines), encoding="utf-8")
            item = {"case": name, "ok": ok, "result": result, "exception": error, "errors": feedback.errors,
                    "existing_outputs_unchanged": all(digest(p) == h for p, h in existing.items())}
            record["cases"].append(item)
            (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
            print(json.dumps(item), flush=True)
            assert item["existing_outputs_unchanged"]
            if success:
                assert ok and not error and not feedback.errors and all(p.is_file() for p in targets)
                assert all(Path(result[k]).resolve() == Path(supplied[k]).resolve() for k in ("MANIFEST", "CONTEXT", "OUTPUT"))
            else:
                assert not ok and all(not p.exists() for p in targets if str(p) not in existing)
            return supplied

        entries = []
        current = params["INPUT"]
        for f in fixture:
            year = str(f["year"])
            supplied = run("terrain-" + year, {"INPUT": current, "EVENT_ID": f["event_id"],
                "TERRAIN": str(folder / f["path"]), "MANIFEST": str(folder / ("terrain " + year + ".json")),
                "CONTEXT": str(folder / ("linked " + year + ".gpkg")),
                "OUTPUT": str(root / ("define study area.html" if year == "2016" else "linked " + year + ".html"))}, True)
            entries.append(supplied)
            current = supplied["CONTEXT"]
        (root / "entries.json").write_text(json.dumps(entries, indent=2), encoding="utf-8")
        fresh = {"MANIFEST": str(folder / "never.json"), "CONTEXT": str(folder / "never.gpkg"), "OUTPUT": str(root / "never.html")}
        run("already-selected", fresh | {"INPUT": current})
        run("unknown-event", fresh | {"EVENT_ID": "unknown"})
        run("missing-file", fresh | {"TERRAIN": str(folder / "missing.tif")})
        run("wrong-format", fresh | {"TERRAIN": params["INPUT"]})
        run("missing-evidence", fresh | {"EVIDENCE": "   "})
        run("manifest-collision", fresh | {"MANIFEST": params["MANIFEST"]})
        run("context-collision", fresh | {"CONTEXT": params["CONTEXT"]})
        run("report-collision", fresh | {"OUTPUT": params["OUTPUT"]})
        with (root / "direct-evidence.log").open("w", encoding="utf-8") as log:
            subprocess.run([str(a.r_home / "bin/Rscript.exe"), "--vanilla",
                str(Path(__file__).with_name("qgis-event-terrain-evidence.R")), str(a.r_library.resolve()), str(root)],
                stdout=log, stderr=subprocess.STDOUT, check=True)
        record["direct_comparison_passed"] = True
    record["source_inputs_unchanged"] = all(digest(p) == h for p, h in sources.items())
    record["copied_inputs_unchanged"] = all(digest(p) == h for p, h in copies.items())
    assert record["source_inputs_unchanged"] and record["copied_inputs_unchanged"]
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
