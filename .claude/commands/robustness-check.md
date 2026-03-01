Review the robustness checks for this paper and assess their status.

Standard robustness checks expected by JDE/World Development reviewers for this type of paper:

**1. Alternative conflict measures**
- [ ] Binary exposure (d_violence) ← DONE (Table 3, col 1)
- [ ] Continuous intensity (deathwounded_100) ← DONE (Table 3, col 2)
- [ ] Lagged conflict measure (lag_deathwounded_100) ← check in do-files
- [ ] Cumulative years of violence (v_s_violence) ← check in do-files

**2. Alternative sample restrictions**
- [ ] All households including split-offs (numsplit≠0)
- [ ] Including marriage migration (restr_1)
- [ ] Drop households with pre-1998 migrants

**3. Pre-trends / Parallel trends**
- [ ] Test for differential pre-trends across violence intensity groups
- [ ] Placebo: use future violence to predict current migration

**4. Identification / Endogeneity**
- [ ] IV: geographic instruments (altitude, rainfall) from inst.dta
- [ ] Attrition analysis (are attriters different from stayers?)

**5. Mechanisms**
- [ ] Mediation analysis: does victimization mediate village violence → migration?
- [ ] Natural shocks as placebo: do non-conflict shocks have same effect?

**6. Heterogeneity** ← Appendix A1-A3
- [ ] By age (adults vs children) ← DONE (Appendix A1)
- [ ] By gender (women vs men) ← DONE (Appendix A2)
- [ ] By poverty (poor vs non-poor) ← DONE (Appendix A3)

Steps:
1. Read `do-files/03b_Individual_Akresh-etal_July2025.do` to check which robustness checks are already coded
2. Read `do-files/03c_NaturalShocks_Akresh-etal_July2025.do` for placebo analysis
3. Read `manuscript/paper.qmd` to see which are already discussed in the paper
4. For each check: DONE | IN CODE NOT IN PAPER | NOT CODED | NOT POSSIBLE WITH DATA
5. Recommend top 3 priority robustness checks to add for reviewers

Respond in Spanish with a detailed status matrix.
