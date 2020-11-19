
path = "/Users/christianbaehr/Box Sync/demining/inputData"
out_path = "/Users/christianbaehr/Box Sync/demining/inputData"
#path = "/sciclone/home20/cbaehr/demining/inputData"
#out_path = "/sciclone/scr20/cbaehr/demining"

import itertools
import rasterio
from shapely.geometry import box
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point, shape
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

gdf.reset_index(inplace=True)

gdf["cell_id"] = gdf.index+1

##########

#hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
#hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]

#hazard_polygons["country"] = "Afghanistan"
#hazard_dissolve = hazard_polygons.dissolve(by="country")
#hazard_outline = hazard_dissolve.buffer(0.015)
#hazard_outline.to_file(path+"/hazard_outline.geojson", driver="GeoJSON")
#hazard_dissolve = hazard_dissolve.buffer(0)
#hazard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")

boundary = fiona.open(path+"/hazard_outline.geojson")
boundary = boundary[0]
boundary = shape(boundary["geometry"])
prep_boundary = prep(boundary)

boundary_col = []

for _, row in gdf.iterrows():
    c = Point(row['lon'], row['lat'])
    boundary_col.append(prep_boundary.intersects(c))

gdf["temp"] = boundary_col
gdf = gdf.loc[gdf["temp"]==True, :]


gdf = gdf[["cell_id", "lon", "lat", "geometry"]]
gdf.reset_index(drop=True, inplace=True)

gdf.to_file(out_path+"/empty_grid_afg.geojson", driver="GeoJSON")


##########

#gdf3.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")
#gdf3 = gpd.read_file(path+"/empty_grid_afg.geojson")

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

#gdf3.merge(df1, on="merge_id", inplace=True)
#gdf3 = pd.concat([gdf3, df1.drop(["merge_id"], axis=1)], axis=1)


##########

gdf["pct_area"] = pct_covered
#gdf4 = pd.concat([gdf3, df1.drop(["merge_id"], axis=1), df2.drop(["merge_id"], axis=1), df3.drop(["merge_id"], axis=1)], axis=1)
#gdf4 = gdf3.merge(df, how="left", on="merge_id")
#gdf.loc[gdf["pct_area_y"].isnull(), "pct_area_y"] = 0
#gdf.drop(["merge_id"], axis=1, inplace=True)

###

#grid.to_csv(path+"/pre_panel.csv", index=False)

gdf = gdf[["cell_id", "lon", "lat", "pct_area", "geometry"]]

#gdf.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")

gdf = gdf.loc[gdf["pct_area"]>0, : ]

gdf.to_file(out_path+"/empty_grid_afg_trimmed.geojson", driver="GeoJSON")
gdf.drop(["geometry"], axis=1).to_csv(out_path+"/empty_grid_afg_trimmed.csv", index=False)












#gdf.to_file(path+"/temp.geojson", driver="GeoJSON")



