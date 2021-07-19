
********************
* GIE of Mine Action in Afghanistan from 1990-2020
* For ITAD / FCDO
* Data processing as well as main summary statistics and statistical models
********************

* set global macros for working directories
global data "/Users/christianbaehr/Box Sync/demining/inputData"
global results "/Users/christianbaehr/Box Sync/demining/Results"

* import cross-sectional data
import delimited "$data/pre_panel_1km_updated.csv", clear

* convert data to panel, reshape time-series variables, year is time variable and cell_id as panel variable
reshape long ntl popcount popdensity ha_count area_cleared ucdp_events builtup entry_cost network_cost exit_cost, i(cell_id) j(year)

* generate logs of population variables
gen log_popcount = log(popcount)
gen log_popdensity = log(popdensity)

* dummy indicating if cell i has zero hazardous areas in year j
gen all_cleared = (ha_count==0)

* create new variable indicating which year cell i received its first clearance treatment.
* which years is the count of HAs not equal to the total number of HAs for that cell?
gen first_trt_tmp = (ha_count!=total_ha) * year
* replace zeroes with missing for the min function to run correct
replace first_trt_tmp = . if first_trt_tmp==0
* find the minimum year in which ha_count != total_ha, this is the first year clearance happened
egen first_clearance_year = min(first_trt_tmp), by(cell_id)

* create new variable indicating which year cell i received its last clearance treatment.
* which years were there no hazardous areas left for cell i?
gen last_trt_tmp = (ha_count==0) * year
* replace zeroes with missing for the min function to run correct
replace last_trt_tmp = . if last_trt_tmp==0
* find the min year
egen last_clearance_year = min(last_trt_tmp), by(cell_id)
* only considering window -2013, so post-2013 clearance set to missing
replace last_clearance_year= . if last_clearance_year>2013

* generate cell-level variable indicating number of years between first and last clearance activity
gen time_of_clearance = last_clearance_year-first_clearance_year

* generate numeric district and province IDs for use in models
egen district_id = group(gid_2)
egen province_id = group(gid_1)

* generate year-province grouping variable
egen year_province = group(year province_id)

* change unit to km
replace distance_to_road = distance_to_road / 1000

* indicate if cell if fully cleared in 2013
bys cell_id (year): gen cleared_by_2013 = all_cleared[22]
su ntl if cleared_by_2013==1
su ntl if cleared_by_2013==0
bys cleared_by_2013: su all_cleared if year==2013

* generate pre-clearance baseline population variable
bysort cell_id (year): gen baseline_pop = popdensity[9]

* max and min nighttime light by cell
egen max_ntl = max(ntl), by(cell_id)
egen min_ntl = min(ntl), by(cell_id)

* gen cell-level sum of total ucdp conflict events over time
egen total_ucdp_events = sum(ucdp_events), by(cell_id)

* dummy indicating if a cell was cleared after 2008
gen cleared_post2008 = (cleared_pre2008==0)

* gen dummies indicating which period the cell was completely cleared in
gen sample1_a = (last_clearance_year<2006)
gen sample1_b = (last_clearance_year>=2006 & last_clearance_year<2008)
gen sample2_a = (last_clearance_year>=2008 & last_clearance_year<2011)
gen sample2_b = (last_clearance_year>=2011 & last_clearance_year<=2013)

* will use this variable so reghdfe can still run in models w/ no FEs
gen absorb_temp=1

*export delimited "$data/panel.csv", replace

* write summary statistics for all variables to Word doc
outreg2 using "$results/summary_statistics_1km.doc", replace sum(log)
rm "$results/summary_statistics_1km.txt"

***************************************************************

*** generate a balance table of areas cleared pre- and post-2008

* set current directory
cd "$results"

* add variable labels 
label var pct_area_mined "Percent of cell mined"
label var total_ha "Number hazardous areas in cell"
label var popcount "Population count"
label var distance_to_road "Distance to year-round road"
label var distance_to_kabul "Distance to Kabul"
label var ntl "Nighttime light"
label var ucdp_events "Conflict events"
label var water "Water blockages"
label var road "Road blockages"
label var mines "Mine blockages"
label var historical "Historical blockages"
label var housing "Housing blockages"
label var infrastructure "Infra. blockages"
label var agriculture "Agriculture blockages"
label var grazing "Grazing blockages"


