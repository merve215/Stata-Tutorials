
clear all
set more off
use "C:\Users\90505\Documents\StataTutorials\Ps7\dataset_field.dta" 
svyset
describe

* Observations:         2,499                  
* Variables:            70  


*2. Data preparation

*a) 
gen title_x_enter = hastitle*enter 
gen squat_x_enter = squat*enter
*b) 	
tabulate region, gen(region_)

*c) FE Interactions

forval k = 1/8 { 
	egen mean_region`k' = mean(region_`k')
	gen weight_region`k' = region_`k' - mean_region`k'
	gen wgt_squat`k' = squat*weight_region`k'
	gen wgt_entry`k' = enter*weight_region`k'
}


*3. Exploratory Analysis

*a) If we do so, we might face with a bias, due to several resons, such as selection bias, outcome differences(pre-existing differences), and endogeneity (reverse causality and confounding variables). 


*b)
tabstat sexhd agehd avgage members if squat == 1, statistics(mean) by(enter)
tabstat sexhd agehd avgage members if squat == 0, statistics(mean) by(enter)


label define enter 0 "No Program" 1 "Program" 

estpost tabstat sexhd agehd avgage members if squat == 1 & enter == 1,statistics(mean) listwise columns(statistics) 

eststo table1

estpost tabstat sexhd agehd avgage members if squat == 1 & enter == 0,statistics(mean) listwise columns(statistics)  

eststo table2

estpost ttest sexhd agehd avgage members if squat == 1, by(enter)

eststo table3

estpost tabstat sexhd agehd avgage members if hastitle == 1 & enter == 1,statistics(mean) listwise columns(statistics) 

eststo table4

estpost tabstat sexhd agehd avgage members if hastitle == 1 & enter == 0,statistics(mean) listwise columns(statistics)  

eststo table5

estpost ttest sexhd agehd avgage members if hastitle == 1, by(enter)

eststo table6

esttab table* , main(mean) nostar unstack label mtitles("Program" "No Program" "delta t" "Program" "No Program" "delta t") nonumbers

eststo clear


*c) The differences in time-invariant characteristics between squatters and non-squatters in program and non-program areas underscore the complexities of socio-economic dynamics. Addressing these differences requires targeted interventions that consider the unique challenges faced by squatters and the resources available in program areas.


*d)kdensity
* Set up the graph with 4 KDE lines

twoway (kdensity totwkhrs if squat == 1 & enter == 0, range(0 350)) (kdensity totwkhrs if squat == 1 & enter == 1, range(0  350)) (kdensity totwkhrs if hastitle == 1 & enter == 0, range(0 350)) (kdensity totwkhrs if hastitle == 1 & enter == 1, range(0 350)), xtitle("Total hours worked per week") ytitle("") legend(order (4 "Program & Has title" 3 "No program & has title" 2 "Program & Squatter" 1 "No program & squatter") ring(0)) 
	   
*4. Regression Analysis

*(a) Replicate Table 4 (cols 1-7) - Total Weekly Hours

/// Columns 1 - 3

gen walk_x_distance1 = walk1 * tmtran1
gen walk_x_distance2 = walk2 * tmtran2
gen walk_x_distance3 = walk6 * tmtran3
gen walk_x_distance4 = walk8 * tmtran4
gen walk_x_distance5 = walk10 * tmtran5


eststo: quietly svyreg totwkhrs ///
squat enter squat_x_enter ///
enteryr agehd collhd elemhd hshd literhd sexhd ///
unihd reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
plumbing shock hadporg wrkage members seniors ///
segschlprog segsocprog segfamplan invader ///
inherit enteryr lotsize tenure pctmale

esttab, keep(squat squat_x_enter)

eststo clear

eststo: quietly svyreg totwkhrs ///
squat enter squat_x_enter enteryr enteryrsquat ///
agehd collhd elemhd hshd literhd sexhd unihd /// 
reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
plumbing shock hadporg wrkage members seniors segschlprog ///
segsocprog segfamplan invader inherit enteryr lotsize tenure pctmale

