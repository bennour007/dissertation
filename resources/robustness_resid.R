pacman::p_load(targets, fixest, tidyverse, modelsummary, gt, car)

data <- tar_read(dis_data_z, store = "../../_targets_EMP")

# --- prep ------------------------------------------------------
aux <- lm(pred11 ~ relatedness_density, data, na.action = na.exclude)

data <- data |>
  mutate(resid_z = as.numeric(scale(resid(aux))))

# --- Table A: diagnostics --------------------------------------
diag_tbl <- tibble(
  Diagnostic = c(
    "Correlation (Potential, density)",
    "R² of Potential on density",
    "Share of Potential unexplained by density",
    "VIF: Potential",
    "VIF: relatedness density"
  ),
  Value = c(
    cor(data$pred11, data$relatedness_density, use = "complete.obs"),
    summary(aux)$r.squared,
    1 - summary(aux)$r.squared,
    car::vif(lm(entry ~ pred11 + relatedness_density + patent_n +
                  reg_comp + tech_comp, data))[["pred11"]],
    car::vif(lm(entry ~ pred11 + relatedness_density + patent_n +
                  reg_comp + tech_comp, data))[["relatedness_density"]]
  )
) 
# |>
#   gt() |>
#   fmt_number(Value, decimals = 3) |>
#   tab_header(title = "Collinearity diagnostics, Model 0") |>
#   tab_source_note("VIF from the pooled joint specification. Values below 5 indicate the joint-model coefficients are interpretable as conditional contributions.")

# --- Table B: entry models -------------------------------------
ctrl <- "patent_n + reg_comp + tech_comp | region + year"

m <- function(x) feols(as.formula(paste("f(entry, 1) ~", x, "+", ctrl)),
                       data, vcov = ~ region + tech,
                       # vcov = "cluster",
                       panel.id = ~ rt + year)


mods <- list(
  "Density"        = m("relatedness_density"),
  "Potential"      = m("pred11"),
  "Both"           = m("relatedness_density + pred11"),
  "Residual only"  = m("resid_z")
)


mod_list <- modelsummary(
  mods,
  output = "gt",
  stars   = T,
  coef_map = c(
    "relatedness_density" = "Relatedness density",
    "pred11"              = "Potential",
    "resid_z"             = "Resid",
    "patent_n"            = "Patent count",
    "reg_comp"            = "Regional complexity",
    "tech_comp"           = "Technology complexity"
  ),
  gof_map = c("nobs", "r2.within", "rmse"),
  title   = "Entry benchmark with the orthogonal component of Potential",
  notes   = "All models include region and year fixed effects; standard errors clustered by region and technology. 'Resid' is the standardised residual from regressing Potential on relatedness density."
)



saveRDS(
  list(
    diagnostics = diag_tbl,   # the tibble before gt()
    models = mod_list
    # models      = list(
    #   "Density"       = m("relatedness_density"),
    #   "Potential"     = m("pred11"),
    #   "Both"          = m("relatedness_density + pred11"),
    #   "Residual only" = m("resid_z")
    # )
  ),
  here::here("resources/benchmark_check.rds")
)
