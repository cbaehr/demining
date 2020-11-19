local user = "r"

if "`user'" == "c" {
	global data "/Users/christianbaehr/Box Sync/demining/inputData/"
	global mistidata "${data}/misti/"
}
if "`user'" == "r" {
	global data "C:\Users\rcsayers\Box\demining\inputData\"
	global mistidata "${data}misti\"
}

cd "$mistidata"
import delimited "misti_panel.csv", clear

gen ha_count = total_ha-num_cleared

drop if ha_count2012 == 0

gen all_cleared = .
replace all_cleared = 0 if ha_count == 0

************

/*levelsof q1
label define a 1 "Right direction (a lot)" 2 "Right direction (a little)" 3 "Wrong direction (a little)" 4 "Wrong direction (a lot)"

encode q1, generate(q1n) label(a)
replace q1n = . if q1n>4*/

gen q1n = .
replace q1n = 2 if strpos(q1, "Right direction (a lot)") > 0
replace q1n = 1 if strpos(q1, "Right direction (a little)") > 0
replace q1n = 0 if strpos(q1, "Neither right nor wrong") > 0 | strpos(q1, "Don't Know'") > 0
replace q1n = -1 if strpos(q1, "Wrong direction (a little)") > 0
replace q1n = -2 if strpos(q1, "Wrong direction (a lot)") > 0

*

/*label define b 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Somewhat dissatisfied" 4 "Very dissatisfied"

encode q26, generate(q26n) label(b)
replace q26n = . if q26n>4*/

gen q26n = .
replace q26n = 2 if strpos(q26, "Very satisfied") > 0
replace q26n = 1 if strpos(q26, "Somewhat satisfied") > 0
replace q26n = 0 if strpos(q26, "Don't Know") > 0
replace q26n = -1 if strpos(q26, "Somewhat dissatisfied") > 0
replace q26n = -2 if strpos(q26, "Very dissatisfied") > 0

*

/*encode q27, generate(q27n) label(b)
replace q27n = . if q27n>4*/

gen q27n = .
replace q27n = 2 if strpos(q27, "Very satisfied") > 0
replace q27n = 1 if strpos(q27, "Somewhat satisfied") > 0
replace q27n = 0 if strpos(q27, "Don't Know") > 0
replace q27n = -1 if strpos(q27, "Somewhat dissatisfied") > 0
replace q27n = -2 if strpos(q27, "Very dissatisfied") > 0

*

/*label define c 1 "Increased a lot" 2 "Increased a little" 3 "Decreased a little" 4 "Decreased a lot"

encode q28, generate(q28n) label(c)
replace q28n = . if q28n>4*/

gen q28n = .
replace q28n = 2 if strpos(q28, "Increased a lot") > 0
replace q28n = 1 if strpos(q28, "Increased a little") > 0
replace q28n = 0 if strpos(q28, "Stayed about the same") > 0 | strpos(q28, "Don't Know") > 0
replace q28n = -1 if strpos(q28, "Decreased a little") > 0
replace q28n = -2 if strpos(q28, "Decreased a lot") > 0

/*label define d 1 "Not worried" 2 "A little worried" 3 "Very worried"

encode q29, generate(q29n) label(d)
replace q29n = . if q29n>3*/

gen q29n = .
replace q29n = 1 if strpos(q29, "Not worried") > 0
replace q29n = 0 if strpos(q29, "Don't Know") > 0
replace q29n = -1 if strpos(q29, "A little worried") > 0 | strpos(q29, "Very worried") > 0

***

local lhs = "q28n q29n"
local indexname = "q28_q29_index"
local rhs = "all_cleared"

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

************

/*label define e 1 "The situation in this area is certain enough for me to make plans for my future" 2 "The situation in this area is too uncertain for me to make plans for my future"

encode q30, generate(q30n) label(e)
replace q30n = . if q30n>2*/

gen q30n = .
replace q30n = 1 if strpos(q30, "The situation in this area is certain enough") > 0
replace q30n = 0 if strpos(q30, "Don't Know") > 0
replace q30n = -1 if strpos(q30, "The situation in this area is too uncertain") > 0

*

