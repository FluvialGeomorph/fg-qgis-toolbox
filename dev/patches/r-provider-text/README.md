# Scalar text transport correction (development only)

Study Area editing introduces free-text inputs. Actual provider execution with
`4.1.0-fg-cancel1` returned success but changed the literal Windows path
`C:\terrain\new` in an analyst note into R escape characters. The backend stores
what it receives correctly; the provider's `_r_string()` only escaped double
quotes. Direct comparison against the requested text failed, even though an
HTML report existed. Evidence: ignored `study-edit-v1/provider-baseline/`.

`dev/scripts/stage-text-candidate.py` copies that candidate into a new directory
under `dev/check-output`, requires the reviewed template SHA-256 and candidate
version, and changes only `_r_string()` plus the identifying metadata. The
development version is **4.1.0-fg-text1**, retaining the cancellation correction.
JSON-style string quoting escapes backslashes, quotes and control characters;
Unicode is retained directly rather than emitting surrogate-pair escapes R cannot
parse. Embedded NUL is not a supported R string. No scientific algorithm changes.

The staging manifest records all source/candidate hashes and the exact two changed
files. The original candidate, installed plugin, analyst profile and R libraries
are untouched. The initial `study-edit-v1/plugin/` attempt failed its Windows path
comparison assertion; `plugin-final/` is the completed, inventoried candidate.

Qualification combines `check-provider-text.py` (the actual extracted scalar
method through R, including literal paths/escapes, Unicode, quotes, multiline and
code-looking text) and `qualify-qgis-provider.py --revise-context` (real QGIS,
new-file preservation, exact context comparison and direct-R reporting).
This does not qualify every provider string-list/expression serializer, other
platforms, or an official plugin release. The cancellation implementation is
byte-identical to its separately qualified candidate; that analyst task is not
reopened. Upstream contribution and maintained-provider adoption remain separate;
this development correction has not been published or deployed.
