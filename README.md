# Civil War and Household Structure: Evidence from Burundi

**Richard Akresh, Juan Carlos Muñoz-Mora, and Philip Verwimp**
*Preliminary Draft — December 2025*

---

## Overview

This repository contains the replication code and manuscript for *"Civil War and Household Structure: Evidence from Burundi"*.
The paper examines how the 1993–2005 Burundi civil war affected household structure through individual and household migration decisions, using a two-wave longitudinal household panel (HPS 1998 + follow-up 2007).

**Key findings:**
- Village conflict exposure increases non-marital migration by **+3.1 pp** (individual) and **+4.1 pp** (household)
- Marital migration is **not affected** by village-level violence, but sensitive to household asset losses
- Conflict reduces return migration by **14–34 pp**, implying durable household compositional change

---

## Repository Structure

```
household_structure_burundi/
├── do-files/            # Original STATA code (20 scripts)
├── code/                # R code (migrated from STATA, 2026)
│   ├── master.R         # Entry point — runs full pipeline
│   ├── R/               # Analysis scripts
│   │   ├── 00_data_prep.R
│   │   ├── 00b_gen_pca.R
│   │   ├── 01_summary_tables.R
│   │   ├── 03a_household_analysis.R
│   │   ├── 03b_individual_analysis.R
│   │   ├── 03c_marital_migration.R
│   │   ├── 03d_return_migration.R
│   │   ├── 1a_appendix.R
│   │   ├── figures.R
│   │   └── utils/
│   │       ├── helpers.R    # Regression functions + variable lists
│   │       └── labels.R     # Variable labels
│   └── README.md
├── data/                # Data files (NOT tracked — too large)
│   ├── final/           # panel_individual.dta (main panel)
│   ├── job/             # pca.dta, schocks.dta
│   ├── origin/          # poverty_status*.dta, raw data
│   └── survival/        # Migration duration data
├── manuscript/          # Paper files
│   ├── paper.qmd        # Quarto manuscript (→ Word .docx)
│   ├── references.bib   # BibTeX references (31 citations)
│   ├── _quarto.yml      # Quarto configuration
│   └── Akresh_Munoz_Verwimp_Burundi HH Structure_24Dec2025.pdf
├── docs/                # Project documentation
│   ├── submission_checklist.md
│   └── analysis_notes.md
└── out/                 # Analysis outputs (CSV, Excel, RDS)
```

---

## Reproducing the Results

### R Pipeline (recommended)

**Requirements:** R ≥ 4.3, packages installed automatically by `master.R`:
`haven`, `tidyverse`, `fixest`, `modelsummary`, `gt`, `kableExtra`, `psych`, `openxlsx`, `glue`, `scales`, `here`

```r
# Set working directory to project root
setwd("/path/to/household_structure_burundi")

# Run full pipeline (loads data, runs all regressions, saves outputs)
source("code/master.R")
```

Individual scripts can be run in order if preferred — see [code/README.md](code/README.md).

### Quarto Manuscript

After running the R pipeline (which saves model RDS files to `out/`):

```bash
# Render to Word
quarto render manuscript/paper.qmd
```

Requires: [Quarto CLI](https://quarto.org) ≥ 1.4. The output `paper.docx` will appear in `manuscript/`.

### STATA Pipeline (original)

```stata
do "do-files/Master_Do-Files.do"
```

Requires Stata 15+ with `estpost`, `putexcel`, `xtreg` commands.

---

## Data

The primary dataset (`data/final/panel_individual.dta`) is **not included** in this repository due to confidentiality restrictions.
Please contact the authors for data access.

**Panel structure:**
- 872 rural households, Burundi
- 3,480 household members
- 34,800 individual-year observations (1998–2007)
- Conflict exposure: deaths and wounded at village (sous-colline) level

---

## Key Variables

| Variable | Description |
|----------|-------------|
| `id_person` | Individual panel ID = concat(reczd, numen, numsplit, pid07) |
| `id_hh` | Household ID = concat(reczd, numen) |
| `reczd` | Village (sous-colline) = clustering unit |
| `leave` | Individual migrated (non-marital) in year t |
| `d_violence` | Village had any casualties in year t (0/1) |
| `deathwounded_100` | (Deaths + wounded) / 100 population |
| `restr_7` | Baseline sample: non-marriage migration + non-migrants |
| `numsplit==0` | Parental (original) households only |

---

## Citation

Akresh, R., Muñoz-Mora, J. C., & Verwimp, P. (2025). *Civil War and Household Structure: Evidence from Burundi*. Preliminary draft.

---

## Contact

- Richard Akresh: akresh@illinois.edu
- Juan Carlos Muñoz-Mora: jcmunozm@eafit.edu.co
- Philip Verwimp: philip.verwimp@ulb.be
