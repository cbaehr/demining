
global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

use "$data/misti_panel_formatted", clear


*egen district_id = group(m21)
egen province_id = group(m6)
egen district_id = group(m4 m6)
egen village_id = group(village m4 m6)

rename m7 survey_year

egen province_year = group(survey_year province_id)

su



********************************************************************************

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











