
import delimited "/Users/christianbaehr/Box Sync/demining/inputData/full_grid_landuse_hazardlevel.csv", clear

gen baseline_farmland = (farmland1995>0 & !missing(farmland1995))
gen ag_blockage = (agricultur=="Agriculture" & !missing(agricultur))
gen road_blockage = (roads=="Road" & !missing(roads))


reshape long bareearth builtup farmland forest grassland snow water temperature precipitation cleared, i(objectid) j(year)

encode gid_2, generate(district_id)
egen year_province = group(year gid_1)

gen IHS_bareearth = log(bareearth + sqrt(bareearth^2 + 1))
gen IHS_builtup = log(builtup + sqrt(builtup^2 + 1))
gen IHS_farmland = log(farmland + sqrt(farmland^2 + 1))
gen IHS_forest = log(forest + sqrt(forest^2 + 1))
gen IHS_grassland = log(grassland + sqrt(grassland^2 + 1))
gen IHS_snow = log(snow + sqrt(snow^2 + 1))
gen IHS_water = log(water + sqrt(water^2 + 1))

gen builtup_dummy = (builtup>0 & !missing(builtup))
gen farmland_dummy = (farmland>0 & !missing(farmland))

***

egen not_cleared = max(cleared), by(objectid)

gen a = (!cleared * year)
egen pre_clearance = max(a), by(objectid)
replace pre_clearance = (pre_clearance==year)
replace pre_clearance = 0 if status_1!="Expired"

local lulc "bareearth builtup farmland forest grassland"
foreach i in `lulc' {
	gen `i'_a = `i' * pre_clearance
	egen `i'_b = max(`i'_a), by(objectid)
	gen `i'_pre = (`i'_b >= 0.5)
	drop `i'_a `i'_b
}






*outreg2 using "/Users/christianbaehr/Downloads/summary_statistics_1km.doc", replace sum(log)
*rm "$results/summary_statistics_1km.txt"

gen absorb_temp =1 

**************************************************

local lulc "bareearth builtup farmland forest grassland"

foreach i in `lulc' {
	
	reghdfe IHS_`i' cleared [aw=hazard_are], absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models.doc", replace noni nocons ctitle(All) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared [aw=hazard_are] if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models.doc", append noni nocons ctitle(Pre08) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared [aw=hazard_are] if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models.doc", append noni nocons ctitle(Post08) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared [aw=hazard_are] if ag_blockage, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models.doc", append noni nocons ctitle(All (ag. block)) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared [aw=hazard_are] if cleared_post2008==0 & ag_blockage, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models.doc", append noni nocons ctitle(Pre08 (ag. block)) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared [aw=hazard_are] if cleared_post2008==1 & ag_blockage, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models.doc", append noni nocons ctitle(Post08 (ag. block)) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	rm "/Users/christianbaehr/Downloads/`i'_models.txt"
	
}


rm "/Users/christianbaehr/Downloads/farmland_models.doc"
local lulc "bareearth builtup farmland forest grassland"
foreach i in `lulc' {
	
	su farmland if `i'_pre & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_farmland cleared [aw=hazard_are] if `i'_pre, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/farmland_models.doc", append noni nocons ctitle(`i'all) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance fmld.", `avg')
	
	su farmland if cleared_post2008==0 & `i'_pre & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	
	reghdfe IHS_farmland cleared [aw=hazard_are] if cleared_post2008==0 & `i'_pre, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/farmland_models.doc", append noni nocons ctitle(`i'pre) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance fmld.", `avg')
	
	su farmland if cleared_post2008==1 & `i'_pre & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_farmland cleared [aw=hazard_are] if cleared_post2008==1 & `i'_pre, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/farmland_models.doc", append noni nocons ctitle(`i'post) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance fmld.", `avg')
	
	
	
}
rm "/Users/christianbaehr/Downloads/farmland_models.txt"


rm "/Users/christianbaehr/Downloads/builtup_models.doc"
local lulc "bareearth builtup farmland forest grassland"
foreach i in `lulc' {
	
	su builtup if `i'_pre & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_builtup cleared [aw=hazard_are] if `i'_pre, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/builtup_models.doc", append noni nocons ctitle(`i'all) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance builtup", `avg')
	
	su builtup if cleared_post2008==0 & `i'_pre & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==0 & `i'_pre, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/builtup_models.doc", append noni nocons ctitle(`i'pre) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance builtup", `avg')
	
	su builtup if cleared_post2008==1 & `i'_pre & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==1 & `i'_pre, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/builtup_models.doc", append noni nocons ctitle(`i'post) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance builtup", `avg')
	
}
rm "/Users/christianbaehr/Downloads/builtup_models.txt"




gen water_bloc = (waters=="Water" & !missing(waters))
gen road_bloc = (roads=="Road" & !missing(roads))
gen housing_bloc = (housing=="Housing" & !missing(housing))
gen infrastructure_bloc = (infrastruc=="Infrastructure" & !missing(infrastruc))
gen agriculture_bloc = (agricultur=="Agriculture" & !missing(agricultur))
gen grazing_bloc = (grazing=="Grazing" & !missing(grazing))


rm "/Users/christianbaehr/Downloads/farmland_models_blockage.doc"
local lulc "water road housing infrastructure agriculture grazing"
foreach i in `lulc' {
	
	su farmland if `i'_bloc & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_farmland cleared [aw=hazard_are] if `i'_bloc, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/farmland_models_blockage.doc", append noni nocons ctitle(`i'_all) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance fmld.", `avg')
	
	su farmland if cleared_post2008==0 & `i'_bloc & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_farmland cleared [aw=hazard_are] if cleared_post2008==0 & `i'_bloc, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/farmland_models_blockage.doc", append noni nocons ctitle(`i'_pre) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance fmld.", `avg')
	
	su farmland if cleared_post2008==1 & `i'_bloc & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_farmland cleared [aw=hazard_are] if cleared_post2008==1 & `i'_bloc, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/farmland_models_blockage.doc", append noni nocons ctitle(`i'_post) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance fmld.", `avg')
	
}
rm "/Users/christianbaehr/Downloads/farmland_models_blockage.txt"

