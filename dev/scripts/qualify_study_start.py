"""New-study cases for the shared QGIS qualification harness; no source input."""
import json
import os
from pathlib import Path
import subprocess


def qualify(a, root, app, algorithm, record, Feedback, digest, plugin_parent,
            installed_script, settings):
    from qgis.core import QgsProcessingContext
    assert algorithm.parameterDefinition("SCOPE_NOTES").multiLine()
    folder = root / "New Cr\u00e9ek drafts"
    folder.mkdir()
    values = {"STUDY_NAME": 'Example Creek — new "draft"',
              "SCOPE_NOTES": 'Customer\'s question — test only.\nReference: C:\\terrain\\new; <not approval>.'}
    (root / "start-values.json").write_text(json.dumps(values), encoding="utf-8")
    context = folder / "developer draft.gpkg"
    report = root / "define study area.html"
    params = values | {"CONTEXT": str(context), "OUTPUT": str(report)}

    if a.inspect_dialog_only:
        from qgis.PyQt.QtGui import QFont, QFontDatabase
        from processing.gui.AlgorithmDialog import AlgorithmDialog
        font = QFontDatabase.addApplicationFont(str(Path(os.environ["WINDIR"]) / "Fonts/segoeui.ttf"))
        assert font >= 0
        app.setFont(QFont(QFontDatabase.applicationFontFamilies(font)[0], 10))
        dialog = AlgorithmDialog(algorithm.create())
        dialog.setParameters(params)
        dialog.resize(1100, 750)
        dialog.show()
        app.processEvents()
        returned = dialog.createProcessingParameters()
        assert all(returned[k] == v for k, v in values.items())
        assert all(Path(returned[k]).resolve() == Path(params[k]) for k in ("CONTEXT", "OUTPUT"))
        assert dialog.grab().save(str(root / "parameter-dialog.png"))
        record["dialog_parameters_roundtrip"] = True
        (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
        dialog.close()
        return

    def run(name, overrides=None, success=False):
        supplied = params | (overrides or {})
        targets = [Path(supplied[k]) for k in ("CONTEXT", "OUTPUT")]
        before = {str(p): digest(p) for p in targets if p.is_file()}
        feedback = Feedback()
        error = None
        result, ok = {}, False
        try:
            result, ok = algorithm.createInstance().run(supplied, QgsProcessingContext(), feedback)
        except Exception as exc:
            error = str(exc)
        (root / (name + ".log")).write_text("\n".join(feedback.lines), encoding="utf-8")
        item = {"case": name, "ok": ok, "result": result, "exception": error,
                "reported_errors": feedback.errors,
                "existing_outputs_unchanged": all(digest(p) == h for p, h in before.items())}
        record["cases"].append(item)
        (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
        print(json.dumps(item), flush=True)
        assert item["existing_outputs_unchanged"]
        if success:
            assert ok and not error and not feedback.errors and all(p.is_file() for p in targets)
            assert all(Path(result[k]).resolve() == Path(supplied[k]).resolve() for k in ("CONTEXT", "OUTPUT"))
            assert any(line.startswith("Using R's spatial resources;") for line in feedback.lines)
        else:
            assert not ok and all(not p.exists() for p in targets if str(p) not in before)

    run("valid-unicode", success=True)
    run("overwrite")
    run("blank-name", {"STUDY_NAME": "   ", "CONTEXT": str(folder / "invalid.gpkg"),
                       "OUTPUT": str(root / "invalid.html")})
    run("report-collision", {"CONTEXT": str(folder / "collision.gpkg")})
    # Provider preprocessParameters creates output parent directories before R.
    # This differs from calling the R function directly with a missing parent.
    run("provider-created-directory", {"CONTEXT": str(folder / "absent" / "draft.gpkg"),
                                       "OUTPUT": str(root / "new folder.html")}, success=True)
    record["provider_created_output_parent"] = (folder / "absent").is_dir()
    run("blank-notes", {"SCOPE_NOTES": "", "CONTEXT": str(folder / "blank notes.gpkg"),
                        "OUTPUT": str(root / "blank notes.html")}, success=True)
    # Reference rendering only; never create a second identity to compare HTML.
    with (root / "direct-evidence.log").open("w", encoding="utf-8") as log:
        subprocess.run([str(a.r_home / "bin/Rscript.exe"), "--vanilla",
                        str(Path(__file__).with_name("qgis-start-evidence.R")),
                        str(a.r_library.resolve()), str(root)],
                       stdout=log, stderr=subprocess.STDOUT, check=True)
    record["direct_comparison_passed"] = True
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
    if a.prepare_desktop_trial:
        settings.sync()
        trial = {
            "schema_version": 4, "status": "prepared-not-analyst-qualified",
            "root": str(root), "osgeo": str(a.osgeo.resolve()),
            "profiles_path": str(root / "profile"), "profile_name": "default",
            "r_home": str(a.r_home.resolve()), "r_library": str(a.r_library.resolve()),
            "algorithm": algorithm.id(), "script_name": installed_script.name,
            "suggested_context": str(folder / "analyst draft.gpkg"),
            "suggested_output": str(root / "analyst report.html"),
            "qgis": record["qgis"], "provider": record["provider"],
            "proj_sha256": digest(a.osgeo / "share/proj/proj.db"),
            "script_sha256": digest(installed_script),
            "plugin_files": {str(p.relative_to(plugin_parent)): digest(p)
                             for p in sorted((plugin_parent / "processing_r").rglob("*"))
                             if p.is_file() and "__pycache__" not in p.parts and p.suffix != ".pyc"}}
        (root / "trial.json").write_text(json.dumps(trial, indent=2), encoding="utf-8")
        print("New-study trial prepared; no desktop window launched", flush=True)
