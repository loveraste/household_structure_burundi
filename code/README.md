# R Code: Civil War and Household Structure - Burundi

Migration from STATA to R — Akresh, Muñoz-Mora & Verwimp (2025)

## Requirements

```r
install.packages(c(
  "haven",        # Read Stata .dta files
  "tidyverse",    # dplyr, ggplot2, purrr, tidyr
  "fixest",       # Fast panel FE regressions (replaces xtreg fe)
  "modelsummary", # Publication regression tables
  "gt",           # Table formatting (Word-compatible)
  "kableExtra",   # LaTeX/HTML tables
  "psych",        # PCA
  "openxlsx",     # Excel output
  "glue",         # String interpolation
  "scales"        # Plot scales
))
```

## Running the Pipeline

```r
# Set working directory to project root
setwd("/path/to/household_structure_burundi")

# Run full pipeline
source("code/master.R")
```

Or run scripts individually (must run in order):

```r
source("code/00_data_prep.R")    # Data preparation (REQUIRED FIRST)
source("code/00b_gen_pca.R")     # PCA computation
source("code/01_summary_tables.R") # Tables 1 & 2
source("code/03b_individual_analysis.R") # Table 3
source("code/03a_household_analysis.R")  # Table 4
source("code/03c_marital_migration.R")   # Tables 5 & 6
source("code/03d_return_migration.R")    # Table 7
source("code/1a_appendix.R")            # Appendix Tables 1-3
source("code/figures.R")                # Figures 1 & 2
```

## File Structure

```
code/
├── master.R                     # Main entry point — runs full pipeline
├── 00_data_prep.R               # Data loading + variable generation
├── 00b_gen_pca.R                # PCA computation
├── 01_summary_tables.R          # Summary statistics (Tables 1 & 2)
├── 03a_household_analysis.R     # Household FE regressions (Table 4)
├── 03b_individual_analysis.R    # Individual FE regressions (Table 3)
├── 03c_marital_migration.R      # Marital migration (Tables 5 & 6)
├── 03d_return_migration.R       # Return migration (Table 7)
├── 1a_appendix.R                # Appendix Tables A1-A3
├── figures.R                    # Figures 1 & 2
├── utils/
│   ├── labels.R                 # Variable labels
│   └── helpers.R                # Reusable functions + variable lists
└── README.md                    # This file
```

## STATA → R Key Translations

| STATA | R (fixest) |
|-------|-----------|
| `xtset id_person year` | Panel structure via `id_person` and `year` columns |
| `xtreg leave d_violence i.year province_trend, fe cluster(reczd)` | `feols(leave ~ d_violence \| id_person + year + province[year], cluster = ~reczd)` |
| `bys group: gen n=_n` | `group_by(group) %>% mutate(n = row_number())` |
| `bys group: egen s=sum(x)` | `group_by(group) %>% mutate(s = sum(x, na.rm=TRUE))` |
| `merge m:1 ... using ...` | `left_join(df, by = ...)` |
| `estpost tabstat` | `datasummary()` from modelsummary |
| `putexcel` | `gt::gtsave()` or `openxlsx::writeData()` |
| PCA: `pca vars, comp(1)` | `psych::principal(X, nfactors=1, rotate="none")` |
| `gen adult_18=(age>=18)` | `mutate(adult_18 = as.integer(age >= 18))` |
| `replace sk_*=0 if sk_*==.` | `mutate(across(all_of(shock_vars), ~replace_na(., 0)))` |

## Province Time Trend

In STATA: `bys province year: gen province_trend=_n`
In R/fixest: Use `province[year]` as interacted fixed effects:

```r
feols(leave ~ d_violence | id_person + year + province[year], cluster = ~reczd)
```

The `province[year]` syntax in fixest creates province-specific year effects,
equivalent to the province time trend (province × year interaction).

## Key Variables

- **`id_person`**: Individual panel ID = concat(reczd, numen, numsplit, pid07)
- **`id_hh`**: Household ID = concat(reczd, numen)
- **`reczd`**: Village (sous-colline) = clustering unit for standard errors
- **`leave`**: Individual migrated for non-marital reasons in year t (0/1)
- **`d_violence`**: Village had any casualties in year t (0/1)
- **`deathwounded_100`**: Deaths + wounded / 100 population
- **`restr_7`**: Baseline sample (non-marriage migration + non-migrants)
- **`numsplit==0`**: Parental (original) households only

## Notes on Variable Names

Some variable names may differ from STATA depending on how `haven::read_dta()`
reads the `.dta` files. Check actual column names with:

```r
df_raw <- haven::read_dta("data/final/panel_individual.dta")
names(df_raw)
str(df_raw)
```

Gender variable (adjust in scripts if needed):
```r
# Check:
df_raw %>% select(matches("sex|gender|female|male")) %>% glimpse()
```
