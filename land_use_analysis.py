
path = "/Users/christianbaehr/Box Sync/demining/inputData"
out_path = "/Users/christianbaehr/Box Sync/demining/inputData"
#path = "/sciclone/home20/cbaehr/demining/inputData"
#out_path = "/sciclone/scr20/cbaehr/demining"

import itertools
import rasterio
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point, shape, box
from shapely.prepared import prep
import fiona

#landuse2020 = rasterio.open(path+"/LandUseProducts/2020/2020_L8_lulc.tif")
#sample_raster = path+"/LandUseProducts/2020/2020_L8_lulc.tif"
sample_raster = path+"/2020_L8_lulc.tif"

#Create rectangles using shapely
with rasterio.open(sample_raster) as dataset:
    data = dataset.read(1)
    t = dataset.transform
    move_x = t[0]
    # t[4] is negative, as raster start upper left 0,0 and goes down
    # later for steps calculation (ymin=...) we use plus instead of minus
    move_y = t[4]
    height = dataset.height
    width = dataset.width
    polygons = []
    indices = list(itertools.product(range(width), range(height)))
    for x,y in indices:
        x_min, y_max = t*(x,y)
        x_max = x_min + move_x
        y_min = y_max + move_y
        polygons.append(box(x_min, y_min, x_max, y_max))

#Extract the data
data_list = []
for x,y in indices:
    data_list.append(data[y,x])

#Combine in a GeoDataFrame using geopandas
#gdf = gpd.GeoDataFrame(data=data_list, crs="epsg:4326", geometry=polygons, columns=['value'])
gdf = gpd.GeoDataFrame(data=data_list, crs="epsg:32642", geometry=polygons, columns=['value'])
cent = gdf.centroid
gdf["lon"] = cent.x
gdf["lat"] = cent.y

gdf.reset_index(inplace=True, drop=True)

gdf["cell_id"] = gdf.index+1

gdf.to_file(out_path+"/land_use_grid_hazardlevel.geojson", driver="GeoJSON")

############################################################

hazard_polygons = gpd.read_file(path+"/hazard_polygons_32642_trimmed.geojson")
hazard_polygons.crs="epsg:32642"
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
hazard_polygons["country"] = "Afghanistan"
hazard_polygons_mineonly = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_dissolve_mineonly = hazard_polygons_mineonly.buffer(0)
hazard_dissolve_mineonly = gpd.GeoDataFrame(hazard_polygons_mineonly, crs="epsg:32642", geometry=hazard_dissolve_mineonly)
hazard_dissolve_mineonly = hazard_dissolve_mineonly.dissolve(by="country")


geom_p1 = [ shape(feat) for feat in gdf["geometry"]]
geom_p2 = [ shape(feat) for feat in hazard_dissolve_mineonly["geometry"]]

#geom_p1 = [ shape(feat["geometry"]) for feat in polygon1 ]
#geom_p2 = [ shape(feat["geometry"]) for feat in polygon2 ]

g2 = geom_p2[0]
g1_area = geom_p1[0].area

pct_covered = []

for i, g1 in enumerate(geom_p1):
    a = (g1.intersection(g2).area/g1_area) * 100
    pct_covered = pct_covered + [a]

gdf["pct_area_mined"] = pct_covered

############################################################

hazard_polygons = gpd.read_file(path+"/hazard_polygons_32642.geojson")
hazard_polygons.crs="epsg:32642"
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
hazard_polygons["country"] = "Afghanistan"
hazard_polygons_mineonly = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_dissolve_mineonly = hazard_polygons_mineonly.buffer(0)
hazard_dissolve_mineonly = gpd.GeoDataFrame(hazard_polygons_mineonly, crs="epsg:32642", geometry=hazard_dissolve_mineonly)
hazard_dissolve_mineonly = hazard_dissolve_mineonly.dissolve(by="country")

all_cells=gpd.sjoin(gdf, hazard_dissolve_mineonly, how="left")
cond=all_cells.Shape_Leng.isnull()

main_cells = all_cells.loc[~cond, :]

main_cells.to_file("/Users/christianbaehr/Downloads/landuse_grid_hazardlevel.geojson", driver="GeoJSON")

graps = sklurg

############################################################


coords_x = main_cells.geometry.centroid.x
coords_y = main_cells.geometry.centroid.y
coords = [(x,y) for x, y in zip(coords_x, coords_y)]

probs = ["1995_L5_lulc.tif", "2000_L5_lulc.tif"]

for i in [1995, 2000, 2008, 2010, 2015, 2020]:
	if i in [1995, 2000, 2010]:
		lcname = str(i)+"_L5_lulc.tif"
		probname = str(i)+"_L5_prob.tif"
	else:
		lcname = str(i)+"_L8_lulc.tif"
		probname = str(i)+"_L8_prob.tif"
	src_lc = rasterio.open("/Users/christianbaehr/Box Sync/demining/inputData/LandUseProducts/"+str(i)+"/"+lcname)
	src_prob = rasterio.open("/Users/christianbaehr/Box Sync/demining/inputData/LandUseProducts/"+str(i)+"/"+probname)
	main_cells["lc"+str(i)] = [x[0] for x in src_lc.sample(coords)]
	main_cells["prob"+str(i)] = [x[0] for x in src_prob.sample(coords)]

############################################################


treatment = gpd.sjoin(main_cells, hazard_polygons, how="left", op="intersects")

main_cells["total_ha"] = treatment.groupby(["cell_id"], sort=False)["Status_C_1"].count().reset_index(drop=True)

main_cells.total_ha.describe()

###

treatment_cleared = treatment.loc[treatment["Status_1"]=="Expired", : ]
#treatment_cleared=treatment

tc2 = treatment_cleared[["cell_id", "Status_C_1"]]
tc2["Status_C_1"] = tc2["Status_C_1"].astype("Int64").astype("str")

tc3 = tc2.pivot_table(values="Status_C_1", index="cell_id", aggfunc='|'.join)

tc3_1 = tc3
tc3_1 = main_cells[["cell_id"]].merge(tc3, how="left", left_on="cell_id", right_index=True)
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

tc8 = tc8.add(main_cells["total_ha"], axis=0)

#tc8 = (tc7.sub(grid["total_ha"], axis=0) == 0)*1
tc9 = tc8.reindex(sorted(tc8.columns), axis=1)
for i in tc9.columns:
	tc9.rename({str(i):"ha_count"+str(i)}, axis=1, inplace=True)

keep_cols = ["ha_count"+str(i) for i in range(1992, 2014)] + ["ha_count2015", "ha_count2020"]
tc9 = tc9[keep_cols]

main_cells = pd.concat([main_cells, tc9], axis=1)
















