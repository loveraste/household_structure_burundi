# Analysis Notes: Civil War and Household Structure - Burundi

## 1. Data Sources

### Primary Dataset
- **HPS 1998:** Household Priority Survey, World Bank + Burundi Stats
  - 3908 rural households from 391 hills (sous-collines), nationally representative
- **Follow-up 2007:** 1000 households from 100 randomly selected hills
  - 87.4% tracked (874 households); attrition 12.6%
  - Attrition: 2.8% deceased, 2.5% moved unknown, 2.4% disappeared, 3.6% dissolved, 1.3% unknown
  - Attrition analysis: No systematic selection on poverty or violence (Verwimp & Bundervoet 2009)

### Conflict Data
- Deaths and wounded per village (sous-colline), 1998–2007
- Source: Not explicitly stated in paper — likely ACLED or administrative records
- Variable: `deathwounded` → scaled as `deathwounded_100 = deathwounded/100`

### Additional Data Merged
- `inst.dta`: Altitude, average rainfall, average temperature (instruments)
- `poverty_status98.dta`: Poverty status in 1998
- `poverty_status98-07.dta`: Poverty status in both 1998 and 2007
- `pca.dta`: Pre-computed PCA indices (merge by id_hh + year)

---

## 2. Sample Restrictions

### Core Restriction (BASELINE)
```stata
keep if numsplit==0    # Only parental (original) households, not split households
drop if age==.        # Drop individuals with missing age
drop if Code98==.     # Drop individuals not registered in 1998 survey
gen age=year-born_year_07  # Recalculate age from birth year
keep if restr_7==1    # Keep only non-marriage migration + non-migrants
```

### `numsplit==0` Logic
- `numsplit` identifies households that split from the original (new households formed between waves)
- The paper focuses on the ORIGINAL parental households only
- Split households are tracked but analyzed separately

### Sample Restriction Variables (restr_1 through restr_7)
| Variable | Description |
|----------|-------------|
| `restr_1` | All sample (no restriction) |
| `restr_2` | Permanent migrants + non-migrants |
| `restr_3` | Temporary migrants + non-migrants |
| `restr_4` | Permanent + temporary migrants |
| `restr_5` | Permanent migrants only |
| `restr_6` | Marriage migrants only |
| `restr_7` | All WITHOUT marriage (baseline used throughout) |

### Migration Types (`type_people` and `mig_why`)
- `type_people==1`: Permanent migration
- `type_people==2`: Temporary migration
- `type_people==3`: No migration (stayed home)
- `mig_why==3`: Married (marital migration reason)

---

## 3. Key Variable Construction

### Individual ID and Panel Setup
```r
# R equivalent
df <- df %>%
  mutate(
    id_person = as.numeric(paste0(reczd, numen, numsplit, pid07)),
    id_hh     = as.numeric(paste0(reczd, numen))
  )
```

### Dependent Variable: `leave`
- Binary indicator: person migrated for non-marital reasons in year t
- Source: Retrospective questions in 2007 follow-up survey
- Years covered: 1998–2007 (10 years; STATA labels say 1997-2008 = data entry years)

### Conflict Variables
```r
# Violence exposure (binary): any casualties in village-year
d_violence = (deathwounded > 0)

# Intensity: casualties per 100 people
deathwounded_100 = deathwounded / 100
```

### Household Victimization Indexes
```r
# Agricultural related losses
index_agri  = sk_vl_rob_land + sk_vl_rob_product

# Asset related losses
index_asset = sk_vl_rob_money + sk_vl_rob_goods + sk_vl_rob_destruction
```

### Province Time Trend
- STATA: `bys province year: gen province_trend=_n`
- This generates a running number (1, 2, 3, ...) within each province×year cell
- **Effect:** Controls for any province-specific temporal trends that might confound conflict-migration relationship
- **R equivalent:** Implement as `province[year]` interaction in fixest or add `province*year` interaction

---

## 4. Econometric Specification

### Individual-Level Model (Eq. 1)
$$Migration_{ijvt} = \alpha (ViolenceExposure)_{vt} + c_i + \sum_{k=1999}^{2008} \theta_k dT_k + x_v' \delta + u_{ijvt}$$

- $i$ = individual, $j$ = household, $v$ = village (sous-colline), $t$ = year
- $c_i$ = individual fixed effects (time-invariant characteristics)
- $dT_k$ = year fixed effects (common shocks)
- $x_v'$ = province-specific time trend
- $u_{ijvt}$ clustered at village level

