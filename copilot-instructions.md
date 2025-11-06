# Copilot Instructions for Household Structure Burundi Project

## Project Overview
This is a replication repository for the research paper **"Civil War and Household Structure: Evidence from Burundi"** by Richard Akresh, Juan Carlos Munoz-Mora, and Philip Verwimp (2025).

The project investigates how civil conflict affects household composition and structure using panel data from Burundi. It combines econometric analysis with geospatial data to understand the impact of civil war on household demographics and welfare outcomes.

## Key Variables & Concepts

### Primary Outcome Variables
- **Household Composition**: Changes in household structure over time (1993-2007)
- **Migration**: Types of migration (permanent, temporary, marriage-related)
- **Welfare Indicators**: Coffee income, economic shocks, natural disasters

### Conflict & Shock Measures
- `deathwounded`: Deaths and wounded from civil conflict
- `deathwounded_100`: Deaths and wounded per 100 population
- **Natural Shocks**: Rain, drought, disease, crop failures, erosion
- **Violent Shocks**: Robbery, destruction, land seizure
- **Economic Shocks**: Input access/prices, output prices, land sales, crop help

### Migration Classification (type_people)
- 1 = Permanent migration
- 2 = Temporary migration
- 3 = Marriages
- Related variables: `mig_why` (reason for migration)

### Individual Characteristics
- `age`: Individual age (track `adult_15`, `adult_18` dummy variables)
- `pid07`: Person identifier within household
- `reczd`, `numen`, `numsplit`: Household identifiers (can be concatenated)

## Project Structure

### Data Organization (in `data/`)
- **`final/`**: Cleaned panel data ready for analysis
  - `panel_individual.dta`: Main individual-level panel dataset (1993-2007)
  - `panel_individual_93-98.dta`: Subset for 1993-1998 period
  - `inst.dta`: Institutional data
  - `com_z.dta`, `geo2 data.dta`: Geographic/community data
  - `lon2.dta`: Longitude/latitude coordinates

- **`job/`**: Industry-specific and processed data
  - `coffee.dta`: Coffee production/income data
  - `livestock.dta`: Livestock data
  - `pca.dta`: Principal component analysis results
  - `schocks.dta`: Shock variables
  - `p_balanced_93-98.dta`, `p_balanced.dta`: Balanced panel data

- **`map/`**: Geospatial data (shapefiles)
  - BDI_adm3 shapefiles for Burundi administrative boundaries
  - `uscoord.dta`, `usdb.dta`: Coordinate and database information

- **`origin/`**: Raw/original datasets
  - `demofinal17.dta`: Demographic data
  - `poverty_status98.dta`, `poverty_status98-07.dta`: Poverty indicators
  - `conflictlong3.dta`: Conflict data
  - `coffee.dta`, `livestock.dta`: Raw industry data

- **`survival/`**: Migration and survival analysis data
  - `data-survival.dta`: Full survival data
  - `no-migration.dta`: Non-migrants subset
  - `permanet.dta`: Permanent migrants
  - `temporal.dta`: Temporary migrants

### Do-Files (STATA Scripts)
- **`Master_Do-Files.do`**: Main entry point (defines paths and calls other scripts)
- **`00_DataPreliminaries_Akresh-etal_2025.do`**: Data loading and initial variable generation
  - Creates person ID (`id_person`) and household ID (`id_hh`)
  - Sets up panel structure with `xtset`
  - Generates key variables: logs, shock indicators, age dummies
  - Defines sample restrictions (migration types)
  
- **`00a_Genvariables_Akresh-etal_2025.do`**: Additional variable generation
- **`00b_Gen_PCA.do`**: Principal component analysis calculations
- **`01_Tables_Akresh-etal_March2025.do`**: Main descriptive and regression tables
- **`03a_Household_Akresh-etal_July2025.do`**: Household-level analysis
- **`03b_Individual_Akresh-etal_July2025.do`**: Individual-level analysis
- **`03c_NaturalShocks_Akresh-etal_July2025.do`**: Natural shocks analysis
- **`03e_Welfare_Akresh_etal_July2025.do`**: Welfare analysis (July version)
- **`04_Welfare_new_Akresh-etal_August2025.do`**: Updated welfare analysis (August version)
- **`1a_Appendix_Akresh-etal_March2025.do`**: Appendix tables and robustness checks
- **`2_Extras_Akresh-etal_March2025.do`**: Additional analysis and side analyses
- **`3d_OtherShocks_Akresh-etal_July2025.do`**: Other types of shocks analysis
- **`labels.do`**: Variable labels and formatting

