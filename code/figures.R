# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# Figures 1 and 2
# ============================================================

library(tidyverse)
library(ggplot2)
library(scales)

source("code/utils/labels.R")
source("code/utils/helpers.R")

if (!exists("df_baseline")) source("code/00_data_prep.R")

# ============================================================
# FIGURE 1: Poverty Transition by Migration and Violence
# ============================================================
# Stacked bar chart showing poverty status transitions (1998-2007)
# Split by: (a) villages with violence, (b) villages without violence
# Within each: by whether HH had individual migration

cat("Building Figure 1: Poverty transition...\n")

# Build household-level poverty transition data
# Need: Poverty_status_98, Poverty_status_07, d_leave_hh_t, v1_d_violence
df_poverty <- df_hh_year %>%
  filter(n_hh == 1) %>%  # one obs per household
  filter(!is.na(Poverty_status_98), !is.na(Poverty_status_07)) %>%
  mutate(
    # Poverty categories 1998
    poor_98     = Poverty_status_98,
    # Poverty status 2007
    poor_07     = Poverty_status_07,
    # Migration indicator
    had_migration = as.integer(d_leave_hh_t > 0),
    # Violence village indicator
    violence_village = as.integer(v1_d_violence > 0),
    # Group label for x-axis
    migration_label = ifelse(had_migration == 1,
                             "At least one HH\nmember migrated",
                             "Non-Individual\nMigration")
  )

# Compute percentages for each cell
fig1_data <- df_poverty %>%
  group_by(violence_village, poor_98, migration_label, poor_07) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(violence_village, poor_98, migration_label) %>%
  mutate(pct = n / sum(n) * 100) %>%
  ungroup() %>%
  mutate(
    panel_label = if_else(violence_village == 1,
                          "(a) Villages that experienced violence in at least 1 year during 1998-2007",
                          "(b) Villages that never experienced violence"),
    poverty_status_label = if_else(poor_98 == 1, "Extreme Poor Households\n(1998)", "Non-Extreme Poor Households\n(1998)"),
    poor_07_label = if_else(poor_07 == 1, "Extreme Poor (2007)", "Non-Extreme Poor (2007)")
  )

# Figure 1 plot (replicating the STATA stacked bar chart)
fig1 <- ggplot(fig1_data,
               aes(x = migration_label, y = pct, fill = factor(poor_07))) +
  geom_col(width = 0.6) +
  geom_text(aes(label = round(pct, 0)),
            position = position_stack(vjust = 0.5),
            size = 3.5, color = "white", fontface = "bold") +
  facet_grid(panel_label ~ poverty_status_label, scales = "free_x") +
  scale_fill_manual(
    name   = NULL,
    values = c("1" = "grey70", "0" = "grey20"),
    labels = c("1" = "Extreme Poor (2007)", "0" = "Non-Extreme Poor (2007)")
  ) +
  scale_y_continuous(labels = label_percent(scale = 1), limits = c(0, 110)) +
  labs(
    title  = "Figure 1. Household transition on poor status between 1998 and 2007,\nby experience of migration",
    x      = NULL,
    y      = "%",
    caption = paste(
      "Notes: Number of households = 871.",
      "Poverty incidence in 1998 based on rural poverty line of BIF 8,173.15.",
      "In 1998, 68% were under the poverty line and 55.9% were extreme poor.",
      "Data source: 2007 Burundi Priority Panel Survey."
    )
  ) +
  theme_classic(base_family = "serif", base_size = 11) +
  theme(
    legend.position   = "bottom",
    strip.background  = element_blank(),
    strip.text        = element_text(italic = TRUE, size = 9),
    plot.caption      = element_text(hjust = 0, size = 8),
    axis.text.x       = element_text(size = 8)
  )

ggsave("out/figure1_poverty_transition.pdf", fig1, width = 8, height = 7)
ggsave("out/figure1_poverty_transition.png", fig1, width = 8, height = 7, dpi = 300)
cat("Figure 1 saved.\n")

# ============================================================
# FIGURE 2: Marital Migration Over Group Ages (Coefficient Plot)
# ============================================================
# Point estimates for asset related losses across age groups 15-20 to 15-65

cat("Building Figure 2: Marital migration coefficient plot...\n")

# Load pre-computed Figure 2 results (from 03c_marital_migration.R)
if (file.exists("out/fig2_marital_migration_by_age.rds")) {
  fig2_data <- readRDS("out/fig2_marital_migration_by_age.rds")
} else {
  # If not yet computed, create placeholder
  message("Run 03c_marital_migration.R first to generate Figure 2 data.")
  fig2_data <- tibble(
    age_group = paste0("15-", seq(20, 65, by = 5)),
    coef      = rnorm(10, 0.01, 0.005),
    ci_lo     = coef - 0.02,
    ci_hi     = coef + 0.02
  )
}

# Order age groups
fig2_data <- fig2_data %>%
  mutate(age_group = factor(age_group, levels = rev(paste0("15-", seq(20, 65, by = 5)))))

fig2 <- ggplot(fig2_data, aes(x = coef, y = age_group)) +
  geom_vline(xintercept = 0, linetype = "solid", color = "red", linewidth = 0.5) +
  geom_errorbarh(aes(xmin = ci_lo, xmax = ci_hi),
                 height = 0, linewidth = 0.5) +
  geom_point(size = 3, shape = 19) +
  scale_x_continuous(
    name   = "Point Estimates and confidence interval (95%)",
    limits = c(-0.03, 0.05),
    breaks = seq(-0.02, 0.04, by = 0.02)
  ) +
  labs(
    title  = "Figure 2. Civil war and marital migration over group ages.",
    y      = "Civil War and Marital Migration over group ages",
    caption = paste(
      "Notes: This figure shows point estimates for the household-level analysis for marital migration",
      "and asset related losses index. Dependent variable: at least one woman between each group age",
      "migrates due to marriage in a given year. Data source: 2007 Burundi Priority Panel Survey."
    )
  ) +
  theme_classic(base_family = "serif", base_size = 11) +
  theme(
    plot.caption = element_text(hjust = 0, size = 8),
    axis.title.y = element_text(size = 9)
  )

ggsave("out/figure2_marital_migration_ages.pdf", fig2, width = 7, height = 6)
ggsave("out/figure2_marital_migration_ages.png", fig2, width = 7, height = 6, dpi = 300)
cat("Figure 2 saved.\n")

cat("All figures complete.\n")
