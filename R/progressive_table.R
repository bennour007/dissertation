# Progressive summary table (reviewer suggestion, Szabó): one source, one view per chapter.
# Content: resources/progressive_table.csv (one row per hypothesis).
# Each view shows the columns introduced up to that chapter; edit `views` to change them.

progressive_table <- function(view = c("ch1", "ch3", "ch4", "ch6")) {
  view <- match.arg(view)

  views <- list(
    ch1 = c("H", "Claim"),
    ch3 = c("H", "Claim", "Gap", "Measure", "Provenance"),
    ch4 = c("H", "Claim", "Measure", "Key variables", "Model", "Method", "Level"),
    ch6 = c("H", "Claim", "Measure", "Model", "Level", "Finding")
  )

  dat <- readr::read_csv(
    here::here("resources/progressive_table.csv"),
    show_col_types = FALSE
  )

  dat |>
    dplyr::select("RQ", dplyr::all_of(views[[view]])) |>
    gt::gt(groupname_col = "RQ") |>
    gt::cols_align(align = "left") |>
    gt::tab_options(
      table.font.size = gt::px(10),
      data_row.padding = gt::px(2),
      row_group.font.weight = "bold",
      table.width = gt::pct(100)
    )
}
