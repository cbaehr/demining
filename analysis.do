

global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

import delimited "$data/pre_panel.csv", clear

* drop IHAs
gen drop_iha = has_cha+has_sha
drop if drop_iha==0

reshape long ntl popcount popdensity, i(cell_id) j(year)

gen log_popcount = log(popcount)
gen log_popdensity = log(popdensity)

gen time_to_cha_clearance = (year - cha_clearance_year)
gen cha_cleared = (time_to_cha_clearance >= 0) & !missing(cha_clearance_year)
replace cha_cleared = 1 if has_cha==0

gen time_to_sha_clearance = (year - sha_clearance_year)
gen sha_cleared = (time_to_sha_clearance >= 0) & !missing(sha_clearance_year)
replace sha_cleared = 1 if has_sha==0

gen all_clearance_yr = max(cha_clearance_year, sha_clearance_year)
gen time_to_all_clearance = (year-all_clearance_yr)
* gen all_cleared = (time_to_all_clearance >= 0) & !missing(all_clearance_yr)

gen all_cleared = (cha_cleared * sha_cleared)

gen any_road_blockage = (cha_road_blockage + sha_road_blockage) > 0

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

gen absorb_temp=1

replace distance_to_road = distance_to_road / 1000

*egen a = mean(cha_trt), by(cell_id)
*egen b = mean(sha_trt), by(cell_id)
*gen c = a+b
*drop if c==0

bysort cell_id (year): gen baseline_pop = popdensity[9]

*export delimited "$data/panel.csv", replace

outreg2 using "$results/summary_statistics_1km.doc", replace sum(log)
rm "$results/summary_statistics_1km.txt"

***************************************************************

* CHA only results

reghdfe ntl cha_cleared [aw=pct_area_cha], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", replace noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl cha_cleared [aw=pct_area_cha], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl cha_cleared [aw=pct_area_cha], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl cha_cleared [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.cha_cleared##c.distance_to_road  [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.cha_cleared##c.baseline_pop  [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popcount cha_cleared [aw=pct_area_cha], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount cha_cleared [aw=pct_area_cha], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount cha_cleared [aw=pct_area_cha], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount cha_cleared [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.cha_cleared##c.distance_to_road  [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popdensity cha_cleared [aw=pct_area_cha], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity cha_cleared [aw=pct_area_cha], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity cha_cleared [aw=pct_area_cha], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity cha_cleared [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.cha_cleared##c.distance_to_road  [aw=pct_area_cha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_cha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_cha.txt"

***

* SHA only results

reghdfe ntl sha_cleared [aw=pct_area_sha], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", replace noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl sha_cleared [aw=pct_area_sha], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl sha_cleared [aw=pct_area_sha], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl sha_cleared [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.sha_cleared##c.distance_to_road  [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.sha_cleared##c.baseline_pop  [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popcount sha_cleared [aw=pct_area_sha], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount sha_cleared [aw=pct_area_sha], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount sha_cleared [aw=pct_area_sha], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount sha_cleared [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.sha_cleared##c.distance_to_road  [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popdensity sha_cleared [aw=pct_area_sha], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity sha_cleared [aw=pct_area_sha], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity sha_cleared [aw=pct_area_sha], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity sha_cleared [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.sha_cleared##c.distance_to_road  [aw=pct_area_sha], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_sha.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_sha.txt"

***


* all HA results

