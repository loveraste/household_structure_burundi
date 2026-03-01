* ============================================================
* Master Do-File: Civil War and Household Structure - Burundi
* Akresh, Muñoz-Mora & Verwimp (2025)
* ============================================================
*
* HOW TO RUN:
*   Set your working directory to the project root, then:
*   do "do-files/Master_Do-Files.do"
*
*   OR define path_work before sourcing:
*   global path_work "/your/path/to/household_structure_burundi"
*   do "$path_work/do-files/Master_Do-Files.do"
*
* ============================================================

* --- --- --- --- --- --- --- --- ---
* Defining Working Paths
* --- --- --- --- --- --- --- --- ---

	* Use current Stata working directory if path_work not set
	if "$path_work" == "" {
		global path_work "`c(pwd)'"
	}
	global path_results "$path_work/out"
	cd "$path_work"

	* --- Author-specific paths (comment out all but yours) ---
	* JC (OneDrive):
	* global path_work "/Users/jcmunoz/Library/CloudStorage/OneDrive-UniversidadEAFIT/Projects/2025_Paper_Burundi/household_structure_burundi"
	* JC (GitHub):
	* global path_work "/Users/jcmunoz/Documents/GitHub/household_structure_burundi"
	* JM (macOS Local):
	* global path_work "/Users/jmunozm1/Documents/GitHub/household_structure_burundi"
	* SL (Windows):
	* global path_work "C:/Users/Stefany Lopez/OneDrive - Universidad EAFIT/VP/Burundi/nuevo"
	
*--- Initial

	  clear all
	  set more off
	  set logtype smcl
	  set matsize 8000
	  pause on
	  set type double, permanently
	  set type float, permanently


 