# Plan
revised: __YYMMDD__

The stage is the unit of planning. Each stage has inputs, a method, outputs, a done-when, and a
decision criterion: what we decide from the result and what each outcome implies. When the plan
changes, the change and its reason go in a log entry; this file shows only the current plan.

## Per-batch stages (pipeline — applied identically to every batch)
### P1 — <name>
- inputs:
- method:
- outputs:
- done when:
- status: planned

## Cumulative stages (rerun when batches merge)
### A1 — <name>
- goal:
- inputs:
- method:
- outputs:
- decision criterion:
- status: planned · active · done · superseded (log YYMMDD_HHMM)
