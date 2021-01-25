
import pandas as pd

import fiona
import geopandas as gpd
import rasterio
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np

grid = gpd.read_file("/Users/christianbaehr/Box Sync/demining/inputData/empty_grid_1km.geojson", crs="epsg:4326")

#landuse = "/Users/christianbaehr/Downloads/builtupbinary_1995_4326.tif"

years = [1995, 2000, 2008, 2015, 2020]

for i in years:
	file = "/Users/christianbaehr/Downloads/builtupbinary_"+str(i)+"_4326.tif"
	#file = rasterio.open("/Users/christianbaehr/Downloads/builtupbinary_"+str(i)+"_4326.tif")
	a = zonal_stats(grid, file, stats=["mean"])
	a = pd.DataFrame(a)
	a.columns = ["ghs"+str(i)]
	grid = pd.concat([grid, a], axis=1)

new_grid = grid.loc[~grid.ghs2000.isnull(), :]


######################################################################

hazard_polygons = gpd.read_file("/Users/christianbaehr/Box Sync/demining/inputData/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
#hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")
hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_Cha", "Status_C_1", "Hazard_Cla", "geometry"]]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Status_1"]=="Expired", :]
#hazard_polygons["hazard_area"] = hazard_polygons["geometry"].area

###

treatment = gpd.sjoin(new_grid, hazard_polygons, how="left", op="intersects").reset_index(drop=True)
treatment2 = treatment.loc[treatment.groupby("cell_id").Status_C_1.idxmin()].reset_index(drop=True)


grid_geometry = [Point(xy) for xy in zip(treatment2.lon, treatment2.lat)]
grid_geo = gpd.GeoDataFrame(treatment2, crs='epsg:4326', geometry=grid_geometry)


adm = gpd.read_file("/Users/christianbaehr/Box Sync/demining/inputData/gadm36_AFG_2.geojson")
treatment3 = gpd.sjoin(grid_geo.drop(["index_right"], axis=1), adm, how="left", op="intersects")

new_grid2 = new_grid.merge(treatment3[["cell_id", "GID_1", "GID_2", "Status_C_1"]], left_on="cell_id", right_on="cell_id")

new_grid2.drop(["geometry"], axis=1).to_csv("/Users/christianbaehr/Downloads/full_grid_landuse.csv", index=False)














































new_grid["total_ha"] = treatment.groupby(["cell_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

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

keep_cols = ["ha_count"+str(i) for i in years]
tc9 = tc9[keep_cols]

###

new_grid = pd.concat([new_grid, tc9], axis=1)




























