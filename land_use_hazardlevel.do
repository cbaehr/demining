
import delimited "/Users/christianbaehr/Downloads/temp.csv", clear

reshape long builtup farmland prob temperature precipitation cleared, i(objectid) j(year)

encode gid_2, generate(district_id)
egen year_province = group(year gid_1)

outreg2 using "/Users/christianbaehr/Downloads/summary_statistics_1km.doc", replace sum(log)
*rm "$results/summary_statistics_1km.txt"

gen absorb_temp =1 

**************************************************

reghdfe builtup cleared [aw=hazard_are], absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are], absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are], absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are], absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe builtup cleared [aw=hazard_are] if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe builtup cleared [aw=hazard_are]  if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are]  if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are] if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe builtup cleared [aw=hazard_are] if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)


reghdfe builtup cleared [aw=hazard_are]  if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are]  if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe builtup cleared [aw=hazard_are]  if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/builtup_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)


**************************************************


reghdfe farmland cleared [aw=hazard_are], absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", replace noni nocons ctitle(All) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are], absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are], absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are], absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are], absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(All) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe farmland cleared [aw=hazard_are] if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==0, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Pre08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

***

reghdfe farmland cleared [aw=hazard_are] if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", N, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(absorb_temp) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", N, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(objectid year) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", Y, "Hazard FEs", Y, "Year*Prov. FEs", N)

reghdfe farmland cleared temperature precipitation [aw=hazard_are] if cleared_post2008==1, absorb(objectid year_province) cluster(district_id year)
outreg2 using "/Users/christianbaehr/Downloads/farmland_landuse_models.doc", append noni nocons ctitle(Post08) addtext("Climate Controls", Y, "Year FEs", N, "Hazard FEs", Y, "Year*Prov. FEs", Y)