### Household-Level Model (Eq. 2)
$$Migration_{jvt} = \alpha (Victimization)_{jvt} + c_j + \sum_{k=1999}^{2008} \theta_k dT_k + x_k' \delta + u_{jvt}$$

- $j$ = household, same structure but at HH level

### R Implementation (fixest)
```r
library(fixest)

# Individual FE - violence exposure
m1 <- feols(leave ~ d_violence | id_person + year + province[year],
            cluster = ~reczd, data = df_individual)

# Individual FE - violence intensity
m2 <- feols(leave ~ deathwounded_100 | id_person + year + province[year],
            cluster = ~reczd, data = df_individual)

# Household FE - asset losses
m3 <- feols(d_leave_hh ~ index_asset | id_hh + year + province[year],
            cluster = ~reczd, data = df_household)
```

**Note on province[year]:** In fixest, `province[year]` creates province-specific year FE (i.e., interacted FE), which is equivalent to the province time trend in STATA when province × year combinations are included.

---

## 5. PCA Construction

### Variables Used for PCA
- **Agricultural losses PCA (`pca_agri`):** `sk_vl_rob_land`, `sk_vl_rob_product`
- **Asset losses PCA (`pca_asset`):** `sk_vl_rob_money`, `sk_vl_rob_goods`, `sk_vl_rob_destruction`
- **All losses PCA (`pca_all`):** All 5 variables above

### R Implementation
```r
library(psych)

# Asset PCA
pca_asset <- principal(
  df_hh_year %>% select(sk_vl_rob_money, sk_vl_rob_goods, sk_vl_rob_destruction),
  nfactors = 1, rotate = "none"
)

df_hh_year$pca_asset <- pca_asset$scores[, 1]
```

### Household-Level PCA Variables
- `pca_agri_hh`, `pca_asset_hh`, `pca_all_hh` = household-level aggregates
- These come from `data/job/pca.dta` and are merged by (id_hh, year)

---

## 6. Missing Value Treatment

Shock variables default to 0 when missing (documented assumption):
```r
shock_vars <- c("sk_nt_rain", "sk_nt_drought", "sk_nt_disease",
                "sk_nt_crop_good", "sk_nt_crop_bad", "sk_nt_destru_rain",
                "sk_nt_erosion", "sk_vl_rob_money", "sk_vl_rob_product",
                "sk_vl_rob_goods", "sk_vl_rob_destruction", "sk_vl_rob_land",
                "sk_ec_input_access", "sk_ec_input_price", "sk_ec_nonmarket",
                "sk_ec_output_price", "sk_ec_sell_land", "sk_ec_sell_other",
                "sk_ec_rec_help")

df <- df %>%
  mutate(across(all_of(shock_vars), ~replace_na(., 0)))
```

---

## 7. Sub-Sample Analyses

### By Gender
- Women: `sex == "female"` (or equivalent code)
- Men: `sex == "male"`

### By Age
- Adults: `age >= 18` (`adult_18 == 1`)
- Children: `age < 18` (`adult_18 == 0`)

### By Poverty Status (1998)
- Rural poverty line: BIF 8,173.15 (1998)
- Updated 2007 poverty line: BIF 16,560.64
- Variables: `Poverty_status_98`, `Poverty_status_07`

### Marital Migration Sample
- Focus: Non-married women of marital age
- Age groups: 15–25, 15–35, 15–45 (individual level)
- Household level: Households with at least one non-married woman aged 15–45

---

## 8. Output Files Reference

| Output File | Analysis | Script |
|-------------|----------|--------|
| `Akresh_etal_20250708_individual.xlsx` | Tables 1–3, individual analysis | 03b |
| `Akresh_etal_20250708_household.xlsx` | Table 4, household analysis | 03a |
| `Akresh_etal_20250708_natural_shocks.xlsx` | Natural shocks interactions | 03c |
| `Akresh_etal_20251112_otherschocks.xlsx` | Other shocks analysis | 05 |
| `results_welfare_*.xlsx` | Welfare/poverty analysis | 04 |
| `table1_summary.csv` | Summary statistics | 03b |
| `table2_*.csv` | Regression tables | 03b |
| `table3_*.csv` | Household regression tables | 03a/03b |
| `table5_*.csv` | Migration by type/demographics | 04 |
