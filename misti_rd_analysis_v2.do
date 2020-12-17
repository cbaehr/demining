

/*******************************************************************************
Declare file paths
*******************************************************************************/

local user = "r"

if "`user'" == "c" {
	global data "/Users/christianbaehr/Box Sync/demining/inputData/"
	global mistidata "${data}/misti/"
	global results "/Users/christianbaehr/Box Sync/deminingResults/"
}
if "`user'" == "r" {
	global data "C:\Users\rcsayers\Box\demining\inputData\"
	global mistidata "${data}misti\"
	global results "C:\Users\rcsayers\Box\demining\Results\"
}

/*******************************************************************************
Declare locals
*******************************************************************************/

local cutoff_year = 1
local cutoff_month = 0

/*******************************************************************************
Load data
*******************************************************************************/

cd "${data}"
use "misti_panel_formatted_sample.dta", clear

/*******************************************************************************
Generate variables for fixed effects
*******************************************************************************/

egen province_id = group(m6)
egen district_id = group(m4 m6)
egen village_id = group(village m4 m6)

rename m7 survey_year

egen wave = group(m2)
egen district_wave = group(wave district_id)
egen district_year = group(survey_year district_id)
egen province_wave = group(wave province_id)
egen province_year = group(survey_year province_id)

/*******************************************************************************
Create treatment date variables for each radius
*******************************************************************************/

//for each radius band, extract date information
local radiuslist = "1 3 5"
foreach radius of local radiuslist {
    gen treat_`radius'km_year = substr(last_clearance_date_`radius'km, 1, 4)
    gen treat_`radius'km_month = substr(last_clearance_date_`radius'km, 6, 2)
    gen treat_`radius'km_day = substr(last_clearance_date_`radius'km, 9, 2)
	local timelist = "year month day"
	foreach time of local timelist {
		destring treat_`radius'km_`time', replace
	}
}
//for larger radius bands, make sure treatment date is the largest of that band
//and any smaller bands (e.g. if 1 km was cleared in 2019 and 3 km was cleared
//in 2017, then treatment date of 3km should be 2019) 
local radiuslist = "3 5"
foreach radius of local radiuslist {
    if `radius' == 3 {
	    local smallerradius = 1
	}
	else {
	    local smallerradius = 3
	}
	gen tag = 0
	replace tag = 1 if (treat_`radius'km_year < treat_`smallerradius'km_year) | (treat_`radius'km_year == treat_`smallerradius'km_year & treat_`radius'km_month < treat_`smallerradius'km_month) | (treat_`radius'km_year == treat_`smallerradius'km_year & treat_`radius'km_month == treat_`smallerradius'km_month & treat_`radius'km_day < treat_`smallerradius'km_day)
	local timelist = "year month day"
	foreach time of local timelist {
		replace treat_`radius'km_`time' = treat_`smallerradius'km_`time' if tag == 1
	}
	drop tag
}

/*******************************************************************************
Create interview date variables
*******************************************************************************/

//extract interview date information
gen monthend = strpos(interview_date, "-")
replace monthend = monthend - 1
gen inter_month = substr(interview_date, 1, monthend)
gen daystart = monthend + 2
drop monthend
gen dayyear = substr(interview_date, daystart, .)
drop daystart
gen dayend = strpos(dayyear, "-")
replace dayend = dayend - 1
gen inter_day = substr(dayyear, 1, dayend)
gen yearstart = dayend + 2
drop dayend
gen inter_year = substr(dayyear, yearstart, .)
drop dayyear yearstart
local timelist = "year month day"
foreach time of local timelist {
    destring inter_`time', replace
}

/*******************************************************************************
Identify treatment group
*******************************************************************************/

//generate the treatment cutoff date
local timelist = "year month"
foreach time of local timelist {
	gen treat_cutoff_`time' = inter_`time' - `cutoff_`time''
}
gen treat_cutoff_day = inter_day
//fix any negatives in the month
replace treat_cutoff_year = treat_cutoff_year - 1 if treat_cutoff_month < 1
replace treat_cutoff_month = treat_cutoff_month + 12 if treat_cutoff_month < 1

