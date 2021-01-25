

import delimited "/Users/christianbaehr/Box Sync/demining/inputData/pre_panel_landuse_1km.csv", clear

reshape long ghs ntl ha_count, i(cell_id) j(year)

encode gid_2, generate(district_id)
egen year_province = group(year gid_1)

gen IHS_builtup = log(ghs + sqrt(ghs^2 + 1))

gen cleared = (ha_count==0)

reghdfe IHS_builtup cleared [aw=pct_area_mined], absorb(cell_id year) cluster(district_id year)
reghdfe IHS_builtup cleared, absorb(cell_id year_province) cluster(district_id year)



gen IHS_builtup = log(builtup + sqrt(builtup^2 + 1))
gen IHS_farmland = log(farmland + sqrt(farmland^2 + 1))

gen builtup_dummy = (builtup>0)
gen farmland_dummy = (farmland>0)


outreg2 using "/Users/christianbaehr/Downloads/summary_statistics_1km.doc", replace sum(log)
*rm "$results/summary_statistics_1km.txt"


gen absorb_temp =1 
