local user = "r"

if "`user'" == "c" {
	global data "/Users/christianbaehr/Box Sync/demining/inputData/"
	global mistidata "${data}/misti/"
	global results "/Users/christianbaehr/Box Sync/demining/Results"
}
if "`user'" == "r" {
	global data "C:\Users\rcsayers\Box\demining\inputData\"
	global mistidata "${data}misti\"
	global results "C:\Users\rcsayers\Box\demining\Results\"
}

cd "$data"
use "misti_panel_formatted", clear

*preserve
*drop if ha_count_1km_1992==0
*sample 25
*save "$data/misti_panel_formatted_sample", replace
*restore

*egen district_id = group(m21)
egen province_id = group(m6)
egen district_id = group(m4 m6)
egen village_id = group(village m4 m6)

rename m7 survey_year

egen wave = group(m2)
egen province_wave = group(wave province_id)
*egen province_year = group(survey_year province_id)


* drop if ha_count2012==0

gen cleared_since_2012 = (ha_count2012 - ha_count)

gen absorb_temp = 1

* su

outreg2 using "$results/summary_statistics_misti.doc", replace sum(log)
rm "$results/summary_statistics_misti.txt"

********************************************************************************

reghdfe q1n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", replace noni nocons addtext("Wave FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q1: Generally speaking are things in [district] going in the right direction or in the wrong direction? Is that a lot or a little? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q1n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q1n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q1n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q1.doc", append noni nocons addtext("Wave FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q1.txt"

***


reghdfe q26n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", replace noni nocons addtext("Wave FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q26: All things considered how satisfied are you with your life as a whole these days? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q26n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q26n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q26n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q26.doc", append noni nocons addtext("Wave FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q26.txt"

***


reghdfe q27n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", replace noni nocons addtext("Wave FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q27: How satisfied are you with your household's current financial situation? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q27n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q27n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", append noni nocons addtext("Wave FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q27n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q27.doc", append noni nocons addtext("Wave FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q27.txt"

***

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q28: Thinking about the past year would you say overall that your ability to meet your basic needs increased decreased or stayed the same? Q29: How worried are you about being able to meet your basic needs over the next year? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q28_q29_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q28_q29_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q28_q29_index.txt"

***

reghdfe q30n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q30: Please tell me which statement is closest to your opinion: The situation in this area is certain enough/too uncertain for me to make plans for my future. Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q30n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q30n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q30n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q30.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q30.txt"

***

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q2a: Would you say security in your local area is good fair or poor? Is that very good/poor'? Q2b: Is your local area more secure just as secure or less secure than it was a year ago? Is that much more/less secure' or a little more/less secure'? Q2c: And what about a year from now do your expect your local area will be more secure just as secure or less secure than it is now? Is that much more/less secure' or somewhat more/less secure'? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q2a_q2b_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q2a_q2b_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q2a_q2b_index.txt"

***

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q3b: Would you say that security on the roads you use in this area has improved worsened or stayed the same in the past year? Is that improved/worsened a little or a lot'? Q4e: ... traveling to a neighboring village? Q4f: ... traveling to the district or provincial capital? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q3b_q4d_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q3b_q4d_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q3b_q4d_index.txt"

***


reghdfe q31n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q31: Compared to a year ago how would you describe your ability to get to your local markets? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q31n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q31n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q31n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q31n.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q31n.txt"

***

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q11a: Over the past year has the [Insert Item] ability to get things done in this area improved worsened or has there been no change? - District Governor's. Q11b: District Government's. Q11c: Local village/neighborhood leaders. Q11d: Provincial Governor's. Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q11a_q11d_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q11a_q11d_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q11a_q11d_index.txt"

***

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q14b: Please tell me which statement is closest to your opinion: The district government does/does not understand the problems of people in this area. Q14c: Please tell me which statement is closest to your opinion: The district government does/does not care about the people in this area. Q14d. Please tell me which statement is closest to your opinion: District government officials do/do not abuse their authority to make money for themselves. Q14f: Please tell me which statement is closest to your opinion: The district government officials are/are not doing their jobs honestly. Q14g: Please tell me which statement is closest to your opinion: The District Government does/does not deliver basic services to this area in a fair manner. Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q14b_q14f_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q14b_q14f_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q14b_q14f_index.txt"

***

reghdfe q15n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q15: Overall do you think that services from the government in this area have improved worsened or not changed in the past year? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q15n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q15n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q15n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q15.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q15.txt"

***

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q16a: Generally speaking how satisfied or dissatisfied are you with the District Government's provision of ... Clean Drinking Water? Q16b: Water for irrigation and uses other than drinking? Q16c: Agricultural assistance (seed fertilizer or equipment)? Q16d: Retaining and flood walls? Q16e: Roads and bridges? Q16f: Medical Care? Q16g: Schooling for girls? Q16h: Schooling for boys? Q16i: Electricity? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q16a_q16i_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q16a_q16i_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q16a_q16i_index.txt"

***

reghdfe q32n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q32: Compared to a year ago how have prices for basic goods changed in your local markets? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q32n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q32n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q32n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q32.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q32.txt"

***

reghdfe q33n all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Q33: Compared to a year ago how would you describe the availability of paid jobs in your local area? Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe q33n all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe q33n all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe q33n all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_q33.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_q33.txt"

***

reghdfe govtrust_super_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_govtrust_super_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe govtrust_super_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_govtrust_super_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe govtrust_super_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_govtrust_super_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe govtrust_super_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_govtrust_super_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_govtrust_super_index.txt"

***

reghdfe security_super_index all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id wave)
outreg2 using "$results/misti_security_super_index.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)

reghdfe security_super_index all_cleared [aw=pct_area], absorb(survey_year) cluster(district_id wave)
outreg2 using "$results/misti_security_super_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", N, "Wave*Province FEs", N)

reghdfe security_super_index all_cleared [aw=pct_area], absorb(survey_year village_id) cluster(district_id wave)
outreg2 using "$results/misti_security_super_index.doc", append noni nocons addtext("Year FEs", Y, "Village FEs", Y, "Wave*Province FEs", N)

reghdfe security_super_index all_cleared [aw=pct_area], absorb(village_id province_wave) cluster(district_id wave)
outreg2 using "$results/misti_security_super_index.doc", append noni nocons addtext("Year FEs", N, "Village FEs", Y, "Wave*Province FEs", Y)

rm "$results/misti_security_super_index.txt"






















