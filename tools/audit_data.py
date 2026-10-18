"""Independent audit of M1's data (M1 only; standard library only).

Rebuilds the hourly, daily and season tables from data/raw/ without running or
importing any of the R code, and compares them cell by cell with data/*.csv.

    python3 tools/audit_data.py              # checks 1-8, offline
    python3 tools/audit_data.py --api 40     # plus a spot-check of 40 random days against NEA's API
    python3 tools/audit_data.py --data DIR   # audit another copy of data/

Ends with AUDIT PASS (exit 0) or AUDIT FAIL: <n> problems (exit 1).
"""
import argparse, csv, glob, json, os, random, re, sys, time, urllib.error, urllib.request
from datetime import date, datetime, timedelta

REG = ["north", "south", "east", "west", "central"]
RELABELLED_ROWS = [16956, 17616, 35640, 38355]   # data rows (file line minus the header)
API = "https://api-open.data.gov.sg/v2/real-time/api/psi?date="
HOUR = timedelta(hours=1)
problems = []


def report(name, bad, ok_detail=""):
    """Print one line per check; list up to 5 problems under it."""
    problems.extend(bad)
    print(f"{name}: " + (f"OK {ok_detail}".rstrip() if not bad else f"{len(bad)} problems"))
    for b in bad[:5]:
        print("   ", b)


def parse_label(s):
    for f in ("%d/%m/%Y %H:%M", "%Y-%m-%d %H:%M:%S"):
        try:
            return datetime.strptime(s.strip(), f)
        except ValueError:
            pass
    return None


