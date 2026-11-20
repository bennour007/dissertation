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

  # Column widths (% of table width) so that cells wrap in the PDF instead of overflowing
  widths <- list(
    ch1 = c(H = 8, Claim = 92),
    ch3 = c(H = 5, Claim = 33, Gap = 34, Measure = 13, Provenance = 15),
    ch4 = c(H = 5, Claim = 30, Measure = 14, `Key variables` = 19, Model = 7, Method = 17, Level = 8),
    ch6 = c(H = 5, Claim = 28, Measure = 14, Model = 7, Level = 8, Finding = 38)
  )
  w <- widths[[view]]
  width_specs <- lapply(names(w), function(col) {
    stats::as.formula(paste0("`", col, "` ~ gt::pct(", w[[col]], ")"))
  })

  dat |>
    dplyr::select("RQ", dplyr::all_of(views[[view]])) |>
    gt::gt(groupname_col = "RQ") |>
    gt::cols_align(align = "left") |>
    gt::cols_width(.list = width_specs) |>
    gt::tab_options(
      table.font.size = gt::px(12),
      data_row.padding = gt::px(2),
      row_group.font.weight = "bold",
      table.width = gt::pct(100)
    )
}
