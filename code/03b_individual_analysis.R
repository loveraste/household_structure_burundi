# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# 03b: Individual-Level Analysis (Table 3)
# Equivalent to: 03b_Individual_Akresh-etal_July2025.do (Table III section)
#
# Model: Migration_ijvt = α(ViolenceExposure)_vt + c_i + year_t + province×year + ε
# ============================================================

library(tidyverse)
library(fixest)
library(modelsummary)
library(gt)

source("code/utils/labels.R")
source("code/utils/helpers.R")

if (!exists("df_baseline")) source("code/00_data_prep.R")
if (!exists("df_pca"))      source("code/00b_gen_pca.R")

# Merge PCA
df_ind <- df_baseline %>%
  left_join(df_pca %>% select(id_hh, year, pca_agri, pca_asset, pca_all),
            by = c("id_hh", "year"))

# ============================================================
# TABLE 3: Individual-Level Baseline Regressions
# ============================================================
# 7 columns: Baseline, Women, Men, Adults, Children, Poor, Non-Poor
# 2 panels: A (exposure: d_violence), B (intensity: deathwounded_100)

cat("Running Table 3: Individual FE regressions...\n")

# Function to run both panels for a given subsample
run_table3_col <- function(df_sub) {
  list(
    exposure  = feols(leave ~ d_violence | id_person + year + province[year],
                      cluster = ~reczd, data = df_sub),
    intensity = feols(leave ~ deathwounded_100 | id_person + year + province[year],
                      cluster = ~reczd, data = df_sub)
  )
}

# Column samples
col_samples <- list(
  "Baseline"         = df_ind,
  "Only women"       = df_ind %>% filter(sex == 0 | sexo == "F"),  # adjust to actual gender var
  "Only men"         = df_ind %>% filter(sex == 1 | sexo == "M"),
  "Adults (>=18)"    = df_ind %>% filter(adult_18 == 1),
  "Children (<18)"   = df_ind %>% filter(adult_18 == 0),
  "Poor (1998)"      = df_ind %>% filter(Poverty_status_98 == 1),
  "Non-Poor (1998)"  = df_ind %>% filter(Poverty_status_98 == 0)
)

# Note: adjust sex/sexo variable name to actual column name in data
# Check with: names(df_ind) %>% grep("sex|gender", ., value = TRUE, ignore.case = TRUE)

# Run regressions for all columns
models_table3 <- lapply(col_samples, run_table3_col)

# Extract Panel A (exposure) and Panel B (intensity) models
panel_a <- lapply(models_table3, `[[`, "exposure")
panel_b <- lapply(models_table3, `[[`, "intensity")

# ============================================================
# RENDER TABLE 3
# ============================================================

# Coefficient labels
coef_labels_3 <- c(
  "d_violence"       = "Violence in a given year (yes=1)",
  "deathwounded_100" = "Number of casualties in a given year"
)

# Additional statistics rows
gof_map3 <- tribble(
  ~raw,          ~clean,                   ~fmt,
  "nobs",        "Observations",           0,
  "mean.dep.var","Mean Dependent Variable", 3
)

# Panel A table
t3_panel_a <- modelsummary(
  panel_a,
  coef_map  = coef_labels_3["d_violence"],
  gof_map   = gof_map3,
  stars     = c("*" = .10, "**" = .05, "***" = .01),
  fmt       = 3,
  statistic = "[{std.error}]",
  output    = "gt"
) %>%
  tab_header(title = "Table 3. Baseline Results: Civil War and Migration, Individual-level Analysis") %>%
  tab_spanner(label = "Panel A: Exposure (Violence in year = 1)",
              columns = 2:8) %>%
  opt_table_font(font = "Times New Roman")

# Panel B table
t3_panel_b <- modelsummary(
  panel_b,
  coef_map  = coef_labels_3["deathwounded_100"],
  gof_map   = gof_map3,
  stars     = c("*" = .10, "**" = .05, "***" = .01),
  fmt       = 3,
  statistic = "[{std.error}]",
  output    = "data.frame"
)

cat("Table 3 models estimated successfully.\n")

# ============================================================
# SAVE RESULTS
# ============================================================

# Save model list for use in Quarto document
models_ind_baseline <- list(panel_a = panel_a, panel_b = panel_b)
saveRDS(models_ind_baseline, "out/models_table3_individual.rds")

# Export to CSV for inspection
bind_rows(
  t3_panel_b %>% mutate(panel = "B: Intensity"),
  .id = "spec"
) %>%
  write_csv("out/table2_individual_interaction_exposure.csv")

cat("Results saved to out/models_table3_individual.rds\n")
