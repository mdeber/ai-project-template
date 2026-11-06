# Session log
One file per session that did anything worth remembering. This is the only place where narrative,
history, and verbose reasoning belong. Everything in the living docs is derived from here.

File name: `YYMMDD_HHMM_<topic>.md` — e.g. `261103_1420_integrate_batch2.md`
Timestamps (file name and title line) come from `date +%y%m%d_%H%M`, never typed from memory.

```markdown
# 261103 14:20 — integrate batch 261029 with existing object
stage: A2 integration · data: thru_261029 · agent: Claude Code (<model>) · mode: interactive | unattended · human: Mike

## Did
## Observed
## Reasoning
Why this and not that. Expensive thinking is recorded here so it never has to be recomputed.
## DECISION: <one line>
Because … Alternatives rejected: … Consequence for plan: …
## DEAD END: <one line>
Tried …, saw …, abandoned because …
## Next
```

The index is the first two lines of every file:   `head -2 docs/log/*.md`
The decision record:   `grep -h '^## DECISION\|^## DEAD END' docs/log/*.md`
Entries are never edited after the session ends. Corrections are new entries.
