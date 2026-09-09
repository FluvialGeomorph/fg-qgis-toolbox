"""Exercise the unmodified R Provider in an isolated headless QGIS profile.

Run with the OSGeo4W python-qgis-ltr launcher. No installs or downloads occur.
Arguments: --osgeo --plugin-parent --r-home --r-library --input --output-root.
Use a NEW output root; raw evidence is written there, not into the user profile.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys

p = argparse.ArgumentParser(description=__doc__)
for name in ("osgeo", "plugin-parent", "r-home", "r-library", "input", "output-root"):
    p.add_argument("--" + name, required=True, type=Path)
p.add_argument("--isolate-r-spatial-env", action="store_true",
               help="Test R without inherited OSGeo GDAL/PROJ overrides; changes this process only")
p.add_argument("--inspect-dialog-only", action="store_true",
               help="Inspect/render the real Qt parameter dialog offscreen, without running R")
a = p.parse_args()
root = a.output_root.resolve()
root.mkdir(parents=True, exist_ok=False)
os.environ["QT_QPA_PLATFORM"] = "offscreen"
os.environ["QGIS_CUSTOM_CONFIG_PATH"] = str(root / "profile")
os.environ["R_ENVIRON_USER"] = str(root / "absent-Renviron")
os.environ["R_PROFILE_USER"] = str(root / "absent-Rprofile")
os.environ["LC_ALL"] = "English_United States.utf8"
os.environ["LANG"] = "English_United States.utf8"
os.environ["PATH"] = os.pathsep.join(str(a.osgeo / part) for part in
    ("bin", "apps/Qt5/bin", "apps/qgis-ltr/bin")) + os.pathsep + os.environ["WINDIR"] + "/System32"
os.environ["QGIS_PREFIX_PATH"] = str(a.osgeo / "apps/qgis-ltr")
os.environ["QT_PLUGIN_PATH"] = str(a.osgeo / "apps/Qt5/plugins")
# Detect the observed mixed-package failure before initializing spatial libraries.
with sqlite3.connect((a.osgeo / "share/proj/proj.db").resolve().as_uri() + "?mode=ro", uri=True) as db:
    proj_metadata = dict(db.execute("select * from metadata"))
inventory = (a.osgeo / "etc/setup/installed.db").read_text()
expected_package = "proj-runtime-data proj-runtime-data-" + proj_metadata["PROJ.VERSION"] + "-"
assert any(line.startswith(expected_package) for line in inventory.splitlines()), "OSGeo4W PROJ database does not match its installed runtime-data package; repair/qualify the installation first"
# Retain handles: embedded Python needs explicit DLL directories on this host.
dll_handles = [os.add_dll_directory(str(a.osgeo / part)) for part in
               ("bin", "apps/Qt5/bin", "apps/qgis-ltr/bin")]
sys.path.insert(0, str(a.osgeo / "apps/qgis-ltr/python/plugins"))
sys.path.insert(0, str(a.plugin_parent.resolve()))
from qgis.core import (Qgis, QgsApplication, QgsProcessingContext,
                       QgsProcessingFeedback, QgsCoordinateReferenceSystem,
                       QgsCoordinateTransform, QgsProject, QgsPointXY)
from qgis.PyQt.QtCore import QSettings, QCoreApplication

QSettings.setDefaultFormat(QSettings.IniFormat)
QSettings.setPath(QSettings.IniFormat, QSettings.UserScope, str(root / "settings"))
QCoreApplication.setOrganizationName("fgqgis-qualification")
QCoreApplication.setApplicationName("isolated-provider-test")
(root / "profile").mkdir()
app = QgsApplication([], a.inspect_dialog_only, str(root / "profile"))
print("Profile before initialization: " + QgsApplication.qgisSettingsDirPath(), flush=True)
print("QGIS application created", flush=True)
app.initQgis()
assert Path(QgsApplication.qgisSettingsDirPath()).resolve().is_relative_to(root), QgsApplication.qgisSettingsDirPath()
print("QGIS initialized", flush=True)
geographic = QgsCoordinateReferenceSystem("EPSG:4326")
projected = QgsCoordinateReferenceSystem("EPSG:26914")
assert geographic.isValid() and projected.isValid()
point = QgsPointXY(-96.1, 41.2)
forward = QgsCoordinateTransform(geographic, projected, QgsProject.instance())
inverse = QgsCoordinateTransform(projected, geographic, QgsProject.instance())
back = inverse.transform(forward.transform(point))
roundtrip_error = max(abs(back.x() - point.x()), abs(back.y() - point.y()))
assert roundtrip_error < 1e-8, "CRS round-trip smoke check failed (not a survey accuracy test)"
from processing.core.ProcessingConfig import ProcessingConfig
from processing_r.processing.provider import RAlgorithmProvider
from processing_r.processing.utils import RUtils, plugin_version
print("Processing and R Provider imported", flush=True)
sys.excepthook = sys.__excepthook__
sys.stderr = sys.__stderr__
QgsApplication.messageLog().messageReceived.connect(
    lambda message, tag, level: print(f"QGIS {tag}: {message}", flush=True))
# Register only the provider under test, not unrelated 3D/PDAL/GRASS providers.
ProcessingConfig.initialize()
provider = RAlgorithmProvider()
print("R Provider constructed", flush=True)
QgsApplication.processingRegistry().addProvider(provider)
print("R Provider registered", flush=True)
scripts = a.r_library.resolve() / "fgqgis/rscripts"
source_script = Path(__file__).resolve().parents[2] / "inst/rscripts/fg_review_stream_network.rsx"
installed_script = scripts / source_script.name
assert installed_script.read_bytes() == source_script.read_bytes(), "Install the current fgqgis into the test library first"
for key, value in ((RUtils.RSCRIPTS_FOLDER, str(scripts)),
                   (RUtils.R_FOLDER, str(a.r_home.resolve())),
                   (RUtils.R_USE64, True), (RUtils.R_USE_USER_LIB, True),
                   (RUtils.R_LIBS_USER, str(a.r_library.resolve()))):
    ProcessingConfig.setSettingValue(key, value)
provider.refreshAlgorithms()
print("Script folders: " + str(RUtils.script_folders()), flush=True)
print("Algorithms: " + str([x.id() for x in provider.algorithms()]), flush=True)
algorithm = QgsApplication.processingRegistry().algorithmById("r:fgreviewstreamnetwork")
assert algorithm is not None, "Wrapper was not registered"
record = {"qgis": Qgis.QGIS_VERSION, "provider": plugin_version(),
          "proj_metadata": proj_metadata, "crs_roundtrip_error_degrees": roundtrip_error,
          "profile": QgsApplication.qgisSettingsDirPath(),
          "algorithm": algorithm.id(), "parser_error": algorithm.error,
          "help_present": "ALG_DESC" in (algorithm.inline_help or {}),
          "parameters": [x.name() for x in algorithm.parameterDefinitions()],
          "cases": []}
record["removed_r_environment_keys"] = []
if a.isolate_r_spatial_env:
    for key in ("GDAL_DRIVER_PATH", "GDAL_DATA", "PROJ_LIB", "PROJ_DATA"):
        if key in os.environ:
            record["removed_r_environment_keys"].append(key)
            del os.environ[key]
(root / "help.html").write_text(algorithm.shortHelpString(), encoding="utf-8")
assert not algorithm.error, algorithm.error
assert record["help_present"]
assert record["parameters"] == ["INPUT", "OUTPUT"]

class Feedback(QgsProcessingFeedback):
    def __init__(self):
        super().__init__()
        self.lines = []
        self.errors = []

    def pushInfo(self, text):
        self.lines.append(text)

    def pushConsoleInfo(self, text):
        self.lines.append(text)

    def pushCommandInfo(self, text):
        self.lines.append(text)

    def reportError(self, text, fatalError=False):
        self.errors.append(text)
        self.lines.append(text)

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

source_hash = digest(a.input)
inputs = root / "Cole Cr\u00e9ek inputs"
inputs.mkdir()
copied = inputs / "network draft.gpkg"
shutil.copy2(a.input, copied)
output = root / "network review.html"

if a.inspect_dialog_only:
    # Qt's offscreen platform does not discover Windows fonts automatically.
    # Explicitly load a system font into this test process only.
    from qgis.PyQt.QtGui import QFont, QFontDatabase
    font_id = QFontDatabase.addApplicationFont(str(Path(os.environ["WINDIR"]) / "Fonts/segoeui.ttf"))
    assert font_id >= 0, "Cannot load the offscreen test font"
    app.setFont(QFont(QFontDatabase.applicationFontFamilies(font_id)[0], 10))
    from processing.gui.AlgorithmDialog import AlgorithmDialog
    dialog = AlgorithmDialog(algorithm.create())
    dialog.setParameters({"INPUT": str(copied), "OUTPUT": str(output)})
    dialog.resize(1100, 750)
    dialog.show()
    app.processEvents()
    params = dialog.createProcessingParameters()
    assert Path(params["INPUT"]).resolve() == copied
    assert Path(params["OUTPUT"]).resolve() == output
    assert dialog.grab().save(str(root / "parameter-dialog.png"))
    record["dialog_parameters_roundtrip"] = True
    record["source_unchanged"] = digest(a.input) == source_hash
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
    dialog.close()
    print("Dialog parameter round-trip and offscreen rendering passed", flush=True)
    sys.exit(0)

def run_case(name, source, destination):
    feedback = Feedback()
    context = QgsProcessingContext()
    alg = algorithm.createInstance()
    params = {"INPUT": str(source), "OUTPUT": str(destination)}
    before = digest(destination) if Path(destination).is_file() else None
    result, ok, error = None, None, None
    try:
        result, ok = alg.run(params, context, feedback)
    except Exception as exc:
        error = str(exc)
    (root / (name + ".log")).write_text("\n".join(feedback.lines), encoding="utf-8")
    item = {"case": name, "ok": ok, "result": result, "exception": error,
            "reported_errors": feedback.errors, "output_exists": Path(destination).is_file(),
            "wrapper_isolation_reported": any(line.startswith("Using R's spatial resources;") for line in feedback.lines),
            "existing_output_unchanged": before is None or digest(destination) == before}
    record["cases"].append(item)
    print(json.dumps(item), flush=True)
    (root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")

run_case("valid-unicode", copied, output)
run_case("overwrite", copied, output)
run_case("missing-input", inputs / "absent.gpkg", root / "must-not-exist.html")
record["source_unchanged"] = digest(a.input) == source_hash
record["copy_unchanged"] = digest(copied) == source_hash
(root / "results.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
assert record["source_unchanged"] and record["copy_unchanged"]
# Keep failures as evidence, rather than equating an output path with success.
assert record["cases"][0]["output_exists"], "Provider did not produce the valid report"
assert record["cases"][0]["ok"] and not record["cases"][0]["reported_errors"]
if not a.isolate_r_spatial_env:
    assert record["cases"][0]["wrapper_isolation_reported"]
assert record["cases"][1]["ok"] is False and record["cases"][1]["existing_output_unchanged"]
assert record["cases"][2]["ok"] is False and not record["cases"][2]["output_exists"]
with (root / "direct-evidence.log").open("w", encoding="utf-8") as log:
    subprocess.run([str(a.r_home / "bin/Rscript.exe"), "--vanilla",
                    str(Path(__file__).with_name("qgis-direct-evidence.R")),
                    str(a.r_library.resolve()), str(copied), str(root)],
                   stdout=log, stderr=subprocess.STDOUT, check=True)
