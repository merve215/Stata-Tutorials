describe
browse
// Label variables for mother's and father's data
label variable wks_wrked_moth "Weeks worked (mother)"
label variable wks_wrked_fath "Weeks worked (father)"
label variable labinc_moth "Mother's labor income"
label variable selfempinc_moth "Mother's self-employment income"
label variable labinc_fath "Father's labor income"
label variable selfempinc_fath "Father's self-employment income"
label variable age_mother "Mother's age"
label variable hourswked_moth "Mother's hours worked"

rename ageqk ageof1stchild
replace agemar = . if agemar == 0

*b)Create indicators for sex of children to be used in the analysis.

tabulate kidcount

gen FirstChildMale = (sexk == 0)
gen SecondChildMale = (sex2nd == 0)
gen BothChildrenMale = (sexk == 0 & sex2nd == 0)
gen BothChildrenFemale = (sexk == 1 & sex2nd == 1)
gen SameSexChildren = (sexk == sex2nd)

gen MoreThanTwoChildren = (kidcount>2)
tabulate MoreThanTwoChildren

*c) Create indicators for race/ethnicity of the mother using the racem variable.

tabulate racem
gen BlackMother = (racem==2)
gen HispanicMother = (racem==12)
gen WhiteMother = (racem==1)
gen AnotherRaceMother = (1-(racem==2)-(racem==12)-(racem==1))
tabulate AnotherRaceMother

*d) Now define the samples in the analysis:

drop MainSample
gen MainSample = (age_mother >= 21 & age_mother <= 35) /// 
                & (kidcount >= 2 & kidcount! = .) ///
                & (ageq2nd > 4 & ageq2nd! = .) ///
                & (age1stbth_moth >= 15 & age1stbth_moth! = .) ///
                & (asex == 0 & aage == 0 & aqtrbrth == 0) ///
                & (asex2nd == 0 & aage2nd == 0 & aqtrbrth == 0)

drop MarriedSample				
gen MarriedSample = (MainSample==1) ///
					& (aged! = .) ///
					& (timesmar == 1) ///
					& (marital == 0) ///
					& (unMarriedbirth == 0) ///
					& (age1stbth_moth >= 15 & age1stbth_moth! = .) ///
					& (age1stbth_fath >= 15 & age1stbth_fath! = .)
					
*3. Summary Statistics

ssc install estout
gen ChildrenEverBorn = (kidcount! = .)

estpost summarize kidcount MoreThanTwoChildren FirstChildMale SecondChildMale BothChildrenMale BothChildrenFemale SameSexChildren age_mother age1stbth_moth workedind_moth wks_wrked_moth hourswked_moth if MainSample==1

estpost summarize kidcount MoreThanTwoChildren FirstChildMale SecondChildMale BothChildrenMale BothChildrenFemale SameSexChildren age_mother age1stbth_moth workedind_moth wks_wrked_moth hourswked_moth if MarriedSample==1

*4. Regression Analysis

*a) More income may give more incentives to make more children.

*b) Having same sex babies increase the incentive to have more than 2 children, whereas first and second boy decreases it. 

regress MoreThanTwoChildren SameSexChildren if 	MainSample==1
regress MoreThanTwoChildren FirstChildMale SecondChildMale SameSexChildren age_mother age1stbth_moth BlackMother HispanicMother AnotherRaceMother if MainSample==1

*c) 
// Step 1: OLS Regression (1)
regress workedind_moth MoreThanTwoChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1

regress wks_wrked_moth MoreThanTwoChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1

regress hourswked_moth MoreThanTwoChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1



// Step 2: IV Regression (2)
regress MoreThanTwoChildren SameSexChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1

ivregress 2sls workedind_moth (MoreThanTwoChildren =SameSexChildren) age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1

ivregress 2sls wks_wrked_moth (MoreThanTwoChildren =SameSexChildren) age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1

ivregress 2sls hourswked_moth (MoreThanTwoChildren =SameSexChildren) age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MainSample==1



// Step 1: OLS Regression (4)
regress workedind_moth MoreThanTwoChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1

regress wks_wrked_moth MoreThanTwoChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1

regress hourswked_moth MoreThanTwoChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1


// Step 2: IV Regression (5)

regress MoreThanTwoChildren SameSexChildren age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1

ivregress 2sls workedind_moth (MoreThanTwoChildren =SameSexChildren) age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1

ivregress 2sls wks_wrked_moth (MoreThanTwoChildren =SameSexChildren) age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1

ivregress 2sls hourswked_moth (MoreThanTwoChildren =SameSexChildren) age_mother age1stbth_moth FirstChildMale SecondChildMale  BlackMother HispanicMother AnotherRaceMother if MarriedSample==1


*d) According to OLS estimates, having a third child lowers the likelihood of working by roughly 17 percentage  points, reduces the number of weeks worked annually by approximately 8–9, reduces the number of hours worked per week by about 6-7, and lowers family income by roughly 13 percent. These findings hold true for  both the complete sample and married women. The married sample's OLS estimates of earnings effects are $3,166, whereas the full sample's estimates are $3,768.

*e) The sign of the coefficient, namely ln(Non-wife income) changes between OLS and IV, it may mean that the OLS results were significantly biased, likely due to strong endogeneity issues. Apart from the last variable, the others might be overstated by OLS because the IV coefficient is smaller than the OLS coefficient. IV estimates for women are significant but smaller than ordinary least-squares estimates. 

*f) F-statistic = 2707.00 Extremely strong instrument.

*g) No because we have one endogenous variable and one instrumental variable.  
