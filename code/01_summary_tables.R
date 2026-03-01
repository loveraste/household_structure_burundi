# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# 01: Summary Statistics (Table 1 & Table 2)
# Equivalent to: 01_Tables_Akresh-etal_March2025.do
#                (Table 1 section of 03b_Individual_Akresh-etal_July2025.do)
# ============================================================

library(tidyverse)
library(gt)
library(modelsummary)

source("code/utils/labels.R")
source("code/utils/helpers.R")

if (!exists("df_baseline")) source("code/00_data_prep.R")
if (!exists("df_pca"))      source("code/00b_gen_pca.R")

# Merge PCA into baseline
df_baseline <- df_baseline %>%
  left_join(df_pca %>% select(id_hh, year, pca_agri, pca_asset, pca_all),
            by = c("id_hh", "year"))

# ============================================================
# TABLE 1: Summary Statistics
# ============================================================

#' Helper: compute stats for a set of variables in a (filtered) dataframe
summary_stats <- function(df, vars, filter_expr = NULL, section_name) {
  if (!is.null(filter_expr)) {
    df <- df %>% filter(!!rlang::parse_expr(filter_expr))
  }
  df %>%
    select(all_of(vars)) %>%
    summarise(across(everything(), list(
      N    = ~sum(!is.na(.)),
      Mean = ~mean(., na.rm = TRUE),
      SD   = ~sd(., na.rm = TRUE)
    ))) %>%
    pivot_longer(
      everything(),
      names_to  = c("variable", ".value"),
      names_sep = "_(?=[^_]+$)"
    ) %>%
    mutate(
      label   = coalesce(var_labels[variable], variable),
      section = section_name
    ) %>%
    select(section, label, N, Mean, SD)
}

# Individual-year level
s1 <- summary_stats(
  df_baseline,
  c("d_violence", "deathwounded_100", "leave"),
  section_name = "Individual-year level"
)

# Individual level (unique persons)
s2 <- summary_stats(
  df_baseline,
  "d_leave_ind",
  filter_expr  = "n_ind == 1",
  section_name = "Individual level"
)

# Household-year level
s3 <- summary_stats(
  df_hh_year,
  c("d_violence", "deathwounded_100", "d_leave_hh", "leave_hh",
    "sk_vl_rob_money", "sk_vl_rob_product", "sk_vl_rob_goods",
    "sk_vl_rob_destruction", "sk_vl_rob_land",
    "index_agri", "index_asset"),
  section_name = "Household-year level"
)

# Household level (collapsed)
s4 <- summary_stats(
  df_hh_year,
  c("hh_d_violence", "hh_deathwounded_100", "d_leave_hh_t", "leave_hh_t",
    "hh_sk_vl_rob_money", "hh_sk_vl_rob_product", "hh_sk_vl_rob_goods",
    "hh_sk_vl_rob_destruction", "hh_sk_vl_rob_land"),
  filter_expr  = "n_hh == 1",
  section_name = "Household level"
)

# Village-year level
s5 <- summary_stats(
  df_baseline,
  c("v_deathwounded", "v_d_violence"),
  filter_expr  = "n_vill_y == 1",
  section_name = "Village-year level"
)

# Village level
s6 <- summary_stats(
  df_baseline,
  "v1_d_violence",
  filter_expr  = "n_vill == 1",
  section_name = "Village level"
)

# Combine all sections
table1_data <- bind_rows(s1, s2, s3, s4, s5, s6)

# Build gt table
table1 <- table1_data %>%
  gt(groupname_col = "section") %>%
  tab_header(title = "Table 1: Summary Statistics") %>%
  cols_label(
    label = "Variable",
    N     = "Obs",
    Mean  = "Mean",
    SD    = "Std. Dev."
  ) %>%
  fmt_number(columns = c(Mean, SD), decimals = 3) %>%
  fmt_integer(columns = N) %>%
  tab_style(
    style = cell_text(italic = TRUE, underline = TRUE),
    locations = cells_row_groups()
  ) %>%
  tab_source_note(
    source_note = "Notes - This table presents the main descriptive statistics at different observation levels.
    Violence in a given year (yes=1) takes the value one if the number of casualties in a given year is positive,
    0 otherwise. Number of casualties in a given year measures the number of individuals killed or wounded in a
    given year (divided by 100). Index of Agricultural Related Losses refers to the sum of Loss of land (yes=1)
    and Theft of crops (yes=1) for a household in a given year. Index of Asset Related Losses refers to the sum
    of Theft of money (yes=1), Theft or destruction of goods (yes=1), and Destruction of house (yes=1) for a
    household in a given year. Data source: 2007 Burundi Priority Panel Survey."
  ) %>%
  opt_table_font(font = "Times New Roman") %>%
  tab_options(
    table.width  = pct(100),
    row_group.border.top.width = px(2),
    column_labels.border.bottom.width = px(2)
  )

print(table1)

# ============================================================
# TABLE 2: Migration by Violence Presence (Means Test)
# ============================================================
# Stata: Table 2 in 03b_Individual (cross-tabulation / t-test)
# Equivalent: comparison of migration rates in conflict vs non-conflict villages

# Village-level violence indicator (any year during 1998-2007)
df_ind_level <- df_baseline %>%
  filter(n_ind == 1) %>%
  mutate(
    ever_violence_village = as.integer(v1_d_violence > 0),
    # Duration outside (need to compute from year-level data)
    duration_outside = sum_leave  # total years migrated
  )

# Mean test: migration rate by village violence
table2_migration <- df_ind_level %>%
  group_by(ever_violence_village) %>%
  summarise(
    n         = n(),
    migration = mean(d_leave_ind, na.rm = TRUE) * 100,  # as percentage
    .groups   = "drop"
  )

# Duration of migration (among migrants)
df_mig_level <- df_baseline %>%
  filter(n_ind == 1, d_leave_ind == 1) %>%
  mutate(ever_violence_village = as.integer(v1_d_violence > 0))

table2_duration <- df_mig_level %>%
  group_by(ever_violence_village) %>%
  summarise(
    n        = n(),
    duration = mean(duration_outside, na.rm = TRUE),
    .groups  = "drop"
  )

# T-test: migration rate difference
t_migration <- t.test(
  d_leave_ind ~ ever_violence_village,
  data     = df_ind_level,
  var.equal = FALSE
)

t_duration  <- t.test(
  duration_outside ~ ever_violence_village,
  data      = df_mig_level,
  var.equal = FALSE
)

cat("\nTable 2: Migration by Violence Presence\n")
cat(sprintf("  Non-violence villages: N=%d, Migration=%.3f%%\n",
            table2_migration$n[1], table2_migration$migration[1]))
cat(sprintf("  Violence villages:     N=%d, Migration=%.3f%%\n",
            table2_migration$n[2], table2_migration$migration[2]))
cat(sprintf("  Difference (t-test): p=%.4f\n", t_migration$p.value))

# Save results
cat("\nTable 1 and Table 2 computed successfully.\n")
cat("Use table1 object for rendering in Quarto.\n")
