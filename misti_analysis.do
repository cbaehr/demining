
global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

use "$data/misti_panel_formatted", clear


*egen district_id = group(m21)
egen province_id = group(m6)
egen district_id = group(m4 m6)
egen village_id = group(village m4 m6)

rename m7 survey_year

egen province_year = group(survey_year province_id)

gen ha_count = total_ha-num_cleared
gen all_cleared = (ha_count==0)

* su

* outreg2 using "$results/summary_statistics_misti.doc", replace sum(log)

********************************************************************************

local lhs = "q28n q29n"
local indexname = "index1"
local rhs = "ha_count"

local i = 0
foreach l in `lhs'{
	local i = `i' + 1
	gen temp_`i' = `l'
}

local nvars = `i'
forvalues i = 1/`nvars' {
	su temp_`i' if `rhs' == 0 `sampand'
	local mean = r(mean)
	local sdev = r(sd)
	gen temp_`i'_z = (temp_`i' - `mean')/`sdev'
}

correl temp_*z if `rhs' == 0 `sampand', covar
local covcount = r(N)
count if `rhs' == 0 `sampand'
local controlcount = r(N)
if `covcount'<`controlcount'/2 {
	display "Correlation matrix is estimated using <50% of the sample, due to missing values in some components of the index."
}

matrix cov = r(C)
matrix invcov = syminv(cov)
matrix unity = J(rowsof(invcov), 1, 1)
matrix weights = syminv(unity' * invcov * unity) * (unity' * invcov)

svmat weights, names(weighttemp1)
forvalues i = 1/`nvars' {
	gen temp2_`i' = temp_`i'_z * weighttemp1`i'[1] `samp'
}

egen `indexname' = rowmean( temp2_* )
summ `indexname' if (`rhs'==0)
replace `indexname' = `indexname'/r(sd)
label var `indexname' "`indexlabel'"

drop weighttemp1*
forvalues i=1/`nvars' {
	drop temp_`i' temp2_`i' temp_`i'_z
}



********************************************************************************

reghdfe q1n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", replace noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q26n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q26) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q27n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q27) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q30n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q30) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe q1n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", replace noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)






***

gen temp = 1
reghdfe q1n num_cleared, absorb(temp) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", replace noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", N, "Year*Prov. FEs", N)

reghdfe q1n num_cleared, absorb(survey_year) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", Y, "Village FEs", N, "Year*Prov. FEs", N)

reghdfe q1n num_cleared, absorb(survey_year village_id) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", Y, "Village FEs", Y, "Year*Prov. FEs", N)

reghdfe q1n num_cleared, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q1n any_cleared, absorb(temp) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", N, "Year*Prov. FEs", N)

reghdfe q1n any_cleared, absorb(survey_year) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", Y, "Village FEs", N, "Year*Prov. FEs", N)

reghdfe q1n any_cleared, absorb(survey_year village_id) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", Y, "Village FEs", Y, "Year*Prov. FEs", N)

reghdfe q1n any_cleared, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/main_models_misti.doc", append noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe q2an any_cleared, absorb(village_id province_year) cluster(district_id survey_year)
reghdfe q2an any_cleared, absorb(village_id province_year) cluster(district_id survey_year)











