# Submission Checklist: Civil War and Household Structure - Burundi

## Stage 1: Econometric Finalization

### Core Results Verification
- [ ] Replicate Table 1 (summary statistics) in R — verify N=34,800 obs, mean leave=0.045
- [ ] Replicate Table 2 (means test) — verify diff=-5.246*** between violence/non-violence villages
- [ ] Replicate Table 3 (individual FE) — verify d_violence coef=0.031** in baseline
- [ ] Replicate Table 4 (household FE) — verify asset index coef=0.041***
- [ ] Replicate Tables 5–7 (marital + return migration)
- [ ] Replicate Appendix Tables 1–3 (by age, gender, poverty)
- [ ] Replicate Figure 1 (poverty mobility transition chart)
- [ ] Replicate Figure 2 (marital migration over age groups)

### Robustness Checks (To Complete)
- [ ] Province-specific time trends included in all specs ✓
- [ ] Alternative clustering levels (commune level)
- [ ] Lagged conflict measures (`lag_deathwounded_100`)
- [ ] Instrumental variables (altitude, rainfall, temperature from `inst.dta`)
- [ ] Alternative age cutoffs (15/18 for adult classification)
- [ ] Balance tests on attrition (Verwimp & Bundervoet 2009 results)

### Additional Analyses (In Progress)
- [ ] Natural shocks interaction analysis (03c → 03e_natural_shocks.R)
- [ ] Other shocks analysis (03d/05 → 03f_other_shocks.R)
- [ ] Welfare/poverty escape analysis (03e/04 → 04_welfare.R)
- [ ] Diagnostic year variation (diagnostic_year_variation.do → to R)

---

## Stage 2: Paper Revision

### Structure & Content
- [ ] Abstract: Update word count for journal (JDE max ~150 words)
- [ ] Introduction: Verify all citations match references.bib
- [ ] Section 2: Update Burundi context with any post-2025 information if needed
- [ ] Section 3: Finalize sample description numbers
- [ ] Section 4: Review econometric equations formatting
- [ ] Section 5: Link discussion directly to regression tables
- [ ] Section 6: Strengthen policy implications
- [ ] Footnotes: Review all footnotes for accuracy

### Tables & Figures
- [ ] Table 1: Verify all statistics match replicated R output
- [ ] Table 2: Verify means test statistics
- [ ] Tables 3–7: Match STATA output exactly in R
- [ ] Figure 1: Recreation in ggplot2 (poverty transition bars)
- [ ] Figure 2: Recreation in ggplot2 (coefficient plot, age groups)
- [ ] All tables: Times New Roman, proper spacing, stars at 10/5/1%
- [ ] All tables: Notes/footnotes with data source citation

### References
- [ ] All 28 citations in references.bib verified for accuracy
- [ ] No missing references (check all in-text citations)
- [ ] Journal format: Check JDE/WD author-year APA style
- [ ] Working papers: Verify if published versions exist

---

## Stage 3: Pre-Submission

### JDE/World Development Requirements
- [ ] Word limit: JDE max ~15,000 words (including tables/figs); WD max ~10,000
- [ ] Abstract: 150 words max
- [ ] Keywords: 4–6 keywords
- [ ] JEL codes: D13, J12, O12 ✓
- [ ] Line/page numbers: Add for review
- [ ] Double blind: Remove author names from main text and acknowledgments
- [ ] Conflict of interest statement
- [ ] Data availability statement (see template below)

### Cover Letter (Template)
```
Dear Editor(s),

We are pleased to submit our manuscript "Civil War and Household Structure:
Evidence from Burundi" for consideration in the [Journal Name].

This paper analyzes whether civil war impacts household structure via individual
migration using a unique longitudinal panel dataset from Burundi (1998–2007).
Our three main contributions are: [...]

The paper has not been previously published and is not under consideration
elsewhere. All authors have approved the submission.

We hope our work will be of interest to your readers.

Sincerely,
[Corresponding Author]
```

### Data Availability Statement (Template)
```
The data that support the findings of this study were collected through the
2007 Burundi Priority Panel Survey. The anonymized data are available from
[data repository] upon reasonable request to the corresponding author.
Replication code is available at [GitHub/OSF link].
```

### Replication Package Checklist
- [ ] `code/master.R` runs end-to-end and produces all tables/figures
- [ ] All required R packages documented in `code/README.md`
- [ ] Data README explaining variable sources and construction
- [ ] Correspondence: STATA output ↔ R output verified
- [ ] README for replication package (separate from project README)
- [ ] Upload to OSF or GitHub (public repo)

---

## Stage 4: Post-Submission

### Revision Process
- [ ] Track submission date and referee turnaround
- [ ] Response to referees template ready
- [ ] Major vs. minor revision protocol agreed upon by co-authors

### Response to Reviewers Template
```
Dear Editor(s) and Reviewers,

We thank the editor and the three anonymous referees for their careful
reading and constructive comments. We have thoroughly revised the manuscript
in response to all comments. Below, we provide a point-by-point response
to each comment, with page references to the revised manuscript.

[Referee 1]
Comment 1: [Quote comment]
Response: [Detailed response with reference to changes]

[...]
```

---

## Key Contacts
- Corresponding author: Richard Akresh (akresh@illinois.edu)
- Co-author: Juan Carlos Muñoz-Mora (jmunozm1@eafit.edu.co)
- Co-author: Philip Verwimp (philip.verwimp@ulb.be)