//for each radius band, classify as treated if clearance was before interview but after treatment cutoff
local radiuslist = "1 3 5"
foreach radius of local radiuslist {
	//categorize all as treated
	gen treated_`radius'km = 1
	//remove from treated category if there are still hazards that haven't been cleared
	replace treated_`radius'km = 0 if treat_`radius'km_year == . | treat_`radius'km_month == . | treat_`radius'km_year == .
	//remove from treated category if clearance occured after interview
	replace treated_`radius'km = 0 if (treat_`radius'km_year > inter_year) | (treat_`radius'km_year == inter_year & treat_`radius'km_month > inter_month) | (treat_`radius'km_year == inter_year & treat_`radius'km_month == inter_month & treat_`radius'km_day > inter_day)
	//remove from treated category if clearance occured before cutoff
	replace treated_`radius'km = 0 if (treat_`radius'km_year < treat_cutoff_year) | (treat_`radius'km_year == treat_cutoff_year & treat_`radius'km_month < treat_cutoff_month) | (treat_`radius'km_year == treat_cutoff_year & treat_`radius'km_month == treat_cutoff_month & treat_`radius'km_day < treat_cutoff_day)
}
 
//drop treatment cutoff date
drop treat_cutoff_year treat_cutoff_month treat_cutoff_day
 
/*******************************************************************************
Identify treatment group
*******************************************************************************/ 

//generate the control cutoff date
local timelist = "year month"
foreach time of local timelist {
	gen control_cutoff_`time' = inter_`time' + `cutoff_`time''
}
gen control_cutoff_day = inter_day
//fix any >12 in the month
replace control_cutoff_year = control_cutoff_year + 1 if control_cutoff_month > 12
replace control_cutoff_month = control_cutoff_month - 12 if control_cutoff_month > 12

//for each radius band, classify as control if clearance was after interview but before control cutoff
local radiuslist = "1 3 5"
foreach radius of local radiuslist {
	//categorize all as treated
	gen control_`radius'km = 1
	//remove from control category if there are still hazards that haven't been cleared
	replace control_`radius'km = 0 if treat_`radius'km_year == . | treat_`radius'km_month == . | treat_`radius'km_year == .
	//remove from control category if clearance occured before interview
	replace control_`radius'km = 0 if (treat_`radius'km_year < inter_year) | (treat_`radius'km_year == inter_year & treat_`radius'km_month < inter_month) | (treat_`radius'km_year == inter_year & treat_`radius'km_month == inter_month & treat_`radius'km_day < inter_day)
	//remove from control category if clearance occured after cutoff
	replace control_`radius'km = 0 if (treat_`radius'km_year > control_cutoff_year) | (treat_`radius'km_year == control_cutoff_year & treat_`radius'km_month > control_cutoff_month) | (treat_`radius'km_year == control_cutoff_year & treat_`radius'km_month == control_cutoff_month & treat_`radius'km_day > control_cutoff_day)
}

/*******************************************************************************
Identify sample
*******************************************************************************/ 

