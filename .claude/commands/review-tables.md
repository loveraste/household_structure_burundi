Review the regression tables from this paper. Compare what the paper manuscript says against what is in the STATA output files.

Steps:
1. Read `manuscript/paper.qmd` — extract ALL numerical results mentioned inline and in tables (coefficients, standard errors, stars, N observations, means)
2. Read the relevant STATA output Excel files from `out/`:
   - `out/Akresh_etal_20250708_individual.xlsx` → Tables 1, 2, 3
   - `out/Akresh_etal_20250708_household.xlsx` → Table 4
3. For each table and each key coefficient in the paper, verify:
   - Coefficient value matches (to 3 decimal places)
   - Standard error matches
   - Significance stars match
   - N observations matches
   - Dep. var. mean matches (if reported)
4. Report discrepancies in a clear table format: Table | Column | Variable | Paper says | STATA output says | Match?
5. Flag any coefficients in the paper that seem inconsistent (sign different from expectation, unusually large/small SE)

Focus especially on:
- Table 3 col (1): d_violence coefficient on leave
- Table 4 col (1): d_violence coefficient on d_leave_hh
- Table 7: return migration coefficients (sign should be NEGATIVE)
- All asterisks/significance levels

Report findings in Spanish, present the comparison table in English.
