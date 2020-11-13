
global data "/Users/christianbaehr/Box Sync/demining/inputData"

import delimited "$data/misti/misti_panel.csv", clear

gen ha_count = total_ha-num_cleared


levelsof q1

************

label define a 1 "Right direction (a lot)" 2 "Right direction (a little)" 3 "Wrong direction (a little)" 4 "Wrong direction (a lot)"

encode q1, generate(q1n) label(a)
replace q1n = . if q1n>4

*

label define b 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Somewhat dissatisfied" 4 "Very dissatisfied"

encode q26, generate(q26n) label(b)
replace q26n = . if q26n>4

*

encode q27, generate(q27n) label(b)
replace q27n = . if q27n>4

*

label define c 1 "Increased a lot" 2 "Increased a little" 3 "Decreased a little" 4 "Decreased a lot"

encode q28, generate(q28n) label(c)
replace q28n = . if q28n>4

label define d 1 "Not worried" 2 "A little worried" 3 "Very worried"

encode q29, generate(q29n) label(d)
replace q29n = . if q29n>3

***

local lhs = "q28n q29n"
local indexname = "q28_q29_index"
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

************

label define e 1 "The situation in this area is certain enough for me to make plans for my future" 2 "The situation in this area is too uncertain for me to make plans for my future"

encode q30, generate(q30n) label(e)
replace q30n = . if q30n>2

*

label define f 1 "Very good" 2 "Good" 3 "Fair" 4 "Poor" 5 "Very poor"

encode q2a, generate(q2an) label(f)
replace q2an = . if q2an>5

*

label define g 1 "Much more secure" 2 "Somewhat more secure" 3 "About the same" 4 "Somewhat less secure" 5 "Much less secure"

encode q2b, generate(q2bn) label(g)
replace q2bn = . if q2bn>5

***

local lhs = "q2an q2bn"
local indexname = "q2a_q2b_index"
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

************

label define h 1 "Improved a lot" 2 "Improved a little" 3 "Stayed the same" 4 "Worsened a little" 5 "Worsened a lot"

encode q3b, generate(q3bn) label(h)
replace q3bn = . if q3bn>5

*

label define i 1 "Very secure" 2 "Somewhat secure" 3 "Somewhat insecure" 4 "Very insecure"

encode q4c, generate(q4cn) label(i)
replace q4cn = . if q4cn>4

*

encode q4d, generate(q4dn) label(i)
replace q4dn = . if q4dn>4

***

local lhs = "q3bn q4cn q4dn"
local indexname = "q3b_q4d_index"
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

************

label define j 1 "Much better" 2 "A little better" 3 "About the same" 4 "A little worse" 5 "Much worse"

encode q31, generate(q31n) label(j)
replace q31n = . if q31n>5

*

label define k 1 "More available" 2 "About the same" 3 "Less available" 4 "Have not been available (vol.)"

encode w1_q36e, generate(w1_q36en) label(k)
replace w1_q36en = . if w1_q36en>4

* 

encode q11a, generate(q11an) label(h)
replace q11an = . if q11an>5

*

encode q11b, generate(q11bn) label(h)
replace q11bn = . if q11bn>5

*

encode q11c, generate(q11cn) label(h)
replace q11cn = . if q11cn>5

*

encode q11d, generate(q11dn) label(h)
replace q11dn = . if q11dn>5

***

local lhs = "q11an q11bn q11cn q11dn"
local indexname = "q11a_q11d_index"
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

************

label define l 1 "The district government understands the problems of people in this area." 2 "The district government does not understand the problems of people in this area."

encode q14b, generate(q14bn) label(l)
replace q14bn = . if q14bn>2

*

label define m 1 "The district government cares about the people in this area" 2 "The district government does not care about the people in this area"

encode q14c, generate(q14cn) label(m)
replace q14cn = . if q14cn>2

*

label define n 1 "District Government officials in this district do not abuse their authority to make money for themselves" 2 "District Government officials in this district abuse their authority to make money for themselves"

encode q14d, generate(q14dn) label(n)
replace q14dn = . if q14dn>2

*

label define o 1 "In general, the district government officials are doing their jobs honestly" 2 "In general, the district government officials are not doing their jobs honestly"

encode q14f, generate(q14fn) label(o)
replace q14fn = . if q14fn>2

*

label define p 1 "The District Government delivers basic services to this area in a fair manner" 2 "The District Government does not deliver basic services to this area in a fair manner"

encode q14g, generate(q14gn) label(p)
replace q14gn = . if q14gn>2

***

local lhs = "q14bn q14cn q14dn q14fn q14gn"
local indexname = "q14b_q14f_index"
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

************

encode q15, generate(q15n) label(h)
replace q15n = . if q15n>5

*

label define q 1 "Very satisfied" 2 "Somewhat satisfied" 3 "Somewhat dissatisfied" 4 "Very dissatisfied"

encode q16a, generate(q16an) label(q)
replace q16an = . if q16an>4

encode q16b, generate(q16bn) label(q)
replace q16bn = . if q16bn>4

encode q16c, generate(q16cn) label(q)
replace q16cn = . if q16cn>4

encode q16d, generate(q16dn) label(q)
replace q16dn = . if q16dn>4

encode q16e, generate(q16en) label(q)
replace q16en = . if q16en>4

encode q16f, generate(q16fn) label(q)
replace q16fn = . if q16fn>4

encode q16g, generate(q16gn) label(q)
replace q16gn = . if q16gn>4

encode q16h, generate(q16hn) label(q)
replace q16hn = . if q16hn>4

encode q16i, generate(q16in) label(q)
replace q16in = . if q16in>4

***

local lhs = "q16an q16bn q16cn q16dn q16en q16fn q16gn q16hn q16in"
local indexname = "q16a_q16i_index"
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

************

encode w1_q36a, generate(w1_q36an) label(k)
replace w1_q36an = . if w1_q36an>4

encode w1_q36b, generate(w1_q36bn) label(k)
replace w1_q36bn = . if w1_q36bn>4

encode w1_q36c, generate(w1_q36cn) label(k)
replace w1_q36cn = . if w1_q36cn>4

encode w1_q36d, generate(w1_q36dn) label(k)
replace w1_q36dn = . if w1_q36dn>4

encode w1_q36f, generate(w1_q36fn) label(k)
replace w1_q36fn = . if w1_q36fn>4


***

local lhs = "w1_q36an w1_q36bn w1_q36cn w1_q36dn w1_q36fn"
local indexname = "q36a_q36f_index"
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

************

encode q32, generate(q32n) label(c)
replace q32n = . if q32n>4

*

label define r 1 "A lot more" 2 "A little more" 3 "About the same" 4 "A little less" 5 "A lot less"

encode q33, generate(q33n) label(r)
replace q33n = . if q33n>5

levelsof q33

***

save "$data/misti_panel_formatted", replace


