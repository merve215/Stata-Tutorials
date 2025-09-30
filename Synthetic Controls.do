clear all

set more off

global dirdata "C:\Users\90505\Documents\StataTutorials\Ps8\Data"

global dirfigs "C:\Users\90505\Documents\StataTutorials\Ps8\Figs"

global dirlogs "C:\Users\90505\Documents\StataTutorials\Ps8\Logs"

global dirprog "C:\Users\90505\Documents\StataTutorials\Ps8\Prog"

global dirrawdata "C:\Users\90505\Documents\StataTutorials\Ps8\Rawdata"

global dirtables "C:\Users\90505\Documents\StataTutorials\Ps8\Tables"

use "${dirrawdata}/PS2_data.dta"

*Intro

label list
desc /// cigsale is the main dependent variable, Treatment is legislation "Proposition 99" in the year 1988 (for California) and in waves from 1989-2000 for other states /// treatment in 1989 

*f) California 

*g) 38 states 

*h) Arizona introduced statedwide tobacco control between 1989 and 2000 and Alaska increased the tax by 50% or more over the 1989-2000 period 


ssc install synth 

* Question 2

* a) State is numeric; b) California is state no. 3

*c) Generating the "treatment" dummy variable

gen cali = .

replace cali = 1 if state == 3

replace cali = 0 if state != 3

br

*d) Running mean tests, by value of "california", before proposition 99 passed.

local var cigsale lnincome beer age15to24 retprice


*e) A table where the first column displays the mean characteritics of California, the second column the mean characteritics of all other states (unweighted by their population), and the last column reports the p-value of the differences in means.

estpost ttest `var' if year <1989, by(cali)
eststo

esttab est1 using "$dirtables/table71.tex", cells("mu_1(fmt(3)) mu_2(fmt(3)) p(fmt(3) star)") ///
collabel("Rest of the US" "California"  "p-Values") noobs replace nonumbers

eststo clear

*g) Evolution of the average cigarette sales for California, as well as for the average of all other states in the dataset. The treatment year as a dashed, grey vertical line.
preserve 
collapse (mean) cigsale ,by(year cali)

twoway (connected cigsale year if cali==0) (connected cigsale year if cali==1), ///
xline(1989, lcolor(gs10)) legend(order(2 "California" 1 "Rest of US") ring(0) pos(1)) ytitle("Average Cigarette Sales") xtitle("Year") ///
title("Evolution of Average" "Cigarette Sales") subtitle("1970-2000")

graph export "$dirfigs/graph72.png", replace
restore


*3) a)

tsset state year

*f)
synth cigsale beer retprice age15to24 lnincome(1980&1985) cigsale(1975) cigsale(1980) cigsale(1988), trunit(3) trperiod(1988) figure keep("$dirdata/main.dta", replace)
*h)
ereturn list

graph export "$dirfigs/fig73.png", replace

use "$dirdata/main.dta", clear

*i)
matrix rmspe = e(RMSPE)
svmat rmspe 
egen rmspemain = mean(rmspe)
drop rmspe1

*j)
gen diff = _Y_treated - _Y_synthetic

*k)
drop if _time == .

drop _W_Weight _Co_Number _Y_synthetic _Y_treated

save "$dirdata/main.dta", replace

use "${dirrawdata}/PS2_data.dta", clear

*4. a) Re-running the same analysis by leaving out Colorado 
tsset state year
drop if state == 4

synth cigsale beer retprice age15to24 lnincome(1980&1985) cigsale(1975) cigsale(1980) cigsale(1988), trunit(3) trperiod(1988) figure keep("$dirdata/ps4.dta", replace) 
ereturn list

use "$dirdata/ps4.dta", clear

matrix rmspe2 = e(RMSPE)
svmat rmspe2 
egen rmspemain2 = mean(rmspe2)
drop rmspe2

*2)
rename _Y_treated _Y_treated2
rename _Y_synthetic _Y_synthetic2

gen diff2 = _Y_treated2 - _Y_synthetic2

drop if _time == . 

rename _W_Weight _W_Weight2

drop _W_Weight2 _Co_Number _Y_treated2 _Y_synthetic2

merge 1:1 _time using "$dirdata/main.dta"

*3)
twoway (connected diff _time) (connected diff2 _time ), /// 
xline(1989, lcolor(gs10)) yline(0, lcolor(gs10)) ///
legend(order(2 "Without Colorado" 1 "Baseline") ring(0) pos(1)) ///
xtitle("Year") ytitle("Effects") title("Comparing SCM Specifications")

graph export "$dirfigs/fig74.png", replace

/// Placebos 

use "${dirrawdata}/PS2_data.dta", clear 

tsset state year 

synth cigsale beer retprice age15to24 lnincome(1980&1985) cigsale(1975) cigsale(1980) cigsale(1985), trunit(3) trperiod(1986) figure 

graph export "$dirfigs/fig75.png", replace

synth cigsale beer retprice age15to24 lnincome(1980&1985) cigsale(1975) cigsale(1980) cigsale(1988), trunit(4) trperiod(1988) figure 

graph export "$dirfigs/fig76.png", replace