*gen treatment_q1 = ()

***Part 2: using outreg
global DESCVARS pct_area_mined total_ha popcount distance_to_road distance_to_kabul ntl ucdp_events water road mines historical housing infrastructure agriculture grazing
mata: mata clear

* First test of differences
local i = 1

foreach var in $DESCVARS {
    reg `var' cleared_post2008, vce(cluster cell_id)
    outreg, keep(cleared_post2008)  rtitle("`: var label `var''") stats(b) ///
        noautosumm store(row`i')  starlevels(10 5 1) starloc(1)
    outreg, replay(diff) append(row`i') ctitles("",Difference ) ///
        store(diff) note("")
    local ++i
}
outreg, replay(diff)

* Then Summary statistics
local count: word count $DESCVARS
mat sumstat = J(`count',6,.)

local i = 1
foreach var in $DESCVARS {
    quietly: summarize `var' if cleared_post2008==0
    mat sumstat[`i',1] = r(N)
    mat sumstat[`i',2] = r(mean)
    mat sumstat[`i',3] = r(sd)
    quietly: summarize `var' if cleared_post2008==1
    mat sumstat[`i',4] = r(N)
    mat sumstat[`i',5] = r(mean)
    mat sumstat[`i',6] = r(sd)
    local i = `i' + 1
}
frmttable, statmat(sumstat) store(sumstat) sfmt(g,f,f,g,f,f)

*And export
outreg using "$results/balance_table_1km.tex", ///
    replay(sumstat) merge(diff) tex nocenter note("") fragment plain replace ///
    ctitles("", Pre-2008 Treatment Sample, "", "", Post-2008 Treatment Sample, "", "", "" \ "", n, mean, sd, n, mean, sd, Diff) ///
    multicol(1,2,3;1,5,3) 
	
***Part 3: using postfiles
tempname memhold
tempfile stats_icc
postfile `memhold' str60 Variable N Mean SD ICC   using "`stats_icc'"

foreach var in $DESCVARS {
    scalar varlabel = `"`: var label `var''"'
    quietly: su `var' 
    scalar N =`r(N)'
    scalar Mean = `r(mean)'
    scalar SD = `r(sd)'
    quietly: loneway `var' cell_id
    scalar ICC = `r(rho)'
    post `memhold' (varlabel) (N) (Mean) (SD) (ICC)
    scalar drop _all
}

postclose `memhold'
use "`stats_icc'", clear

*Export to csv.
export delimited using "$results/balance_table_1km.csv", replace



***************************************************************

* main results

reghdfe ntl all_cleared [aw=pct_area_mined], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", replace tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_road  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.baseline_pop  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_kabul  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.ucdp_events  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_ntl.txt"

***

* pre-2008 only results

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year<2008, absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", replace tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year<2008, absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year<2008, absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year<2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_road  [aw=pct_area_mined] if last_clearance_year<2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.baseline_pop  [aw=pct_area_mined] if last_clearance_year<2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_kabul  [aw=pct_area_mined] if last_clearance_year<2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.ucdp_events  [aw=pct_area_mined] if last_clearance_year<2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_pre2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_ntl_pre2008clearance.txt"


***

* post-2008 only results

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year>=2008, absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", replace tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year>=2008, absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year>=2008, absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl all_cleared [aw=pct_area_mined] if last_clearance_year>=2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_road  [aw=pct_area_mined] if last_clearance_year>=2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.baseline_pop  [aw=pct_area_mined] if last_clearance_year>=2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.distance_to_kabul  [aw=pct_area_mined] if last_clearance_year>=2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.all_cleared##c.ucdp_events  [aw=pct_area_mined] if last_clearance_year>=2008, absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_ntl_post2008clearance.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_ntl_post2008clearance.txt"

***

* population DV results

reghdfe log_popcount all_cleared [aw=pct_area_mined], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", replace tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area_mined], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area_mined], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.all_cleared##c.distance_to_road  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.all_cleared##c.distance_to_kabul  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount.doc", append tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


reghdfe log_popdensity all_cleared [aw=pct_area_mined], absorb(absorb_temp) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", replace tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area_mined], absorb(year) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area_mined], absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.all_cleared##c.distance_to_road  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.all_cleared##c.distance_to_kabul  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popdensity.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_popdensity.txt"

***

* Prelim results table

reghdfe log_popcount all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount_prelim.doc", replace tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.all_cleared##c.distance_to_road  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount_prelim.doc", append tex noni nocons ctitle(ln(Pop. Count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount_prelim.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.all_cleared##c.distance_to_road  [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)
outreg2 using "$results/main_models_popcount_prelim.doc", append tex noni nocons ctitle(ln(Pop. Dens.)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


***************************************************************

* TE by baseline population graph

xtile q_baseline_pop = baseline_pop, nq(5)

reghdfe ntl ibn.q_baseline_pop#c.all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_baseline_pop#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Baseline population count (quintile)") ytitle("Effect on NTL") rename(1.q_baseline_pop#c.all_cleared = 1 2.q_baseline_pop#c.all_cleared = 2 3.q_baseline_pop#c.all_cleared = 3 4.q_baseline_pop#c.all_cleared = 4 5.q_baseline_pop#c.all_cleared = 5) saving("$results/baseline_pop_quintile", replace)

***

* TE by distance to road graph

xtile q_distance_to_road = distance_to_road, nq(5)

reghdfe ntl ibn.q_distance_to_road#c.all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_distance_to_road#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Distance to road (quintile)") ytitle("Effect on NTL") rename(1.q_distance_to_road#c.all_cleared = 1 2.q_distance_to_road#c.all_cleared = 2 3.q_distance_to_road#c.all_cleared = 3 4.q_distance_to_road#c.all_cleared = 4 5.q_distance_to_road#c.all_cleared = 5) saving("$results/distance_to_road_quintile", replace)

***

* TE by percent of cell originally mined graph

xtile q_pct_area_mined = pct_area_mined, nq(5)

reghdfe ntl ibn.q_pct_area#c.all_cleared [aw=pct_area_mined], absorb(cell_id year_province) cluster(district_id year)

coefplot, keep(*.q_pct_area#c.all_cleared) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Pct. area that is hazardous") ytitle("Effect on NTL")

***

* time to treatment graph - create a rolling measure tracking number of years until or since treatment
gen time_to_trt1 = year*all_cleared
replace time_to_trt1=. if time_to_trt1==0
egen time_to_trt2 = min(time_to_trt1), by(cell_id)

gen time_to_trt3 = year-time_to_trt2
* using this as dummy in the model, so add 30 to make sure all values are positive
replace time_to_trt3 = time_to_trt3+30
* not including cases more than 5 years before treatment or more than 8 years after treatment
replace time_to_trt3 = . if time_to_trt3<25
replace time_to_trt3 = . if time_to_trt3>38

* run the model with NDVI on LHS and dummies of distance to/from treatment years on the RHS, inc. UCDP as covariate
reghdfe ntl ib30.time_to_trt3 ucdp_events [aw=pct_area_mined] if last_clearance_year>2008, absorb(cell_id) cluster(district_id year)
* plot the time to treatment coefficients
coefplot, keep(*.time_to_trt3) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white) xtitle("Years to complete hazard clearance") ytitle("Treatment effects on NTL") rename(22.time_to_trt3 = -8 23.time_to_trt3 = -7 24.time_to_trt3 = -6 25.time_to_trt3 = -5 26.time_to_trt3 = -4 27.time_to_trt3 = -3 28.time_to_trt3 = -2 29.time_to_trt3 = -1 30.time_to_trt3 = 0 31.time_to_trt3 = 1 32.time_to_trt3 = 2 33.time_to_trt3 = 3 34.time_to_trt3 = 4 35.time_to_trt3 = 5 36.time_to_trt3 = 6 37.time_to_trt3 = 7 38.time_to_trt3 = 8) saving("$results/event_study", replace)

* time to treatment, this time using first year of clearance as the "treatment year"
gen first_cleared = (total_ha-ha_count!=0) * year
replace first_cleared=. if first_cleared==0
egen first_cleared2 = min(first_cleared), by(cell_id)
gen first_cleared3 = year-first_cleared2
replace first_cleared3 = first_cleared3+30
* dont include cases >8 years away from treatment
replace first_cleared3 = . if first_cleared3<22
replace first_cleared3 = . if first_cleared3>38

reghdfe ntl ib30.first_cleared3 [aw=pct_area_mined] if last_clearance_year<=2008, absorb(cell_id) cluster(district_id year)
coefplot, keep(*.first_cleared3) yline(0) vertical omit   recast(line) color(blue) ciopts(recast(rline)  color(blue) lp(dash) ) graphregion(color(white)) bgcolor(white) xtitle("Years to first hazard clearance") ytitle("Treatment effects on NTL") rename(22.first_cleared3 = -8 23.first_cleared3 = -7 24.first_cleared3 = -6 25.first_cleared3 = -5 26.first_cleared3 = -4 27.first_cleared3 = -3 28.first_cleared3 = -2 29.first_cleared3 = -1 30.first_cleared3 = 0 31.first_cleared3 = 1 32.first_cleared3 = 2 33.first_cleared3 = 3 34.first_cleared3 = 4 35.first_cleared3 = 5 36.first_cleared3 = 6 37.first_cleared3 = 7 38.first_cleared3 = 8) saving("$results/event_study_b", replace)

********************************************************************************

* graph the TE by the number of years it took to clear the cell
local year_lab ""
forv y = 0/17 {
	local year_lab "`year_lab' `y'.time_of_clearance#c.year = `y'"
}

local keep_vals ""
forv z = 0/10 {
	local keep_vals "`keep_vals' `z'.time_of_clearance*"
}

reghdfe ntl ibn.time_of_clearance#c.year if year<2003 [aw=pct_area_mined], absorb(cell_id) cluster(district_id year)
loc ref = _b[0.time_of_clearance#c.year]
coefplot, keep(`keep_vals') vertical yline(`ref') graphregion(color(white)) legend(off) xtitle("Years between first-last clearance activity") ytitle("Pre-2003 trend in NTL") rename(`year_lab') xlabel(, labsize(vsmall) alternate) saving("$results/time_taken_pretrend", replace)


* graph TE by what year the last clearance activity occurred
local year_lab ""
forv y = 1992/2013 {
	local year_lab "`year_lab' `y'.last_clearance_year#c.year = `y'"
}

local keep_vals ""
forv z = 2003/2013 {
	local keep_vals "`keep_vals' `z'.last_clearance_year*"
}

reghdfe ntl ibn.last_clearance_year#c.year if year<2003 [aw=pct_area_mined], absorb(cell_id) cluster(district_id year)
loc ref = _b[2003.last_clearance_year#c.year]
coefplot, keep(`keep_vals') vertical yline(`ref') graphregion(color(white)) legend(off) xtitle("Year of clearance completion") ytitle("Pre-2003 trend in NTL") rename(`year_lab') xlabel(, labsize(vsmall) alternate) saving("$results/timing_pretrend", replace)


* graph TE by what year the first clearance activity occurred
local year_lab ""
forv y = 1992/2013 {
	local year_lab "`year_lab' `y'.first_clearance_year#c.year = `y'"
}

local keep_vals ""
forv z = 2003/2013 {
	local keep_vals "`keep_vals' `z'.first_clearance_year*"
}

reghdfe ntl ibn.first_clearance_year#c.year if year<2003 [aw=pct_area_mined], absorb(cell_id) cluster(district_id year)
loc ref = _b[2003.first_clearance_year#c.year]
coefplot, keep(`keep_vals') vertical yline(`ref') graphregion(color(white)) legend(off) xtitle("Year of first clearance activity") ytitle("Pre-2003 trend in NTL") rename(`year_lab') xlabel(, labsize(vsmall) alternate) saving("$results/timing_pretrend", replace)

********************************************************************************


* bys year: su ntl

* preserve

* collapse (mean) ntl popcount popdensity, by(year)

drop cell_id gid_1 name_1 gid_2 name_2

* collapse panel to district-year level
ds district_id year popcount baseline_pop ha_count total_ha, not
collapse (mean) `r(varlist)' (sum) popcount baseline_pop ha_count total_ha, by(district_id year)


***

*drop cell_id gid_1 name_1 district_id name_2 
*ds gid_2 year popcount baseline_pop ha_count total_ha, not
*collapse (mean) `r(varlist)' (sum) popcount baseline_pop ha_count total_ha, by(gid_2 year)
*ds gid_2 year, not
*reshape wide `r(varlist)', i(gid_2) j(year)
*export delimited "/Users/christianbaehr/Downloads/panel_1km_district.csv", replace

***


replace all_cleared = (all_cleared==1)

su

drop log_popcount log_popdensity
gen log_popcount = log(popcount)
gen log_popdensity = log(popdensity)

levelsof province_id
levelsof district_id
levelsof year_province

gen num_cleared = total_ha - ha_count

***

*  district level
reghdfe ntl ha_count [aw=pct_area_mined], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", replace noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", N, "Year*Prov. FEs", N)

reghdfe ntl ha_count [aw=pct_area_mined], absorb(year) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "District FEs", N, "Year*Prov. FEs", N)

reghdfe ntl ha_count [aw=pct_area_mined], absorb(year district_id) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append noni nocons ctitle(NTL) addtext("Year FEs", Y, "District FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl ha_count [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.ha_count##c.distance_to_road [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.ha_count##c.baseline_pop [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.ha_count##c.distance_to_kabul [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_ntl.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

rm "$results/main_models_district_ntl.txt"



reghdfe log_popcount ha_count [aw=pct_area_mined], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", replace noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount ha_count [aw=pct_area_mined], absorb(year) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popcount ha_count [aw=pct_area_mined], absorb(year district_id) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popcount ha_count [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.ha_count##c.distance_to_road [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popcount c.ha_count##c.distance_to_kabul [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popcount.doc", append noni nocons ctitle(ln(Pop. count)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)



reghdfe log_popdensity ha_count [aw=pct_area_mined], absorb(absorb_temp) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", replace noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity ha_count [aw=pct_area_mined], absorb(year) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", Y, "Grid cell FEs", N, "Year*Prov. FEs", N)

reghdfe log_popdensity ha_count [aw=pct_area_mined], absorb(year district_id) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", Y, "Grid cell FEs", Y, "Year*Prov. FEs", N)

reghdfe log_popdensity ha_count [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.ha_count##c.distance_to_road [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)

reghdfe log_popdensity c.ha_count##c.distance_to_kabul [aw=pct_area_mined], absorb(district_id year_province) cluster(province_id year)
outreg2 using "$results/main_models_district_popdensity.doc", append noni nocons ctitle(ln(Pop. density)) addtext("Year FEs", N, "Grid cell FEs", Y, "Year*Prov. FEs", Y)


rm "$results/main_models_district_popdensity.txt"

***

xtile q_ha_count = ha_count, nq(5)

local year_lab ""
forv y = 1992/2013 {
	local year_lab "`year_lab' `y'.q_ha_count#c.year = `y'"
}

local keep_vals ""
forv z = 2003/2013 {
	local keep_vals "`keep_vals' `z'.q_ha_count*"
}

reghdfe ntl i.q_ha_count, absorb(district_id year) cluster(province_id year)
coefplot, keep(*.q_ha_count) vertical yline(0) graphregion(color(white)) legend(off) xtitle("Num. completed `w' projects")

cap estimates clear
foreach v in ndvi treecover {
	foreach w in roads irrigation {
		reghdfe `v' i.cut_trt_overall_`w' years_since_first_`w'  temperature precip, absorb(year cell_id) cluster(commune_number year) pool(10)
		coefplot, keep(*.cut_trt_overall*) vertical yline(0) graphregion(color(white)) saving("${results}\Treatment_intensity_`v'_`w'", replace) legend(off) xtitle("Num. completed `w' projects") title("Treatment effects of `w' on `v'") ytitle("Effect on `v'")
	}	
}

***

gen builtup_dummy = (builtup>0)
replace builtup_dummy = . if missing(builtup)

gen pct_builtup = builtup

corr ntl network_cost builtup

reghdfe builtup_dummy network_cost, absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/market_access.doc", replace noni nocons addtext("Year FEs", Y, "Grid cell FEs", Y)

reghdfe pct_builtup network_cost, absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/market_access.doc", append noni nocons addtext("Year FEs", Y, "Grid cell FEs", Y)

reghdfe ntl network_cost, absorb(cell_id year) cluster(district_id year)
outreg2 using "$results/market_access.doc", append noni nocons addtext("Year FEs", Y, "Grid cell FEs", Y)


***

collapse (mean) ntl popcount popdensity all_cleared, by(year cleared_by_2013)

sort cell_id year


twoway (connect ntl year if cleared_by_2013==1 & year<=2013) (connect ntl year if cleared_by_2013==0 & year<=2013), xlabel(1992(2)2013) xtitle("Year") ytitle("NTL") legend(order(1 "Cleared by 2013" 2 "Not cleared by 2013")) bgcolor(white) graphregion(color(white)) saving("$results/ntl_timeseries", replace)


*twoway (connect popcount year if cleared_by_2013==1) (connect popcount year if cleared_by_2013==0), xtitle("Year") ytitle("Population") legend(order(1 "Cleared by 2013" 2 "Not cleared by 2013")) bgcolor(white) graphregion(color(white)) 

*twoway connect ntl year
*twoway connect popcount year
*twoway connect popdensity year



***

egen mean_pop = mean(popcount) if year==2000, by(last_clearance_year)

*twoway scatter popcount last_clearance_year if year==2020
twoway scatter mean_pop last_clearance_year if year==2000
graph export "/Users/christianbaehr/Desktop/clearance_pop_correlation.png", replace




egen mean_disttoroad = mean(distance_to_road), by(last_clearance_year)

egen num_obs = count(distance_to_road), by(last_clearance_year)

*twoway scatter popcount last_clearance_year if year==2020
twoway bar num_obs last_clearance_year if year==2000 & !missing(last_clearance_year), yaxis(2) fcolor(blue*0.25) color(blue*0.25) || scatter mean_disttoroad last_clearance_year if year==2000, yaxis(1) yscale(alt axis(1)) yscale(alt axis(2)) ytitle("Avg. distance to road (km)", axis(1)) ytitle("N", axis(2)) legend(order(2 "Avg. distance" 1 "N"))

graph export "/Users/christianbaehr/Desktop/clearance_disttoroad_correlation.png", replace

corr last_clearance_year popcount distance_to_road if year==2000

***

egen test = group (last_clearance_year year)

egen mean_ntl = mean(ntl), by(test)


su mean_ntl

*egen mean_ntl = mean(ntl), by(last_clearance_year)

*egen mean_ntl_2 = mean(mean_ntl), by(year)

su last_clearance_year

sort year

label variable mean_ntl "Avg. Nighttime Lights"
label variable year "Year"
label variable last_clearance_year "year of clearance completion"


twoway line mean_ntl year if year<1996, by(last_clearance_year)
*xlabel(Year) ylabel(Avg. Nighttime Lights)
graph export "/Users/christianbaehr/Desktop/ntl_pretrends1.png", replace



twoway line mean_ntl year if year<2010 & last_clearance_year>=2010 & last_clearance_year<=2016, by(last_clearance_year)
*xlabel(Year) ylabel(Avg. Nighttime Lights)

graph export "/Users/christianbaehr/Desktop/ntl_pretrends2.png", replace


























