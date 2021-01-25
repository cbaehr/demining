
import delimited "/Users/christianbaehr/Downloads/temp.csv", clear

reshape long builtup farmland prob temperature precipitation cleared, i(objectid) j(year)

encode gid_2, generate(district_id)
egen year_province = group(year gid_1)


gen IHS_builtup = log(builtup + sqrt(builtup^2 + 1))
gen IHS_farmland = log(farmland + sqrt(farmland^2 + 1))

gen builtup_dummy = (builtup>0)
gen farmland_dummy = (farmland>0)


outreg2 using "/Users/christianbaehr/Downloads/summary_statistics_1km.doc", replace sum(log)
*rm "$results/summary_statistics_1km.txt"


gen absorb_temp =1 

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
