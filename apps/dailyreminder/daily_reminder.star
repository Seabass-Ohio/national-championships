"""
Applet: Daily Reminder
Summary: A daily reminder app
Description: Set a reminder for each day of the week
Author: Sebastian Odell
"""

load("encoding/json.star", "json")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

FALLBACK_REMINDER = "Life is beautiful"
DEFAULT_LOCATION = """
{
	"lat": "40.6781784",
	"lng": "-73.9441579",
	"description": "Brooklyn, NY, USA",
	"locality": "Brooklyn",
	"place_id": "ChIJCSF8lBZEwokRhngABHRcdoI",
	"timezone": "America/New_York"
}
"""

def main(config):
    location = _timezone_location(config, config.get("location", DEFAULT_LOCATION))
    loc = json.decode(location)
    timezone = loc["timezone"]

    now = time.now().in_location(timezone)
    today_in_words = now.format("Monday").lower()

    default_reminder = config.get("default", FALLBACK_REMINDER)
    todays_reminder = config.get(today_in_words, default_reminder)

    reminder = todays_reminder or default_reminder or FALLBACK_REMINDER

    return render.Root(
        render.Column(
            children = [
                render.Box(
                    color = "#FFF",
                    height = 9,
                    child = render.Row(
                        children = [
                            render.Text(
                                "{}".format(today_in_words),
                                color = "#000",
                            ),
                        ],
                    ),
                ),
                render.Box(
                    child = render.Row(
                        children = [
                            render.Marquee(
                                width = 64,
                                child = render.Text(
                                    content = reminder,
                                ),
                            ),
                        ],
                    ),
                ),
            ],
        ),
    )

description = "Remind me to..."
calendar_icon = "calendar"

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
            schema.Text(
                id = "default",
                name = "Default Reminder",
                desc = "Show me when no reminder has been set",
                icon = calendar_icon,
            ),
            schema.Text(
                id = "monday",
                name = "Monday",
                desc = description,
                icon = calendar_icon,
            ),
            schema.Text(
                id = "tuesday",
                name = "Tuesday",
                desc = description,
                icon = calendar_icon,
            ),
            schema.Text(
                id = "wednesday",
                name = "Wednesday",
                desc = description,
                icon = calendar_icon,
            ),
            schema.Text(
                id = "thursday",
                name = "Thursday",
                desc = description,
                icon = calendar_icon,
            ),
            schema.Text(
                id = "friday",
                name = "Friday",
                desc = description,
                icon = calendar_icon,
            ),
            schema.Text(
                id = "saturday",
                name = "Saturday",
                desc = description,
                icon = calendar_icon,
            ),
            schema.Text(
                id = "sunday",
                name = "Sunday",
                desc = description,
                icon = calendar_icon,
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
