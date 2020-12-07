
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

sample_raster = path+"/ntl/dmsp_afg_1992.tif"

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
gdf = gpd.GeoDataFrame(data=data_list, crs="epsg:4326", geometry=polygons, columns=['value'])
cent = gdf.centroid
gdf["lon"] = cent.x
gdf["lat"] = cent.y

gdf.reset_index(inplace=True, drop=True)

gdf["cell_id"] = gdf.index+1


##########

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons.crs="epsg:4326"
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
hazard_polygons["country"] = "Afghanistan"
hazard_polygons_mineonly = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]

hazard_dissolve_mineonly = hazard_polygons_mineonly.buffer(0)
hazard_dissolve_mineonly = gpd.GeoDataFrame(hazard_polygons_mineonly, crs="epsg:4326", geometry=hazard_dissolve_mineonly)
hazard_dissolve_mineonly = hazard_dissolve_mineonly.dissolve(by="country")
#hazard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")


gdf2 = gpd.sjoin(gdf, hazard_dissolve_mineonly, how="left", op="intersects")
gdf2 = gdf2.loc[~gdf2["Hazard_ID"].isnull(), :]
gdf=gdf2
gdf = gdf[["cell_id", "lon", "lat", "geometry"]]
gdf.reset_index(drop=True, inplace=True)


##########


gdf["merge_id"] = gdf.index

#path1 = out_path+"/empty_grid_afg.geojson"

#polygon1 = fiona.open(path1)
#polygon2 = fiona.open(path+"/hazard_dissolve.geojson")

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

###

#hazard_dissolve_anyhazard = hazard_polygons.buffer(0)
#hazard_dissolve_anyhazard = gpd.GeoDataFrame(hazard_polygons, crs="epsg:4326", geometry=hazard_dissolve_anyhazard)
#hazard_dissolve_anyhazard = hazard_dissolve_anyhazard.dissolve(by="country")
#hazard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")

#geom_p1 = [ shape(feat) for feat in gdf["geometry"]]
#geom_p2 = [ shape(feat) for feat in hazard_dissolve_anyhazard["geometry"]]

#g2 = geom_p2[0]
#g1_area = geom_p1[0].area

#pct_covered = []

#for i, g1 in enumerate(geom_p1):
#    a = (g1.intersection(g2).area/g1_area) * 100
#    pct_covered = pct_covered + [a]

#gdf["pct_area_anyhazard"] = pct_covered

##########

gdf = gdf.loc[gdf["pct_area_mined"]>0, : ]

#gdf = gdf[["cell_id", "lon", "lat", "pct_area_mined", "pct_area_anyhazard", "geometry"]]
gdf = gdf[["cell_id", "lon", "lat", "pct_area_mined", "geometry"]]

gdf.to_file(out_path+"/empty_grid_1km.geojson", driver="GeoJSON")
#gdf.drop(["geometry"], axis=1).to_csv(out_path+"/empty_grid_afg.csv", index=False)




