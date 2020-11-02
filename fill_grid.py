
path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape

empty_grid = gpd.read_file(path+"/empty_grid_afg_trimmed.geojson")
coords = [(x,y) for x, y in zip(empty_grid.longitude, empty_grid.latitude)]

###

grid = empty_grid

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

coords_geom = [Point(xy) for xy in zip(grid.longitude, grid.latitude)]
coords_df = gpd.GeoDataFrame(grid['cell_id'], crs='epsg:4326', geometry=coords_geom)
del coords_geom

adm = gpd.read_file(path+"/gadm36_AFG_2.geojson")

temp = gpd.sjoin(coords_df, adm)
temp = temp[["cell_id", "GID_1", "NAME_1", "GID_2", "NAME_2"]]

grid = grid.merge(temp, how="left", on="cell_id")

#grid.drop(["geometry"], axis=1).to_csv(path+"/pre_panel.csv", index=False)

###

grid = pd.read_csv(path+"/pre_panel.csv")

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
#hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")
hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_Cha", "Status_C_1", "Hazard_Cla", "Blockages", "geometry"]]

###

# CHA
cha = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="CHA", :]

#cha = gpd.sjoin(empty_grid, cha[["OBJECTID", "Status_Cha", "geometry"]], how="left", op="intersects")
cha_grid = gpd.sjoin(empty_grid, cha, how="left", op="intersects")

test3 = gpd.sjoin(empty_grid, cha)
cha_cells = test3["cell_id"].unique()
has_cha = [i in cha_cells for i in grid["cell_id"]]
grid["has_cha"] = has_cha
grid["has_cha"] = grid["has_cha"] * 1

###

# cha_grid.loc[cha_grid["cell_id"].duplicated(), :]
# has_cha = cha_grid["OBJECTID"].isnull() * 1

###

cha_grid_cleared = cha_grid.loc[cha_grid["Status_1"]=="Expired", : ]

clearance_year = cha_grid_cleared.groupby(["cell_id"], sort=False)["Status_C_1"].max()

grid = grid.merge(clearance_year.rename("cha_clearance_year"), how="left", left_on="cell_id", right_index=True)

#

road_blockage = cha_grid["Blockages"].str.contains("Road")
road_blockage.fillna(False, inplace=True)

cha_grid["road_blockage"] = road_blockage * 1

road_blockage = cha_grid.groupby(["cell_id"], sort=False)["road_blockage"].max()

grid = grid.merge(road_blockage.rename("cha_road_blockage"), how="left", left_on="cell_id", right_index=True)

#

infra_blockage = cha_grid["Blockages"].str.contains("Infrastructure")
infra_blockage.fillna(False, inplace=True)

cha_grid["infra_blockage"] = infra_blockage * 1

infra_blockage = cha_grid.groupby(["cell_id"], sort=False)["infra_blockage"].max()

grid = grid.merge(infra_blockage.rename("cha_infrastructure_blockage"), how="left", left_on="cell_id", right_index=True)

#

ag_blockage = cha_grid["Blockages"].str.contains("Agriculture")
ag_blockage.fillna(False, inplace=True)

cha_grid["ag_blockage"] = ag_blockage * 1

ag_blockage = cha_grid.groupby(["cell_id"], sort=False)["ag_blockage"].max()

grid = grid.merge(infra_blockage.rename("cha_agriculture_blockage"), how="left", left_on="cell_id", right_index=True)

#

housing_blockage = cha_grid["Blockages"].str.contains("Housing")
housing_blockage.fillna(False, inplace=True)

cha_grid["housing_blockage"] = housing_blockage * 1

housing_blockage = cha_grid.groupby(["cell_id"], sort=False)["housing_blockage"].max()

grid = grid.merge(infra_blockage.rename("cha_housing_blockage"), how="left", left_on="cell_id", right_index=True)

###

# SHA
sha = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="SHA", :]

sha_grid = gpd.sjoin(empty_grid, sha, how="left", op="intersects")

sha_grid_cleared = sha_grid.loc[sha_grid["Status_1"]=="Expired", : ]


test4 = gpd.sjoin(empty_grid, sha)
sha_cells = test4["cell_id"].unique()
has_sha = [i in sha_cells for i in grid["cell_id"]]
grid["has_sha"] = has_sha
grid["has_sha"] = grid["has_sha"] * 1

###

clearance_year = sha_grid_cleared.groupby(["cell_id"], sort=False)["Status_C_1"].max()

grid = grid.merge(clearance_year.rename("sha_clearance_year"), how="left", left_on="cell_id", right_index=True)

#

road_blockage = sha_grid["Blockages"].str.contains("Road")
road_blockage.fillna(False, inplace=True)

sha_grid["road_blockage"] = road_blockage * 1

road_blockage = sha_grid.groupby(["cell_id"], sort=False)["road_blockage"].max()

grid = grid.merge(road_blockage.rename("sha_road_blockage"), how="left", left_on="cell_id", right_index=True)

#

infra_blockage = sha_grid["Blockages"].str.contains("Infrastructure")
infra_blockage.fillna(False, inplace=True)

sha_grid["infra_blockage"] = infra_blockage * 1

infra_blockage = sha_grid.groupby(["cell_id"], sort=False)["infra_blockage"].max()

grid = grid.merge(infra_blockage.rename("sha_infrastructure_blockage"), how="left", left_on="cell_id", right_index=True)

#

ag_blockage = sha_grid["Blockages"].str.contains("Agriculture")
ag_blockage.fillna(False, inplace=True)

sha_grid["ag_blockage"] = ag_blockage * 1

ag_blockage = sha_grid.groupby(["cell_id"], sort=False)["ag_blockage"].max()

grid = grid.merge(infra_blockage.rename("sha_agriculture_blockage"), how="left", left_on="cell_id", right_index=True)

#

housing_blockage = sha_grid["Blockages"].str.contains("Housing")
housing_blockage.fillna(False, inplace=True)

sha_grid["housing_blockage"] = housing_blockage * 1

housing_blockage = sha_grid.groupby(["cell_id"], sort=False)["housing_blockage"].max()

grid = grid.merge(infra_blockage.rename("sha_housing_blockage"), how="left", left_on="cell_id", right_index=True)

###

for i in [2000, 2005, 2010, 2015, 2020]:
	count_ras = rasterio.open(path+"/pop/pop_count/gpw_popcount_resample_"+str(i)+".tif")
	count_col = [j[0] for j in count_ras.sample(coords)]
	grid["popcount"+str(i)] = count_col
	density_ras = rasterio.open(path+"/pop/pop_density/gpw_popdensity_resample_"+str(i)+".tif")
	density_col = [k[0] for k in density_ras.sample(coords)]
	grid["popdensity"+str(i)] = density_col

###

grid.to_csv(path+"/pre_panel.csv", index=False)



#schema = gpd.io.file.infer_schema(test)
#schema["properties"]["Status_Cha"] = "datetime"
#test.to_file(path+"/grid_afg_test.geojson", driver="GeoJSON", schema=schema)



