/*label define f 1 "Very good" 2 "Good" 3 "Fair" 4 "Poor" 5 "Very poor"

encode q2a, generate(q2an) label(f)
replace q2an = . if q2an>5*/

gen q2an = .
replace q2an = 2 if strpos(q2a, "Very good") > 0
replace q2an = 1 if strpos(q2a, "Good") > 0
replace q2an = 0 if strpos(q2a, "Fair") > 0 | strpos(q2a, "Don't Know") > 0
replace q2an = -1 if strpos(q2a, "Poor") > 0
replace q2an = -2 if strpos(q2a, "Very poor") > 0

*

/*label define g 1 "Much more secure" 2 "Somewhat more secure" 3 "About the same" 4 "Somewhat less secure" 5 "Much less secure"

encode q2b, generate(q2bn) label(g)
replace q2bn = . if q2bn>5*/

gen q2bn = .
replace q2bn = 2 if strpos(q2b, "Much more secure") > 0
replace q2bn = 1 if strpos(q2b, "Somewhat more secure") > 0
replace q2bn = 0 if strpos(q2b, "About the same") > 0 | strpos(q2b, "Don't know") > 0
replace q2bn = -1 if strpos(q2b, "Somewhat less secure") > 0
replace q2bn = -2 if strpos(q2b, "Much less secure") > 0

***

local lhs = "q2an q2bn"
local indexname = "q2a_q2b_index"
local rhs = "all_cleared"

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

************

/*label define h 1 "Improved a lot" 2 "Improved a little" 3 "Stayed the same" 4 "Worsened a little" 5 "Worsened a lot"

encode q3b, generate(q3bn) label(h)
replace q3bn = . if q3bn>5*/

gen q3bn = .
replace q3bn = 2 if strpos(q3b, "Improved a lot") > 0
replace q3bn = 1 if strpos(q3b, "Improved a little") > 0
replace q3bn = 0 if strpos(q3b, "Stayed the same") > 0 | strpos(q3b, "Don't know") > 0
replace q3bn = -1 if strpos(q3b, "Worsened a little") > 0
replace q3bn = -2 if strpos(q3b, "Worsened a lot") > 0

*
/*
gen q4an = .
replace q4an = 2 if strpos(q4a, "Very secure") > 0
replace q4an = 1 if strpos(q4a, "Somewhat secure") > 0
replace q4an = 0 if strpos(q4a, "Don't know") > 0
replace q4an = -1 if strpos(q4a, "Somewhat insecure") > 0
replace q4an = -2 if strpos(q4a, "Very insecure") > 0

gen q4bn = .
replace q4bn = 2 if strpos(q4b, "Very secure") > 0
replace q4bn = 1 if strpos(q4b, "Somewhat secure") > 0
replace q4bn = 0 if strpos(q4b, "Don't know") > 0
replace q4bn = -1 if strpos(q4b, "Somewhat insecure") > 0
replace q4bn = -2 if strpos(q4b, "Very insecure") > 0
*/

/*label define i 1 "Very secure" 2 "Somewhat secure" 3 "Somewhat insecure" 4 "Very insecure"

encode q4c, generate(q4cn) label(i)
replace q4cn = . if q4cn>4*/

gen q4cn = .
replace q4cn = 2 if strpos(q4c, "Very secure") > 0
replace q4cn = 1 if strpos(q4c, "Somewhat secure") > 0
replace q4cn = 0 if strpos(q4c, "Don't know") > 0
replace q4cn = -1 if strpos(q4c, "Somewhat insecure") > 0
replace q4cn = -2 if strpos(q4c, "Very insecure") > 0

*

/*encode q4d, generate(q4dn) label(i)
replace q4dn = . if q4dn>4*/

gen q4dn = .
replace q4dn = 2 if strpos(q4d, "Very secure") > 0
replace q4dn = 1 if strpos(q4d, "Somewhat secure") > 0
replace q4dn = 0 if strpos(q4d, "Don't know") > 0
replace q4dn = -1 if strpos(q4d, "Somewhat insecure") > 0
replace q4dn = -2 if strpos(q4d, "Very insecure") > 0


***

local lhs = "q3bn q4cn q4dn"
local indexname = "q3b_q4d_index"
local rhs = "all_cleared"

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

************

