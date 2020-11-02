
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

#test = grid.sample(10000)
#test.to_file(path+"/empty_grid_afg_test.geojson", driver="GeoJSON")

#hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
#hazard_polygons["country"] = "Afghanistan"
#hazard_dissolve = hazard_polygons.dissolve(by="country")
#azard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")

gdf3["merge_id"] = grid.index

path1 = path+"/empty_grid_afg_trimmed.geojson"
path2 = path+"/hazard_dissolve.geojson"

polygon1 = fiona.open(path1)
polygon2 = fiona.open(path2)

geom_p1 = [ shape(feat["geometry"]) for feat in polygon1 ]
geom_p2 = [ shape(feat["geometry"]) for feat in polygon2 ]

df = pd.DataFrame(columns=["merge_id", "pct_area"])

for i, g1 in enumerate(geom_p1):
    for j, g2 in enumerate(geom_p2):
        if g1.intersects(g2):
            a = (g1.intersection(g2).area/g1.area)*100
            df=df.append({"merge_id": i, "pct_area": a}, ignore_index=True)

gdf4 = gdf3.merge(df, how="left", on="merge_id")
gdf4.loc[gdf4["pct_area_y"].isnull(), "pct_area_y"] = 0
gdf4.drop(["merge_id"], axis=1, inplace=True)

###

#grid.to_csv(path+"/pre_panel.csv", index=False)

gdf4 = gdf4[["cell_id", "longitude", "latitude", "pct_area_y", "geometry"]]

gdf4.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")

gdf5 = gdf4.loc[gdf4["pct_area"]>0, : ]

gdf5.to_file(path+"/empty_grid_afg_trimmed.geojson", driver="GeoJSON")
gdf5.drop(["geometry"], axis=1).to_csv(path+"/empty_grid_afg_trimmed.csv", index=False)
















