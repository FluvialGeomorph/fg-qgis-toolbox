"""Read-only OSGeo4W package audit, with test-owned staging and backups.

Arguments: OSGeo4W root, cached proj-runtime-data archive, NEW evidence directory.
Never changes the installation. The archive must match its cached setup.ini.
"""
import gzip
import hashlib
import json
from pathlib import Path
import re
import shutil
import sqlite3
import sys
import tarfile

installation, archive, out = [Path(x).resolve() for x in sys.argv[1:]]
catalog = archive.parents[3] / "setup.ini"
block = re.search(r"^@ proj-runtime-data\n(.*?)(?=\n@ |\Z)",
                  catalog.read_text(encoding="utf-8"), re.M | re.S).group(1)
entry = re.search(r"^install: (\S+) (\d+) ([a-f0-9]+)$", block, re.M)
assert Path(entry[1]).name == archive.name
payload = archive.read_bytes()
assert len(payload) == int(entry[2])
assert hashlib.md5(payload).hexdigest() == entry[3]
installed_db = installation / "etc/setup/installed.db"
assert f"proj-runtime-data {archive.name} 0" in installed_db.read_text()
out.mkdir(parents=True, exist_ok=False)
shutil.copy2(installed_db, out / "installed.db.before")
shutil.copy2(catalog, out / "setup.ini.evidence")
owners = {}
for listing in (installation / "etc/setup").glob("*.lst.gz"):
    for name in gzip.open(listing, "rt").read().splitlines():
        owners.setdefault(name, []).append(listing.name.removesuffix(".lst.gz"))

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest() if path.is_file() else None

record = {"installation": str(installation), "archive": str(archive),
          "archive_md5": entry[3], "archive_sha256": hashlib.sha256(payload).hexdigest(),
          "installed_db_sha256": sha(installed_db), "files": []}
with tarfile.open(archive) as package:
    for member in package.getmembers():
        if member.isdir():
            continue
        assert member.isfile(), "Refuse links or special archive members"
        relative = Path(member.name)
        assert not relative.is_absolute() and ".." not in relative.parts
        assert member.name.startswith("share/proj/") or member.name == "etc/ini/proj-runtime-data.bat"
        target = (installation / relative).resolve()
        assert target.is_relative_to(installation)
        staged = out / "package" / relative
        staged.parent.mkdir(parents=True, exist_ok=True)
        staged.write_bytes(package.extractfile(member).read())
        backup = out / "before" / relative
        if target.is_file():
            backup.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(target, backup)
        record["files"].append({"path": relative.as_posix(), "before_sha256": sha(target),
                                "package_sha256": sha(staged), "owners": owners.get(member.name, [])})
for label, path in (("before", installation / "share/proj/proj.db"),
                    ("package", out / "package/share/proj/proj.db")):
    with sqlite3.connect(path.as_uri() + "?mode=ro", uri=True) as connection:
        record[label + "_metadata"] = dict(connection.execute("select * from metadata"))
record["different_files"] = [x["path"] for x in record["files"]
                              if x["before_sha256"] != x["package_sha256"]]
(out / "audit.json").write_text(json.dumps(record, indent=2), encoding="utf-8")
print(json.dumps({k: record[k] for k in ("before_metadata", "package_metadata", "different_files")}, indent=2))