/*label define j 1 "Much better" 2 "A little better" 3 "About the same" 4 "A little worse" 5 "Much worse"

encode q31, generate(q31n) label(j)
replace q31n = . if q31n>5*/

gen q31n = .
replace q31n = 2 if strpos(q31, "Much better") > 0
replace q31n = 1 if strpos(q31, "A little better") > 0
replace q31n = 0 if strpos(q31, "About the same") > 0 | strpos(q31, "Don't Know") > 0
replace q31n = -1 if strpos(q31, "A little worse") > 0
replace q31n = -2 if strpos(q31, "Much worse") > 0

*

/*label define k 1 "More available" 2 "About the same" 3 "Less available" 4 "Have not been available (vol.)"

encode w1_q36e, generate(w1_q36en) label(k)
replace w1_q36en = . if w1_q36en>4*/

gen w1_q36en = .
replace w1_q36en = 1 if strpos(w1_q36e, "More available") > 0
replace w1_q36en = 0 if strpos(w1_q36e, "About the same") > 0 | strpos(w1_q36e, "Don't Know") > 0 | strpos(w1_q36e, "Have not been available") > 0
replace w1_q36en = -1 if strpos(w1_q36e, "Less available") > 0


* 

/*encode q11a, generate(q11an) label(h)
replace q11an = . if q11an>5*/

gen q11an = .
replace q11an = 2 if strpos(q11a, "Improved a lot") > 0
replace q11an = 1 if strpos(q11a, "Improved a little") > 0
replace q11an = 0 if strpos(q11a, "Stayed the same") > 0 | strpos(q11a, "Don't know") > 0
replace q11an = -1 if strpos(q11a, "Worsened a little") > 0
replace q11an = -2 if strpos(q11a, "Worsened a lot") > 0

*

/*encode q11b, generate(q11bn) label(h)
replace q11bn = . if q11bn>5*/

gen q11bn = .
replace q11bn = 2 if strpos(q11b, "Improved a lot") > 0
replace q11bn = 1 if strpos(q11b, "Improved a little") > 0
replace q11bn = 0 if strpos(q11b, "Stayed the same") > 0 | strpos(q11b, "Don't know") > 0
replace q11bn = -1 if strpos(q11b, "Worsened a little") > 0
replace q11bn = -2 if strpos(q11b, "Worsened a lot") > 0


*

/*encode q11c, generate(q11cn) label(h)
replace q11cn = . if q11cn>5*/

gen q11cn = .
replace q11cn = 2 if strpos(q11c, "Improved a lot") > 0
replace q11cn = 1 if strpos(q11c, "Improved a little") > 0
replace q11cn = 0 if strpos(q11c, "Stayed the same") > 0 | strpos(q11c, "Don't know") > 0
replace q11cn = -1 if strpos(q11c, "Worsened a little") > 0
replace q11cn = -2 if strpos(q11c, "Worsened a lot") > 0

*

/*encode q11d, generate(q11dn) label(h)
replace q11dn = . if q11dn>5*/

gen q11dn = .
replace q11dn = 2 if strpos(q11d, "Improved a lot") > 0
replace q11dn = 1 if strpos(q11d, "Improved a little") > 0
replace q11dn = 0 if strpos(q11d, "Stayed the same") > 0 | strpos(q11d, "Don't know") > 0
replace q11dn = -1 if strpos(q11d, "Worsened a little") > 0
replace q11dn = -2 if strpos(q11d, "Worsened a lot") > 0

***

local lhs = "q11an q11bn q11cn q11dn"
local indexname = "q11a_q11d_index"
local rhs = "all_cleared"

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

************

/*label define l 1 "The district government understands the problems of people in this area." 2 "The district government does not understand the problems of people in this area."

encode q14b, generate(q14bn) label(l)
replace q14bn = . if q14bn>2*/

gen q14bn = .
replace q14bn = 1 if strpos(q14b, "The district government understands") > 0
replace q14bn = 0 if strpos(q14b, "Don't Know") > 0
replace q14bn = -1 if strpos(q14b, "The district government does not understand") > 0

*

/*label define m 1 "The district government cares about the people in this area" 2 "The district government does not care about the people in this area"

encode q14c, generate(q14cn) label(m)
replace q14cn = . if q14cn>2*/

