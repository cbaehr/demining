
import itertools
import rasterio
from shapely.geometry import box
import geopandas as gpd

sample_raster = "/Users/christianbaehr/Downloads/dmsp_afg_1992.tif"

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

mask = gpd.read_file("/Users/christianbaehr/Downloads/gadm36_AFG_2.geojson")

gdf2 = gpd.clip(gdf, mask)

gdf2["longitude"] = gdf2.geometry.centroid.x
gdf2["latitude"] = gdf2.geometry.centroid.y

gdf2.reset_index(inplace=True)

gdf2["cell_id"] = gdf2.index+1

gdf3 = gdf2[["cell_id", "longitude", "latitude", "geometry"]]

gdf3.to_file("/Users/christianbaehr/Downloads/empty_grid_afg.geojson", driver="GeoJSON")

gdf3.drop(["geometry"], axis=1).to_csv("/Users/christianbaehr/Downloads/empty_grid_afg.csv", index=False)











