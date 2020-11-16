

global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

import delimited "$data/pre_panel.csv", clear

* drop IHAs
reshape long ntl popcount popdensity ha_count area_cleared, i(cell_id) j(year)

drop if year==2014 | (year>2015 & year<2020)

gen log_popcount = log(popcount)
gen log_popdensity = log(popdensity)

gen all_cleared = (ha_count==0)

*gen time_to_cha_clearance = (year - cha_clearance_year)
*gen cha_cleared = (time_to_cha_clearance >= 0) & !missing(cha_clearance_year)
*replace cha_cleared = 1 if has_cha==0

*gen all_clearance_yr = max(cha_clearance_year, sha_clearance_year)
*gen time_to_all_clearance = (year-all_clearance_yr)
* gen all_cleared = (time_to_all_clearance >= 0) & !missing(all_clearance_yr)

*gen a = subinstr(cha_enddate, "-", "", .)
*gen c = date(a, "YMD")
*format c %d
*gen cha_yr = year(c)

*gen d = subinstr(cha_enddate, "-", "", .)
*gen e = date(d, "YMD")
*format e %d
*gen sha_yr = year(e)

egen district_id = group(gid_2)
egen province_id = group(gid_1)

egen year_province = group(year province_id)


replace distance_to_road = distance_to_road / 1000

bys cell_id (year): gen cleared_by_2013 = all_cleared[22]
su ntl if cleared_by_2013==1
su ntl if cleared_by_2013==0

bys cleared_by_2013: su all_cleared if year==2013


bysort cell_id (year): gen baseline_pop = popdensity[9]

gen absorb_temp=1

*export delimited "$data/panel.csv", replace

outreg2 using "$results/summary_statistics_1km.doc", replace sum(log)
rm "$results/summary_statistics_1km.txt"

***************************************************************


* main results

reghdfe ntl all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", replace noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.baseline_pop  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_kabul  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_ntl.txt"


reghdfe log_popcount all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", replace noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.all_cleared##c.distance_to_kabul  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popdensity all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", replace noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_popdensity.txt"


***************************************************************

xtile q_baseline_pop = baseline_pop, nq(5)

reghdfe ntl ibn.q_baseline_pop#c.all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_baseline_pop#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Baseline population count (quintile)") ytitle("Effect on NTL") rename(1.q_baseline_pop#c.all_cleared = 1 2.q_baseline_pop#c.all_cleared = 2 3.q_baseline_pop#c.all_cleared = 3 4.q_baseline_pop#c.all_cleared = 4 5.q_baseline_pop#c.all_cleared = 5) saving("$results/baseline_pop_quintile", replace)

***

xtile q_distance_to_road = distance_to_road, nq(5)

reghdfe ntl ibn.q_distance_to_road#c.all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_distance_to_road#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Distance to road (quintile)") ytitle("Effect on NTL") rename(1.q_distance_to_road#c.all_cleared = 1 2.q_distance_to_road#c.all_cleared = 2 3.q_distance_to_road#c.all_cleared = 3 4.q_distance_to_road#c.all_cleared = 4 5.q_distance_to_road#c.all_cleared = 5) saving("$results/distance_to_road_quintile", replace)

***

xtile q_pct_area = pct_area, nq(5)

reghdfe ntl ibn.q_pct_area#c.all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_pct_area#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Pct. area that is hazardous") ytitle("Effect on NTL")

***

gen time_to_trt1 = year*all_cleared
replace time_to_trt1=. if time_to_trt1==0
egen time_to_trt2 = min(time_to_trt1), by(cell_id)

gen time_to_trt3 = year-time_to_trt2
replace time_to_trt3 = time_to_trt3+30
replace time_to_trt3 = . if time_to_trt3<22
replace time_to_trt3 = . if time_to_trt3>38

reghdfe ntl ib30.time_to_trt3 [aw=pct_area], absorb(cell_id) cluster(district_id year)
coefplot, keep(*.time_to_trt3) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white) xtitle("Years to complete hazard clearance") ytitle("Treatment effects on NTL") rename(22.time_to_trt3 = -8 23.time_to_trt3 = -7 24.time_to_trt3 = -6 25.time_to_trt3 = -5 26.time_to_trt3 = -4 27.time_to_trt3 = -3 28.time_to_trt3 = -2 29.time_to_trt3 = -1 30.time_to_trt3 = 0 31.time_to_trt3 = 1 32.time_to_trt3 = 2 33.time_to_trt3 = 3 34.time_to_trt3 = 4 35.time_to_trt3 = 5 36.time_to_trt3 = 6 37.time_to_trt3 = 7 38.time_to_trt3 = 8) saving("$results/event_study", replace)

