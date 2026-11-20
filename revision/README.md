# Revision log

Tracks every change made in response to the pre-reviews (Szabó = NS, Szakálné Kanó = ISK),
so that each promise in the response letters can be traced to a merged change.

## Files

| File | One row per | Purpose |
|---|---|---|
| `units.csv` | promised change, per location | The full list of what must be done. Single source of truth. |
| `log/<unit>.csv` | unit (one file each) | What was changed, why, what else was checked, what remains open. One file per unit so open PRs never conflict. Columns as in `log/_template.csv`. |
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
| `partial` | Part merged; `open_ends` in the log says what remains |

Flags (`flags.csv`) use `open`, `in_pr`, `resolved`, and `archived` (closed by author decision, not fixed; the GitHub issue is closed as *not planned* with the `archived` label).

## Protocol (per issue)

1. **Plan**: posted on the issue before any edit: what (lines), how, why (reviewer comment + promise), knock-on effects.
2. **Go / adjust** from the author.
3. **PR** into `revision`: one branch per unit (`rev/<unit-id>`), the PR description repeats the plan,
   lists dependents checked and changed, and drafts the response-letter line. The PR adds `log/<unit>.csv`
   and any new problems to `flags.csv`.
4. **Author renders locally**, reviews the diff, merges or comments.

Conventions:

- Issues: PRs into `revision` do **not** auto-close issues. Label `in-pr` when the PR opens; close the issue manually (comment with the PR number) when it is merged; label `partial` if only part is done.

- Guiding questions: new or restructured sections open with one short, plain guiding question (reviewer suggestion).
- Tables: proposed as a plain Markdown table in the plan; implemented as an R `gt` table in the `.qmd`.
- Missing inputs (data, references, page numbers) are parked as blocked/flags, never guessed.
- Every unit also reports anything else found that is inconsistent, imprecise, or bad practice (in `flags.csv`).
- `master` is untouched until the revision is complete.
- `status` in `units.csv` is synced in a small commit after each batch of merges (not inside every PR), to avoid conflicts.

## Checking for loose ends (R)

```r
library(tidyverse)
units <- read_csv("revision/units.csv")
log   <- list.files("revision/log", pattern = "^[^_].*\\.csv$", full.names = TRUE) |>
  map(read_csv, col_types = cols(.default = "c")) |>
  list_rbind()
flags <- read_csv("revision/flags.csv")

units |> count(status)
log   |> filter(!is.na(open_ends))
flags |> filter(!status %in% c("resolved", "archived"))
units |> filter(status == "merged", !id %in% log$unit_id)   # merged but not logged
```
