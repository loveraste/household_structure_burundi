# CLAUDE.md — Civil War and Household Structure: Burundi

Proyecto de investigación académica. Objetivo: publicar en JDE o World Development.
Comunicación en **español**. Outputs en **inglés** (paper académico).

---

## Proyecto

**Título:** Civil War and Household Structure: Evidence from Burundi
**Autores:** Richard Akresh (UIUC), Juan Carlos Muñoz-Mora (EAFIT), Philip Verwimp (ULB)
**Estado:** Borrador preliminar (diciembre 2025) → preparando para submission
**Journal objetivo:** Journal of Development Economics / World Development

---

## Estructura del Repositorio

```
household_structure_burundi/
├── code/              ← R: pipeline principal de análisis
│   ├── master.R       ← Entry point: source("code/master.R")
│   ├── 00_data_prep.R, 00b_gen_pca.R, 01_summary_tables.R
│   ├── 03a_household_analysis.R, 03b_individual_analysis.R
│   ├── 03c_marital_migration.R, 03d_return_migration.R
│   ├── 1a_appendix.R, figures.R
│   └── utils/         ← helpers.R, labels.R
├── www/               ← Sitio Quarto (technical supplement) → compila a docs/
│   ├── _quarto.yml    ← Config website (output-dir: ../docs)
│   ├── index.qmd      ← Overview + key findings
│   ├── data.qmd       ← Data, survey design, descriptive stats
│   ├── results.qmd    ← Tablas principales (3-7) + coef. plots
│   ├── robustness.qmd ← Robustness checks + heterogeneidad (A1-A3)
│   └── styles.css     ← Academic CSS theme
├── docs/              ← Output del website (GitHub Pages) — NO editar a mano
├── manuscript/        ← Paper en Quarto (.qmd → .docx) + references.bib + PDF base
├── data/              ← Datos (panel_individual.dta + auxiliares)
├── out/               ← Outputs del análisis R
├── legacy/            ← Archivos históricos: STATA do-files, misc (NO tocar)
├── .claude/           ← Config Claude: CLAUDE.md, MEMORY.md, commands/
└── README.md          ← Documentación pública
```

## Website (www/)

Para compilar y actualizar el sitio:
```bash
quarto render www/
# output va a docs/ → GitHub Pages
```

El sitio tiene 4 páginas: Overview, Data, Results, Robustness. Al editar el paper, también actualizar el website para mantener coherencia. El website usa `bibliography: ../manuscript/references.bib`.

---

## Pipeline de Análisis (R)

El pipeline corre desde `code/master.R` con `source("code/master.R")`:

| Script | Tabla/Output |
|--------|-------------|
| `code/00_data_prep.R` | Carga datos, genera IDs, variables base, muestra |
| `code/00b_gen_pca.R` | PCA shocks → `out/models_pca.rds` |
| `code/01_summary_tables.R` | Tabla 1 (summary stats), Tabla 2 (means test) |
| `code/03b_individual_analysis.R` | Tabla 3 (individual FE) |
| `code/03a_household_analysis.R` | Tabla 4 (household FE) |
| `code/03c_marital_migration.R` | Tablas 5-6 (marital migration) |
| `code/03d_return_migration.R` | Tabla 7 (return migration) |
| `code/1a_appendix.R` | Appendix Tables A1-A3 |
| `code/figures.R` | Figuras 1-2 |

**Funciones compartidas en `code/utils/`:**
- `helpers.R` — `run_ind_fe()`, `run_hh_fe()`, `make_reg_table()`, listas de variables
- `labels.R` — `var_labels` (named vector), `get_label()`, `apply_labels()`

**Referencia STATA** (archivado en `legacy/do-files/`):
- El análisis fue originalmente en STATA — los do-files están en legacy como referencia
- La equivalencia R clave: `xtreg ... fe cluster(reczd)` → `feols(... | id + year + province[year], cluster = ~reczd)`

---

## Modelo Econométrico Core

**Ecuación individual (Eq. 1):**
```r
feols(leave ~ d_violence | id_person + year + province[year], cluster = ~reczd, data = df)
```
- `id_person` = concat(reczd, numen, numsplit, pid07)
- `province[year]` = province-specific time trends (equivale a `bys province year: gen province_trend=_n` en STATA)
- Clustering: `reczd` (sous-colline = village)

**Ecuación household (Eq. 2):**
```r
feols(d_leave_hh ~ {var} | id_hh + year + province[year], cluster = ~reczd, data = df)
```
- `id_hh` = concat(reczd, numen)

**Muestra baseline:** `numsplit==0 & restr_7==1` (hogares parentales, sin migración matrimonial)

---

## Variables Clave

| Variable | Descripción |
|----------|-------------|
| `leave` | Individual migró (no-matrimonial) en año t |
| `d_leave_hh` | Al menos 1 miembro del HH migró en año t |
| `d_violence` | Village tuvo bajas (muertes/heridos) en año t |
| `deathwounded_100` | (Muertes + heridos) / 100 población |
| `sk_vl_rob_land` | Pérdida de tierra (sí=1) |
| `sk_vl_rob_product` | Robo de cosechas (sí=1) |
| `sk_vl_rob_money` | Robo de dinero (sí=1) |
| `sk_vl_rob_goods` | Robo/destrucción de bienes (sí=1) |
| `sk_vl_rob_destruction` | Destrucción de casa (sí=1) |
| `pca_agri` | PCA: pérdidas agrícolas |
| `pca_asset` | PCA: pérdidas de activos |
| `pca_all` | PCA: todas las pérdidas por conflicto |
| `restr_7` | Muestra baseline (sin migración matrimonial) |

---

## Resultados Principales (para referencia rápida)

| Tabla | Resultado |
|-------|-----------|
| T3 (individual) | Violencia: +3.1 pp migración; Bajas: +0.9 pp |
| T4 (household) | Pérdida activos: +4.1 pp migración HH |
| T5 (marital, ind) | Sin efecto de violencia village-level |
| T6 (marital, HH) | Pérdida activos: +1.5 pp migración matrimonial |
| T7 (return) | Conflicto reduce retorno en 14-34 pp |
| A1 | Adultos y niños ambos afectados |
| A2 | Efectos iguales por género |
| A3 | Efectos más fuertes en hogares pobres |

---

## Manuscript

- **Archivo principal:** `manuscript/paper.qmd` (Quarto → Word .docx)
- **Referencias:** `manuscript/references.bib` (31 entradas BibTeX)
- **Config:** `manuscript/_quarto.yml` (APA style, docx output)
- **Render:** `quarto render manuscript/paper.qmd`

Para editar el paper, siempre leer `manuscript/paper.qmd` primero.
Las tablas en el paper son dinámicas — los números inline deben coincidir con `out/*.xlsx`.

---

## Reglas de Trabajo

1. **No modificar datos** en `data/` sin instrucción explícita
2. **No modificar do-files del pipeline** (`00_*`, `03a/b/c/d/e_*`) sin verificar primero
3. **legacy/** es solo archivo histórico — no restaurar sin pedir
4. **Siempre citar** con formato APA author-year (usa las claves del .bib)
5. **Commits** solo cuando el usuario los solicite explícitamente
6. Para ecuaciones en el paper: LaTeX math inline `$...$` o display `$$...$$`

---

## Checklist de Submission (resumen)

Ver `docs/submission_checklist.md` para detalle completo.

Fase actual: **Revisión econométrica final → formateo → submission**

Pendientes principales:
- [ ] Verificar consistencia tablas paper vs. outputs STATA
- [ ] Robustness checks documentados
- [ ] Data availability statement
- [ ] Replication package limpio
- [ ] Cover letter
