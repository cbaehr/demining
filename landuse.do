
import delimited "/Users/christianbaehr/Box Sync/demining/inputData/full_grid_landuse.csv", clear

reshape long ghs, i(cell_id) j(year)

gen time_to_trt = year - status_c_1
replace time_to_trt = . if time_to_trt>10 | time_to_trt<-10

replace time_to_trt = time_to_trt+30

encode gid_2, gen(district_id)


*reghdfe ghs ib30.time_to_trt , absorb(year district_id) cluster(year district_id)
*coefplot, keep(*.time_to_trt) xline(10) vertical omit recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white) xtitle("Years to complete hazard clearance") ytitle("Treatment effects on Built up status") rename(21.time_to_trt = -9 22.time_to_trt = -8 23.time_to_trt = -7 24.time_to_trt = -6 25.time_to_trt = -5 26.time_to_trt = -4 27.time_to_trt = -3 28.time_to_trt = -2 29.time_to_trt = -1 30.time_to_trt = 0 31.time_to_trt = 1 32.time_to_trt = 2 33.time_to_trt = 3 34.time_to_trt = 4 35.time_to_trt = 5 36.time_to_trt = 6 37.time_to_trt = 7 38.time_to_trt = 8 39.time_to_trt = 9 40.time_to_trt = 10)

*saving("$results/event_study", replace)

reghdfe ghs ib30.time_to_trt if status_c_1<2008, absorb(year district_id) cluster(year district_id)
estout using "/Users/christianbaehr/Downloads/model_pre2008.tsv", replace cells("b se ci_l ci_u") mlabels(,none)

reghdfe ghs ib30.time_to_trt if status_c_1>=2008, absorb(year district_id) cluster(year district_id)
estout using "/Users/christianbaehr/Downloads/model_post2008.tsv", replace cells("b se ci_l ci_u") mlabels(,none)

import delimited "/Users/christianbaehr/Downloads/model_pre2008.tsv", clear

gen index=_n
replace index = index-10

twoway(line b index, color(blue)) (line min95 index, lp(dash) color(blue)) (line max95 index, lp(dash) color(blue)), graphregion(color(white)) bgcolor(white) xtitle(Time to complete hazard clearance) ytitle(Treatment effect on built up status) xline(0) legend(off) xlabel(-9(1)10)

*********

import delimited "/Users/christianbaehr/Downloads/model_pre2008.tsv", clear

gen index=_n
replace index = index-9

twoway(line b index, color(blue)) (line min95 index, lp(dash) color(blue)) (line max95 index, lp(dash) color(blue)) if index<11, graphregion(color(white)) bgcolor(white) xtitle(Time to complete hazard clearance (Pre-2008 sample)) ytitle(Treatment effect on built up status) xline(0) legend(off) xlabel(-8(1)10)


import delimited "/Users/christianbaehr/Downloads/model_post2008.tsv", clear

gen index=_n
replace index = index-9

twoway(line b index, color(blue)) (line min95 index, lp(dash) color(blue)) (line max95 index, lp(dash) color(blue)) if index<11, graphregion(color(white)) bgcolor(white) xtitle(Time to complete hazard clearance (Post-2008 sample)) ytitle(Treatment effect on built up status) xline(0) legend(off) xlabel(-8(1)10)