reghdfe ntl all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", replace noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.baseline_pop  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popcount all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popdensity all_cleared [aw=pct_area], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.all_cleared##c.distance_to_road  [aw=pct_area], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_all.doc", append noni nocons ctitle(log(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_all.txt"


***************************************************************

xtile q_baseline_pop = baseline_pop, nq(5)

reghdfe ntl ibn.q_baseline_pop#c.all_cleared, absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_baseline_pop#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off)

***

* replace time_to_all_clearance = time_to_all_clearance+30

* replace time_to_all_clearance = . if time_to_all_clearance>40 | time_to_all_clearance<20

gen test = time_to_all_clearance
replace test = test+30
replace test = 20 if test<20 & !missing(test)
replace test = 40 if test>40 & !missing(test)



reghdfe ntl ib30.test if year<=2013 & all_clearance_yr<=2013, absorb(cell_id year) cluster(district_id year)

coefplot, keep(*.test) vertical omit recast(line) ciopts(recast(rline) color(blue) lp(dash))








egen yrtodem_p = cut(yrtodem), at(-30 -10(1)13)
levelsof yrtodem_p, loc(levels) sep()
foreach l of local levels{
	local j = `l' + 30
	local label `"`label' `j' "`l'" "'
	} 
cap la drop yrtodem_p	
la def  yrtodem_p `label'

replace yrtodem_p = yrtodem_p + 30
la values  yrtodem_p yrtodem_p


reghdfe maxl_ ib30.yrtodem_p `climate' i.year, cluster(reu_id year) absorb(reu_id)

coefplot, keep(*.yrtodem_p) drop(0.yrtodem_p) xline(10.5) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white)  ///
	xtitle("Years to demarcation") ytitle("Treatment effects on NDVI")
graph save Graph "C:\Users\Ariel\Dropbox\AidData\KfW\Paper\Data\Years-to-demarcation community FE.gph", replace





***

xtile q_count = cell_count_30m, nq(5)
xtile q_pct_area = pct_area, nq(5)

reghdfe ntl ibn.q_pct_area#c.all_cleared, absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_pct_area#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off)


reghdfe ndvi ibn.q_count#c.(trt_overall_road trt_overall_irrigation trt_overall_else) temperature precipitation, absorb(cell_id year_province) cluster(commune_id year)

* a)
coefplot, keep(*.q_count#c.trt_overall_road) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Quintile of share initially forested") ytitle("Effect of roads on NDVI") rename(1.q_count#c.trt_overall_road = 1 2.q_count#c.trt_overall_road = 2 3.q_count#c.trt_overall_road = 3 4.q_count#c.trt_overall_road = 4 5.q_count#c.trt_overall_road = 5) ylabel(-0.002(0.002)0.008) yscale(range(-0.002(0.002)0.008)) saving(figure4_a, replace)

* b)
coefplot, keep(*.q_count#c.trt_overall_irrigation) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Quintile of share initially forested") ytitle("Effect of irrigation on NDVI") rename(1.q_count#c.trt_overall_irrigation = 1 2.q_count#c.trt_overall_irrigation = 2 3.q_count#c.trt_overall_irrigation = 3 4.q_count#c.trt_overall_irrigation = 4 5.q_count#c.trt_overall_irrigation = 5) ylabel(-0.002(0.002)0.008) yscale(range(-0.002(0.002)0.008)) saving(figure4_b, replace)

reghdfe treecover ibn.q_count#c.(trt_overall_road trt_overall_irrigation trt_overall_else) temperature precipitation, absorb(cell_id year_province) cluster(commune_id year)




***************************************************************

gen time_to_cha_clearance_fac = time_to_cha_clearance + 40
replace time_to_cha_clearance_fac = 30 if time_to_cha_clearance_fac<30
replace time_to_cha_clearance_fac = 50 if time_to_cha_clearance_fac>50

egen test = cut(time_to_cha_clearance), at(-30 -10(1)13)
levelsof test, loc(levels) sep()
foreach l of local levels {
	local j = `l' + 30
	local label `"`label' `j' "`l'" "'
}

cap la drop test
la def test `label'

replace test = test+30
la values test test

reghdfe ntl i.test, absorb(cell_id year_province) cluster(district_id year)
estimate store e1
coefplot, keep(*test) drop(0.test) vertical omit recast(line)



egen yrtodem_p = cut(yrtodem), at(-30 -10(1)13)
levelsof yrtodem_p, loc(levels) sep()
foreach l of local levels{
	local j = `l' + 30
	local label `"`label' `j' "`l'" "'
	} 
cap la drop yrtodem_p	
la def  yrtodem_p `label'

replace yrtodem_p = yrtodem_p + 30
la values  yrtodem_p yrtodem_p


reghdfe maxl_ ib30.yrtodem_p `climate' i.year, cluster(reu_id year) absorb(reu_id)

coefplot, keep(*.yrtodem_p) drop(0.yrtodem_p) xline(10.5) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white)  ///
	xtitle("Years to demarcation") ytitle("Treatment effects on NDVI")
graph save Graph "C:\Users\Ariel\Dropbox\AidData\KfW\Paper\Data\Years-to-demarcation community FE.gph", replace











forvalues i = -10/9 {
	local labels `labels' `i'
}

display "`labels'"

