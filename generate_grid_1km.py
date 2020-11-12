
path = "/Users/christianbaehr/Box Sync/demining/inputData"

import itertools
import rasterio
from shapely.geometry import box
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point, shape
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

mask = gpd.read_file(path+"/gadm36_AFG_2.geojson")

gdf2 = gpd.clip(gdf, mask)

gdf2["longitude"] = gdf2.geometry.centroid.x
gdf2["latitude"] = gdf2.geometry.centroid.y

gdf2.reset_index(inplace=True)

gdf2["cell_id"] = gdf2.index+1

#gdf3 = gdf2[["cell_id", "longitude", "latitude", "geometry"]]
#gdf3.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")

###

# area of the grid cell covered by hazard

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="CHA", :]
hazard_polygons["country"] = "Afghanistan"

hazard_dissolve = hazard_polygons.dissolve(by="country")
hazard_dissolve = hazard_dissolve.buffer(0)
hazard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")

#hazard_polygons_cha = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="CHA", :]
#hazard_dissolve_cha = hazard_polygons_cha.dissolve(by="country")
#hazard_dissolve_cha = hazard_dissolve_cha.buffer(0)
#hazard_dissolve_cha.to_file(path+"/hazard_dissolve_cha.geojson", driver="GeoJSON")

#hazard_polygons_sha = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="SHA", :]
#hazard_polygons_sha["country"] = "Afghanistan"
#hazard_dissolve_sha = hazard_polygons_sha.dissolve(by="country")
#hazard_dissolve_sha = hazard_dissolve_sha.buffer(0)
#hazard_dissolve_sha.to_file(path+"/hazard_dissolve_sha.geojson", driver="GeoJSON")

##########

#gdf3.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")
gdf3 = gpd.read_file(path+"/empty_grid_afg_trimmed.geojson")

gdf3["merge_id"] = gdf3.index

path1 = path+"/empty_grid_afg_trimmed.geojson"
path2 = path+"/hazard_dissolve.geojson"

polygon1 = fiona.open(path1)
polygon2 = fiona.open(path2)

geom_p1 = [ shape(feat["geometry"]) for feat in polygon1 ]
geom_p2 = [ shape(feat["geometry"]) for feat in polygon2 ]

df1 = pd.DataFrame(columns=["merge_id", "pct_area"])

for i, g1 in enumerate(geom_p1):
    for j, g2 in enumerate(geom_p2):
        a = (g1.intersection(g2).area/g1.area)*100
        df1=df1.append({"merge_id": i, "pct_area": a}, ignore_index=True)

#gdf3.merge(df1, on="merge_id", inplace=True)
#gdf3 = pd.concat([gdf3, df1.drop(["merge_id"], axis=1)], axis=1)

###

#path3 = path+"/hazard_dissolve_cha.geojson"
#polygon3 = fiona.open(path3)
#geom_p3 = [ shape(feat["geometry"]) for feat in polygon3 ]

#df2 = pd.DataFrame(columns=["merge_id", "pct_area_cha"])

#for i, g1 in enumerate(geom_p1):
#    for j, g3 in enumerate(geom_p3):
#        a = (g1.intersection(g3).area/g1.area)*100
#        df2=df2.append({"merge_id": i, "pct_area_cha": a}, ignore_index=True)

#gdf3.merge(df2, on="merge_id", inplace=True)
#gdf3 = pd.concat([gdf3, df2.drop(["merge_id"], axis=1)], axis=1)

###

#path4 = path+"/hazard_dissolve_sha.geojson"
#polygon4 = fiona.open(path4)
#geom_p4 = [ shape(feat["geometry"]) for feat in polygon4 ]

#df3 = pd.DataFrame(columns=["merge_id", "pct_area_sha"])

#for i, g1 in enumerate(geom_p1):
#    for j, g4 in enumerate(geom_p4):
#        a = (g1.intersection(g4).area/g1.area)*100
#        df3=df3.append({"merge_id": i, "pct_area_sha": a}, ignore_index=True)

#gdf3.merge(df3, on="merge_id", inplace=True)
#gdf3 = pd.concat([gdf3, df3.drop(["merge_id"], axis=1)], axis=1)

##########

gdf4 = pd.concat([gdf3, df1.drop(["merge_id"], axis=1)], axis=1)
#gdf4 = pd.concat([gdf3, df1.drop(["merge_id"], axis=1), df2.drop(["merge_id"], axis=1), df3.drop(["merge_id"], axis=1)], axis=1)
#gdf4 = gdf3.merge(df, how="left", on="merge_id")
gdf4.loc[gdf4["pct_area_y"].isnull(), "pct_area_y"] = 0
gdf4.drop(["merge_id"], axis=1, inplace=True)

###

#grid.to_csv(path+"/pre_panel.csv", index=False)

gdf4 = gdf4[["cell_id", "longitude", "latitude", "pct_area", "geometry"]]
#gdf4 = gdf4[["cell_id", "longitude", "latitude", "pct_area", "pct_area_cha", "pct_area_sha", "geometry"]]

#gdf4.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")

gdf5 = gdf4.loc[gdf4["pct_area"]>0, : ]

gdf5.to_file(path+"/empty_grid_afg_trimmed.geojson", driver="GeoJSON")
gdf5.drop(["geometry"], axis=1).to_csv(path+"/empty_grid_afg_trimmed.csv", index=False)
















