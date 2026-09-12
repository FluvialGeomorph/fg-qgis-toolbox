"""Isolated metadata transport; assertions are explicitly synthetic."""
import json
import os
from pathlib import Path
import shutil
import subprocess


def qualify(a, root, app, algorithm, record, Feedback, digest):
    from qgis.core import QgsProcessingContext
    assert not root.is_relative_to(a.input.resolve().parent)
    source = {str(p): digest(p) for p in a.input.parent.rglob("*") if p.is_file()}
    folder = root / "Papillion Cr\u00e9ek inputs"
    shutil.copytree(a.input.parent, folder)
    copied = {str(p): digest(p) for p in folder.rglob("*") if p.is_file()}
    fixture = json.loads((folder / "terrain-fixture.json").read_text(encoding="utf-8"))
    params = dict(INPUT=str(folder / a.input.name), EVENT_ID=fixture[0]["event_id"],
                  VERTICAL_UNIT="", VERTICAL_REFERENCE="SYNTHETIC TEST reference - not Cole Creek metadata",
                  EVIDENCE='Synthetic "transport" evidence only; no source datum established.',
                  ANALYST="Developer fixture", MANIFEST=str(folder / "metadata.json"),
                  CONTEXT=str(folder / "metadata.gpkg"), OUTPUT=str(root / "synthetic metadata.html"))
    (root / "parameters.json").write_text(json.dumps(params, indent=2), encoding="utf-8")
    if a.inspect_dialog_only:
        from qgis.PyQt.QtGui import QFont, QFontDatabase
        from processing.gui.AlgorithmDialog import AlgorithmDialog
        font = QFontDatabase.addApplicationFont(str(Path(os.environ["WINDIR"]) / "Fonts/segoeui.ttf"))
        app.setFont(QFont(QFontDatabase.applicationFontFamilies(font)[0], 10))
        dialog = AlgorithmDialog(algorithm.create()); dialog.setParameters(params); dialog.resize(1100, 900)
        dialog.show(); app.processEvents(); returned = dialog.createProcessingParameters()
        for key, value in params.items():
            if key == "VERTICAL_UNIT":
                assert returned.get(key) in (None, "")
            elif key in ("EVENT_ID", "VERTICAL_REFERENCE", "EVIDENCE", "ANALYST"):
                assert returned[key] == value
            else:
                assert Path(returned[key]).resolve() == Path(value).resolve()
        assert dialog.grab().save(str(root / "parameter-dialog.png"))
        record["dialog_parameters_roundtrip"] = True; dialog.close()
    else:
        def run(name, overrides, success):
            p = params | overrides
            targets = [Path(p[k]) for k in ("MANIFEST", "CONTEXT", "OUTPUT")]
            existing = {str(t): digest(t) for t in targets if t.exists()}
            feedback = Feedback(); result, ok = algorithm.createInstance().run(p, QgsProcessingContext(), feedback)
            (root / (name + ".log")).write_text("\n".join(feedback.lines), encoding="utf-8")
            record["cases"].append(dict(case=name, ok=ok, result=result, errors=feedback.errors))
            (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
            print(json.dumps(record["cases"][-1]), flush=True)
            assert bool(ok) == success
            assert all(digest(t) == h for t, h in existing.items())
            if success:
                assert not feedback.errors and all(t.is_file() for t in targets)
            else:
                assert all(not t.exists() for t in targets if str(t) not in existing)
        run("partial-metadata", {}, True)
        run("overwrite", {}, False)
        fresh = dict(MANIFEST=str(folder / "never.json"), CONTEXT=str(folder / "never.gpkg"), OUTPUT=str(root / "never.html"))
        run("no-evidence", fresh | {"EVIDENCE": " "}, False)
        run("no-fields", fresh | {"VERTICAL_REFERENCE": ""}, False)
        with (root / "direct-evidence.log").open("w", encoding="utf-8") as log:
            subprocess.run([str(a.r_home / "bin/Rscript.exe"), "--vanilla",
                str(Path(__file__).with_name("qgis-terrain-metadata-evidence.R")), str(a.r_library.resolve()), str(root)],
                stdout=log, stderr=subprocess.STDOUT, check=True)
        record["direct_comparison_passed"] = True
    record["source_inputs_unchanged"] = all(digest(p) == h for p, h in source.items())
    record["copied_inputs_unchanged"] = all(digest(p) == h for p, h in copied.items())
    assert record["source_inputs_unchanged"] and record["copied_inputs_unchanged"]
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
