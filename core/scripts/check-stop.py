#!/usr/bin/env python3
"""
Reads EVAL.md stop criteria and LOOP-LOG.md history.
Outputs:  CONTINUE
    or:   STOP
          CONDITIONS:
          - reason1
          - reason2
"""
import sys, re, os
from datetime import date, datetime

EVAL_FILE = os.environ.get("EVAL_FILE", ".planning/EVAL.md")
LOG_FILE  = os.environ.get("LOG_FILE",  ".planning/LOOP-LOG.md")


def field(text, name):
    m = re.search(rf'\*\*{re.escape(name)}:\*\*\s*(.+)', text)
    return m.group(1).strip() if m else None


def to_float(s):
    if not s:
        return None
    m = re.search(r'-?[\d.]+', s)
    return float(m.group()) if m else None


def parse_log_rows(text):
    rows = []
    for line in text.splitlines():
        cols = [c.strip() for c in line.split("|")]
        if len(cols) < 9:
            continue
        try:
            n = int(cols[1])
        except ValueError:
            continue
        rows.append(dict(n=n, before=cols[3], after=cols[4],
                         delta=cols[5], date=cols[8]))
    return sorted(rows, key=lambda r: r["n"])


def main():
    for path in [EVAL_FILE, LOG_FILE]:
        if not os.path.exists(path):
            print(f"ERROR: {path} not found", file=sys.stderr)
            sys.exit(1)

    eval_text = open(EVAL_FILE).read()
    log_text  = open(LOG_FILE).read()

    direction      = (field(eval_text, "Direction") or "higher").strip().lower()
    time_box_days  = to_float(field(eval_text, "Time box"))
    target_thresh  = to_float(field(eval_text, "Target threshold"))
    delta_thresh   = to_float(field(eval_text, "Delta threshold"))
    stagnation_cnt = int(to_float(field(eval_text, "Stagnation count")) or 0)

    rows      = parse_log_rows(log_text)
    data_rows = [r for r in rows if r["n"] > 0]

    conditions = []

    # 1 — Time box
    if time_box_days is not None:
        baseline = next((r for r in rows if r["n"] == 0), None)
        if baseline and re.match(r'\d{4}-\d{2}-\d{2}', baseline["date"]):
            try:
                start   = datetime.strptime(baseline["date"], "%Y-%m-%d").date()
                elapsed = (date.today() - start).days
                if elapsed >= time_box_days:
                    conditions.append(
                        f"time_box: {elapsed}d elapsed of {int(time_box_days)}d limit")
            except Exception:
                pass

    # 2 — Target threshold
    if target_thresh is not None and data_rows:
        current = to_float(data_rows[-1]["after"])
        if current is not None:
            hit = (current >= target_thresh) if "higher" in direction \
                  else (current <= target_thresh)
            if hit:
                op = ">=" if "higher" in direction else "<="
                conditions.append(f"target: {current} {op} {target_thresh}")

    # 3 — Diminishing returns
    if delta_thresh is not None and stagnation_cnt > 0 and \
            len(data_rows) >= stagnation_cnt:
        recent = data_rows[-stagnation_cnt:]
        below  = [r for r in recent
                  if to_float(r["delta"]) is not None
                  and abs(to_float(r["delta"])) < delta_thresh]
        if len(below) >= stagnation_cnt:
            conditions.append(
                f"diminishing_returns: {stagnation_cnt} consecutive "
                f"iterations below {delta_thresh} threshold")

    if conditions:
        print("STOP")
        print("CONDITIONS:")
        for c in conditions:
            print(f"- {c}")
    else:
        print("CONTINUE")


if __name__ == "__main__":
    main()
