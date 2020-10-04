
path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape

grid = gpd.read_file(path+"/empty_grid_afg.geojson")
coords = [(x,y) for x, y in zip(grid.longitude, grid.latitude)]

###

for i in range(1992, 2014):
	ras = rasterio.open(path+"/ntl/dmsp_afg_"+str(i)+".tif")
	col = [j[0] for j in ras.sample(coords)]
	grid["ntl"+str(i)] = col

###

grid = pd.read_csv(path+"/pre_panel.csv")

coords_geom = [Point(xy) for xy in zip(grid.longitude, grid.latitude)]
coords = gpd.GeoDataFrame(grid['cell_id'], crs='epsg:4326', geometry=coords_geom)
del coords_geom

adm = gpd.read_file(path+"/gadm36_AFG_2.geojson")
adm.drop(["GID_0", "NAME_0", "NL_NAME_1", "VARNAME_2", "NL_NAME_2", "TYPE_2", "ENGTYPE_2", "CC_2", "HASC_2"], axis=1, inplace=True)

temp = gpd.sjoin(coords, adm)

grid = grid.merge(temp, how="left", on="cell_id")

###

# area of the grid cell covered by hazard

#test = grid.sample(10000)
#test.to_file(path+"/empty_grid_afg_test.geojson", driver="GeoJSON")

test = gpd.read_file(path+"/empty_grid_afg_test.geojson")
test["merge_id"] = test.index

#hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
#hazard_polygons["country"] = "Afghanistan"
#hazard_dissolve = hazard_polygons.dissolve(by="country")
#hazard_dissolve.to_file(path+"/hazard_dissolve.geojson", driver="GeoJSON")

path1 = path+"/empty_grid_afg_test.geojson"
path2 = path+"/hazard_dissolve.geojson"

polygon1 = fiona.open(path1)
polygon8 = fiona.open(path2)

geom_p1 = [ shape(feat["geometry"]) for feat in polygon1 ]
geom_p8 = [ shape(feat["geometry"]) for feat in polygon8 ]

df = pd.DataFrame(columns=["merge_id", "pct_area"])

for i, g1 in enumerate(geom_p1):
    for j, g8 in enumerate(geom_p8):
        if g1.intersects(g8):
        	a = (g1.intersection(g8).area/g1.area)*100
        	df=df.append({"merge_id": i, "pct_area": a}, ignore_index=True)
            #print (i, j, (g1.intersection(g8).area/g1.area)*100)

#test2 = test.merge(df, how="left", on="merge_id")
#test2.to_file("/Users/christianbaehr/Downloads/test.geojson", driver="GeoJSON")

###

def build(year_str):
    j = year_str.split('|')
    return {i:j.count(i) for i in set(j)}

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")

hazard_polygons["Status_Cha_year"] = hazard_polygons["Status_Cha"].str[:4]

x = gpd.sjoin(test, hazard_polygons[["OBJECTID", "Status_Cha_year", "geometry"]], how="left", op="intersects")
x = x[["cell_id", "Status_Cha_year"]]
x["Status_Cha_year"] = x["Status_Cha_year"].astype("float").astype('Int64').astype("str")
y = x.pivot_table(values="Status_Cha_year", index="cell_id", aggfunc="|".join)
y = y["Status_Cha_year"].tolist()
y = list(map(build, y))
y = pd.DataFrame(y)
y = y.fillna(0)



###

grid.drop(["geometry"], axis=1).to_csv(path+"/pre_panel.csv", index=False)






































