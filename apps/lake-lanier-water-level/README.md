# Lake Lanier Level

Live water-level display for **Lake Sidney Lanier (GA)** on a 64×32 LED matrix.

- **LANIER** label and water temperature along the top
- **Hero number**: feet from full pool (1,071 ft) — green when rising, red when falling
- **Animated wave** colored by alert zone (blue / green / yellow / amber / red)
- **Scrolling ticker** with level, temp, and last-update time
- **Zone color bar** along the bottom

In app settings you can turn **Animate waves** off for a still surface, and turn **Scrolling ticker** off to show only the last-update time (the rest of the ticker repeats the header and hero). Both default on.

Data comes from the [Lanier Level Watch](https://lanierlevel.com) public API (USGS gauge, refreshed hourly).

## Timezone settings (September 2026)

Timezone is now a searchable IANA timezone setting. Leave it blank to follow the display timezone. Existing installations retain their previous effective timezone through the reviewed Cloud migration.

Downstream change, original authorship retained. Requires the Niblet runtime with timezone Text metadata. All changed schemas were evaluated with networking denied. Migration and rendering evidence is recorded in the timezone release audit; schema checks alone do not certify live provider behavior.
