

import delimited "/Users/christianbaehr/Downloads/district_panel_withpercents.csv", clear

keep gid_2 pct_covered_*

drop pct_covered_327

bys gid_2: gen new_id=_n
keep if new_id==1


reshape long pct_covered_, i(gid_2) j(year)

rename pct_covered_ pct_hazardous

sort gid_2 year

drop new_id

save "/Users/christianbaehr/Downloads/merge_data.dta", replace

***

import delimited "/Users/christianbaehr/Downloads/district_panel_withpercents.csv", clear

drop pct_covered_*

drop if year>2015

sort gid_2 year

merge 1:1 gid_2 year using "/Users/christianbaehr/Downloads/merge_data"

***



* drop if year==2014 | (year>2015 & year<2020)

gen log_popcount = log(popcount)
gen log_popdensity = log(popdensity)

gen all_cleared = (ha_count==0)

gen first_trt_tmp = (ha_count!=total_ha) * year
replace first_trt_tmp = . if first_trt_tmp==0
egen first_clearance_year = min(first_trt_tmp), by(cell_id)

gen last_trt_tmp = (ha_count==0) * year
replace last_trt_tmp = . if last_trt_tmp==0
egen last_clearance_year = min(last_trt_tmp), by(cell_id)
replace last_clearance_year= . if last_clearance_year>2013

gen time_of_clearance = last_clearance_year-first_clearance_year


egen district_id = group(gid_2)
egen province_id = group(gid_1)

egen year_province = group(year province_id)


replace distance_to_road = distance_to_road / 1000

bys cell_id (year): gen cleared_by_2013 = all_cleared[22]
su ntl if cleared_by_2013==1
su ntl if cleared_by_2013==0

bys cleared_by_2013: su all_cleared if year==2013


bysort cell_id (year): gen baseline_pop = popdensity[9]

egen max_ntl = max(ntl), by(cell_id)
egen min_ntl = min(ntl), by(cell_id)

egen total_ucdp_events = sum(ucdp_events), by(cell_id)

gen cleared_post2008 = (cleared_pre2008==0)

gen sample1_a = (last_clearance_year<2006)
gen sample1_b = (last_clearance_year>=2006 & last_clearance_year<2008)
gen sample2_a = (last_clearance_year>=2008 & last_clearance_year<2011)
gen sample2_b = (last_clearance_year>=2011 & last_clearance_year<=2013)


gen absorb_temp=1




***

egen district_id = group(gid_2)


*  district level
*reghdfe ntl pct_hazardous, absorb(absorb_temp) cluster(province_id year)
*outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", replace tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", N, "Year*Prov. FEs", N)

*reghdfe ntl pct_hazardous, absorb(year) cluster(province_id year)
*outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", Y, "District FEs", N, "Year*Prov. FEs", N)

*reghdfe ntl pct_hazardous, absorb(year district_id) cluster(province_id year)
*outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", append tex  noni nocons ctitle(NTL) addtext("Year FEs", Y, "District FEs", Y, "Year*Prov. FEs", N)

reghdfe ntl pct_hazardous, absorb(district_id year_province) cluster(province_id year)
outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", replace tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.pct_hazardous##c.distance_to_road, absorb(district_id year_province) cluster(province_id year)
outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

reghdfe ntl c.pct_hazardous##c.baseline_pop, absorb(district_id year_province) cluster(province_id year)
outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

*reghdfe ntl c.pct_hazardous##c.distance_to_kabul, absorb(district_id year_province) cluster(province_id year)
*outreg2 using "/Users/christianbaehr/Downloads/pcthazard_models.doc", append tex noni nocons ctitle(NTL) addtext("Year FEs", N, "District FEs", Y, "Year*Prov. FEs", Y)

rm "/Users/christianbaehr/Downloads/pcthazard_models.txt"





