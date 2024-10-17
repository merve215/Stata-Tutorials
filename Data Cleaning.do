

*1.	Import different data types*

cd "C:\Users\90505\Documents\Basics_Part1"

describe

import excel "C:\Users\90505\Documents\Basics_Part1\DatasetB.xlsx", sheet("Data") clear

import delimited "C:\Users\90505\Documents\Basics_Part1\DatasetB.txt", clear


*Combine and Save Data*


use "C:\Users\90505\Documents\Basics_Part1\patient_hospital1.dta", clear
describe
*To add lines to your code:
append using "C:\Users\90505\Documents\Basics_Part1\patient_hospital2.dta"  
bysort docid: egen patient_count = count(docid)

*Codebook to see the values in the dataset more detail
*Summarize to find min and max
egen max_patients = max(patient_count)
list docid patient_count if patient_count == max_patients

egen min_patients = min(patient_count)
list docid patient_count if patient_count == min_patients

*Duplicates drop
*duplicates drop
*to get rid of the one copy. 

*If you wanna merge two datasets you need to have a common identifier.
merge m:1 docid using "C:\Users\90505\Documents\Basics_Part1\doctor.dta"
describe
drop if _merge != 3
save "C:\Users\90505\Documents\Basics_Part1\combined_dataset.dta"
use "C:\Users\90505\Documents\Basics_Part1\combined_dataset.dta", clear
edit
browse
describe 
summarize (medicaid)
duplicates report
duplicates drop
count
duplicates report hospid
egen unique_hospids = tag(hospid)
count if unique_hospids == 1
tabulate hospid

*Converting missing codes to numeric variables (dots)

summarize *
mvdecode _all, mv(-99=.)
mvdecode _all, mv(999=.)
mvdecode _all, mv(9=.)
mvdecode _all, mv(-9=.)

replace lungcapacity = . if lungcapacity < 0 | lungcapacity > 100
replace age = . if age > 100
replace co2 = . if co2 < 0

*Handling missing string data.

describe
tabulate hospital, missing
tabulate docid, missing
tabulate familyhx, missing
tabulate smokinghx, missing
tabulate sex, missing
tabulate cancerstage, missing
tabulate wbc, missing
tabulate school, missing

replace familyhx = "" if familyhx == "-99"
replace smokinghx = "" if smokinghx == "-99"
replace sex = "" if sex == "12.2"
replace wbc = "" if wbc == "not assessed"

*Managing numeric variables

*a)
rename age Age
label variable Age "Age of the patient"
*b)
rename (experience school lawsuits medicaid) (doc_experience doc_school doc_lawsuits doc_medicaid)
*c)
generate average = .
replace average = (test1 + test2) / 2 if !missing(test1) & !missing(test2)
replace average = test1 if missing(test2) & !missing(test1)
replace average = test2 if missing(test1) & !missing(test2)
*d) Dummy 
generate above50 = (Age >= 50)

*e)
label define age_labels 0 "Aged 0-49" 1 "Aged 50+"
label values above50 age_labels
tabulate above50

*f)
egen avg_age_per_doctor = mean(Age), by(docid)


*Managing string variables

tabulate hospital
replace hospital = strtrim(hospital)
tabulate hospital
tabulate docid
gen doc_id = substr(docid, 3, 3)
list docid doc_id in 1/10
generate hosp_doc = string(hospid) + "-" + doc_id


*Change data type – From string to numeric, and the other way around

tabulate cancerstage
encode cancerstage, gen(stage)
tabulate stage
tabulate stage, nolabel

describe wbc
list wbc if missing(real(wbc)) in 1/20
destring wbc, replace ignore(not assessed)
describe wbc

* Reshape a dataset, macrodatasets such as IMF dataset

import delimited "DatasetB.txt", clear
describe
browse

reshape wide numberofnewlimitedliability, i(country) j(year)
browse


*Robustness check do file data I will download simple version of data after the cleaning 
*Narrative: images, tables easy html code to upload the homework online