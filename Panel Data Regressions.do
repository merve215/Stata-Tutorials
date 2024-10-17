clear all
cd "C:\Users\90505\Documents\StataTutorials\Ps5\WDI_CSV_2024_09_25"
import delimited "C:\Users\90505\Documents\StataTutorials\Ps5\WDI_CSV_2024_09_25\WDICSV.csv", varnames(1) 

keep if inlist(indicatorcode, "NY.GDP.PCAP.KD", ///  GDP per capita
                "IC.LGL.DURS", ///  Time required to enforce a contract (days)
                "SG.GEN.PARL.ZS", ///  Proportion of seats held by women in national parliaments (%)
                "TM.TAX.MRCH.WM.AR.ZS", ///  Tariff rate, applied, weighted mean, all products (%)
                "NY.GDP.TOTL.RT.ZS", ///  Total natural resources rents (% of GDP)
                "SE.SEC.ENRR", ///  School enrollment, secondary (% gross)
                "SH.ANM.ALLW.ZS", ///  Prevalence of anemia among women of reproductive age (% of women ages 15-49)
                "SE.SEC.CMPT.LO.ZS") ///  Lower secondary completion rate, total (% of relevant age group)

local start_year = 1960

* Loop through variables from v5 to v68
forval i = 5/68 {
local year = `=`i' + 1955'  // Calculate the corresponding year
    local newvar = "y" + "`year'"  // Create a new valid variable name
    rename v`i' `newvar'  // Rename the variable
}

*2. Data preparation

local regionstodrop ARB CSS CEB EAR EAS EAP TEA EMU ECS ECA TEC EUU FCS HPC HIC IBD IBT IDB IDX IDA LTE LCN LAC TLA LDC LMY LIC LMC MEA MNA TMN MIC NAC OED OSS PSS PST PRE SST SAS TSA SSF SSA TSS UMC WLD INX  foreach region in `regionstodrop' { drop if countrycode=="`region'"}


* Replace indicator codes with descriptive names

replace indicatorcode = "pcgdp" if indicatorcode == "NY.GDP.PCAP.KD"
replace indicatorcode = "contract_enforcement_days" if indicatorcode == "IC.LGL.DURS"                   // Time required to enforce a contract (days)
replace indicatorcode = "women_parliament_seats" if indicatorcode == "SG.GEN.PARL.ZS"                   // Proportion of seats held by women in national parliaments (%)
replace indicatorcode = "tariff_rate" if indicatorcode == "TM.TAX.MRCH.WM.AR.ZS"                        // Tariff rate, applied, weighted mean, all products (%)
replace indicatorcode = "natural_resources_rents" if indicatorcode == "NY.GDP.TOTL.RT.ZS"              // Total natural resources rents (% of GDP)
replace indicatorcode = "secondary_school_enrollment" if indicatorcode == "SE.SEC.ENRR"                 // School enrollment, secondary (% gross)
replace indicatorcode = "anemia_prevalence" if indicatorcode == "SH.ANM.ALLW.ZS"                        // Prevalence of anemia among women of reproductive age (% of women ages 15-49)
replace indicatorcode = "secondary_completion_rate" if indicatorcode == "SE.SEC.CMPT.LO.ZS"       // Lower secondary completion rate, total (% of relevant age group)



* Drop the unnecessary variables
drop countryname indicatorname 

* Reshape the dataset from wide to long format
reshape long y, i(countrycode indicatorcode) j(year)
rename y var_
reshape wide var_, i(countrycode year) j(indicatorcode) string

* Drop observations where the year is less than 1970
drop if year < 1970

* Encode the country_code variable
encode countrycode, gen(country_id)

* Create a new variable for the logarithm of GDP per capita
gen log_pcgdp = log(var_pcgdp)

*3. Exploratory Analysis
ssc install mdesc
mdesc
summarize
twoway line log_pcgdp year if countrycode == "TUR" , title("Log GDP of Türkiye Over Time") ///
   xlabel(1970(1)2023, angle(45) labsize(small)) ylabel(, angle(0)) ///
   legend(off)
   
   
*4. Regression Analysis

regress log_pcgdp var_contract_enforcement_days var_women_parliament_seats var_tariff_rate var_natural_resources_rents var_secondary_school_enrollment       var_anemia_prevalence var_secondary_completion_rate



regress log_pcgdp var_contract_enforcement_days var_women_parliament_seats var_tariff_rate var_natural_resources_rents var_secondary_school_enrollment       var_anemia_prevalence var_secondary_completion_rate i.country_id i.year

regress log_pcgdp var_contract_enforcement_days var_women_parliament_seats var_tariff_rate var_natural_resources_rents var_secondary_school_enrollment       var_anemia_prevalence var_secondary_completion_rate i.country_id i.year, cluster(country_id)

xtset country_id year
xtreg log_pcgdp var_contract_enforcement_days var_women_parliament_seats var_tariff_rate var_natural_resources_rents var_secondary_school_enrollment var_anemia_prevalence var_secondary_completion_rate, fe