gen q14cn = .
replace q14cn = 1 if strpos(q14c, "The district government cares") > 0
replace q14cn = 0 if strpos(q14c, "Don't Know") > 0
replace q14cn = -1 if strpos(q14c, "The district government does not care") > 0

*

/*label define n 1 "District Government officials in this district do not abuse their authority to make money for themselves" 2 "District Government officials in this district abuse their authority to make money for themselves"

encode q14d, generate(q14dn) label(n)
replace q14dn = . if q14dn>2*/

gen q14dn = .
replace q14dn = 1 if strpos(q14d, "District Government officials in this district do not abuse") > 0
replace q14dn = 0 if strpos(q14d, "Don't Know") > 0
replace q14dn = -1 if strpos(q14d, "District Government officials in this district abuse") > 0

*

/*label define o 1 "In general, the district government officials are doing their jobs honestly" 2 "In general, the district government officials are not doing their jobs honestly"

encode q14f, generate(q14fn) label(o)
replace q14fn = . if q14fn>2*/

gen q14fn = .
replace q14fn = 1 if strpos(q14f, "In general, the district government officials are doing their jobs honestly") > 0
replace q14fn = 0 if strpos(q14f, "Don't Know") > 0
replace q14fn = -1 if strpos(q14f, "In general, the district government officials are not doing their jobs honestly") > 0

*

/*label define p 1 "The District Government delivers basic services to this area in a fair manner" 2 "The District Government does not deliver basic services to this area in a fair manner"

encode q14g, generate(q14gn) label(p)
replace q14gn = . if q14gn>2*/

gen q14gn = .
replace q14gn = 1 if strpos(q14g, "The District Government delivers basic services to this area in a fair manner") > 0
replace q14gn = 0 if strpos(q14g, "Don't Know") > 0
replace q14gn = -1 if strpos(q14g, "The District Government does not deliver basic services to this area in a fair manner") > 0


***

local lhs = "q14bn q14cn q14dn q14fn q14gn"
local indexname = "q14b_q14f_index"
local rhs = "all_cleared"

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

************

/*encode q15, generate(q15n) label(h)
replace q15n = . if q15n>5*/

gen q15n = .
replace q15n = 2 if strpos(q15, "Improved a lot") > 0
replace q15n = 1 if strpos(q15, "Improved a little") > 0
replace q15n = 0 if strpos(q15, "Not changed") > 0 | strpos(q15, "Don't Know") > 0
replace q15n = -1 if strpos(q15, "Worsened a little") > 0
replace q15n = -2 if strpos(q15, "Worsened a lot") > 0

*

/*label define q 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Somewhat dissatisfied" 4 "Very dissatisfied"

encode q16a, generate(q16an) label(q)
replace q16an = . if q16an>4*/

gen q16an = .
replace q16an = 2 if strpos(q16a, "Very satisfied") > 0
replace q16an = 1 if strpos(q16a, "Somewhat satisfied") > 0
replace q16an = 0 if strpos(q16a, "Don't Know") > 0 | strpos(q16a, "Service not provided") > 0
replace q16an = -1 if strpos(q16a, "Somewhat dissatisfied") > 0
replace q16an = -2 if strpos(q16a, "Very dissatisfied") > 0

/*encode q16b, generate(q16bn) label(q)
replace q16bn = . if q16bn>4*/

gen q16bn = .
replace q16bn = 2 if strpos(q16b, "Very satisfied") > 0
replace q16bn = 1 if strpos(q16b, "Somewhat satisfied") > 0
replace q16bn = 0 if strpos(q16b, "Don't Know") > 0 | strpos(q16b, "Service not provided") > 0
replace q16bn = -1 if strpos(q16b, "Somewhat dissatisfied") > 0
replace q16bn = -2 if strpos(q16b, "Very dissatisfied") > 0

/*encode q16c, generate(q16cn) label(q)
replace q16cn = . if q16cn>4*/

