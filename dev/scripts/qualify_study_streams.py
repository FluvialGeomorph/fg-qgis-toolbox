"""Initial Stream definition qualification; names-only and mapped source modes."""
import json
import os
from pathlib import Path
import shutil
import subprocess


def qualify(a, root, app, algorithm, record, Feedback, digest):
    from qgis.core import QgsProcessingContext
    assert algorithm.parameterDefinition("RATIONALE").multiLine()
    assert not root.is_relative_to(a.input.resolve().parent)
    sources = {str(p): digest(p) for p in a.input.parent.rglob("*") if p.is_file()}
    folder = root / "Papillion Cr\u00e9ek inputs"
    shutil.copytree(a.input.parent, folder)
    copies = {str(p): digest(p) for p in folder.rglob("*") if p.is_file()}
    params = {"INPUT": str(folder / a.input.name), "STREAM_NAMES": "",
              "STREAM_SOURCE": str(folder / "stream areas.gpkg"), "SOURCE_LAYER": "selected_streams",
              "NAME_FIELD": "Name", "RATIONALE": 'Chosen HUC names — developer test only.\nSource: C:\\archive\\new; "Papillion".',
              "CONTEXT": str(folder / "study with streams.gpkg"), "OUTPUT": str(root / "define study area.html")}
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
            if key in ("STREAM_NAMES", "SOURCE_LAYER", "NAME_FIELD", "RATIONALE"):
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

        run("valid-streams", success=True)
        run("overwrite")
        fresh = {"CONTEXT": str(folder / "never.gpkg"), "OUTPUT": str(root / "never.html")}
        run("blank-rationale", fresh | {"RATIONALE": "   "})
        run("missing-name-field", fresh | {"NAME_FIELD": "absent_field"})
        run("existing-inventory", fresh | {"INPUT": params["CONTEXT"]})
        run("conflicting-modes", fresh | {"STREAM_NAMES": "Other Creek"})
        run("report-collision", {"CONTEXT": str(folder / "never.gpkg")})
        run("names-only", {"INPUT": str(folder / "named.gpkg"), "STREAM_NAMES": 'New Créek\nSecond "Creek"',
                          "STREAM_SOURCE": "", "SOURCE_LAYER": "", "NAME_FIELD": "",
                          "CONTEXT": str(folder / "names only.gpkg"), "OUTPUT": str(root / "names only.html")}, success=True)
        with (root / "direct-evidence.log").open("w", encoding="utf-8") as log:
            subprocess.run([str(a.r_home / "bin/Rscript.exe"), "--vanilla",
                            str(Path(__file__).with_name("qgis-streams-evidence.R")),
                            str(a.r_library.resolve()), str(root)],
                           stdout=log, stderr=subprocess.STDOUT, check=True)
        record["direct_comparison_passed"] = True
    record["source_inputs_unchanged"] = all(digest(p) == h for p, h in sources.items())
    record["copied_inputs_unchanged"] = all(digest(p) == h for p, h in copies.items())
    assert record["source_inputs_unchanged"] and record["copied_inputs_unchanged"]
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