//generate sample group
local radiuslist = "1 3 5"
foreach radius of local radiuslist {
	gen sample_`radius'km = 0
	replace sample_`radius'km = 1 if treated_`radius'km == 1 | control_`radius'km == 1
}

/*******************************************************************************
Finalize weight variables
*******************************************************************************/ 

//geenerate weights
gen weight_1km = pct_covered_1km
gen weight_3km = (3.14 * pct_covered_1km + (28.27 - 3.14) * pct_covered_3km) / 28.27
gen weight_5km = (3.14 * pct_covered_1km + (28.27 - 3.14) * pct_covered_3km + (78.54 - 28.27) * pct_covered_5km) / 78.54

/*******************************************************************************
Simplistic regression
*******************************************************************************/
/*
local lhsvarlist = "q1n q26n q27n q28_q29_index q30n q2a_q2b_index q3b_q4d_index q31n q11a_q11d_index q14b_q14f_index q15n q16a_q16i_index q32n q33n govtrust_super_index security_super_index"
local label_q1n = "Single question: Generally speaking are things in your district going in the right direction or in the wrong direction?"
local label_q26n = "Single question: All things considered how satisfied are you with your life as a whole these days?"
local label_q27n = "Single question: How satisfied are you with your household's current financial situation?"
local label_q28_q29_index = "Index: 1. Thinking about the past year would you say overall that your ability to meet your basic needs increased decreased or stayed the same? 2. How worried are you about being able to meet your basic needs over the next year?"
local label_q30n = "Single question: Please tell me which statement is closest to your opinion: The situation in this area is certain enough/too uncertain for me to make plans for my future."
local label_q2a_q2b_index = "Index: 1. Would you say security in your local area is good fair or poor? 2. Is your local area more secure just as secure or less secure than it was a year ago? 3. And what about a year from now do your expect your local area will be more secure just as secure or less secure than it is now?"
local label_q3b_q4d_index = "Index: 1. Would you say that security on the roads you use in this area has improved worsened or stayed the same in the past year? 2. Please tell me how secure do you feel when you are traveling to a neighboring village? 3. Please tell me how secure do you feel when you are traveling to the district or provincial capital?"
local label_q31n = "Single question: Compared to a year ago how would you describe your ability to get to your local markets?"
local label_q11a_q11d_index = "Index: 1. Over the past year has the District Governor's ability to get things done in this area improved worsened or has there been no change? 2. Over the past year has the District Government's ability to get things done in this area improved worsened or has there been no change? 3. Over the past year has the local village/neighborhood leaders ability to get things done in this area improved worsened or has there been no change? 4. Over the past year has the Provincial Governor's ability to get things done in this area improved worsened or has there been no change?"
local label_q14b_q14f_index = "Index: 1. Please tell me which statement is closest to your opinion: The district government does/does not understand the problems of people in this area. 2. Please tell me which statement is closest to your opinion: The district government does/does not care about the people in this area. 3. Please tell me which statement is closest to your opinion: District government officials do/do not abuse their authority to make money for themselves. 4. Please tell me which statement is closest to your opinion: The district government officials are/are not doing their jobs honestly. 5. Please tell me which statement is closest to your opinion: The District Government does/does not deliver basic services to this area in a fair manner."
local label_q15n = "Single question: Overall do you think that services from the government in this area have improved, worsened or not changed in the past year?"
local label_q16a_q16i_index = "Index: 1. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of clean drinking water? 2. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of water for irrigation and uses other than drinking? 3. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of agricultural assistance (seed fertilizer or equipment)? 4. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of retaining and flood walls? 5. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of roads and bridges? 6. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of medical Care? 7. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for girls? 8. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for boys? 9. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of electricity?"
local label_q32n = "Single question: Compared to a year ago how have prices for basic goods changed in your local markets?"
local label_q33n = "Single question: Compared to a year ago how would you describe the availability of paid jobs in your local area?"
local label_govtrust_super_index = "Index: 1. Over the past year has the District Governor's ability to get things done in this area improved worsened or has there been no change? 2. Over the past year has the District Government's ability to get things done in this area improved worsened or has there been no change? 3. Over the past year has the local village/neighborhood leaders ability to get things done in this area improved worsened or has there been no change? 4. Over the past year has the Provincial Governor's ability to get things done in this area improved worsened or has there been no change? 5. Please tell me which statement is closest to your opinion: The district government does/does not understand the problems of people in this area. 6. Please tell me which statement is closest to your opinion: The district government does/does not care about the people in this area. 7. Please tell me which statement is closest to your opinion: District government officials do/do not abuse their authority to make money for themselves. 8. Please tell me which statement is closest to your opinion: The district government officials are/are not doing their jobs honestly. 9. Please tell me which statement is closest to your opinion: The District Government does/does not deliver basic services to this area in a fair manner. 10. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of clean drinking water? 11. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of water for irrigation and uses other than drinking? 12. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of agricultural assistance (seed fertilizer or equipment)? 13. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of retaining and flood walls? 14. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of roads and bridges? 15. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of medical Care? 16. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for girls? 17. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for boys? 18. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of electricity?"
local label_security_super_index = "Index: 1. Would you say security in your local area is good fair or poor? 2. Is your local area more secure just as secure or less secure than it was a year ago? 3. And what about a year from now do your expect your local area will be more secure just as secure or less secure than it is now? 4. Would you say that security on the roads you use in this area has improved worsened or stayed the same in the past year? 5. Please tell me how secure do you feel when you are traveling to a neighboring village? 6. Please tell me how secure do you feel when you are traveling to the district or provincial capital?"
local fes = "district_wave"
//local radiuslist = "1 3 5"
local radiuslist = "1"
foreach radius of local radiuslist {
<<<<<<< HEAD
    foreach lhsvar of local lhsvarlist {
	    reghdfe `rlsvar' treated_`radius'km [aw=weight_`radius'km], absorb(`fes') cluster(district_id) if sample_`radius'km == 1
		outreg2 using "$results/misti_rdbasic_`lhsvar'_`radius'km.doc", replace noni nocons addtext("Year FEs", N, "Village FEs", N, "Wave*Province FEs", N) nonotes addnote(`label_`rhsvar'' Robust standard errors in parentheses. *** p<0.01 ** p<0.05 * p<0.1)
=======
    foreach rhsvar of local rhsvarlist {
	    reghdfe `rhsvar' treated_`radius'km [aw=weight_`radius'km] if sample_`radius'km == 1, absorb(`fes') cluster(district_id)
>>>>>>> 7e593094fe355bfe6fbf19ac4abed23e31e2e643
	}
}
*/
/*******************************************************************************
Generate running variable
*******************************************************************************/ 

