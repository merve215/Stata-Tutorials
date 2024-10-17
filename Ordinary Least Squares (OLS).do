
use "C:\Users\90505\Downloads\Tutorial2_data.dta"
describe
twoway (scatter wphy edlevel)

*2)	Simple regression of two continuous variables

reg wphy edlevel, robust
predict predicted_wage

 twoway (scatter wphy edlevel) ///
       (line predicted_wage edlevel), ///
       title("Scatterplot of Wage with Regression Line") ///
       xlabel(0(2)5) ///
       xtitle("Years of Education") ///
       ytitle("Real Hourly Wage")

 *Predict the residuals  
 reg wphy edlevel, robust

predict residuals, residuals
	   
	 *Plot a histogram
histogram residuals, normal


*3) Regression with dummies

regress wphy urban

regress wphy race

regress wphy african colored indian  white

label define race_lbl 1 "African" 2 "Colored" 3 "Indian" 4 "White"
label values race race_lbl
tabulate race

regress wphy i.race
regress wphy ib4.race


*4) Non-linearities

regress logwphy educ
predict new_residuals, residuals
histogram new_residuals, bin(30) normal


gen log_educ = log(educ + 1)
regress logwphy log_educ
predict new_residuals1, residuals
histogram new_residuals1, bin(30) normal

*5)Non-linearities in variables: quadratic transformation

gen educ_squared= edlevel^2
reg logwphy educ educ_square

regress logwphy c.educ##c.educ_square

* 6) Non-linearities in variables: interaction terms
regress logwphy c.educ##i.urban
