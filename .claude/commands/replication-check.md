Verify that the replication package for this paper is complete and ready for journal submission.

**Standard JDE/World Development replication requirements:**

Check each item against the current repository state:

**1. Code completeness**
- [ ] All do-files present to reproduce every table in the paper
- [ ] Master script exists that runs everything in order (`do-files/Master_Do-Files.do`)
- [ ] Scripts are numbered/ordered to reflect pipeline
- [ ] No hardcoded absolute paths (check `global path_work` in Master_Do-Files.do)
- [ ] Code runs from start to finish without manual intervention

**2. Data documentation**
- [ ] README describes all datasets and their sources
- [ ] Variable codebook or labels documented
- [ ] Data sources cited with links/DOIs where available
- [ ] Confidentiality restrictions documented if data cannot be shared

**3. Output verification**
- [ ] Every table in the paper corresponds to code that produces it
- [ ] Output files match paper results (use /review-tables for this)
- [ ] Figure code is present and reproducible

**4. Package structure**
- [ ] Clean directory structure (no unused files in main folders)
- [ ] `legacy/` clearly labeled as non-replication archive
- [ ] `.gitignore` appropriate (no sensitive data committed unintentionally)

**5. Documentation**
- [ ] README.md is complete and accurate
- [ ] STATA version and required packages documented
- [ ] Expected runtime documented (approximate)

Steps:
1. Read `README.md` and `do-files/Master_Do-Files.do`
2. List all tables in `manuscript/paper.qmd` (Tables 1-7, A1-A3, Figures 1-2)
3. Match each table to its generating do-file
4. Check for hardcoded paths in all do-files
5. Report: READY | NEEDS WORK | MISSING for each element

Flag critical issues that would cause a replication failure.
Respond in Spanish.
