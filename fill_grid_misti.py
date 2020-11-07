
import pandas as pd
from shapely.geometry import Point
import geopandas as gpd
from rasterstats import zonal_stats

path = "/Users/christianbaehr/Box Sync/demining/inputData"


cols = ["m1", "m2", "m2a", "m3", "m4", "m5", "m6", "m7", "m8", "m9", "date", "m21", "m22",
"m23", "m24a", "m24b", "q1", "q30", "q31", "q32", "q33", "q34", "q2a", "q2b", "q2c",
"q3b", "q4e", "q4f", "q35", "q36e", "q14a", "q14b", "q14c", "q14d", "q17b", "q17c", "q17d",
"q17f", "q17g", "q18", "q19a", "q19b", "q19c", "q19d", "q19e", "q19f", "q19g", "q19h",
"q19i", "q36a", "q36b", "q36c", "q36d", "q36f", "q37", "q38"]

wave1 = pd.read_csv(path+"/misti/MISTI Wave1 Data File V3 CSV updated.csv")
wave1.rename({"m24_lat":"m24a", "m24_lon":"m24b"}, axis=1, inplace=True)

wave1_cols = [x for x in cols if x in wave1.columns]

wave1 = wave1[wave1_cols]
wave1["wave"] = "wave1"

###

wave2 = pd.read_csv(path+"/misti/MISTI Wave2 Data File V2.csv")

wave2_cols = [x for x in cols if x in wave2.columns]

wave2 = wave2[wave2_cols]
wave2["wave"] = "wave2"

###

wave3 = pd.read_csv(path+"/misti/MISTI W3 Data File FINAL V7 12-03-2014 CSV updated.csv")

wave3_cols = [x for x in cols if x in wave3.columns]

wave3 = wave3[wave3_cols]
wave3["wave"] = "wave3"

###

wave4 = pd.read_csv(path+"/misti/MISTI W4 Data File FINAL V3 19-08-20142_XLS updated.csv")

wave4_cols = [x for x in cols if x in wave4.columns]

wave4 = wave4[wave4_cols]
wave4["wave"] = "wave4"

###

wave5 = pd.read_csv(path+"/misti/MISTI W5 Data File V3 18-01-2015 CSV updated.csv")

wave5_cols = [x for x in cols if x in wave5.columns]

wave5 = wave5[wave5_cols]
wave5["wave"] = "wave5"

##########


misti = pd.concat([wave1, wave2, wave3, wave4, wave5], axis=0)

misti["survey_id"] = misti.index + 1

misti["m24a"].describe()
misti["m24b"].describe()

points = [Point(xy) for xy in zip(misti.m24b, misti.m24a)]
crs = "epsg:4326"
misti_geo = gpd.GeoDataFrame(misti, crs=crs, geometry=points)
misti_geo.geometry = misti_geo.geometry.buffer(0.010)

###

#misti_geo = misti_geo.sample(100)
#misti_geo = misti_geo.reset_index(drop=True)

hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]

hazard_polygons["Status_Cha"]
hazard_polygons["cleared_year"] = hazard_polygons["Status_Cha"].str[:4].astype(int)


test = gpd.sjoin(misti_geo, hazard_polygons, how="left", op="intersects")

test2 = test[["survey_id", "cleared_year"]]
test2["cleared_year"] = test2["cleared_year"].astype("Int64").astype("str")

test3 = test2.pivot_table(values="cleared_year", index="survey_id", aggfunc='|'.join)

test4 = test3["cleared_year"].to_list()

def build(year_str):
    j = year_str.split('|')
    return {i:j.count(i) for i in set(j)}

test5 = list(map(build, test4))

test6 = pd.DataFrame(test5)
test6.drop(["<NA>"], axis=1, inplace=True)


misti_geo["num_cleared"] = 0

for i in range(1, misti_geo.shape[0]):
	temp_year = misti_geo.m7.iloc[i]
	a = test6.iloc[i]
	b = a.index.tolist()
	b = [int(i) for i in b]
	c = a[b<temp_year]
	misti_geo["num_cleared"].iloc[i] = c.sum()

misti_geo["any_cleared"] = (misti_geo["num_cleared"]>0) * 1

###


a = zonal_stats(misti_geo, path+"/pop/pop_count/gpw_popcount_resample_2015.tif", stats=["mean"])
b = pd.DataFrame(a)
b.columns = ["pop_count2015"]
misti_geo = pd.concat([misti_geo, b], axis=1)


###

# misti_geo.to_file("/Users/christianbaehr/Downloads/test.geojson", driver="GeoJSON")

##########


misti_geo.to_file(path+"/misti/misti_panel.geojson", driver="GeoJSON")


























