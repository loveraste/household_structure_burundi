# ============================================================
# Civil War and Household Structure - Burundi
# Akresh, Muñoz-Mora & Verwimp (2025)
# ============================================================
# MASTER SCRIPT
# Run all analysis scripts in order
#
# Usage:
#   Rscript code/master.R             # Run full pipeline
#   source("code/master.R")           # From R console
#
# Requirements: Run from project root directory
#   setwd("/path/to/household_structure_burundi")
# ============================================================

# ============================================================
# 0. SETUP
# ============================================================

cat("=======================================================\n")
cat("Civil War and Household Structure - Burundi\n")
cat("Akresh, Muñoz-Mora & Verwimp (2025)\n")
cat("=======================================================\n\n")

# Check working directory
if (!file.exists("data/final/panel_individual.dta")) {
  stop("Error: Please set working directory to project root.\n",
       "Required file not found: data/final/panel_individual.dta\n",
       "Use: setwd('/path/to/household_structure_burundi')")
}

# Install/load required packages
required_packages <- c(
  "haven",        # Read .dta files
  "tidyverse",    # Data manipulation + ggplot2
  "fixest",       # Fast panel FE regressions
  "modelsummary", # Publication-quality tables
  "gt",           # Table formatting
  "kableExtra",   # LaTeX/HTML tables
  "psych",        # PCA
  "openxlsx",     # Excel output
  "glue",         # String interpolation
  "scales"        # Plot formatting
)

missing_pkgs <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
if (length(missing_pkgs) > 0) {
  cat("Installing missing packages:", paste(missing_pkgs, collapse = ", "), "\n")
  install.packages(missing_pkgs)
}

suppressPackageStartupMessages({
  invisible(lapply(required_packages, library, character.only = TRUE))
})

cat("All packages loaded.\n\n")

# ============================================================
# 1. DATA PREPARATION
# ============================================================

cat("Step 1: Data Preparation...\n")
cat("-------------------------------\n")
source("code/00_data_prep.R")
cat("Data preparation COMPLETE.\n\n")

# ============================================================
# 2. PCA INDICES
# ============================================================

cat("Step 2: PCA Indices...\n")
cat("-------------------------------\n")
source("code/00b_gen_pca.R")
cat("PCA computation COMPLETE.\n\n")

# ============================================================
# 3. SUMMARY STATISTICS (Tables 1 & 2)
# ============================================================

cat("Step 3: Summary Statistics (Tables 1 & 2)...\n")
cat("-------------------------------\n")
source("code/01_summary_tables.R")
cat("Summary tables COMPLETE.\n\n")

# ============================================================
# 4. INDIVIDUAL ANALYSIS (Table 3)
# ============================================================

cat("Step 4: Individual Analysis (Table 3)...\n")
cat("-------------------------------\n")
source("code/03b_individual_analysis.R")
cat("Individual analysis COMPLETE.\n\n")

# ============================================================
# 5. HOUSEHOLD ANALYSIS (Table 4)
# ============================================================

cat("Step 5: Household Analysis (Table 4)...\n")
cat("-------------------------------\n")
source("code/03a_household_analysis.R")
cat("Household analysis COMPLETE.\n\n")

# ============================================================
# 6. MARITAL MIGRATION (Tables 5 & 6)
# ============================================================

cat("Step 6: Marital Migration (Tables 5 & 6)...\n")
cat("-------------------------------\n")
source("code/03c_marital_migration.R")
cat("Marital migration analysis COMPLETE.\n\n")

# ============================================================
# 7. RETURN MIGRATION (Table 7)
# ============================================================

cat("Step 7: Return Migration (Table 7)...\n")
cat("-------------------------------\n")
source("code/03d_return_migration.R")
cat("Return migration analysis COMPLETE.\n\n")

# ============================================================
# 8. APPENDIX TABLES
# ============================================================

cat("Step 8: Appendix Tables (A1-A3)...\n")
cat("-------------------------------\n")
source("code/1a_appendix.R")
cat("Appendix tables COMPLETE.\n\n")

# ============================================================
# 9. FIGURES
# ============================================================

cat("Step 9: Figures (1 & 2)...\n")
cat("-------------------------------\n")
source("code/figures.R")
cat("Figures COMPLETE.\n\n")

# ============================================================
# DONE
# ============================================================

cat("=======================================================\n")
cat("PIPELINE COMPLETE\n")
cat("=======================================================\n")
cat("Output files saved to: out/\n")
cat("  - models_table3_individual.rds\n")
cat("  - models_table4_household.rds\n")
cat("  - models_tables5_6_marital.rds\n")
cat("  - models_table7_return.rds\n")
cat("  - models_appendix_tables.rds\n")
cat("  - figure1_poverty_transition.pdf/.png\n")
cat("  - figure2_marital_migration_ages.pdf/.png\n\n")
cat("To render the Quarto manuscript:\n")
cat("  quarto render manuscript/paper.qmd\n")
cat("=======================================================\n")
