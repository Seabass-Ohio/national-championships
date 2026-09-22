"""
Applet: Company Clock
Summary: Clock from Lethal Company
Description: Displays a rendition of the clock from the game "Lethal Company".
Author: qqvq-d
"""

load("encoding/json.star", "json")
load("images/half_sun.png", HALF_SUN_ASSET = "file")
load("images/moon.png", MOON_ASSET = "file")
load("images/skull.png", SKULL_ASSET = "file")
load("images/sun.png", SUN_ASSET = "file")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

HALF_SUN = HALF_SUN_ASSET.readall()
MOON = MOON_ASSET.readall()
SKULL = SKULL_ASSET.readall()
SUN = SUN_ASSET.readall()

orange = "#d6440b"
font = "5x8"

# Image Data

# To manually set the time
debug = False

def main(config):
    timezone = json.decode(_timezone_location(config, config.get("timezone")))["timezone"] if _timezone_location(config, config.get("timezone")) != None else "America/New_York"
    now = time.now().in_location(timezone)

    if debug == True:
        now = time.parse_time("2021-03-22T22:00:50.52Z")

    tp_adj = 0

    if now.hour >= 6 and now.hour < 12:
        img_src = SUN
    elif now.hour >= 12 and now.hour < 18:
        img_src = HALF_SUN
        tp_adj = 5
    elif now.hour >= 18 and now.hour < 22:
        img_src = MOON
    else:
        img_src = SKULL

    return render.Root(
        delay = 500,
        child = render.Stack(
            children = [
                # Border
                render.Plot(
                    data = [(0, 0), (0, 32), (64, 32), (64, 0), (0, 0)],
                    color = orange,
                    width = 64,
                    height = 32,
                ),
                # Time
                render.Padding(
                    pad = (4, 8, 0, 0),
                    child = render.Animation(
                        children = [
                            render.Text(
                                content = now.format("3:04"),
                                color = orange,
                                font = font,
                            ),
                            render.Text(
                                content = now.format("3 04"),
                                color = orange,
                                font = font,
                            ),
                        ],
                    ),
                ),
                render.Padding(
                    pad = (4, 16, 0, 0),
                    child = render.Text(
                        content = now.format("PM"),
                        color = orange,
                        font = font,
                    ),
                ),
                # Image
                render.Padding(
                    pad = (33, tp_adj, 0, 0),
                    child = render.Image(
                        src = img_src,
                    ),
                ),
            ],
        ),
    )

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "timezone",
                name = "Timezone",
                desc = "Leave blank to use the display timezone.",
                icon = "clock",
                default = "",
                format = "timezone",
                time_context = True,
            ),
        ],
    )

# Downstream modification: standardized timezone input, with legacy-config compatibility.
def _timezone_location(config, legacy):
    zone = config.get("timezone")
    if zone == None or (type(zone) == "string" and zone.startswith("{")):
        return legacy
    zone = zone.strip() or config.get("$tz", time.tz()) or "UTC"
    if not time.is_valid_timezone(zone):
        fail("Choose a valid IANA timezone")
    location = {"timezone": zone}
    return json.encode(location)
