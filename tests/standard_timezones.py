"""Offline schema and runtime input-contract checks for the reviewed Location migrations."""
from pathlib import Path
import json
import os
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
runtime = str(Path(sys.argv[1]).resolve())
apps = json.loads((root / "tests/timezone-migrations.json").read_text())
for app in apps:
    path = root / app["source_path"]
    schema = json.loads(subprocess.check_output([runtime, "schema", str(path)]))
    fields = {field["id"]: field for field in schema["schema"]}
    if app["kind"] == "unused-location":
        assert app["location_field"] not in fields and "timezone" not in fields
        continue
    assert fields["timezone"]["format"] == "timezone" and fields["timezone"]["time_context"]
    assert not any(field["type"] == "location" for field in fields.values())
    source = path.read_text().replace("def main(config):", "def original_main(config):", 1)
    source += '''
def main(config):
    legacy = json.encode({"timezone": "America/New_York", "lat": "40", "lng": "-74"})
    if _timezone_location({}, legacy) != legacy:
        fail("legacy configuration changed")
    for zone in ["America/New_York", "Europe/London", "Asia/Kolkata", "Australia/Sydney"]:
        result = json.decode(_timezone_location({"timezone": zone, "$tz": "UTC"}, legacy))
        if result["timezone"] != zone or "lng" in result:
            fail("explicit timezone lost or coordinates retained")
    inherited = json.decode(_timezone_location({"timezone": "", "$tz": "Europe/London"}, legacy))
    if inherited["timezone"] != "Europe/London":
        fail("display timezone ignored")
    actual = json.decode(_timezone_location(config, legacy))
    if actual["timezone"] != "Asia/Kolkata":
        fail("runtime configuration differs from dictionary configuration")
    return render.Root(child = render.Text(content = "Timezone OK", font = "5x8"))
'''
    if app["kind"] == "timezone-and-hemisphere":
        source = source.replace('    actual = json.decode', '    for hemisphere, sign in [("northern", "1"), ("southern", "-1")]:\n        if json.decode(_timezone_location({"timezone": "UTC", "hemisphere": hemisphere}, legacy))["lat"] != sign:\n            fail("hemisphere changed")\n    actual = json.decode')
    if app["kind"] == "timezone-and-label":
        source = source.replace('    actual = json.decode', '    if json.decode(_timezone_location({"timezone": "UTC", "timezone_label": "Sydney"}, legacy))["locality"] != "Sydney":\n        fail("label changed")\n    actual = json.decode')
    temporary = path.parent / ".timezone-contract-test.star"
    try:
        temporary.write_text(source)
        with tempfile.TemporaryDirectory() as output:
            result = subprocess.run([runtime, "render", str(temporary), "timezone=Asia/Kolkata", "--output", output + "/test.webp", "--silent"], env={**os.environ, "TZ": "UTC"}, capture_output=True, text=True)
            assert result.returncode == 0, (app["app_id"], result.stderr)
    finally:
        temporary.unlink(missing_ok=True)
    print(app["app_id"] + ": schema and runtime timezone contract passed")
