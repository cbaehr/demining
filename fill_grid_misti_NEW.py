
path = "/sciclone/home20/cbaehr/demining/inputData"
out_path = "/sciclone/scr20/cbaehr/demining"


#path = "/Users/christianbaehr/Box Sync/demining/inputData"
#out_path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np
from operator import attrgetter
import datetime

misti = pd.read_csv(path+"/misti/misti_full.csv")
misti.m24a.describe()
misti.m24b.describe()

points = [Point(xy) for xy in zip(misti.m24b, misti.m24a)]
misti_geo = gpd.GeoDataFrame(misti, crs="epsg:4326", geometry=points)

misti_geo["survey_id"] = misti_geo.index+1


misti_geo_1km = misti_geo[["survey_id", "geometry"]]
misti_geo_3km = misti_geo[["survey_id", "geometry"]]
misti_geo_5km = misti_geo[["survey_id", "geometry"]]
misti_geo_1km["geometry"] = misti_geo_1km["geometry"].buffer(0.010755)
misti_geo_3km["geometry"] = misti_geo_3km["geometry"].buffer(0.0330)
misti_geo_5km["geometry"] = misti_geo_5km["geometry"].buffer(0.0555)

#misti_geo_1km.to_file("/Users/christianbaehr/Downloads/misti_geo_1km.geojson", driver="GeoJSON")
#misti_geo_3km.to_file("/Users/christianbaehr/Downloads/misti_geo_3km.geojson", driver="GeoJSON")
#misti_geo_5km.to_file("/Users/christianbaehr/Downloads/misti_geo_5km.geojson", driver="GeoJSON")


###

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons.crs="epsg:4326"
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")

hazard_polygons["country"] = "Afghanistan"
hazard_dissolve = hazard_polygons.buffer(0)
hazard_dissolve = gpd.GeoDataFrame(hazard_polygons, crs="epsg:4326", geometry=hazard_dissolve)
hazard_dissolve = hazard_dissolve.dissolve(by="country")
#hazard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")

##########


misti_geo["merge_id"] = misti_geo.index

geom_p1km = [shape(feat) for feat in misti_geo_1km["geometry"]]
geom_p3km = [shape(feat) for feat in misti_geo_3km["geometry"]]
geom_p5km = [shape(feat) for feat in misti_geo_5km["geometry"]]
geom_p2 = [shape(feat) for feat in hazard_dissolve["geometry"]]

g2 = geom_p2[0]
g1km_area = geom_p1km[0].area
g3km_area = geom_p3km[0].area
g5km_area = geom_p5km[0].area


pct_covered_1km = []
pct_covered_3km = []
pct_covered_5km = []


for i, g1 in enumerate(geom_p1km):
	a = (g1.intersection(g2).area/g1km_area) * 100
	pct_covered_1km = pct_covered_1km + [a]

for i, g1 in enumerate(geom_p3km):
	b = (g1.intersection(g2).area/g3km_area) * 100
	pct_covered_3km = pct_covered_3km + [b]

for i, g1 in enumerate(geom_p5km):
	c = (g1.intersection(g2).area/g5km_area) * 100
	pct_covered_5km = pct_covered_5km + [c]

misti_geo["pct_covered_1km"] = pct_covered_1km
misti_geo["pct_covered_3km"] = pct_covered_3km
misti_geo["pct_covered_5km"] = pct_covered_5km

#misti_geo = misti_geo.loc[gdf["pct_area"]>0, : ]

misti_geo.reset_index(drop=True, inplace=True)

misti_geo.to_file(out_path+"/empty_grid_misti.geojson", driver="GeoJSON")

###

