# Controlled OSGeo4W PROJ data repair

Completed 2026-09-09 under the user's authorization to proceed with the proposed
controlled repair and durable R/QGIS interoperability. This is a workstation
maintenance record, not an automatic package-installation feature of fgqgis.

## Cause and repair scope

Verified package lists assign `share/proj/proj.db` to both modern
`proj-runtime-data` and legacy `proj72-runtime`, `proj80-runtime`,
`proj81-runtime`, `proj82-runtime`. The installation log records modern 9.8.1
data extraction on 2026-09-06 at 08:50:15, followed by the legacy packages,
ending with 8.2.1 at 08:50:17; each rewrote the shared database. The final file
identified itself as PROJ 8.2.1. This establishes a package-file collision during
that installation, not a GeoPackage format failure or a fluvgeo CRS conversion.

The cached `proj-runtime-data-9.8.1-1.tar.bz2` matches the version already in
`etc/setup/installed.db` and its cached official catalog entry:

- Size: 1,574,571 bytes.
- Catalog MD5: `3a2ada9321bb62b1310f4d523bf7a08b`.
- Archive SHA-256: `599b2307ed72001ab1b28b9cf4ac007523687571ee0cc1ec54c511a893f74f1d`.

The installer help was inspected; it did not document a dedicated unattended
reinstall switch. The performed repair was therefore **explicit restoration
of six differing package-owned files from that verified exact-version archive**,
not an installer transaction, upgrade, uninstall/reinstall cycle or a database
borrowed from another application. This refinement keeps the target bounded.

Restored under `C:/Users/R1Suser/AppData/Local/Programs/OSGeo4W/share/proj/`:
`CH`, `ITRF2008`, `ITRF2014`, `proj.db`, `proj.ini`, `projjson.schema.json`.
Matching files were left unchanged. Package inventory hashes are unchanged;
no DLLs, other packages, normal profiles, R libraries or production tools were
updated by this repair. The existing isolated fgqgis test library was reused.

Database transition: PROJ 8.2.1/layout 1.2/EPSG v10.041 (2021-12-03) to
PROJ 9.8.1/layout 1.6/EPSG v12.029 (2025-10-02).
The repaired database SHA-256 is
`37165492257d87ad504c0f7097b96f3bd504d1238bed292ecb73273ab5ae4ebf`.

## Evidence and repeatability

`dev/scripts/audit-proj-package.py` verifies the archive against the cached
catalog and installed version, checks member paths/types, stages its payload,
backs up current package files and records hashes, ownership and SQLite metadata.
It never modifies the installation. Its positional inputs are the installation,
cached runtime-data archive and a **new** evidence directory.

`dev/scripts/restore-proj-package.ps1` performs read-only preflight by default.
Its `-Apply` mode is intentionally restricted to the six reviewed paths above;
it checks no QGIS process is open, validates installation identity, prior hashes,
staged payloads and backups before copying, then checks copied hashes and the
unchanged package inventory. Re-running requires a new review, not blind reuse.
An elevated filesystem permission was approved for the actual copy operation.

Local evidence is ignored under `dev/check-output/osgeo-repair-v1/`:

- `audit/`: original backups, staged exact-version files, catalog/inventory
  snapshots, `audit.json` and `restore-result.json`.
- `post-audit/`: independent reinspection finds **zero package-file differences**.
- `provider-run/`: actual provider success/failure tests and direct-R comparison.
- `dialog-run-3/`: real Qt dialog parameter tests, CRS smoke test, rendered preview.
- `stale-fixture/`: disposable copy of the old database used to prove rejection.

Retain `audit/before/` until broader legacy-application checks are satisfactory.
These backups are local and **not in Git**. Recovery, if deliberately requested,
would restore those six original files after checking that current files still
match this repair. That would reinstate the known modern-QGIS failure; it is not
an automatic rollback. No backup or source artifact was deleted.

## Verification and remaining work

QGIS 3.44.14 now initializes without the previous PROJ warning. The provider
again generates its report with the packaged R guard, and R captures no spatial
warnings. All nine report tables match direct R except the fresh validation
timestamp; overwrite/missing-input failures and source hashes remain correct.
The upstream provider still adds a secondary traceback to backend failures.

The 51 fast package assertions pass without test failures or test warnings.
Strict agentic-context validation passes with two existing modified-seed notices;
the validator was loaded from the sibling reproducibleai source repository.

The harness now rejects a database/package version mismatch before initializing
QGIS. Both the repaired installation and a negative test using the original
database were exercised. EPSG:4326 and EPSG:26914 resolve; a test point round-trip
has error about 1.42e-14 degrees (an execution smoke check, not survey accuracy).

The real Qt Processing dialog was instantiated offscreen, its INPUT/OUTPUT
values round-tripped and its rendered help/controls visually inspected. Offscreen
rendering required loading Segoe UI into that test process only. This is **not**
an analyst's interactive desktop test or a production-profile deployment.

Next: an analyst-run trial in an explicitly isolated QGIS 3.44 profile, including
file selection, report opening and cancellation. All legacy programs using the
shared PROJ data have not been regression-tested. Do not remove legacy packages
without investigating their consumers. Run the preflight after OSGeo4W updates,
because reinstalling a conflicting legacy package can recur. The preflight
checks version consistency and a CRS smoke test, not every transformation grid
or custom datum configuration.
