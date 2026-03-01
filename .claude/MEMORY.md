# Project Memory: Civil War and Household Structure - Burundi

## Project Overview
- **Title:** Civil War and Household Structure: Evidence from Burundi
- **Authors:** Richard Akresh (UIUC), Juan Carlos Muñoz-Mora (EAFIT), Philip Verwimp (ULB)
- **Status:** PRELIMINARY DRAFT (December 2025) → Preparando submission
- **Target journal:** Journal of Development Economics / World Development (APA/Harvard citations)
- **Working directory:** `/Users/jcmunoz/Documents/GitHub/household_structure_burundi`

## Project Structure (post-cleanup, March 2026)
```
household_structure_burundi/
├── code/               # R: pipeline principal ← ANÁLISIS PRINCIPAL
│   ├── master.R        # Entry point
│   ├── 00_data_prep.R, 00b_gen_pca.R, 01_summary_tables.R
│   ├── 03a_household_analysis.R, 03b_individual_analysis.R
│   ├── 03c_marital_migration.R, 03d_return_migration.R
│   ├── 1a_appendix.R, figures.R
│   └── utils/          # helpers.R, labels.R
├── data/               # Data (tracked in git - incluye .dta files)
│   ├── final/          # panel_individual.dta - MAIN dataset
│   ├── job/            # pca.dta, schocks.dta, etc.
│   ├── origin/         # poverty_status*.dta, raw data
│   ├── map/            # Shapefiles (Burundi ADM3)
│   └── survival/       # Migration duration data
├── manuscript/         # Paper en Quarto (.qmd → Word .docx)
│   ├── paper.qmd       # Manuscript principal
│   ├── references.bib  # BibTeX (31 entradas)
│   └── _quarto.yml     # Config Quarto (APA, docx)
├── docs/               # submission_checklist.md + analysis_notes.md
├── out/                # Outputs del análisis R
├── legacy/             # Archivo histórico: STATA do-files, CSVs, misc (no tocar)
├── .claude/commands/   # Skills de Claude Code (7 comandos)
├── CLAUDE.md           # Instrucciones proyecto para Claude
├── MEMORY.md           # Este archivo
└── README.md           # Documentación pública
```

## .claude/ Commands Disponibles
- `/review-tables` — Verificar que números del paper coinciden con outputs STATA
- `/submission-check` — Checklist completo de submission
- `/robustness-check` — Estado de robustness checks
- `/referee-response` — Borrador de respuesta a referees
- `/replication-check` — Verificar paquete de replicación
- `/cover-letter` — Borrador de carta de presentación al journal
- `/edit-paper` — Editar secciones del manuscript con guía de estilo

## Data Key Facts
- **Main dataset:** `data/final/panel_individual.dta`
- **Panel:** Individual-year, 1998–2007 (10 years)
- **Sample (baseline):** 872 households, 3480 members, 34800 obs (individual-year)
- **Panel ID:** `id_person = concat(reczd, numen, numsplit, pid07)`
- **HH ID:** `id_hh = concat(reczd, numen)`
- **Village ID:** `reczd` (= sous-colline, clustering unit for SEs)
- **Survey:** HPS 1998 (World Bank + Burundi Stats) + follow-up 2007

## R Pipeline (code/)
| Script | Tabla/Output |
|--------|-------------|
| `code/00_data_prep.R` | Datos, IDs, variables, muestra baseline |
| `code/00b_gen_pca.R` | PCA shocks → `out/models_pca.rds` |
| `code/01_summary_tables.R` | Tabla 1 (summary stats), Tabla 2 (means test) |
| `code/03b_individual_analysis.R` | Tabla 3 (individual FE) |
| `code/03a_household_analysis.R` | Tabla 4 (household FE) |
| `code/03c_marital_migration.R` | Tablas 5-6 (marital migration) |
| `code/03d_return_migration.R` | Tabla 7 (return migration) |
| `code/1a_appendix.R` | Appendix Tables A1-A3 |
| `code/figures.R` | Figuras 1-2 |
| `code/master.R` | Entry point — corre todo en orden |

**STATA (legacy):** Do-files archivados en `legacy/do-files/` como referencia histórica. No son el pipeline activo.

## Key Variables
- **Dependent:** `leave` (binary, migrated in year t); `d_leave_hh` (any HH member left)
- **Conflict exposure:** `d_violence` (binary); `deathwounded_100` (deaths+wounded/100)
- **HH victimization:** `sk_vl_rob_land/product/money/goods/destruction`
- **Indexes:** `index_agri` (land+product), `index_asset` (money+goods+destruction)
- **PCA:** `pca_agri`, `pca_asset`, `pca_all` (from `data/job/pca.dta`)
- **Sample restriction:** `restr_7==1` + `numsplit==0` = MUESTRA BASELINE
- **Province trend:** `bys province year: gen province_trend=_n`

## Empirical Strategy
- **Model:** Individual FE + Year FE + Province-specific time trend
- **STATA:** `xtreg leave d_violence i.year province_trend, fe cluster(reczd)`
- **Clustering:** Sous-colline (village) level = `reczd`

## Main Results (Paper Tables)
| Table | Content | Key Result |
|-------|---------|-----------|
| Table 1 | Summary stats | N=34800 ind-year; 13.8% ever migrated |
| Table 2 | Means test by violence | +5.24 pp migration in conflict villages |
| Table 3 | Individual FE baseline | Violence: +3.1 pp; Casualties: +0.9 pp |
| Table 4 | Household FE baseline | Asset losses: +4.1 pp migration |
| Table 5 | Marital migration, individual | No effect of village violence |
| Table 6 | Marital migration, household | Asset losses: +1.5 pp marital migration |
| Table 7 | Return migration | Conflicto reduce retorno 14-34 pp |
| App. 1 | HH by age (adult/child) | Both affected; children slightly less |
| App. 2 | HH by gender (woman/man) | Both affected equally |
| App. 3 | HH by poverty (poor/non-poor) | Stronger for poor households |

## Empirical Strategy (R)
- **Model:** `feols(leave ~ {var} | id_person + year + province[year], cluster = ~reczd)`
- `province[year]` = province-specific time trends (equivale a STATA `province_trend`)
- Clustering: `reczd` (sous-colline)
- Muestra baseline: `numsplit==0 & restr_7==1`

## User Preferences
- Comunicación: **español**
- Paper/outputs: inglés (académico)
- Pipeline: **R** con fixest — STATA archivado en legacy/
- Manuscript: Quarto (.qmd → .docx Word)
- Referencias: BibTeX en manuscript/references.bib
- Commits: solo cuando se piden explícitamente