def data_end(repo):
    """DATA_END as set in R/00_fns_data.R (read as text, never run); None while it is NA."""
    m = re.search(r'^DATA_END <- as\.Date\("(\d{4}-\d{2}-\d{2})"\)', open(os.path.join(repo, "R/00_fns_data.R")).read(), re.M)
    return datetime.strptime(m.group(1), "%Y-%m-%d") + timedelta(hours=23) if m else None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data", default="data")
    ap.add_argument("--api", type=int, default=0)
    a = ap.parse_args()
    repo = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    raw = os.path.join(a.data, "raw")

    # 1. history file: one row per hour, true time = first label + i hours
    rows = list(csv.reader(open(os.path.join(raw, "psi_hist.csv"))))
    bad = [] if rows[0] == ["24hr_psi"] + REG else [f"unexpected header {rows[0]}"]
    rows = rows[1:]
    t0 = parse_label(rows[0][0])
    hist, off = {}, []
    for i, r in enumerate(rows):
        t = t0 + i * HOUR
        if parse_label(r[0]) != t:
            off.append(i + 1)
        try:
            hist[t] = [int(v) for v in r[1:6]]
        except ValueError:
            bad.append(f"data row {i + 1}: non-numeric reading {r[1:6]}")
    if off != RELABELLED_ROWS:
        bad.append(f"labels disagree with position at data rows {off[:10]}, expected exactly {RELABELLED_ROWS}")
    report("1 history labels", bad, f"({len(rows):,} rows, {t0} to {t0 + (len(rows) - 1) * HOUR}, {len(off)} relabelled)")

    # 2. live files: date field = file name; no hour twice with different values
    live, bad, files = {}, [], sorted(glob.glob(os.path.join(raw, "live", "*.json")))
    for f in files:
        day = os.path.basename(f)[:10]
        for it in json.load(open(f))["data"]["items"]:
            if it["date"] != day:
                bad.append(f"{day}.json holds an item dated {it['date']}")
            t = datetime.fromisoformat(it["timestamp"]).replace(tzinfo=None)
            v = [it["readings"]["psi_twenty_four_hourly"].get(k) for k in REG]
            if t in live and live[t] != v:
                bad.append(f"{t} differs between live files")
            live[t] = v
    report("2 live files", bad, f"({len(files)} files, {len(live):,} hours)")

    # 3. overlap: history and live agree on every shared hour
    shared = sorted(set(hist) & set(live))
    report("3 history/live overlap", [f"{t}: history {hist[t]}, live {live[t]}" for t in shared if hist[t] != live[t]],
           f"({len(shared)} shared hours)")

    # 4. merged hours strictly hourly; gaps of 3 hours or less are interpolated (the documented gap rule)
    merged = dict(live)
    merged.update(hist)                                   # history wins on overlap
    end = data_end(repo)
    if end:
        merged = {t: v for t, v in merged.items() if t <= end}
    source = {t: ("hist" if t in hist else "live") for t in merged}
    ts, bad, filled = sorted(merged), [], {}
    for p, n in zip(ts, ts[1:]):
        k = int((n - p) / HOUR) - 1
        if k > 3:
            bad.append(f"gap of {k} hours after {p}")
        for j in range(1, k + 1) if 0 < k <= 3 else ():
            t = p + j * HOUR
            filled[t] = [round(merged[p][r] + (merged[n][r] - merged[p][r]) * j / (k + 1)) for r in range(5)]
    for t, v in filled.items():
        merged[t], source[t] = v, "fill"
    ts = sorted(merged)
    report("4 hourly order", bad, f"({len(ts):,} hours to {ts[-1]}, {len(filled)} interpolated)")

    # 5. psi_hourly.csv, cell for cell
    relab = {t0 + (r - 1) * HOUR for r in RELABELLED_ROWS}
    H = list(csv.DictReader(open(os.path.join(a.data, "psi_hourly.csv"))))
    bad = [] if len(H) == len(ts) else [f"{len(H)} rows in file, {len(ts)} rebuilt"]
    for r in H:
        t = datetime.strptime(r["time"], "%Y-%m-%d %H:%M")
        if t not in merged:
            bad.append(f"psi_hourly {r['time']}: not in the raw data"); continue
        exp = dict(zip(REG, map(str, merged[t])), natmax=str(max(merged[t])), source=source[t],
                   flag="relabelled" if t in relab else "interpolated" if t in filled else "")
        bad += [f"psi_hourly {r['time']} {k}: file {r[k]}, rebuilt {v}" for k, v in exp.items() if r[k] != v]
    report("5 psi_hourly.csv", bad, f"({len(H):,} rows, every cell)")

    # 6. psi_daily.csv: all 11 columns
    oni = {}
    for line in open(os.path.join(raw, "oni.txt")):
        p = line.split()
        if len(p) == 4 and p[0] == "JJA":
            oni[int(p[1])] = float(p[3])
    days = {}
    for t in ts:
        days.setdefault(t.date(), []).append(t)
    trig, nat = {}, {}
    for d in sorted(days):
        c8 = merged.get(datetime(d.year, d.month, d.day, 8))
        trig[d] = None if c8 is None else c8[4] > 100
        nat[d] = max(max(merged[t]) for t in days[d])
    tf = lambda x: "NA" if x is None else str(x).upper()
    D = list(csv.DictReader(open(os.path.join(a.data, "psi_daily.csv"))))
    bad = [] if len(D) == len(days) else [f"{len(D)} rows in file, {len(days)} rebuilt"]
    for r in D:
        d = date.fromisoformat(r["date"])
        if d not in days:
            bad.append(f"psi_daily {d}: not in the raw data"); continue
        c8 = merged.get(datetime(d.year, d.month, d.day, 8))
        exp = dict(year=str(d.year), month=str(d.month), n_hours=str(len(days[d])), central8="NA" if c8 is None else str(c8[4]),
                   natmax=str(nat[d]), trigger=tf(trig[d]), trigger_prev=tf(trig.get(d - timedelta(days=1))),
                   in_season=tf(d.month in (9, 10)), el_nino=tf(oni[d.year] >= 0.5))
        bad += [f"psi_daily {d} {k}: file {r[k]}, rebuilt {v}" for k, v in exp.items() if r[k] != v]
        if abs(float(r["oni_jja"]) - oni[d.year]) > 1e-9:
            bad.append(f"psi_daily {d} oni_jja: file {r['oni_jja']}, rebuilt {oni[d.year]}")
    report("6 psi_daily.csv", bad, f"({len(D):,} days, all 11 columns)")

    # 7. psi_season.csv: all 9 columns
    S = list(csv.DictReader(open(os.path.join(a.data, "psi_season.csv"))))
    years = sorted({d.year for d in days if d.month in (9, 10)})
    bad = [] if [int(r["year"]) for r in S] == years else [f"seasons {[r['year'] for r in S]}, rebuilt {years}"]
    for r in S:
        y = int(r["year"]); sd = [d for d in sorted(days) if d.year == y and d.month in (9, 10)]
        known = [d for d in sd if trig[d] is not None]; td = sum(trig[d] for d in known); pk = max(nat[d] for d in sd)
        exp = dict(oni_jja=None, el_nino=tf(oni[y] >= 0.5), days=str(len(known)), trigger_days=str(td), trigger_rate=None,
                   bad_days=str(sum(nat[d] > 100 for d in sd)), peak_natmax=str(pk), peak_date=str(next(d for d in sd if nat[d] == pk)))
        bad += [f"psi_season {y} {k}: file {r[k]}, rebuilt {v}" for k, v in exp.items() if v is not None and r[k] != v]
        for k, v in (("oni_jja", oni[y]), ("trigger_rate", td / len(known))):
            if abs(float(r[k]) - v) > 1e-9:
                bad.append(f"psi_season {y} {k}: file {r[k]}, rebuilt {v}")
    report("7 psi_season.csv", bad, f"({len(S)} seasons, all 9 columns)")

    # 8. each repaired hour sits within 5 PSI of both neighbours in every region
    bad = []
    for t in sorted(relab):
        for nb in (t - HOUR, t + HOUR):
            if nb in merged and max(abs(x - y) for x, y in zip(merged[t], merged[nb])) > 5:
                bad.append(f"relabelled {t} jumps more than 5 PSI from {nb}")
    report("8 repaired hours", bad, f"({len(relab)} hours fit their neighbours)")

    # 9. NEA API spot-check of random past days against the history file
    if a.api:
        random.seed(1202)
        span = (date(2026, 8, 31) - date(2016, 1, 1)).days
        sample = sorted(date(2016, 1, 1) + timedelta(days=k) for k in random.sample(range(span + 1), a.api))
        # NEA's live feed and its history file are two releases of the same readings: they differ slightly
        # on about 2.5% of hours (1-7 PSI on 18 Oct 2026). Only a difference that could change a result fails.
        bad, got_days, hours, small, unreachable = [], 0, 0, [], 0
        for d in sample:
            items = []
            for attempt in (1, 2):                # a rate limit or timeout is retried once, then counts as no data
                try:
                    req = urllib.request.Request(API + d.isoformat(), headers={"User-Agent": "Mozilla/5.0"})
                    items = json.load(urllib.request.urlopen(req, timeout=30))["data"]["items"]
                    break
                except urllib.error.HTTPError as e:
                    if e.code == 404:
                        break
                except Exception:
                    pass
                if attempt == 2:
                    unreachable += 1
                time.sleep(10)
            n = 0
            for it in items:
                t = datetime.fromisoformat(it["timestamp"]).replace(tzinfo=None)
                v = [it["readings"]["psi_twenty_four_hourly"].get(k) for k in REG]
                if t in hist:
                    n += 1
                    if None in v or hist[t] == v:
                        continue
                    gap = max(abs(x - y) for x, y in zip(hist[t], v))
                    flips = (max(hist[t]) > 100) != (max(v) > 100) or (t.hour == 8 and (hist[t][4] > 100) != (v[4] > 100))
                    if gap > 10 or flips:
                        bad.append(f"API {t}: API {v}, history {hist[t]} ({gap} PSI apart{', crosses PSI 100' if flips else ''})")
                    else:
                        small.append(gap)
            got_days += n > 0; hours += n
            time.sleep(1.5)
        if got_days < a.api / 2:
            bad.append(f"only {got_days} of {a.api} sampled days returned data (need at least half)")
        if hours and len(small) > 0.05 * hours:
            bad.append(f"{len(small)} of {hours} hours differ slightly: more than 5%")
        note = f"; {len(small)} differ by 1-{max(small)} PSI, none crossing PSI 100" if small else "; all identical"
        note += f"; {unreachable} days unreachable" if unreachable else ""
        report("9 NEA API spot-check", bad, f"({got_days} of {a.api} days returned data, {hours:,} hours compared{note})")

    if problems:
        print(f"AUDIT FAIL: {len(problems)} problems")
        sys.exit(1)
    print("AUDIT PASS")


if __name__ == "__main__":
    main()
