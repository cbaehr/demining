
path = "/Users/christianbaehr/Box Sync/demining/inputData"
#out_path = "/sciclone/scr20/cbaehr/demining"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np


empty_grid = gpd.read_file(path+"/empty_grid_1km.geojson")
#empty_grid=empty_grid.sample(1000)
empty_grid.reset_index(drop=True, inplace=True)

grid = empty_grid

###

#adm

#coords_geom = [Point(xy) for xy in zip(grid.lon, grid.lat)]
#coords_df = gpd.GeoDataFrame(grid['cell_id'], crs='epsg:4326', geometry=coords_geom)
#del coords_geom

adm = gpd.read_file(path+"/gadm36_AFG_2.geojson")
adm = adm[["GID_1", "NAME_1", "GID_2", "NAME_2", "geometry"]]

grid = gpd.sjoin(grid, adm, how="left")
grid = grid[~grid.index.duplicated(keep="first")]

grid.drop(["index_right"], axis=1, inplace=True)

#temp = temp[["cell_id", "GID_1", "NAME_1", "GID_2", "NAME_2"]]

#idx = temp["cell_id"].duplicated()*1
#temp = temp.loc[idx==0, : ]

#grid = grid.merge(temp, how="left", on="cell_id")

#grid.drop(grid[grid.NAME_2.isnull()].index, inplace=True)

#grid.reset_index(drop=True, inplace=True)

coords = [(x,y) for x, y in zip(grid.lon, grid.lat)]

for i in range(1992, 2014):
	if i<=2008:
		ras = rasterio.open(path+"/ntl/dmsp_afg_"+str(i)+".tif")
		col = [j[0] for j in ras.sample(coords)]
		grid["ntl"+str(i)] = col
	else:
		ras = rasterio.open(path+"/ntl/dmsp_afg_resample_"+str(i)+".tif")
		col = [j[0] for j in ras.sample(coords)]
		grid["ntl"+str(i)] = col


###

#treatment

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
#hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")
hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_Cha", "Status_C_1", "Hazard_Cla", "geometry"]]
#hazard_polygons["hazard_area"] = hazard_polygons["geometry"].area

###

treatment = gpd.sjoin(grid, hazard_polygons, how="left", op="intersects")

grid["total_ha"] = treatment.groupby(["cell_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

grid.total_ha.describe()

###

treatment_cleared = treatment.loc[treatment["Status_1"]=="Expired", : ]
#treatment_cleared=treatment

tc2 = treatment_cleared[["cell_id", "Status_C_1"]]
tc2["Status_C_1"] = tc2["Status_C_1"].astype("Int64").astype("str")

tc3 = tc2.pivot_table(values="Status_C_1", index="cell_id", aggfunc='|'.join)

tc3_1 = tc3
tc3_1 = grid[["cell_id"]].merge(tc3, how="left", left_on="cell_id", right_index=True)
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

tc8 = tc8.add(grid["total_ha"], axis=0)

#tc8 = (tc7.sub(grid["total_ha"], axis=0) == 0)*1
tc9 = tc8.reindex(sorted(tc8.columns), axis=1)
for i in tc9.columns:
	tc9.rename({str(i):"ha_count"+str(i)}, axis=1, inplace=True)

keep_cols = ["ha_count"+str(i) for i in range(1992, 2014)] + ["ha_count2015", "ha_count2020"]
tc9 = tc9[keep_cols]

grid = pd.concat([grid, tc9], axis=1)

###

ucdp = gpd.read_file(path+"/ucdp_afghanistan.geojson")

for i in range(1992, 2020):
	ucdp_temp = ucdp.loc[ucdp["year"]==i, :]
	events = gpd.sjoin(grid, ucdp_temp, op="intersects")
	events = events.groupby(["cell_id"], sort=False)["high"].count()
	a= grid.merge(events, left_on="cell_id", right_index=True, how="left")
	a.loc[pd.isnull(a["high"]), "high"] = 0
	a.rename({"high":"ucdp_events"+str(i)}, axis=1, inplace=True)
	grid=a






###

for i in [2000, 2005, 2010, 2015, 2020]:
	count_ras = rasterio.open(path+"/pop/pop_count/gpw_popcount_resample_"+str(i)+".tif")
	count_col = [j[0] for j in count_ras.sample(coords)]
	grid["popcount"+str(i)] = count_col
	density_ras = rasterio.open(path+"/pop/pop_density/gpw_popdensity_resample_"+str(i)+".tif")
	density_col = [k[0] for k in density_ras.sample(coords)]
	grid["popdensity"+str(i)] = density_col

###

a = zonal_stats(grid, path+"/distance_starts_roads.tif", stats=["mean"])
b = pd.DataFrame(a)
b.columns = ["distance_to_road"]
grid = pd.concat([grid, b], axis=1)

###

for i in [1990, 2000, 2015]:
	a = zonal_stats(grid, path+"/ghs_"+str(i)+"_resampled.tif", stats=["mean"])
	b = pd.DataFrame(a)
	b.columns = ["ghs_"+str(i)]
	grid = pd.concat([grid, b], axis=1)

###

# Kabul coords 34.535169, 69.171300

#grid = pd.read_csv(path+"/pre_panel.csv")


distance_to_kabul = np.sqrt(((grid["lon"]-69.171300)**2 + (grid["lat"]- 34.535169)**2))
distance_to_kabul_km = distance_to_kabul/0.010
grid["distance_to_kabul"] = distance_to_kabul_km

###

grid["cleared_pre2008"] = (grid["ha_count2007"]==0)*1

###

for i in [1990, 2000, 2015]:
	a = zonal_stats(grid, path+"/ghs_"+str(i)+"_resampled.tif", stats=["mean"])
	b = pd.DataFrame(a)
	b.columns = ["ghs_"+str(i)]
	grid = pd.concat([grid, b], axis=1)

#grid = pd.read_csv(path+"/pre_panel.csv")

###

grid.drop(["geometry"], axis=1).to_csv(path+"/pre_panel_1km.csv", index=False)
grid.to_file("/Users/christianbaehr/Downloads/pre_panel.geojson", driver="GeoJSON")

#grid.to_csv(path+"/pre_panel.csv", index=False)

###

#schema = gpd.io.file.infer_schema(test)
#schema["properties"]["Status_Cha"] = "datetime"
#test.to_file(path+"/grid_afg_test.geojson", driver="GeoJSON", schema=schema)



















