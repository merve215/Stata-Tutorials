

clear all
set more off

* Set up global macros for paths to input and output folders
global Data "C:\Users\90505\Documents\StataTutorials\Ps3\Data"
global Figs "C:\Users\90505\Documents\StataTutorials\Ps3\Figs"
global Logs "C:\Users\90505\Documents\StataTutorials\Ps3\Logs"
global Prog "C:\Users\90505\Documents\StataTutorials\Ps3\Prog"
global Rawdata "C:\Users\90505\Documents\StataTutorials\Ps3\Rawdata"
global Tables "C:\Users\90505\Documents\StataTutorials\Ps3\Tables"


*3. Open the database
global Rawdata "C:\Users\90505\Documents\StataTutorials\Ps3\Rawdata"
tabulate type

*Experimental Winners are the treatment group that is randomly assigned; wheras, control group, as the name suggests, is the control group that will not receive the intervention. Moreover, non-experimental winners represent the individuals who are part of a non-random selection process, but got the treatment throughout another channel. Last but not least, RD group stands for a Regression Discontinuity (RD) group, where participants are assigned to treatment based on a specific criterion or threshold, not random assignment.

tabulate type exp_sample

*If exp sample is coded as 1 (yes, part of the experimental sample) and 0 (no, not part of the experimental sample). Thus, we understand the first two categories received the intervention through randomization. On the other hand, the last two received the treatment through another channel than randomization. 

tabulate type AssignT

*AssignT stands for randomly assigned to treatment.

tabulate AssignT ActualT

* AssignT ActualT. No, there is no perfect compliance. (e.g. imperfect compliance)

tabulate exist

*Exist represents the existance of an application for an existing business or not.

tabulate m_date1 
tabulate s_date1 
tabulate t_resp_10

*The prefix indicates the periods in chronological order with some exceptions. 


*4. Check for Random Assignment at Baseline in the RCT

*Subsample Creation
gen sample = 1 if exist ==0 & (type ==1| type==2 )

*Woman
tabulate Gender
gen Woman = .
replace Woman = 1 if Gender == "Female"
replace Woman = 0 if Gender == "Male"
tabulate Woman

*Married
tabulate Marital
gen Married = .                    
replace Married = 1 if Marital == 1  
replace Married = 0 if Marital !=1      
tabulate Married

*OwnComputer
tabulate HasComputer
gen OwnComputer= .
replace OwnComputer = 1 if HasComputer == 1 | HasComputer == 2 | HasComputer == 3 | ///
                         HasComputer == 4 | HasComputer == 5 | HasComputer == 6 | ///
                         HasComputer == 7 | HasComputer == 8 | HasComputer == 13
replace OwnComputer = 0 if HasComputer == 0
tabulate OwnComputer


*1)

ssc install estout


estpost ttest Woman if sample==1, by (AssignT)
estpost ttest Married if sample==1, by (AssignT)
estpost ttest Age if sample==1, by (AssignT)
estpost ttest HS if sample==1, by (AssignT)
estpost ttest Univ if sample==1, by (AssignT)
estpost ttest PostGrad if sample==1, by (AssignT)
estpost ttest LivedWorkedAbroad if sample==1, by (AssignT)
estpost ttest HasInternet if sample==1, by(AssignT )
estpost ttest OwnComputer if sample==1, by(AssignT )
estpost ttest CropAnimal if sample==1, by(AssignT )
estpost ttest Manu if sample==1, by(AssignT )
estpost ttest Trade if sample==1, by(AssignT )
estpost ttest IT if sample==1, by(AssignT )
estpost ttest OtherSector if sample==1, by(AssignT )
estpost ttest FirstRoundScore if sample==1, by(AssignT )
estpost ttest TotalBPScore if sample==1, by(AssignT)

*2) 
 
estpost ttest Woman Married Age HS Univ PostGrad LivedWorkedAbroad HasInternet OwnComputer CropAnimal Manu Trade IT OtherSector FirstRoundScore TotalBPScore if sample==1, by(AssignT )

esttab using "$Tables\Table_1, replace csv"

*4)
estpost ttest Woman if exist==0 & (type==1 | type==3), by(type)
estpost ttest Married if exist==0 & (type==1 | type==3), by(type)
estpost ttest Age if exist==0 & (type==1 | type==3), by(type)
estpost ttest HS if exist==0 & (type==1 | type==3), by(type)
estpost ttest Univ if exist==0 & (type==1 | type==3), by(type)
estpost ttest PostGrad if exist==0 & (type==1 | type==3), by(type)
estpost ttest LivedWorkedAbroad if exist==0 & (type==1 | type==3), by(type) 
estpost ttest HasInternet if exist==0 & (type==1 | type==3), by(type)
estpost ttest OwnComputer if exist==0 & (type==1 | type==3), by(type)
estpost ttest CropAnimal if exist==0 & (type==1 | type==3), by(type)
estpost ttest Manu if exist==0 & (type==1 | type==3), by(type)
estpost ttest Trade if exist==0 & (type==1 | type==3), by(type)
estpost ttest IT if exist==0 & (type==0 | type==3), by(type)
estpost ttest OtherSector if exist==0 & (type==1 | type==3), by(type) 
estpost ttest FirstRoundScore if exist==0 & (type==1 | type==3), by(type) 
estpost ttest TotalBPScore if exist==0 & (type==1 | type==3), by(type)
Or all in one line:
estpost ttest Woman Married Age HS Univ PostGrad LivedWorkedAbroad HasInternet OwnComputer CropAnimal Manu Trade IT OtherSector FirstRoundScore TotalBPScore, by(type), if exist == 0 & (type == 1 | type==3)

// When the experimental winners are compared with the non-experimental winners, it can be concluded that there are no significant differences. On the other hand, there is a difference in their business plan score, since non-experimental winners were chosen based on their business plans' quality. The strict conclusion about financing RCTs can be made after the outcomes are obtained.

* 5. Impacts on Business Start-up and Survival 

reg t_operatefirm type, robust, if exist == 0 & (type == 1 | type==2)
esttab, compress
eststo clear
egen Strata = group(Woman Region exist)
reg t_operatefirm AssignT i.Strata if sample == 1, robust

*6
reg t_operatefirm AssignT Woman c.AssignT##c.Woman if sample == 1, robust
reg t_operatefirm AssignT TotalBPScore  c.AssignT##c.TotalBPScore if sample == 1, robust


*7

egen InnovIndex = rowmean(t_innovate*)
gen OwnEmp = .
replace OwnEmp = 1 if t_employed == 1
replace OwnEmp = 0 if t_employed == 0
gen TotEmp10 = .
replace TotEmp10 = 1 if t_totalemp1 >= 10
replace TotEmp10 = 0 if t_totalemp1 < 10
replace TotEmp10 = . if t_totalemp1 == .
gen TotEmp25 = .
replace TotEmp25 = 1 if t_totalemp1 >= 25
replace TotEmp25 = 0 if t_totalemp1 < 25
replace TotEmp25 = . if t_totalemp1 == .
gen winner = .
replace winner = 1 if type == 1
replace winner = 1 if type == 3
replace winner = 0 if type == 2
local varlist1 InnovIndex OwnEmp TotEmp10 TotEmp25
foreach var of local varlist1 {
quietly: reg `var' winner i.Strata if (exist == 0) & (type == 1 |
type == 2) , vce(robust) eststo est `var'
}
esttab est *, compress se drop(*Strata cons)