# Dutch Fuzzy Clock

Displays the time of the day in human readable form in the Dutch way. Heavily inspired by the original Fuzzy Clock. The App is in Dutch and English.

The Dutch way is pretty weird. Take these examples:
| Time | The Dutch way |
| --- | --- |
| 10:10 | Ten past ten |
| 10:20 | Ten till half eleven |
| 10:30 | Half eleven |
| 10:40 | Ten past half eleven |
| 10:50 | Ten to eleven |
| 11:00 | Eleven O'clock |

![Dutch Fuzzy Clock for Tidbyt](dutch_fuzzy_clock.webp)

## Timezone settings (September 2026)

Timezone is now a searchable IANA timezone setting. Leave it blank to follow the display timezone. Existing installations retain their previous effective timezone through the reviewed Cloud migration.

Downstream change, original authorship retained. Requires the Niblet runtime with timezone Text metadata. All changed schemas were evaluated with networking denied. Migration and rendering evidence is recorded in the timezone release audit; schema checks alone do not certify live provider behavior.
