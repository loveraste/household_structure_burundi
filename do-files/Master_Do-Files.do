* Note: path_work should be defined before running this file
* Default path (commented out - define in calling file):

* --- --- --- --- --- --- --- --- --- 
* Defining Working Paths  
* --- --- --- --- --- --- --- --- --- 
	clear all
	* -- JC ----
    global path_work "/Users/jcmunoz/Library/CloudStorage/OneDrive-UniversidadEAFIT/Projects/2025_Paper_Burundi/household_structure_burundi"
	cd $path_work
	global result_table "/path/where/tables/are/located" 
    


*--- Initial

  cap restore
  clear all
  *set mem 2g
  set more off
  set logtype smcl
  set matsize 8000
  pause on
  set type double, permanently
  set type float, permanently


 