coefplot, keep(*.time_to_cha_clearance_fac) drop(50.time_to_cha_clearance_fac) vertical omit recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash)) graphregion(color(white)) bgcolor(white) xtitle("Years to demarcation") ytitle("Treatment effects on NDVI") xscale(range(0 20)) byopts(xrescale) bycoefs bylabels("-10" "-9" "-8" "-7" "-6" "-5" "-4" "-3" "-2" "-1")

bylabels(`labels')

rename(30.time_to_cha_clearance_fac 30)

xlabel(-10(1)9) xscale(range(30(1)49))

yscale(range(-0.05(0.05)0.15))

forvalues i = 70/73 {
    regress ln_w grade age if year == `i'
    estimates store year`i'
    local allyears `allyears' year`i' ||
    local labels `labels' `i'
}


coefplot, keep(*.yrtodem_p) drop(0.yrtodem_p) xline(10.5) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white)  ///
	xtitle("Years to demarcation") ytitle("Treatment effects on NDVI")


***************************************************************

* bys year: su ntl

* preserve

* collapse (mean) ntl popcount popdensity, by(year)

drop cell_id gid_1 name_1 gid_2 name_2

ds district_id year popcount baseline_pop, not
collapse (mean) `r(varlist)' (sum) popcount baseline_pop, by(district_id year)

replace any_road_blockage = 1 if any_road_blockage>0 & !missing(any_road_blockage)

su

levelsof province_id
levelsof district_id

***

* CHA only results - district level
reghdfe ntl cha_cleared [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", replace noni nocons ctitle(NTL) addtext("Grid cell FEs", N, "Year FEs", N)

reghdfe ntl cha_cleared [aw=pct_area], absorb(year_province) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", N, "Year FEs", Y)

reghdfe ntl cha_cleared [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe ntl c.cha_cleared##c.distance_to_road [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe ntl c.cha_cleared##c.baseline_pop [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)



reghdfe popcount cha_cleared [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", N, "Year FEs", N)

reghdfe popcount cha_cleared [aw=pct_area], absorb(year_province) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", N, "Year FEs", Y)

reghdfe popcount cha_cleared [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe popcount c.cha_cleared##c.distance_to_road [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe popcount c.cha_cleared##c.baseline_pop [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_cha_commune.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

rm "$results/main_models_cha_commune.txt"


***

* SHA only results - district level
reghdfe ntl sha_cleared [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", replace noni nocons ctitle(NTL) addtext("Grid cell FEs", N, "Year FEs", N)

reghdfe ntl sha_cleared [aw=pct_area], absorb(year_province) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", N, "Year FEs", Y)

reghdfe ntl sha_cleared [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe ntl c.sha_cleared##c.distance_to_road [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)



reghdfe popcount sha_cleared [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", N, "Year FEs", N)

reghdfe popcount sha_cleared [aw=pct_area], absorb(year_province) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", N, "Year FEs", Y)

reghdfe popcount sha_cleared [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe popcount c.sha_cleared##c.distance_to_road [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_sha_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

rm "$results/main_models_sha_district.txt"

***

* results considering both SHA and CHA - district level
reghdfe ntl all_cleared [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", replace noni nocons ctitle(NTL) addtext("Grid cell FEs", N, "Year FEs", N)

reghdfe ntl all_cleared [aw=pct_area], absorb(year_province) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", N, "Year FEs", Y)

reghdfe ntl all_cleared [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe ntl all_cleared [aw=pct_area], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_road [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe ntl c.all_cleared##c.baseline_pop [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(NTL) addtext("Grid cell FEs", Y, "Year FEs", Y)


reghdfe popcount all_cleared [aw=pct_area], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", N, "Year FEs", N)

reghdfe popcount all_cleared [aw=pct_area], absorb(year_province) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", N, "Year FEs", Y)

reghdfe popcount all_cleared [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe popcount c.all_cleared##c.distance_to_road [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

reghdfe popcount c.all_cleared##c.baseline_pop [aw=pct_area], absorb(district_id year) cluster(province_id year)
outreg2 using "$results/main_models_all_district.doc", append noni nocons ctitle(Pop. count) addtext("Grid cell FEs", Y, "Year FEs", Y)

rm "$results/main_models_all_district.txt"


***

collapse (mean) ntl popcount popdensity, by(year)

sort year

twoway connect ntl year

twoway connect popcount year
twoway connect popdensity year

* restore