gen first_cleared = (total_ha-ha_count!=0) * year
replace first_cleared=. if first_cleared==0
egen first_cleared2 = min(first_cleared), by(cell_id)
gen first_cleared3 = year-first_cleared2
replace first_cleared3 = first_cleared3+30
replace first_cleared3 = . if first_cleared3<22
replace first_cleared3 = . if first_cleared3>38

reghdfe ntl ib30.first_cleared3 [aw=pct_area], absorb(cell_id) cluster(district_id year)
coefplot, keep(*.first_cleared3) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white) xtitle("Years to first hazard clearance") ytitle("Treatment effects on NTL") rename(22.first_cleared3 = -8 23.first_cleared3 = -7 24.first_cleared3 = -6 25.first_cleared3 = -5 26.first_cleared3 = -4 27.first_cleared3 = -3 28.first_cleared3 = -2 29.first_cleared3 = -1 30.first_cleared3 = 0 31.first_cleared3 = 1 32.first_cleared3 = 2 33.first_cleared3 = 3 34.first_cleared3 = 4 35.first_cleared3 = 5 36.first_cleared3 = 6 37.first_cleared3 = 7 38.first_cleared3 = 8) saving("$results/event_study_b", replace)

********************************************************************************

gen min_year_tmp = (ha_count!=total_ha) * year
replace min_year_tmp=. if min_year_tmp==0
egen min_year = min(min_year_tmp), by(cell_id)

replace min_year=2002 if min_year<2003
replace min_year=. if min_year>=2015

local year_lab ""
forv y = 2003/2013 {
	local year_lab "`year_lab' `y'.min_year#c.year = `y'"
}

reghdfe ntl ibn.min_year#c.year if year<2003 [aw=pct_area], absorb(cell_id) cluster(district_id year)
coefplot, keep(*.min_year*) vertical graphregion(color(white)) legend(off) xtitle("Year of first clearance activity") ytitle("Pre-2003 trend in NTL") rename(`year_lab') xlabel(, labsize(vsmall) alternate)



********************************************************************************


* bys year: su ntl

* preserve

* collapse (mean) ntl popcount popdensity, by(year)

drop cell_id gid_1 name_1 gid_2 name_2

ds district_id year popcount baseline_pop ha_count, not
collapse (mean) `r(varlist)' (sum) popcount baseline_pop ha_count, by(district_id year)

replace all_cleared = (all_cleared==1)

su

drop log_popcount log_popdensity
gen log_popcount = log(popcount)
gen log_popdensity = log(popdensity)

levelsof province_id
levelsof district_id
levelsof year_province

***

*  district level
reghdfe ntl ha_count [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", replace noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", N, "Year*Prov. FEs", N)

reghdfe ntl ha_count [aw=pct_area], absorb(year) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "District FEs", N, "Year*Prov. FEs", N)

reghdfe ntl ha_count [aw=pct_area], absorb(year district_id) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "District FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl ha_count [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.ha_count##c.distance_to_road [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.ha_count##c.baseline_pop [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.ha_count##c.distance_to_kabul [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_district_ntl.txt"



reghdfe log_popcount ha_count [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", replace noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount ha_count [aw=pct_area], absorb(year) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount ha_count [aw=pct_area], absorb(year district_id) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount ha_count [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.ha_count##c.distance_to_road [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.ha_count##c.distance_to_kabul [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)



reghdfe log_popdensity ha_count [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", replace noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity ha_count [aw=pct_area], absorb(year) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity ha_count [aw=pct_area], absorb(year district_id) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity ha_count [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.ha_count##c.distance_to_road [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.ha_count##c.distance_to_kabul [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


rm "$results/main_models_district_popdensity.txt"

***


collapse (mean) ntl popcount popdensity all_cleared, by(year cleared_by_2013)

sort cell_id year


twoway (connect ntl year if cleared_by_2013==1 & year<=2013) (connect ntl year if cleared_by_2013==0 & year<=2013), xlabel(1992(2)2013) xtitle("Year") ytitle("NTL") legend(order(1 "Cleared by 2013" 2 "Not cleared by 2013")) bgcolor(white) graphregion(color(white)) saving("$results/ntl_timeseries", replace)


*twoway (connect popcount year if cleared_by_2013==1) (connect popcount year if cleared_by_2013==0), xtitle("Year") ytitle("Population") legend(order(1 "Cleared by 2013" 2 "Not cleared by 2013")) bgcolor(white) graphregion(color(white)) 

*twoway connect ntl year
*twoway connect popcount year
*twoway connect popdensity year