esttab, keep(squat squat_x_enter enteryrsquat)

eststo clear


eststo: quietly svyreg totwkhrs squat enter squat_x_enter enteryr enteryrsquat ///
tenentsquat tenuresquat wrkageentsquat wrkageentsquat2 ///
wrkagesquat wrkagesquat2 wrkageent wrkageent2 ///
agehd age collhd elemhd hshd literhd sexhd unihd reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
plumbing shock hadporg wrkage wrkage2 members seniors ///
segschlprog segsocprog segfamplan invader inherit enteryr lotsize tenure pctmale

esttab, keep(squat squat_x_enter enteryrsquat tenentsquat wrkageentsquat wrkageentsquat2)

eststo clear

// Column 4 5

eststo: quietly svyreg totwkhrs squat enter squat_x_enter enteryr lotsize invader tenure wrkage inherit ///
region* wgt_entry* wgt_squat* 

esttab , keep(squat squat_x_enter )

eststo clear

eststo: quietly reg totwkhrs squat squat_x_enter enteryr enteryrsquat ///
lotsize invader tenure wrkage inherit ///
region* wgt_entry* wgt_squat* 

esttab, keep(squat squat_x_enter enteryrsquat)

eststo clear

// Column 6 7 

eststo: quietly svyreg hw squat enter squat_x_enter enteryr lotsize invader tenure wrkage inherit ///
region* wgt_entry* wgt_squat* 

esttab , keep(squat squat_x_enter )

eststo clear

eststo: quietly reg hw squat squat_x_enter enteryr enteryrsquat ///
lotsize invader tenure wrkage inherit ///
region* wgt_entry* wgt_squat* 

esttab, keep(squat squat_x_enter enteryrsquat)

eststo clear


*(b) Run the regression for total weekly work hours with interaction term
/// First Stage Column 1

eststo: quietly svyreg hastitle squat enter squat_x_enter ///
enteryr agehd collhd elemhd hshd literhd sexhd ///
unihd reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
plumbing shock hadporg wrkage members seniors ///
segschlprog segsocprog segfamplan invader ///
inherit enteryr lotsize tenure pctmale

predict hat_title

esttab, keep(squat squat_x_enter) r2(2) b(2) se(2)

eststo clear

/// Second Stage Column 2 

eststo: quietly svyreg totwkhrs hat_title squat ///
enteryr agehd collhd elemhd hshd literhd sexhd ///
unihd reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
plumbing shock hadporg wrkage members seniors ///
segschlprog segsocprog segfamplan invader ///
inherit enteryr lotsize tenure pctmale if hat_title !=.

esttab, keep(squat hat_title) r2(2) b(2) se(2)

eststo clear

/// First Stage Column 3 

eststo: quietly svyreg chtensec squat enter squat_x_enter ///
enteryr agehd collhd elemhd hshd literhd sexhd ///
unihd reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
plumbing shock hadporg wrkage members seniors ///
segschlprog segsocprog segfamplan invader ///
inherit enteryr lotsize tenure pctmale

predict hat_chtensec

esttab, keep(squat squat_x_enter) r2(2) b(2) se(2)

eststo clear

/// Second Stage Column 4

eststo: quietly svyreg totwkhrs hat_chtensec squat ///
enteryr agehd collhd elemhd hshd literhd sexhd ///
unihd reg* weight_reg* wgt_squat* wgt_entry* ///
tmtran1 tmtran2 tmtran3 tmtran4 tmtran5 ///
walk1 walk2 walk6 walk8 walk10 ///
walk_x_distance1 walk_x_distance2 walk_x_distance3 walk_x_distance4 walk_x_distance5  ///
s1 s2 s2y1 s2y2 s2y3 s2y4 s2y5 s3 s4 s5 ///
plumbing shock hadporg wrkage members seniors ///
segschlprog segsocprog segfamplan invader ///
inherit enteryr lotsize tenure pctmale if chtensec !=.

esttab, keep(squat hat_chtensec) r2(2) b(2) se(2)

eststo clear
