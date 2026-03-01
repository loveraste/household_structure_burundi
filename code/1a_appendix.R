# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# 1a: Appendix Tables
# Equivalent to: 1a_Appendix_Akresh-etal_March2025.do
#
# Appendix Table 1: By age (adult vs. children)
# Appendix Table 2: By gender (women vs. men)
# Appendix Table 3: By poverty status (poor vs. non-poor)
# ============================================================

library(tidyverse)
library(fixest)
library(modelsummary)
library(gt)

source("code/utils/labels.R")
source("code/utils/helpers.R")

if (!exists("df_hh_year")) source("code/00_data_prep.R")
if (!exists("df_pca"))     source("code/00b_gen_pca.R")

# Merge PCA
df_hh <- df_hh_year %>%
  left_join(df_pca %>% select(id_hh, year, pca_agri, pca_asset, pca_all),
            by = c("id_hh", "year"))

# ============================================================
# SHARED REGRESSION FUNCTION
# ============================================================

run_hh_specs <- function(df, outcome, regressors = NULL) {
  if (is.null(regressors)) {
    regressors <- list(
      "Village exposure"  = "d_violence",
      "Village intensity" = "deathwounded_100",
      "Agri index"        = "index_agri",
      "Asset index"       = "index_asset"
    )
  }
  lapply(regressors, function(x) {
    fml <- as.formula(paste0(outcome, " ~ ", x,
                             " | id_hh + year + province[year]"))
    tryCatch(
      feols(fml, cluster = ~reczd, data = df),
      error = function(e) NULL
    )
  })
}

# ============================================================
# APPENDIX TABLE 1: By Age Group
# ============================================================
cat("Running Appendix Table 1: By age...\n")

# Adults: any adult (>=18) leaves
# Note: compute these in data prep if not already present
# df_hh should have: d_leave_hh_adult, d_leave_hh_child (from 03a/data)

models_app1_adult <- run_hh_specs(df_hh, "d_leave_hh_adult")
models_app1_child <- run_hh_specs(
  df_hh %>% filter(n_child_hh > 0),  # only HH with children
  "d_leave_hh_child"
)

# ============================================================
# APPENDIX TABLE 2: By Gender
# ============================================================
cat("Running Appendix Table 2: By gender...\n")

models_app2_woman <- run_hh_specs(df_hh, "d_leave_hh_woman")
models_app2_man   <- run_hh_specs(df_hh, "d_leave_hh_man")

# ============================================================
# APPENDIX TABLE 3: By Poverty Status (1998)
# ============================================================
cat("Running Appendix Table 3: By poverty status...\n")

df_nonpoor <- df_hh %>% filter(Poverty_status_98 == 0)
df_poor    <- df_hh %>% filter(Poverty_status_98 == 1)

models_app3_nonpoor <- run_hh_specs(df_nonpoor, "d_leave_hh")
models_app3_poor    <- run_hh_specs(df_poor,    "d_leave_hh")

# ============================================================
# RENDER APPENDIX TABLES
# ============================================================

coef_labels_app <- c(
  "d_violence"       = "Violence in a given year (yes=1)",
  "deathwounded_100" = "Number of casualties in a given year",
  "index_agri"       = "Index of Agricultural Related Losses",
  "index_asset"      = "Index of Asset Related Losses"
)

render_app_table <- function(models_left, models_right,
                             left_title, right_title, table_title) {
  # Combine left and right models
  all_models <- c(
    setNames(models_left,  paste0("L_", names(models_left))),
    setNames(models_right, paste0("R_", names(models_right)))
  )
  all_non_null <- Filter(Negate(is.null), all_models)
  if (length(all_non_null) == 0) return(NULL)

  modelsummary(
    all_non_null,
    coef_map  = coef_labels_app,
    stars     = c("*" = .10, "**" = .05, "***" = .01),
    fmt       = 3,
    statistic = "[{std.error}]",
    output    = "gt"
  ) %>%
    tab_header(title = table_title) %>%
    tab_spanner(label = left_title,  columns = 2:5) %>%
    tab_spanner(label = right_title, columns = 6:9) %>%
    tab_footnote(
      footnote = paste(
        "Robust standard errors, clustered at Sous-Colline level.",
        "* p<0.10 ** p<0.05 *** p<0.01.",
        "Data source: 2007 Burundi Priority Panel Survey."
      )
    ) %>%
    opt_table_font(font = "Times New Roman")
}

table_app1 <- render_app_table(
  models_app1_adult, models_app1_child,
  left_title   = "Adults (older than 18 years old)",
  right_title  = "Children (younger than 18 years old)",
  table_title  = "Appendix Table 1: Civil War and Migration, Household Level, By Age"
)

table_app2 <- render_app_table(
  models_app2_woman, models_app2_man,
  left_title   = "Women",
  right_title  = "Men",
  table_title  = "Appendix Table 2: Civil War and Migration, Household Level, By Gender"
)

table_app3 <- render_app_table(
  models_app3_nonpoor, models_app3_poor,
  left_title   = "Non-Poor (1998)",
  right_title  = "Poor (1998)",
  table_title  = "Appendix Table 3: Civil War and Migration, Household Level, By Poverty Status"
)

# ============================================================
# KEY PAPER RESULTS CHECK
# ============================================================
cat("\nExpected results from paper (Appendix Tables):\n")
cat("App Table 1 - Adults, village exposure: 0.040** [0.016]\n")
cat("App Table 1 - Adults, asset index:      0.041*** [0.010]\n")
cat("App Table 1 - Children, village exposure: 0.032* [0.016]\n")
cat("App Table 1 - Children, asset index:      0.032*** [0.01]\n")
cat("App Table 2 - Women, asset index: 0.028*** [0.009]\n")
cat("App Table 2 - Men, asset index:   0.039*** [0.010]\n")
cat("App Table 3 - Poor, village exposure: 0.046** [0.018]\n")
cat("App Table 3 - Poor, asset index:      0.042*** [0.013]\n")

# ============================================================
# SAVE
# ============================================================
saveRDS(
  list(
    app1_adult  = models_app1_adult,
    app1_child  = models_app1_child,
    app2_woman  = models_app2_woman,
    app2_man    = models_app2_man,
    app3_nonpoor = models_app3_nonpoor,
    app3_poor    = models_app3_poor
  ),
  "out/models_appendix_tables.rds"
)

cat("Appendix tables complete.\n")
