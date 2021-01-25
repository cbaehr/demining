
import pandas as pd
import fiona
import geopandas as gpd
import rasterio
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np

path = "/Users/christianbaehr/Box Sync/demining/inputData"

grid = gpd.read_file("/Users/christianbaehr/Box Sync/demining/inputData/empty_grid_1km.geojson", crs="epsg:4326")


years = [1995, 2000, 2008, 2015, 2020]

for i in years:
	file = "/Users/christianbaehr/Box Sync/demining/inputData/LandUseProducts/builtupbinary_"+str(i)+"_4326.tif"
	#file = rasterio.open("/Users/christianbaehr/Downloads/builtupbinary_"+str(i)+"_4326.tif")
	a = zonal_stats(grid, file, stats=["mean"])
	a = pd.DataFrame(a)
	a.columns = ["builtuppct"+str(i)]
	grid = pd.concat([grid, a], axis=1)

#new_grid = grid.loc[~grid.ghs2000.isnull(), :]
grid = grid.loc[~grid.ghs2000.isnull(), :].reset_index(drop=True)
#new_grid.to_file("/Users/christianbaehr/Downloads/test.geojson", driver="GeoJSON")

##########################################################################################

adm = gpd.read_file(path+"/gadm36_AFG_2.geojson")
adm = adm[["GID_1", "NAME_1", "GID_2", "NAME_2", "geometry"]]

grid = gpd.sjoin(grid, adm, how="left")
grid = grid[~grid.index.duplicated(keep="first")]

grid.drop(["index_right"], axis=1, inplace=True)

###


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

##########################################################################################

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

##########################################################################################



grid.drop(["geometry"], axis=1).to_csv(path+"/pre_panel_landuse_1km.csv", index=False)
grid.to_file("/Users/christianbaehr/Downloads/pre_panel_landuse_1km.geojson", driver="GeoJSON")













































