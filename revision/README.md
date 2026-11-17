# Revision log

Tracks every change made in response to the pre-reviews (Szabó = NS, Szakálné Kanó = ISK),
so that each promise in the response letters can be traced to a merged change.

## Files

| File | One row per | Purpose |
|---|---|---|
| `units.csv` | promised change, per location | The full list of what must be done. Single source of truth. |
| `log.csv` | merged PR (per unit) | What was changed, why, what else was checked, what remains open. |
| `flags.csv` | problem found while working | Contradictions, imprecisions, bad practice found along the way that no reviewer raised. |

## Unit status

| Status | Meaning |
|---|---|
| `ready` | Unblocked, can be planned now |
| `todo` | Waits on other units (`depends_on`) |
| `blocked` | Waits on an author decision, input, or the pipeline (`blocked_by`) |
| `deferred` | Consciously postponed |
| `planned` | Plan posted on the issue, awaiting go |
| `in_pr` | PR open |
| `merged` | Merged into `revision` **and** logged with empty `open_ends` |

## Protocol (per issue)

1. **Plan**: posted on the issue before any edit: what (lines), how, why (reviewer comment + promise), knock-on effects.
2. **Go / adjust** from the author.
3. **PR** into `revision`: one branch per unit (`rev/<unit-id>`), the PR description repeats the plan,
   lists dependents checked and changed, and drafts the response-letter line. The PR adds its row to `log.csv`
   and any new problems to `flags.csv`.
4. **Author renders locally**, reviews the diff, merges or comments.

Conventions:

- Tables: proposed as a plain Markdown table in the plan; implemented as an R `gt` table in the `.qmd`.
- Every unit also reports anything else found that is inconsistent, imprecise, or bad practice (in `flags.csv`).
- `master` is untouched until the revision is complete.

## Checking for loose ends (R)

```r
library(tidyverse)
units <- read_csv("revision/units.csv")
log   <- read_csv("revision/log.csv")
flags <- read_csv("revision/flags.csv")

units |> count(status)
log   |> filter(!is.na(open_ends))
flags |> filter(status != "resolved")
units |> filter(status == "merged", !id %in% log$unit_id)   # merged but not logged
```