gen q16cn = .
replace q16cn = 2 if strpos(q16c, "Very satisfied") > 0
replace q16cn = 1 if strpos(q16c, "Somewhat satisfied") > 0
replace q16cn = 0 if strpos(q16c, "Don't Know") > 0 | strpos(q16c, "Service not provided") > 0
replace q16cn = -1 if strpos(q16c, "Somewhat dissatisfied") > 0
replace q16cn = -2 if strpos(q16c, "Very dissatisfied") > 0

/*encode q16d, generate(q16dn) label(q)
replace q16dn = . if q16dn>4*/

gen q16dn = .
replace q16dn = 2 if strpos(q16d, "Very satisfied") > 0
replace q16dn = 1 if strpos(q16d, "Somewhat satisfied") > 0
replace q16dn = 0 if strpos(q16d, "Don't Know") > 0 | strpos(q16d, "Service not provided") > 0
replace q16dn = -1 if strpos(q16d, "Somewhat dissatisfied") > 0
replace q16dn = -2 if strpos(q16d, "Very dissatisfied") > 0

/*encode q16e, generate(q16en) label(q)
replace q16en = . if q16en>4*/

gen q16en = .
replace q16en = 2 if strpos(q16e, "Very satisfied") > 0
replace q16en = 1 if strpos(q16e, "Somewhat satisfied") > 0
replace q16en = 0 if strpos(q16e, "Don't Know") > 0 | strpos(q16e, "Service not provided") > 0
replace q16en = -1 if strpos(q16e, "Somewhat dissatisfied") > 0
replace q16en = -2 if strpos(q16e, "Very dissatisfied") > 0

/*encode q16f, generate(q16fn) label(q)
replace q16fn = . if q16fn>4*/

gen q16fn = .
replace q16fn = 2 if strpos(q16f, "Very satisfied") > 0
replace q16fn = 1 if strpos(q16f, "Somewhat satisfied") > 0
replace q16fn = 0 if strpos(q16f, "Don't Know") > 0 | strpos(q16f, "Service not provided") > 0
replace q16fn = -1 if strpos(q16f, "Somewhat dissatisfied") > 0
replace q16fn = -2 if strpos(q16f, "Very dissatisfied") > 0

/*encode q16g, generate(q16gn) label(q)
replace q16gn = . if q16gn>4*/

gen q16gn = .
replace q16gn = 2 if strpos(q16g, "Very satisfied") > 0
replace q16gn = 1 if strpos(q16g, "Somewhat satisfied") > 0
replace q16gn = 0 if strpos(q16g, "Don't Know") > 0 | strpos(q16g, "Service not provided") > 0
replace q16gn = -1 if strpos(q16g, "Somewhat dissatisfied") > 0
replace q16gn = -2 if strpos(q16g, "Very dissatisfied") > 0

/*encode q16h, generate(q16hn) label(q)
replace q16hn = . if q16hn>4*/

gen q16hn = .
replace q16hn = 2 if strpos(q16h, "Very satisfied") > 0
replace q16hn = 1 if strpos(q16h, "Somewhat satisfied") > 0
replace q16hn = 0 if strpos(q16h, "Don't Know") > 0 | strpos(q16h, "Service not provided") > 0
replace q16hn = -1 if strpos(q16h, "Somewhat dissatisfied") > 0
replace q16hn = -2 if strpos(q16h, "Very dissatisfied") > 0

/*encode q16i, generate(q16in) label(q)
replace q16in = . if q16in>4*/*/

gen q16in = .
replace q16in = 2 if strpos(q16i, "Very satisfied") > 0
replace q16in = 1 if strpos(q16i, "Somewhat satisfied") > 0
replace q16in = 0 if strpos(q16i, "Don't Know") > 0 | strpos(q16i, "Service not provided") > 0
replace q16in = -1 if strpos(q16i, "Somewhat dissatisfied") > 0
replace q16in = -2 if strpos(q16i, "Very dissatisfied") > 0

***

local lhs = "q16an q16bn q16cn q16dn q16en q16fn q16gn q16hn q16in"
local indexname = "q16a_q16i_index"
local rhs = "all_cleared"

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

************

/*encode w1_q36a, generate(w1_q36an) label(k)
replace w1_q36an = . if w1_q36an>4*/

