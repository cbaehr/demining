
global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

use "$data/misti_panel_formatted", clear


*egen district_id = group(m21)
egen province_id = group(m6)
egen district_id = group(m4 m6)
egen village_id = group(village m4 m6)

rename m7 survey_year

egen province_year = group(survey_year province_id)

gen all_cleared = (ha_count==0)

* su

* outreg2 using "$results/summary_statistics_misti.doc", replace sum(log)

********************************************************************************

reghdfe q1n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", replace noni nocons ctitle(Q1) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q26n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q26) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q27n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q27) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q28_q29_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q28-29_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q30n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/general_attitudes_misti.doc", append noni nocons ctitle(Q30) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe q2a_q2b_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/security_misti.doc", replace noni nocons ctitle(Q2a-Q2b_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe q3b_q4d_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/mktaccess_misti.doc", replace noni nocons ctitle(Q3b-Q4d_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q31n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/mktaccess_misti.doc", append noni nocons ctitle(Q31) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe w1_q36en ha_count, absorb(village_id) cluster(district_id)
outreg2 using "$results/mktaccess_misti.doc", append noni nocons ctitle(Q36e) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", N)

***

reghdfe q11a_q11d_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/gvmttrust_misti.doc", replace noni nocons ctitle(Q11a-Q11d_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q11a_q11d_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/gvmttrust_misti.doc", append noni nocons ctitle(Q11a-Q11d_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q14b_q14f_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/gvmttrust_misti.doc", append noni nocons ctitle(Q14a-Q14f_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q15n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/gvmttrust_misti.doc", append noni nocons ctitle(Q18) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q16a_q16i_index ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/gvmttrust_misti.doc", append noni nocons ctitle(Q16a-Q16i_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe q36a_q36f_index ha_count, absorb(village_id) cluster(district_id)
outreg2 using "$results/accesstoservices_misti.doc", replace noni nocons ctitle(Q36a-Q36f_index) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", N)

***

reghdfe q32n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/economy_misti.doc", replace noni nocons ctitle(Q32) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

reghdfe q33n ha_count, absorb(village_id province_year) cluster(district_id survey_year)
outreg2 using "$results/economy_misti.doc", append noni nocons ctitle(Q33) addtext("Year FEs", N, "Village FEs", Y, "Year*Prov. FEs", Y)

cd
cd "$results"
shell rm *.txt
