//generate running variable
//local radiuslist = "1 3 5"
local radiuslist = "1"
foreach radius of local radiuslist {
	gen running_`radius'km_months = 12*(inter_year-treat_`radius'km_year)+(inter_month-treat_`radius'km_month)
}
//days before the 1st of each month
local daysbefore = "0 31 59 90 120 151 181 212 243 273 304 334"
gen interdays = word("`daysbefore'", inter_month)
destring interdays, replace
foreach radius of local radiuslist {
	gen treat_`radius'kmdays = word("`daysbefore'", treat_`radius'km_month)
	destring treat_`radius'kmdays, replace
	gen running_`radius'km_days = 365*(inter_year-treat_`radius'km_year)+(interdays-treat_`radius'kmdays)+(inter_day-treat_`radius'km_day)
	//drop interdays
}

/*******************************************************************************
Regression discontinuity
*******************************************************************************/

local lhsvarlist = "q1n q26n q27n q28_q29_index q30n q2a_q2b_index q3b_q4d_index q31n q11a_q11d_index q14b_q14f_index q15n q16a_q16i_index q32n q33n govtrust_super_index security_super_index"
local label_q1n = "Single question: Generally speaking are things in your district going in the right direction or in the wrong direction?"
local label_q26n = "Single question: All things considered how satisfied are you with your life as a whole these days?"
local label_q27n = "Single question: How satisfied are you with your household's current financial situation?"
local label_q28_q29_index = "Index: 1. Thinking about the past year would you say overall that your ability to meet your basic needs increased decreased or stayed the same? 2. How worried are you about being able to meet your basic needs over the next year?"
local label_q30n = "Single question: Please tell me which statement is closest to your opinion: The situation in this area is certain enough/too uncertain for me to make plans for my future."
local label_q2a_q2b_index = "Index: 1. Would you say security in your local area is good fair or poor? 2. Is your local area more secure just as secure or less secure than it was a year ago? 3. And what about a year from now do your expect your local area will be more secure just as secure or less secure than it is now?"
local label_q3b_q4d_index = "Index: 1. Would you say that security on the roads you use in this area has improved worsened or stayed the same in the past year? 2. Please tell me how secure do you feel when you are traveling to a neighboring village? 3. Please tell me how secure do you feel when you are traveling to the district or provincial capital?"
local label_q31n = "Single question: Compared to a year ago how would you describe your ability to get to your local markets?"
local label_q11a_q11d_index = "Index: 1. Over the past year has the District Governor's ability to get things done in this area improved worsened or has there been no change? 2. Over the past year has the District Government's ability to get things done in this area improved worsened or has there been no change? 3. Over the past year has the local village/neighborhood leaders ability to get things done in this area improved worsened or has there been no change? 4. Over the past year has the Provincial Governor's ability to get things done in this area improved worsened or has there been no change?"
local label_q14b_q14f_index = "Index: 1. Please tell me which statement is closest to your opinion: The district government does/does not understand the problems of people in this area. 2. Please tell me which statement is closest to your opinion: The district government does/does not care about the people in this area. 3. Please tell me which statement is closest to your opinion: District government officials do/do not abuse their authority to make money for themselves. 4. Please tell me which statement is closest to your opinion: The district government officials are/are not doing their jobs honestly. 5. Please tell me which statement is closest to your opinion: The District Government does/does not deliver basic services to this area in a fair manner."
local label_q15n = "Single question: Overall do you think that services from the government in this area have improved, worsened or not changed in the past year?"
local label_q16a_q16i_index = "Index: 1. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of clean drinking water? 2. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of water for irrigation and uses other than drinking? 3. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of agricultural assistance (seed fertilizer or equipment)? 4. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of retaining and flood walls? 5. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of roads and bridges? 6. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of medical Care? 7. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for girls? 8. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for boys? 9. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of electricity?"
local label_q32n = "Single question: Compared to a year ago how have prices for basic goods changed in your local markets?"
local label_q33n = "Single question: Compared to a year ago how would you describe the availability of paid jobs in your local area?"
local label_govtrust_super_index = "Index: 1. Over the past year has the District Governor's ability to get things done in this area improved worsened or has there been no change? 2. Over the past year has the District Government's ability to get things done in this area improved worsened or has there been no change? 3. Over the past year has the local village/neighborhood leaders ability to get things done in this area improved worsened or has there been no change? 4. Over the past year has the Provincial Governor's ability to get things done in this area improved worsened or has there been no change? 5. Please tell me which statement is closest to your opinion: The district government does/does not understand the problems of people in this area. 6. Please tell me which statement is closest to your opinion: The district government does/does not care about the people in this area. 7. Please tell me which statement is closest to your opinion: District government officials do/do not abuse their authority to make money for themselves. 8. Please tell me which statement is closest to your opinion: The district government officials are/are not doing their jobs honestly. 9. Please tell me which statement is closest to your opinion: The District Government does/does not deliver basic services to this area in a fair manner. 10. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of clean drinking water? 11. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of water for irrigation and uses other than drinking? 12. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of agricultural assistance (seed fertilizer or equipment)? 13. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of retaining and flood walls? 14. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of roads and bridges? 15. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of medical Care? 16. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for girls? 17. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of schooling for boys? 18. Generally speaking how satisfied or dissatisfied are you with the District Government's provision of electricity?"
local label_security_super_index = "Index: 1. Would you say security in your local area is good fair or poor? 2. Is your local area more secure just as secure or less secure than it was a year ago? 3. And what about a year from now do your expect your local area will be more secure just as secure or less secure than it is now? 4. Would you say that security on the roads you use in this area has improved worsened or stayed the same in the past year? 5. Please tell me how secure do you feel when you are traveling to a neighboring village? 6. Please tell me how secure do you feel when you are traveling to the district or provincial capital?"
/*
local fes = "wave"
foreach fe of local fes {
	levelsof `fe', local(felevels)
	local count = 0
	foreach felvl of local felevels {
		local count = `count' + 1
		if `count' != 1 {
			gen `fe'_`felvl' = 0
			replace `fe'_`felvl' = 1 if `fe' == `felvl'
			replace `fe'_`felvl' = . if `fe' == .
		}
	}
}
*/
local fes = "district_wave village_id"
//local radiuslist = "1 3 5"
local radiuslist = "1"