*****

rm "/Users/christianbaehr/Downloads/builtup_models_blockage.doc"
local lulc "water road housing infrastructure agriculture grazing"
foreach i in `lulc' {
	
	su builtup if `i'_bloc & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_builtup cleared [aw=hazard_are] if `i'_bloc, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/builtup_models_blockage.doc", append noni nocons ctitle(`i'_all) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance builtup", `avg')
	
	su builtup if cleared_post2008==0 & `i'_bloc & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==0 & `i'_bloc, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/builtup_models_blockage.doc", append noni nocons ctitle(`i'_pre) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance builtup", `avg')
	
	su builtup if cleared_post2008==1 & `i'_bloc & pre_clearance==1
	local avg = round(r(mean), 0.001)
	
	reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==1 & `i'_bloc, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/builtup_models_blockage.doc", append noni nocons ctitle(`i'_post) addtext("Hazard FEs", Y, "Year*Prov. FEs", Y, "Pre-clearance builtup", `avg')
	
}
rm "/Users/christianbaehr/Downloads/builtup_models_blockage.txt"


*****

local lulc "bareearth builtup farmland forest grassland"

foreach i in `lulc' {
	
	reghdfe IHS_`i' cleared, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models_noweight.doc", replace noni nocons ctitle(All) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared if ag_blockage, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models_noweight.doc", append noni nocons ctitle(All (ag. block)) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared if cleared_post2008==0 & ag_blockage, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models_noweight.doc", append noni nocons ctitle(Pre08 (ag. block)) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	reghdfe IHS_`i' cleared if cleared_post2008==1 & ag_blockage, absorb(objectid year_province) cluster(district_id year)
	outreg2 using "/Users/christianbaehr/Downloads/`i'_models_noweight.doc", append noni nocons ctitle(Post08 (ag. block)) addtext("Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)
	
	rm "/Users/christianbaehr/Downloads/`i'_models_noweight.txt"
	
}

*****



**************************************************

* built up

reghdfe IHS_builtup cleared [aw=hazard_are], absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are], absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are], absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are], absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe IHS_builtup cleared [aw=hazard_are]  if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are]  if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_builtup cleared [aw=hazard_are] if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe IHS_builtup cleared [aw=hazard_are]  if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are]  if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared [aw=hazard_are]  if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)


**************************************************

* farmland

reghdfe IHS_farmland cleared [aw=hazard_are], absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are], absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are], absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are], absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are], absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_farmland cleared [aw=hazard_are] if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_farmland cleared [aw=hazard_are] if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)


**************************************************

* built up no weight

reghdfe IHS_builtup cleared, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_builtup cleared if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe IHS_builtup cleared  if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared  if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_builtup cleared if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe IHS_builtup cleared  if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared  if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_builtup cleared  if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)


**********

* farmland no weight

reghdfe IHS_farmland cleared , absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation , absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation , absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation , absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation , absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_farmland cleared  if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe IHS_farmland cleared  if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe IHS_farmland cleared temperature precipitation  if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_noweight.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)


**************************************************

* built up binary

reghdfe builtup_dummy cleared, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared , absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared , absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe builtup_dummy cleared  if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe builtup_dummy cleared  if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared  if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared  if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe builtup_dummy cleared if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe builtup_dummy cleared if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe builtup_dummy cleared if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)



**************************************************

* farmland binary

reghdfe farmland_dummy cleared , absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation , absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation , absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation , absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe farmland_dummy cleared if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe farmland_dummy cleared if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe farmland_dummy cleared temperature precipitation if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_binary.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

**************************************************

gen ag_blockage = agricultur=="Agriculture"

reghdfe IHS_farmland cleared temperature precipitation if ag_blockage, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_agblockage.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

reghdfe IHS_farmland cleared temperature precipitation if cleared_post2008==0 & ag_blockage, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_agblockage.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

reghdfe IHS_farmland cleared temperature precipitation if cleared_post2008==1 & ag_blockage, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models_agblockage.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)