gen w1_q36an = .
replace w1_q36an = 1 if strpos(w1_q36a, "More available") > 0
replace w1_q36an = 0 if strpos(w1_q36a, "About the same") > 0 | strpos(w1_q36a, "Don't Know") > 0 | strpos(w1_q36a, "Have not been available") > 0
replace w1_q36an = -1 if strpos(w1_q36a, "Less available") > 0

/*encode w1_q36b, generate(w1_q36bn) label(k)
replace w1_q36bn = . if w1_q36bn>4*/

gen w1_q36bn = .
replace w1_q36bn = 1 if strpos(w1_q36b, "More available") > 0
replace w1_q36bn = 0 if strpos(w1_q36b, "About the same") > 0 | strpos(w1_q36b, "Don't Know") > 0 | strpos(w1_q36b, "Have not been available") > 0
replace w1_q36bn = -1 if strpos(w1_q36b, "Less available") > 0

/*encode w1_q36c, generate(w1_q36cn) label(k)
replace w1_q36cn = . if w1_q36cn>4*/

gen w1_q36cn = .
replace w1_q36cn = 1 if strpos(w1_q36c, "More available") > 0
replace w1_q36cn = 0 if strpos(w1_q36c, "About the same") > 0 | strpos(w1_q36c, "Don't Know") > 0 | strpos(w1_q36c, "Have not been available") > 0
replace w1_q36cn = -1 if strpos(w1_q36c, "Less available") > 0

/*encode w1_q36d, generate(w1_q36dn) label(k)
replace w1_q36dn = . if w1_q36dn>4*/

gen w1_q36dn = .
replace w1_q36dn = 1 if strpos(w1_q36d, "More available") > 0
replace w1_q36dn = 0 if strpos(w1_q36d, "About the same") > 0 | strpos(w1_q36d, "Don't Know") > 0 | strpos(w1_q36d, "Have not been available") > 0
replace w1_q36dn = -1 if strpos(w1_q36d, "Less available") > 0

/*encode w1_q36f, generate(w1_q36fn) label(k)
replace w1_q36fn = . if w1_q36fn>4*/

gen w1_q36fn = .
replace w1_q36fn = 1 if strpos(w1_q36f, "More available") > 0
replace w1_q36fn = 0 if strpos(w1_q36f, "About the same") > 0 | strpos(w1_q36f, "Don't Know") > 0 | strpos(w1_q36f, "Have not been available") > 0
replace w1_q36fn = -1 if strpos(w1_q36f, "Less available") > 0


***

local lhs = "w1_q36an w1_q36bn w1_q36cn w1_q36dn w1_q36fn"
local indexname = "q36a_q36f_index"
local rhs = "all_cleared"

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

************

/*encode q32, generate(q32n) label(c)
replace q32n = . if q32n>4*/

gen q32n = .
replace q32n = 2 if strpos(q32, "Increased a lot") > 0
replace q32n = 1 if strpos(q32, "Increased a little") > 0
replace q32n = 0 if strpos(q32, "Stayed about the same") > 0 | strpos(q32, "Don't Know") > 0
replace q32n = -1 if strpos(q32, "Decreased a little") > 0
replace q32n = -2 if strpos(q32, "Decreased a lot") > 0

*

/*label define r 1 "A lot more" 2 "A little more" 3 "About the same" 4 "A little less" 5 "A lot less"

encode q33, generate(q33n) label(r)
replace q33n = . if q33n>5

levelsof q33*/

gen q33n = .
replace q33n = 2 if strpos(q33, "A lot more") > 0
replace q33n = 1 if strpos(q33, "A little more") > 0
replace q33n = 0 if strpos(q33, "About the same") > 0 | strpos(q33, "Don't Know") > 0
replace q33n = -1 if strpos(q33, "A little less") > 0
replace q33n = -2 if strpos(q33, "A lot less") > 0

***

//government satisfaction super-index

local lhs = "q11an q11bn q11cn q11dn q14bn q14cn q14dn q14fn q14gn q16an q16bn q16cn q16dn q16en q16fn q16gn q16hn q16in"
local indexname = "govtrust_super_index"
local rhs = "all_cleared"

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

//security super-index

local lhs = "q2an q2bn q3bn q4cn q4dn"
local indexname = "security_super_index"
local rhs = "all_cleared"

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

save "$data/misti_panel_formatted", replace


