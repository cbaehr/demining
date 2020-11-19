
path = "/Users/christianbaehr/Box Sync/demining/inputData"
out_path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np

misti = pd.read_csv(path+"/misti/misti_full.csv")

###

misti.m24a.describe()
misti.m24b.describe()

points = [Point(xy) for xy in zip(misti.m24b, misti.m24a)]
crs = "epsg:4326"
misti_geo = gpd.GeoDataFrame(misti, crs=crs, geometry=points)
misti_geo.geometry = misti_geo.geometry.buffer(0.010)

misti_geo["survey_id"] = misti_geo.index+1

misti_geo[["survey_id", "geometry"]].to_file(path+"/misti/empty_grid_misti.geojson", driver="GeoJSON")

###


#hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="CHA", :]


#hazard_polygons["cleared_year"] = hazard_polygons["Status_Cha"].str[:4].astype(int)

#hazard_polygons_cleared = hazard_polygons.loc[hazard_polygons["Status_1"]=="Expired", :]

#hazard_polygons_cleared["Hazard_Cla"].unique()

######################################################################################################################


hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
#hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")
hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_Cha", "Status_C_1", "Hazard_Cla", "geometry"]]
#hazard_polygons["hazard_area"] = hazard_polygons["geometry"].area

###

treatment = gpd.sjoin(misti_geo[["survey_id", "geometry"]], hazard_polygons, how="left", op="intersects")

misti_geo["total_ha"] = treatment.groupby(["survey_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

misti_geo.total_ha.describe()

###

treatment_cleared = treatment.loc[treatment["Status_1"]=="Expired", : ]
#treatment_cleared=treatment

tc2 = treatment_cleared[["survey_id", "Status_C_1"]]
tc2["Status_C_1"] = tc2["Status_C_1"].astype("Int64").astype("str")

tc3 = tc2.pivot_table(values="Status_C_1", index="survey_id", aggfunc='|'.join)

tc3_1 = tc3
tc3_1 = misti_geo[["survey_id"]].merge(tc3, how="left", left_on="survey_id", right_index=True)
tc3_1 = tc3_1.fillna("nan")

tc4 = tc3_1["Status_C_1"].to_list()

def build(year_str):
	j = year_str.split('|')
	return {i:j.count(i) for i in set(j)}

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

tc8 = tc8.add(misti_geo["total_ha"], axis=0)

#tc8 = (tc7.sub(grid["total_ha"], axis=0) == 0)*1
tc9 = tc8.reindex(sorted(tc8.columns), axis=1)
for i in tc9.columns:
	tc9.rename({str(i):"ha_count"+str(i)}, axis=1, inplace=True)

keep_cols = ["ha_count"+str(i) for i in range(1992, 2014)] + ["ha_count2015", "ha_count2020"]
tc9 = tc9[keep_cols]

misti_geo = pd.concat([misti_geo, tc9], axis=1)

misti_geo["num_cleared"] = 0

for i in range(1, misti_geo.shape[0]):
	temp_year = misti_geo.m7.iloc[i]
	a = tc7.iloc[i]
	b = a.index.tolist()
	b = [int(i) for i in b]
	c = a[b<temp_year]
	misti_geo["num_cleared"].iloc[i] = c.sum()*-1


######################################################################################################################

misti_geo[["survey_id", "m24a", "m24b", "geometry"]].to_file(path+"/empty_grid_misti.geojson", driver="GeoJSON")
#gdf3.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")
#gdf3 = gpd.read_file(path+"/misti/empty_grid_misti.geojson")

misti_geo["merge_id"] = misti_geo.index

polygon1 = fiona.open(path+"/empty_grid_misti.geojson")
geom_p1 = [ shape(feat["geometry"]) for feat in polygon1 ]

polygon3 = fiona.open(path+"/hazard_dissolve.geojson")
geom_p3 = [ shape(feat["geometry"]) for feat in polygon3 ]

#df2 = pd.DataFrame(columns=["merge_id", "pct_area_cha"])

g3 = geom_p3[0]
g1_area = geom_p1[0].area

pct_covered = []

for i, g1 in enumerate(geom_p1):
	a = (g1.intersection(g3).area/g1_area)*100
	pct_covered = pct_covered + [a]


#for i, g1 in enumerate(geom_p1):
#    for j, g3 in enumerate(geom_p3):
#        a = (g1.intersection(g3).area/g1.area)*100
#        df2=df2.append({"merge_id": i, "pct_area_cha": a}, ignore_index=True)

misti_geo["pct_area"] = a

#misti_geo = misti_geo.merge(df2, on="merge_id")
#misti_geo.rename({"pct_area_cha":"pct_area"}, axis=1, inplace=True)

#gdf3.merge(df2, on="merge_id", inplace=True)
#gdf3 = pd.concat([gdf3, df2.drop(["merge_id"], axis=1)], axis=1)




gdf["merge_id"] = gdf.index

path1 = out_path+"/empty_grid_afg.geojson"
path2 = path+"/hazard_dissolve.geojson"

polygon1 = fiona.open(path1)
polygon2 = fiona.open(path2)

geom_p1 = [ shape(feat["geometry"]) for feat in polygon1 ]
geom_p2 = [ shape(feat["geometry"]) for feat in polygon2 ]

g2 = geom_p2[0]
g1_area = geom_p1[0].area

pct_covered = []

for i, g1 in enumerate(geom_p1):
    a = (g1.intersection(g2).area/g1_area) * 100
    pct_covered = pct_covered + [a]



##########

a = zonal_stats(misti_geo, path+"/pop/pop_count/gpw_popcount_resample_2010.tif", stats=["mean"])
b = pd.DataFrame(a)
b.columns = ["pop_count2010"]
misti_geo = pd.concat([misti_geo, b], axis=1)


# misti_geo.to_file("/Users/christianbaehr/Downloads/test.geojson", driver="GeoJSON")

##########

#test = misti_geo.sample(100)
#test.to_file("/Users/christianbaehr/Downloads/test_misti.geojson", driver="GeoJSON")

misti_geo.drop(["geometry"], axis=1).to_csv(path+"/misti/misti_panel.csv", index=False)















