* Note: path_work should be defined before running this file
* Default path (commented out - define in calling file):

* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 

	* -- JC ----
    * global path_work "/Users/jcmunoz/Library/CloudStorage/OneDrive-UniversidadEAFIT/Projects/2025_Paper_Burundi/household_structure_burundi"
	
	* --- SL ---
	 global path_work "C:/Users/Stefany Lopez/OneDrive - Universidad EAFIT/VP/Burundi/nuevo"
	 global path_results "$path_work/out" 
	 cd "$path_work"
	
*--- Initial

	  clear all
	  set more off
	  set logtype smcl
	  set matsize 8000
	  pause on
	  set type double, permanently
	  set type float, permanently


 