## STATA Configuration & Best Practices

### Path Setup
- Scripts expect `global path_work` to be defined before execution
- Default output path: `$path_work/out`
- Update paths for your system in the Master file

### STATA Settings Used in This Project
```stata
clear all
set more off
set logtype smcl
set matsize 8000
pause on
set type double, permanently
set type float, permanently
```

### Panel Data Structure
- **Panel Setup**: `xtset id_person year`
- **Time Range**: 1993-2007 (note: some analyses use 1993-1998 subset)
- **Cross-sectional units**: Individuals (within households, within communities)

### Common Transformations
- **Logs**: Used for income variables (e.g., `log_coffe = log(cff_income + 1)`)
- **Scaling**: Shock variables scaled per 100 population
- **Binary indicators**: Generated for age groups (adult_15, adult_18)
- **Missing value imputation**: Shock variables replace missing values with 0 (need to document missing mechanism)

## Key Analysis Samples
The project defines multiple sample restrictions based on migration type:
1. **restr_1**: All sample (no restriction)
2. **restr_2**: Permanent or marriages (type_people==1|type_people==3)
3. **restr_3**: Temporary or marriages (type_people==2|type_people==3)
4. **restr_4**: Permanent or temporary (type_people==1|type_people==2)
5. **restr_5**: Permanent migrants only (type_people==1&mig_why==3)
6. **restr_6**: Marriage only (type_people==1&mig_why==3)
7. **restr_7**: All without marriages (mig_why!=3)

## When Working with This Project

### Adding New Analysis
1. Create a new do-file with naming convention: `0X_[Description]_Akresh-etal_[MONTH]YYYY.do`
2. Start with the data cleaning from `00_DataPreliminaries_Akresh-etal_2025.do`
3. Define the analysis sample explicitly using the `restr_X` variables
4. Document all variables used and sample restrictions clearly

### Modifying Data Processing
1. Changes to variable generation should be made in `00_DataPreliminaries_Akresh-etal_2025.do` or `00a_Genvariables_Akresh-etal_2025.do`
2. Test changes on a subset before running full analysis
3. Verify panel structure is maintained after changes
4. Update `labels.do` if new variables are added

### Adding New Data Sources
1. Place raw data in `data/origin/` with clear naming
2. Create cleaning scripts in do-files with descriptive names
3. Output cleaned data to `data/final/` or `data/job/` as appropriate
4. Document data source, coverage, and any transformations in comments

## Geographic Context
- **Country**: Burundi
- **Administrative Unit**: Admin Level 3 (ADM3 boundaries provided)
- **Geospatial Files**: Shapefiles in `data/map/BDI_adm3.*`
- **Conflict Data**: Available by region/location with death/wound counts

## Analysis Timeline
- **Panel Period**: 1993-2007 (14 years)
- **Pre-conflict**: 1993-1998
- **Conflict Period**: Roughly 1998-2003 (active conflict)
- **Post-conflict**: 2003-2007
- Analyses may use full period or specific sub-periods

## Common Patterns in Replication

### Generating IDs
```stata
egen id_person=concat(reczd numen numsplit pid07)
egen id_hh=concat(reczd numen)
destring id_person id_hh, replace
```

### Setting Up Panel
```stata
xi i.year
xtset id_person year
```

### Shock Variable Handling
```stata
foreach i in [shock variables] {
    replace `i'=0 if `i'==.
}
```

## Tips for Collaboration & Maintenance

- **Comments**: Use clear, English comments explaining analytical choices
- **Variable Naming**: Follow existing conventions (e.g., `sk_` prefix for shocks, `mig_` for migration)
- **Versioning**: Include dates in script names to track versions
- **Logs**: Save STATA logs for all analysis runs for reproducibility
- **Output**: Store all results (tables, figures) in `out/` folder with date stamps

## Known Considerations

- Multiple authors working on different systems (paths vary)
- Mix of full panel (1993-2007) and subset (1993-1998) analyses
- Multiple versions of welfare analysis (July and August iterations suggest ongoing revisions)
- Missing value handling in shocks set to zero—document if this varies by shock type
- Migration categorization has complex interactions between `type_people` and `mig_why`

## Contact & Attribution
Paper: "Civil War and Household Structure: Evidence from Burundi"
Authors: Richard Akresh, Juan Carlos Munoz-Mora, Philip Verwimp (2025)
Repository maintained by the research team.