foreach radius of local radiuslist {
	gen treatedrunning_`radius'km_months = .
	gen treatedrunning_`radius'km_days = .
}

local bandwidthlist = "1 2 3"
cd "${results}"
foreach radius of local radiuslist {
    foreach lhsvar of local lhsvarlist {
		//MONTH BANDWIDTH
		//chosen using default
		/*rdrobust `lhsvar' running_`radius'km_months, c(0) kernel(epa) weights(weight_`radius'km)
		local bw: display %5.3f e(h_l)
		outreg2 using "misti_rd_`lhsvar'_months_`radius'km.doc", replace noni nocons addtext("Wave FEs", N, "Pop. Covariate", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
		rdrobust `lhsvar' running_`radius'km_months, c(0) kernel(epa) weights(weight_`radius'km) covs(wave_* pop_count2005)
		local bw: display %5.3f  e(h_l)
		outreg2 using "misti_rd_`lhsvar'_months_`radius'km.doc", append noni nocons addtext("Wave FEs", Y, "Pop. Covariate", Y, "Bandwidth", `bw') nonotes*/
		rdrobust `lhsvar' running_`radius'km_months, c(0) kernel(uni) weights(weight_`radius'km)
		local bw: display %5.3f  e(h_l)
		replace sample_`radius'km = 0
		replace sample_`radius'km = 1 if running_`radius'km_months >= -`bw' & running_`radius'km_months <= `bw'
		replace treated_`radius'km = 0
		replace treated_`radius'km = 1 if sample_`radius'km == 1 & running_`radius'km_months >= 0
		replace treatedrunning_`radius'km_months = treated_`radius'km * running_`radius'km_months
		reg `lhsvar' treated_`radius'km running_`radius'km_months treatedrunning_`radius'km_months [aw=weight_`radius'km] if sample_`radius'km == 1, vce(cluster district_id)
		//outreg2 using "misti_rd_`lhsvar'_months_uniform_`radius'km.doc", replace noni nocons addtext("District*Wave FEs", N, "Village FEs", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
		outreg2 using "misti_rd_`lhsvar'.doc", replace noni nocons addtext("District*Wave FEs", N, "Village FEs", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
		outreg2 using "misti_rd_`lhsvar'_bywave.doc", replace noni nocons addtext("District*Wave FEs", N, "Village FEs", N, "Bandwidth", `bw', "Wave", All) nonotes addnote(`label_`lhsvar'')
		reghdfe `lhsvar' treated_`radius'km running_`radius'km_months treatedrunning_`radius'km_months [aw=weight_`radius'km] if sample_`radius'km == 1, absorb(`fes') vce(cluster district_id)
		//outreg2 using "misti_rd_`lhsvar'_months_uniform_`radius'km.doc", append noni nocons addtext("District*Wave FEs", Y, "Village FEs", Y, "Bandwidth", `bw') nonotes
		outreg2 using "misti_rd_`lhsvar'.doc", append noni nocons addtext("District*Wave FEs", Y, "Village FEs", Y, "Bandwidth", `bw') nonotes
		//by round
		forvalues wave = 1/5 {
		    gen sample_`radius'km_wave`wave' = 0
			replace sample_`radius'km_wave`wave' = 1 if sample_`radius'km == 1 & wave == `wave'
			reg `lhsvar' treated_`radius'km running_`radius'km_months treatedrunning_`radius'km_months [aw=weight_`radius'km] if sample_`radius'km_wave`wave' == 1, vce(cluster district_id)
			outreg2 using "misti_rd_`lhsvar'_bywave.doc", append noni nocons addtext("District*Wave FEs", N, "Village FEs", N, "Bandwidth", `bw', "Wave", `wave') nonotes addnote(`label_`lhsvar'')
			drop sample_`radius'km_wave`wave'
		}
		stop
		//manually chosen
		/*
		foreach bandwidth of local bandwidthlist { 
			local bw = 12*`bandwidth'
			rdrobust `lhsvar' running_`radius'km_months, c(0) h(`bw') kernel(epa) weights(weight_`radius'km)
			outreg2 using "misti_rd_`lhsvar'_months_`radius'km.doc", append noni nocons addtext("Wave FEs", N, "Pop. Covariate", N, "Bandwidth", `bw') nonotes
			rdrobust `lhsvar' running_`radius'km_months, c(0) h(`bw') kernel(epa) weights(weight_`radius'km) covs(wave_* pop_count2005)
			outreg2 using "misti_rd_`lhsvar'_months_`radius'km.doc", append noni nocons addtext("Wave FEs", Y, "Pop. Covariate", Y, "Bandwidth", `bw') nonotes
		}
		*/
		/*
		//DAY BANDWIDTH
		//chosen using default
		rdrobust `lhsvar' running_`radius'km_days, c(0) kernel(epa) weights(weight_`radius'km)
		local bw: display %5.3f  e(h_l)
		outreg2 using "misti_rd_`lhsvar'_days_`radius'km.doc", replace noni nocons addtext("Wave FEs", N, "Pop. Covariate", N, "Bandwidth", `bw') nonotes addnote(`label_`rhsvar'')
		rdrobust `lhsvar' running_`radius'km_days, c(0) kernel(epa) weights(weight_`radius'km) covs(wave_* pop_count2005)
		local bw: display %5.3f  e(h_l)
		outreg2 using "misti_rd_`lhsvar'_days_`radius'km.doc", append noni nocons addtext("Wave FEs", Y, "Pop. Covariate", Y, "Bandwidth", `bw') nonotes addnote(`label_`rhsvar'')
		//manually chosen
		foreach bandwidth of local bandwidthlist { 
			local bw = 365*`bandwidth'
			rdrobust `lhsvar' running_`radius'km_days, c(0) h(`bw')kernel(epa) weights(weight_`radius'km)
			outreg2 using "misti_rd_`lhsvar'_days_`radius'km.doc", append noni nocons addtext("Wave FEs", N, "Pop. Covariate", N, "Bandwidth", `bw') nonotes addnote(`label_`rhsvar'')
			rdrobust `lhsvar' running_`radius'km_days, c(0) h(`bw')kernel(epa) weights(weight_`radius'km) covs(wave_* pop_count2005)
			outreg2 using "misti_rd_`lhsvar'_days_`radius'km.doc", append noni nocons addtext("Wave FEs", Y, "Pop. Covariate", Y, "Bandwidth", `bw') nonotes addnote(`label_`rhsvar'')
		}
		*/
		/*
		rdrobust `lhsvar' running_`radius'km_days, c(0) kernel(uni) weights(weight_`radius'km)
		local bw: display %5.3f  e(h_l)
		replace sample_`radius'km = 0
		replace sample_`radius'km = 1 if running_`radius'km_days >= -`bw' & running_`radius'km_days <= `bw'
		replace treated_`radius'km = 0
		replace treated_`radius'km = 1 if sample_`radius'km == 1 & running_`radius'km_days >= 0
		replace treatedrunning_`radius'km_days = treated_`radius'km * running_`radius'km_days
		reg `lhsvar' treated_`radius'km running_`radius'km_days treatedrunning_`radius'km_days [aw=weight_`radius'km] if sample_`radius'km == 1, vce(cluster district_id)
		outreg2 using "misti_rd_`lhsvar'_days_uniform_`radius'km.doc", replace noni nocons addtext("District*Wave FEs", N, "Village FEs", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
		reghdfe `lhsvar' treated_`radius'km running_`radius'km_days treatedrunning_`radius'km_days [aw=weight_`radius'km] if sample_`radius'km == 1, absorb(`fes') vce(cluster district_id)
		outreg2 using "misti_rd_`lhsvar'_days_uniform_`radius'km.doc", append noni nocons addtext("District*Wave FEs", Y, "Village FEs", Y, "Bandwidth", `bw') nonotes
		*/
	}
}

//COMPARE BANDWIDTHS
/*
cd "${results}"
foreach lhsvar of local lhsvarlist {
	//MONTH BANDWIDTH
	//chosen using default
	rdrobust `lhsvar' running_1km_months, c(0) kernel(epa) weights(weight_1km)
	local bw: display %5.3f e(h_l)
	outreg2 using "misti_rd_`lhsvar'_kernel.doc", replace noni nocons addtext("Kernel", Epanechnikov, "Pop. Covariate", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
	rdrobust `lhsvar' running_1km_months, c(0) kernel(tri) weights(weight_1km)
	local bw: display %5.3f e(h_l)
	outreg2 using "misti_rd_`lhsvar'_kernel.doc", append noni nocons addtext("Kernel", Triangular, "Pop. Covariate", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
	rdrobust `lhsvar' running_1km_months, c(0) kernel(uni) weights(weight_1km)
	local bw: display %5.3f e(h_l)
	outreg2 using "misti_rd_`lhsvar'_kernel.doc", append noni nocons addtext("Kernel", Uniform, "Pop. Covariate", N, "Bandwidth", `bw') nonotes addnote(`label_`lhsvar'')
}
/*