treatment_1km = gpd.sjoin(misti_geo_1km[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")
misti_geo["total_ha_1km"] = treatment_1km.groupby(["survey_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

treatment_3km = gpd.sjoin(misti_geo_3km[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")
misti_geo["total_ha_3km"] = treatment_3km.groupby(["survey_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

treatment_5km = gpd.sjoin(misti_geo_5km[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")
misti_geo["total_ha_5km"] = treatment_5km.groupby(["survey_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

#misti_geo.total_ha.describe()

###

def build(year_str):
	j = year_str.split('|')
	return {i:j.count(i) for i in set(j)}

treatment_cleared = treatment_1km.loc[treatment_1km["Status_1"]=="Expired", : ]
tc2 = treatment_cleared[["survey_id", "Status_C_1"]]
tc2.loc[:, "Status_C_1"] = tc2["Status_C_1"].astype("Int64").astype("str")
tc3 = tc2.pivot_table(values="Status_C_1", index="survey_id", aggfunc='|'.join)
tc3_1 = tc3
tc3_1 = misti_geo[["survey_id"]].merge(tc3, how="left", left_on="survey_id", right_index=True)
tc3_1 = tc3_1.fillna("nan")
tc4 = tc3_1["Status_C_1"].to_list()
tc5 = list(map(build, tc4))
tc6 = pd.DataFrame(tc5)
tc6.drop(["nan"], axis=1, inplace=True)
for i in range(1992, 2021):
	if str(i) not in tc6.columns:
		tc6[str(i)] = 0
	tc6[str(i)] = tc6[str(i)].fillna(0)
tc6 = tc6*-1
#tc7 = tc6.reindex(sorted(tc6.columns, reverse=True), axis=1)
tc7 = tc6.reindex(sorted(tc6.columns), axis=1)
tc8 = tc7.apply(np.cumsum, axis=1)
tc8 = tc8.add(misti_geo["total_ha_1km"], axis=0)
#tc8 = (tc7.sub(grid["total_ha"], axis=0) == 0)*1
tc9 = tc8.reindex(sorted(tc8.columns), axis=1)
for i in tc9.columns:
	tc9.rename({str(i):"ha_count_1km_"+str(i)}, axis=1, inplace=True)
keep_cols = ["ha_count_1km_"+str(i) for i in range(1992, 2021)]
tc9 = tc9[keep_cols]

misti_geo = pd.concat([misti_geo, tc9], axis=1)

misti_geo["num_cleared_1km"] = 0

for i in range(0, misti_geo.shape[0]):
	temp_year = misti_geo.loc[i, "m7"]
	a = tc7.iloc[i, :]
	b = a.index.tolist()
	b = [int(j) for j in b]
	c = a[b<temp_year]
	misti_geo.loc[i, "num_cleared_1km"] = c.sum()*-1

##########

treatment_cleared = treatment_3km.loc[treatment_3km["Status_1"]=="Expired", : ]
tc2 = treatment_cleared[["survey_id", "Status_C_1"]]
tc2.loc[:, "Status_C_1"] = tc2["Status_C_1"].astype("Int64").astype("str")
tc3 = tc2.pivot_table(values="Status_C_1", index="survey_id", aggfunc='|'.join)
tc3_1 = tc3
tc3_1 = misti_geo[["survey_id"]].merge(tc3, how="left", left_on="survey_id", right_index=True)
tc3_1 = tc3_1.fillna("nan")
tc4 = tc3_1["Status_C_1"].to_list()
tc5 = list(map(build, tc4))
tc6 = pd.DataFrame(tc5)
tc6.drop(["nan"], axis=1, inplace=True)
for i in range(1992, 2021):
	if str(i) not in tc6.columns:
		tc6[str(i)] = 0
	tc6[str(i)] = tc6[str(i)].fillna(0)
tc6 = tc6*-1
#tc7 = tc6.reindex(sorted(tc6.columns, reverse=True), axis=1)
tc7 = tc6.reindex(sorted(tc6.columns), axis=1)
tc8 = tc7.apply(np.cumsum, axis=1)
tc8 = tc8.add(misti_geo["total_ha_3km"], axis=0)
#tc8 = (tc7.sub(grid["total_ha"], axis=0) == 0)*1
tc9 = tc8.reindex(sorted(tc8.columns), axis=1)
for i in tc9.columns:
	tc9.rename({str(i):"ha_count_3km_"+str(i)}, axis=1, inplace=True)
keep_cols = ["ha_count_3km_"+str(i) for i in range(1992, 2021)]
tc9 = tc9[keep_cols]

misti_geo = pd.concat([misti_geo, tc9], axis=1)

misti_geo["num_cleared_3km"] = 0

for i in range(0, misti_geo.shape[0]):
	temp_year = misti_geo.loc[i, "m7"]
	a = tc7.iloc[i, :]
	b = a.index.tolist()
	b = [int(j) for j in b]
	c = a[b<temp_year]
	misti_geo.loc[i, "num_cleared_3km"] = c.sum()*-1

##########

treatment_cleared = treatment_5km.loc[treatment_5km["Status_1"]=="Expired", : ]
tc2 = treatment_cleared[["survey_id", "Status_C_1"]]
tc2.loc[:, "Status_C_1"] = tc2["Status_C_1"].astype("Int64").astype("str")
tc3 = tc2.pivot_table(values="Status_C_1", index="survey_id", aggfunc='|'.join)
tc3_1 = tc3
tc3_1 = misti_geo[["survey_id"]].merge(tc3, how="left", left_on="survey_id", right_index=True)
tc3_1 = tc3_1.fillna("nan")
tc4 = tc3_1["Status_C_1"].to_list()
tc5 = list(map(build, tc4))
tc6 = pd.DataFrame(tc5)
tc6.drop(["nan"], axis=1, inplace=True)
for i in range(1992, 2021):
	if str(i) not in tc6.columns:
		tc6[str(i)] = 0
	tc6[str(i)] = tc6[str(i)].fillna(0)
tc6 = tc6*-1
#tc7 = tc6.reindex(sorted(tc6.columns, reverse=True), axis=1)
tc7 = tc6.reindex(sorted(tc6.columns), axis=1)
tc8 = tc7.apply(np.cumsum, axis=1)
tc8 = tc8.add(misti_geo["total_ha_5km"], axis=0)
#tc8 = (tc7.sub(grid["total_ha"], axis=0) == 0)*1
tc9 = tc8.reindex(sorted(tc8.columns), axis=1)
for i in tc9.columns:
	tc9.rename({str(i):"ha_count_5km_"+str(i)}, axis=1, inplace=True)
keep_cols = ["ha_count_5km_"+str(i) for i in range(1992, 2021)]
tc9 = tc9[keep_cols]

misti_geo = pd.concat([misti_geo, tc9], axis=1)

misti_geo["num_cleared_5km"] = 0

for i in range(0, misti_geo.shape[0]):
	temp_year = misti_geo.loc[i, "m7"]
	a = tc7.iloc[i, :]
	b = a.index.tolist()
	b = [int(j) for j in b]
	c = a[b<temp_year]
	misti_geo.loc[i, "num_cleared_5km"] = c.sum()*-1

######################################################################################################################

for i in [2000, 2005, 2010, 2015, 2020]:
	a = zonal_stats(misti_geo, path+"/pop/pop_count/gpw_popcount_resample_"+str(i)+".tif", stats=["mean"])
	b = pd.DataFrame(a)
	b.columns = ["pop_count"+str(i)]
	misti_geo = pd.concat([misti_geo, b], axis=1)

#misti_geo.drop(["geometry"], axis=1).to_csv(path+"/misti/misti_panel.csv", index=False)

######################################################################################################################

#misti_geo = pd.read_csv(path+"/misti/misti_panel.csv")

#poly = gpd.read_file(path+"/misti/empty_grid_misti.geojson")

#misti_geo2 = misti_geo.merge(poly, how="left", on="survey_id")
#misti_geo3 = gpd.GeoDataFrame(misti_geo2, crs="epsg:4326")

###

#hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
#hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")
#hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_Cha", "Status_C_1", "Hazard_Cla", "geometry"]]
#hazard_polygons["hazard_area"] = hazard_polygons["geometry"].area

###

treatment = gpd.sjoin(misti_geo_1km[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")
treatment_cleared = treatment.loc[treatment["Status_1"]=="Expired", : ]
a = treatment_cleared.groupby(["survey_id"], sort=False)["Status_Cha"].max()
b = pd.DataFrame(a)
#b.reset_index(drop=True, inplace=True)
misti_geo = misti_geo.merge(b, left_on="survey_id", right_index=True, how="left")
misti_geo.rename({"Status_Cha":"last_clearance_date_1km"}, axis=1, inplace=True)
#misti_geo3["last_clearance_date"] = b
#misti_geo3=misti_geo
misti_geo["interview_date_form"] = pd.to_datetime(misti_geo["interview_date"], format="%m-%d-%Y")
a = misti_geo["interview_date_form"].dt.to_period("M")
b = misti_geo["last_clearance_date_1km"].dt.to_period("M")

c = (a-b)
c[~pd.isnull(c)] = c[~pd.isnull(c)].apply(attrgetter("n"))
c[pd.isnull(c)] = 0
c = c.astype(int)

#time = misti_geo["interview_date_form"].dt.to_period("M") - misti_geo["last_clearance_date_1km"].dt.to_period("M")

#misti_geo["months_since_clearance"] = time.apply(attrgetter('n'))
misti_geo["months_since_clearance_1km"] = c

not_cleared = (misti_geo["total_ha_1km"] - misti_geo["num_cleared_1km"])>0
misti_geo.loc[not_cleared, "months_since_clearance_1km"] = np.nan

###

treatment = gpd.sjoin(misti_geo_3km[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")
treatment_cleared = treatment.loc[treatment["Status_1"]=="Expired", : ]
a = treatment_cleared.groupby(["survey_id"], sort=False)["Status_Cha"].max()
b = pd.DataFrame(a)
#b.reset_index(drop=True, inplace=True)
misti_geo = misti_geo.merge(b, left_on="survey_id", right_index=True, how="left")
misti_geo.rename({"Status_Cha":"last_clearance_date_3km"}, axis=1, inplace=True)
#misti_geo3["last_clearance_date"] = b
#misti_geo3=misti_geo
misti_geo["interview_date_form"] = pd.to_datetime(misti_geo["interview_date"], format="%m-%d-%Y")
a = misti_geo["interview_date_form"].dt.to_period("M")
b = misti_geo["last_clearance_date_3km"].dt.to_period("M")

c = (a-b)
c[~pd.isnull(c)] = c[~pd.isnull(c)].apply(attrgetter("n"))
c[pd.isnull(c)] = 0
c = c.astype(int)

#time = misti_geo["interview_date_form"].dt.to_period("M") - misti_geo["last_clearance_date_1km"].dt.to_period("M")

#misti_geo["months_since_clearance"] = time.apply(attrgetter('n'))
misti_geo["months_since_clearance_3km"] = c

not_cleared = (misti_geo["total_ha_3km"] - misti_geo["num_cleared_3km"])>0
misti_geo.loc[not_cleared, "months_since_clearance_3km"] = np.nan

###

treatment = gpd.sjoin(misti_geo_5km[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")
treatment_cleared = treatment.loc[treatment["Status_1"]=="Expired", : ]
a = treatment_cleared.groupby(["survey_id"], sort=False)["Status_Cha"].max()
b = pd.DataFrame(a)
#b.reset_index(drop=True, inplace=True)
misti_geo = misti_geo.merge(b, left_on="survey_id", right_index=True, how="left")
misti_geo.rename({"Status_Cha":"last_clearance_date_5km"}, axis=1, inplace=True)
#misti_geo3["last_clearance_date"] = b
#misti_geo3=misti_geo
misti_geo["interview_date_form"] = pd.to_datetime(misti_geo["interview_date"], format="%m-%d-%Y")
a = misti_geo["interview_date_form"].dt.to_period("M")
b = misti_geo["last_clearance_date_5km"].dt.to_period("M")

c = (a-b)
c[~pd.isnull(c)] = c[~pd.isnull(c)].apply(attrgetter("n"))
c[pd.isnull(c)] = 0
c = c.astype(int)

#time = misti_geo["interview_date_form"].dt.to_period("M") - misti_geo["last_clearance_date_1km"].dt.to_period("M")

#misti_geo["months_since_clearance"] = time.apply(attrgetter('n'))
misti_geo["months_since_clearance_5km"] = c

not_cleared = (misti_geo["total_ha_5km"] - misti_geo["num_cleared_5km"])>0
misti_geo.loc[not_cleared, "months_since_clearance_5km"] = np.nan

###

misti_geo.drop(["geometry"], axis=1).to_csv(out_path+"/misti/misti_panel_new.csv", index=False)












