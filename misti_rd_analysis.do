

/*******************************************************************************
Declare file paths
*******************************************************************************/

local user = "c"

if "`user'" == "c" {
	global data "/Users/christianbaehr/Box Sync/demining/inputData/"
	global mistidata "${data}/misti/"
}
if "`user'" == "r" {
	global data "C:\Users\rcsayers\Box\demining\inputData\"
	global mistidata "${data}misti\"
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
use "misti_panel_formatted.dta", clear

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
local rhsvarlist = "q1n q26n q27n q28_q29_index q30n q2a_q2b_index q3b_q4d_index q31n q11a_q11d_index q14b_q14f_index q15n q16a_q16i_index q32n q33n"
local rhsvarlabellist = `" "Q1: Generally speaking are things in [district] going in the right direction or in the wrong direction? Is that a lot or a little? Robust standard errors in parentheses." "Q26: All things considered how satisfied are you with your life as a whole these days?" "Q27: How satisfied are you with your household current financial situation?" "Q28: Thinking about the past year would you say overall that your ability to meet your basic needs increased decreased or stayed the same? Q29: How worried are you about being able to meet your basic needs over the next year?" "" "" "" "" "" "" "" "" "" "" "'
local fes = "district_wave"
//local radiuslist = "1 3 5"
local radiuslist = "1"
foreach radius of local radiuslist {
    foreach rhsvar of local rhsvarlist {
	    reghdfe `rhsvar' treated_`radius'km [aw=weight_`radius'km] if sample_`radius'km == 1, absorb(`fes') cluster(district_id)
	}
}
/*******************************************************************************
Generate running variable
*******************************************************************************/ 

//generate running variable
local radiuslist = "1 3 5"
foreach radius of local radiuslist {
	gen running_`radius'km_months = 12*(inter_year-treat_`radius'km_year)+(inter_month-treat_`radius'km_month)
}
//days before the 1st of each month
local daysbefore = "0 31 59 90 120 151 181 212 243 273 304 334"
foreach radius of local radiuslist {
    gen interdays = word("`daysbefore'", inter_month)
	destring interdays, replace
	gen treat_`radius'kmdays = word("`daysbefore'", treat_`radius'km_month)
	destring treat_`radius'kmdays, replace
	gen running_`radius'km_days = 365*(inter_year-treat_`radius'km_year)+(interdays-treat_`radius'kmdays)+(inter_day-treat_`radius'km_day)
	drop interdays
}

