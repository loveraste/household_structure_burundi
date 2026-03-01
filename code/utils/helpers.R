# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# Helper Functions
# ============================================================

library(fixest)
library(modelsummary)
library(gt)
library(tidyverse)

# ---- Significance Stars -----------------------------------------------

#' Add significance stars to a coefficient
#'
#' @param p P-value
#' @return String with stars
sig_stars <- function(p) {
  case_when(
    p < 0.01 ~ "***",
    p < 0.05 ~ "**",
    p < 0.10 ~ "*",
    TRUE     ~ ""
  )
}

#' Format coefficient with stars
#'
#' @param b Coefficient
#' @param se Standard error
#' @param df Degrees of freedom (for t-test). Use Inf for z-test.
#' @param digits Number of decimal places
#' @return Named list with coef_str and se_str
format_coef <- function(b, se, df = Inf, digits = 3) {
  p <- 2 * pt(abs(b / se), df = df, lower.tail = FALSE)
  stars <- sig_stars(p)
  coef_str <- paste0(formatC(b, digits = digits, format = "f"), stars)
  se_str   <- paste0("[", formatC(se, digits = digits, format = "f"), "]")
  list(coef = coef_str, se = se_str, p = p)
}

# ---- Regression Runner -----------------------------------------------

#' Run individual FE regression (eq. 1 from paper)
#'
#' Equivalent to: xtreg leave {var} i.year province_trend, fe cluster(reczd)
#' Province time trend is implemented as province x year FE in fixest.
#'
#' @param df Data frame (individual-year level)
#' @param outcome Dependent variable name (string)
#' @param treatment Treatment variable name (string)
#' @param fe_id Individual FE variable (default: id_person)
#' @param cluster Clustering variable (default: reczd)
#' @return fixest model object
run_ind_fe <- function(df, outcome, treatment,
                       fe_id = "id_person", cluster = "reczd") {
  fml <- as.formula(
    glue::glue("{outcome} ~ {treatment} | {fe_id} + year + province[year]")
  )
  feols(fml, cluster = as.formula(glue::glue("~{cluster}")), data = df)
}

#' Run household FE regression (eq. 2 from paper)
#'
#' Equivalent to: xtreg d_leave_hh {var} i.year province_trend, fe cluster(reczd)
#'
#' @param df Data frame (household-year level)
#' @param outcome Dependent variable name (string)
#' @param treatment Treatment variable name (string)
#' @param fe_id Household FE variable (default: id_hh)
#' @param cluster Clustering variable (default: reczd)
#' @return fixest model object
run_hh_fe <- function(df, outcome, treatment,
                      fe_id = "id_hh", cluster = "reczd") {
  fml <- as.formula(
    glue::glue("{outcome} ~ {treatment} | {fe_id} + year + province[year]")
  )
  feols(fml, cluster = as.formula(glue::glue("~{cluster}")), data = df)
}

# ---- Table Export -----------------------------------------------

#' Create a publication-ready regression table using modelsummary
#'
#' @param models Named list of fixest models
#' @param coef_map Named vector: variable names -> display labels
#' @param title Table title
#' @param notes Notes text
#' @param output_format "gt", "kableExtra", or "data.frame"
#' @return gt or kable table object
make_reg_table <- function(models, coef_map, title = NULL,
                           notes = NULL, output_format = "gt") {
  gof_map <- tribble(
    ~raw,             ~clean,                    ~fmt,
    "nobs",           "Observations",             0,
    "FE: id_person",  "Individual Fixed Effect",  NA,
    "FE: id_hh",      "Household Fixed Effect",   NA,
    "FE: year",       "Year Fixed Effect",        NA
  )

  modelsummary(
    models,
    coef_map    = coef_map,
    gof_map     = gof_map,
    title       = title,
    notes       = notes,
    stars       = c("*" = .10, "**" = .05, "***" = .01),
    fmt         = 3,
    output      = output_format,
    statistic   = "[{std.error}]"   # brackets around SE (Stata style)
  )
}

#' Create a summary statistics table
#'
#' @param df Data frame
#' @param vars Character vector of variable names
#' @param labels Named vector of labels (from var_labels)
#' @param title Table title
#' @return gt table
make_summary_table <- function(df, vars, labels = NULL, title = NULL) {
  df_sub <- df %>% select(all_of(vars))

  stats <- df_sub %>%
    summarise(across(everything(), list(
      N    = ~sum(!is.na(.)),
      Mean = ~mean(., na.rm = TRUE),
      SD   = ~sd(., na.rm = TRUE)
    ))) %>%
    pivot_longer(
      everything(),
      names_to  = c("variable", ".value"),
      names_sep = "_(?=[^_]+$)"
    )

  if (!is.null(labels)) {
    stats <- stats %>%
      mutate(variable = coalesce(labels[variable], variable))
  }

  stats %>%
    gt() %>%
    tab_header(title = title) %>%
    fmt_number(columns = c(Mean, SD), decimals = 3) %>%
    fmt_integer(columns = N) %>%
    cols_label(variable = "Variable", N = "Obs", Mean = "Mean", SD = "Std. Dev.")
}

# ---- Data Utilities -----------------------------------------------

#' Extract dep. var. mean from a fixest model
dep_mean <- function(m) mean(m$model[[1]], na.rm = TRUE)

#' Generate province time trend variable
#' Equivalent to: bys province year: gen province_trend=_n
#'
#' @param df Data frame with province and year columns
#' @return Data frame with province_trend added
add_province_trend <- function(df) {
  df %>%
    group_by(province, year) %>%
    mutate(province_trend = row_number()) %>%
    ungroup()
}

#' Make balanced panel indicator
#' @param df Data frame
#' @param id_var Panel identifier
#' @param time_var Time variable
#' @param min_time Minimum time
#' @param max_time Maximum time
is_balanced <- function(df, id_var, time_var, min_time, max_time) {
  n_periods <- max_time - min_time + 1
  df %>%
    group_by(across(all_of(id_var))) %>%
    summarise(n_obs = n()) %>%
    filter(n_obs == n_periods) %>%
    pull(id_var)
}

# ---- Shock Variables -----------------------------------------------

#' Names of all shock variables (for replace_na with 0)
shock_vars <- c(
  # Natural shocks
  "sk_nt_rain", "sk_nt_drought", "sk_nt_disease", "sk_nt_crop_good",
  "sk_nt_crop_bad", "sk_nt_destru_rain", "sk_nt_erosion",
  # Violent shocks
  "sk_vl_rob_money", "sk_vl_rob_product", "sk_vl_rob_goods",
  "sk_vl_rob_destruction", "sk_vl_rob_land",
  # Economic shocks
  "sk_ec_input_access", "sk_ec_input_price", "sk_ec_nonmarket",
  "sk_ec_output_price", "sk_ec_sell_land", "sk_ec_sell_other", "sk_ec_rec_help"
)

#' Violence and household victimization variables (main analysis)
violence_vars  <- c("d_violence", "deathwounded_100")
hh_victim_vars <- c(
  "sk_vl_rob_land", "sk_vl_rob_product", "sk_vl_rob_money",
  "sk_vl_rob_goods", "sk_vl_rob_destruction"
)
index_vars     <- c("index_agri", "index_asset")

# Combined list for household-level regressions (Table 4)
tables_hh <- c(violence_vars, hh_victim_vars, "index_agri", "index_asset")

# Individual-level analysis variables (Table 3)
tables_ind <- c(violence_vars, hh_victim_vars, "pca_agri", "pca_asset", "pca_all")
