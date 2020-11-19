
global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

use "$data/misti_panel_formatted", clear


*egen district_id = group(m21)
egen province_id = group(m6)
egen district_id = group(m4 m6)
egen village_id = group(village m4 m6)

rename m7 survey_year

egen wave = group(m2)
egen province_wave = group(wave province_id)
egen province_year = group(survey_year province_id)

gen all_cleared = (ha_count==0)

drop if ha_count2012==0

gen absorb_temp = 1

* su

outreg2 using "$results/summary_statistics_misti.doc", replace sum(log)
rm "$results/summary_statistics_misti.txt"

********************************************************************************

reghdfe q1n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", replace noni nocons addtext("Wave FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q1n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q1n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q1n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", append noni nocons addtext("Wave FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q1.txt"

***


reghdfe q26n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", replace noni nocons addtext("Wave FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q26n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q26n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q26n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", append noni nocons addtext("Wave FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q26.txt"

***


reghdfe q27n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", replace noni nocons addtext("Wave FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q27n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q27n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q27n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", append noni nocons addtext("Wave FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q27.txt"

***

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q28_q29_index.txt"

***

reghdfe q30n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q30n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q30n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q30n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q30.txt"

***

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q2a_q2b_index.txt"

***

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q3b_q4d_index.txt"

***

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q3b_q4d_index.txt"

***

reghdfe q31n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q31n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q31n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q31n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q31n.txt"

***

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q11a_q11d_index.txt"

***

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q14b_q14f_index.txt"

***

reghdfe q15n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q15n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q15n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q15n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q15.txt"

***

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q16a_q16i_index.txt"

***

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q16a_q16i_index.txt"

***

reghdfe q32n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q32n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q32n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q32n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q32.txt"

***

reghdfe q33n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q33n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q33n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q33n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q33.txt"
























