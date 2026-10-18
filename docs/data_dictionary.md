# Haze data dictionary

Three tables, built by M1 from NEA's 24-hour PSI readings. They cover every hour from 1 Apr 2014 01:00 to the data end, with no missing hours.

## How to load

```r
source("R/00_load.R")
h <- load_hourly(); d <- load_daily(); s <- load_season()
str(d)   # dates are Date, trigger columns are TRUE/FALSE/NA
```

Always load through these functions rather than `read.csv`, so dates and true/false columns come back with the right types.

## Rules everyone shares

- **Time zone.** Every time is Singapore time (SGT, `Asia/Singapore`). A reading's date is its calendar date in SGT; the 00:00 reading belongs to the day it is stamped with. Never call `as.Date()` on a time without `tz = "Asia/Singapore"`: R defaults to UTC and moves 00:00–07:59 readings to the previous day.
- **PSI.** NEA's 24-hour Pollutant Standards Index, reported every hour for five regions. NEA's Unhealthy band starts at 101.
- **Trigger.** The refund triggers on a day when the Central region's 24-hour PSI at 08:00 is above 100. If there is no 08:00 reading, the trigger is NA ("unknown"), never FALSE.
- **Season.** September and October (`in_season`). About 90% of haze days since 2014 fall in these two months.
- **Persistence pairs.** For p(haze | hazy yesterday) and p(haze | clear yesterday), use days that are `in_season`, are not 1 September, and have non-NA `trigger` and `trigger_prev`. M1's chart 3 and M2's analysis both use this rule, so their numbers match exactly.
- **El Niño.** A year is an El Niño year when NOAA's June–August Oceanic Niño Index (`oni_jja`) is at least 0.5. As of Oct 2026 these are 2015, 2023 and 2026.
- **Bad day.** A day when any region's 24-hour PSI goes above 100 at any hour (`natmax > 100`). HazeShield counts these.

## `data/psi_hourly.csv` (one row per hour)

| Column | Type | Unit | Meaning |
| --- | --- | --- | --- |
| `time` | time (SGT) | hour | Reading time, written as `YYYY-MM-DD HH:MM` |
| `north` | integer | PSI | 24-hour PSI, North region |
| `south` | integer | PSI | 24-hour PSI, South region |
| `east` | integer | PSI | 24-hour PSI, East region |
| `west` | integer | PSI | 24-hour PSI, West region |
| `central` | integer | PSI | 24-hour PSI, Central region (the trigger region) |
| `natmax` | integer | PSI | Highest of the five regions that hour |
| `source` | text | | `hist` (data.gov.sg history file), `live` (real-time API) or `fill` (interpolated) |
| `flag` | text | | Empty, `relabelled` (timestamp repaired, see below) or `interpolated` (gap filled) |

## `data/psi_daily.csv` (one row per day)

| Column | Type | Unit | Meaning |
| --- | --- | --- | --- |
| `date` | Date | day | SGT calendar date |
| `year` | integer | | Calendar year |
| `month` | integer | 1–12 | Calendar month |
| `n_hours` | integer | readings | Hourly readings that day: 24 for every full day; 23 on 1 Apr 2014, which starts at 01:00; fewer on today's partial day |
| `central8` | integer | PSI | Central 24-hour PSI at 08:00; NA if there is no 08:00 reading |
| `natmax` | integer | PSI | Highest region-hour reading that day |
| `trigger` | TRUE/FALSE/NA | | `central8 > 100`: would the refund pay out that day? |
| `trigger_prev` | TRUE/FALSE/NA | | `trigger` on the previous calendar day; NA if unknown |
| `in_season` | TRUE/FALSE | | Month is September or October |
| `oni_jja` | number | °C anomaly | NOAA June–August Oceanic Niño Index for that year |
| `el_nino` | TRUE/FALSE | | `oni_jja >= 0.5` |

## `data/psi_season.csv` (one row per year, September–October only)

| Column | Type | Unit | Meaning |
| --- | --- | --- | --- |
| `year` | integer | | Season year (2014–2026) |
| `oni_jja` | number | °C anomaly | That year's June–August ONI |
| `el_nino` | TRUE/FALSE | | `oni_jja >= 0.5` |
| `days` | integer | days | Sep–Oct days with a known trigger (61 for a complete season) |
| `trigger_days` | integer | days | Days the refund would have paid out |
| `trigger_rate` | number | 0–1 | `trigger_days / days` |
| `bad_days` | integer | days | Days with any region above 100 (HazeShield's count) |
| `peak_natmax` | integer | PSI | Highest reading of the season |
| `peak_date` | Date | day | Date of that peak |

## Known fixes to the source data

The data.gov.sg history file has exactly one row per hour, in order, but four rows carry a wrong timestamp label. Their true time comes from their position in the file, and they are flagged `relabelled`:

| Data row | Label in the file | True time | Central PSI |
| --- | --- | --- | --- |
| 16,956 | `7/3/2016 0:00` | 2016-03-07 12:00 | 42 |
| 17,616 | `2016-04-04 010:00:00` | 2016-04-04 00:00 | 53 |
| 35,640 | `24/4/2018 0:00` | 2018-04-25 00:00 | 64 |
| 38,355 | `16/8/2018 2:00` | 2018-08-16 03:00 | 61 |

The file's line number is one higher, because line 1 is the header.

The history file and the live API share one hour (2026-09-01 00:00); the values match exactly. Where both sources have an hour, the history file is used.

## Gap rule

Missing runs of 3 hours or fewer are filled by straight-line interpolation and flagged `interpolated`. A longer run stops the build with an error naming the gap, rather than inventing data. `outputs/00_data_quality.csv` reports the counts; as of 18 Oct 2026 there are 0 missing and 0 interpolated hours.

## Freeze (`DATA_END`)

`DATA_END` in `R/00_fns_data.R` is NA until the freeze, so the data runs up to today. On Sun 1 Nov M1 sets it to `2026-10-31`. From then on every rebuild stops at 31 Oct 23:00 and gives identical numbers.

## Audit

M1 checks this data independently with `python3 tools/audit_data.py --api 40`. It rebuilds every table from `data/raw/` without the R code, compares every cell, and spot-checks NEA's live API. On 18 Oct 2026 it found 0 mismatches. NEA's live feed and its history file are two releases that differ slightly on about 2.5% of hours (by 1 to 7 PSI in the sample, none near PSI 100). See [`docs/data_audit.md`](data_audit.md) for the full results and what they mean for 2026.

## Sources

- NEA, Historical 24-hr PSI, data.gov.sg: https://data.gov.sg/datasets/d_b4cf557f8750260d229c49fd768e11ed/view
- NEA, real-time PSI API, data.gov.sg: https://api-open.data.gov.sg/v2/real-time/api/psi
- NOAA Climate Prediction Center, Oceanic Niño Index: https://www.cpc.ncep.noaa.gov/data/indices/oni.ascii.txt
