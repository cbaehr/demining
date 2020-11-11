
import pandas as pd
from shapely.geometry import Point
import geopandas as gpd
from rasterstats import zonal_stats

path = "/Users/christianbaehr/Box Sync/demining/inputData"

misti = pd.read_csv(path+"/misti/misti_full.csv")

###

misti.m24a.describe()
misti.m24b.describe()

points = [Point(xy) for xy in zip(misti.m24b, misti.m24a)]
crs = "epsg:4326"
misti_geo = gpd.GeoDataFrame(misti, crs=crs, geometry=points)
misti_geo.geometry = misti_geo.geometry.buffer(0.010)

misti_geo["survey_id"] = misti_geo.index+1

misti_geo[["survey_id", "geometry"]].to_file(path+"/misti/empty_grid_misti.geojson", driver="GeoJSON")

###


hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="CHA", :]


hazard_polygons["cleared_year"] = hazard_polygons["Status_Cha"].str[:4].astype(int)

hazard_polygons_cleared = hazard_polygons.loc[hazard_polygons["Status_1"]=="Expired", :]

hazard_polygons_cleared["Hazard_Cla"].unique()

##########

#gdf3.to_file(path+"/empty_grid_afg.geojson", driver="GeoJSON")
gdf3 = gpd.read_file(path+"/misti/empty_grid_misti.geojson")

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

path3 = path+"/hazard_dissolve_cha.geojson"
polygon3 = fiona.open(path3)
geom_p3 = [ shape(feat["geometry"]) for feat in polygon3 ]

df2 = pd.DataFrame(columns=["merge_id", "pct_area_cha"])

for i, g1 in enumerate(geom_p1):
    for j, g3 in enumerate(geom_p3):
        a = (g1.intersection(g3).area/g1.area)*100
        df2=df2.append({"merge_id": i, "pct_area_cha": a}, ignore_index=True)

#gdf3.merge(df2, on="merge_id", inplace=True)
#gdf3 = pd.concat([gdf3, df2.drop(["merge_id"], axis=1)], axis=1)

##########


#misti_geo = misti_geo.sample(100)
#misti_geo = misti_geo.reset_index(drop=True)

mines1 = gpd.sjoin(misti_geo, hazard_polygons, how="left", op="intersects")

mines2 = mines1[["survey_id", "cleared_year"]]
mines2["cleared_year"] = mines2["cleared_year"].astype("Int64").astype("str")

mines3 = mines2.pivot_table(values="cleared_year", index="survey_id", aggfunc='|'.join)

mines4 = mines3["cleared_year"].to_list()

def build(year_str):
    j = year_str.split('|')
    return {i:j.count(i) for i in set(j)}

mines5 = list(map(build, mines4))

mines6 = pd.DataFrame(mines5)
mines6.drop(["<NA>"], axis=1, inplace=True)


misti_geo["num_cleared"] = 0
misti_geo["all_cleared"] = 0

for i in range(1, misti_geo.shape[0]):
	temp_year = misti_geo.m7.iloc[i]
	a = mines6.iloc[i]
	b = a.index.tolist()
	b = [int(i) for i in b]
	c = a[b<temp_year]
	d = a[b>temp_year]
	misti_geo["num_cleared"].iloc[i] = c.sum()
	misti_geo["all_cleared"].iloc[i] = d.sum()

misti_geo["any_cleared"] = (misti_geo["num_cleared"]>0) * 1
misti_geo["all_cleared"] = (misti_geo["all_cleared"]==0) * 1



#test = misti_geo.sample(100)
#test.to_file("/Users/christianbaehr/Downloads/test_misti.geojson", driver="GeoJSON")

###


a = zonal_stats(misti_geo, path+"/pop/pop_count/gpw_popcount_resample_2000.tif", stats=["mean"])
b = pd.DataFrame(a)
b.columns = ["pop_count2000"]
misti_geo = pd.concat([misti_geo, b], axis=1)


###

# misti_geo.to_file("/Users/christianbaehr/Downloads/test.geojson", driver="GeoJSON")

##########


misti_geo.drop(["geometry"], axis=1).to_csv(path+"/misti/misti_panel.csv", index=False)















