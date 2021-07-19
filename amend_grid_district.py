
import pandas as pd

dat = pd.read_csv("/Users/christianbaehr/Downloads/panel_1km_district.csv")

dat["gid_2"]=="AFG.15.2_1"

###

adm2=gpd.read_file("/Users/christianbaehr/Downloads/gadm36_AFG_shp/gadm36_AFG_2.shp")

###

import geopandas as gpd
hazard_polygons = gpd.read_file("/Users/christianbaehr/Downloads/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
#hazard_polygons["Status_Cha"] = pd.to_datetime(hazard_polygons["Status_Cha"], format="%Y-%m-%d")
hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_Cha", "Status_C_1", "Hazard_Cla", "Waters", "Roads", "Mines", "Historical", "Housing", "Infrastruc", "Agricultur", "Grazing", "geometry"]]
#hazard_polygons["hazard_area"] = hazard_polygons["geometry"].area

hazard_polygons["country"]="Afghanistan"

###

from shapely.geometry import Point, shape

geom_p1=[shape(feat) for feat in adm2["geometry"]]
g1_area = [i.area for i in geom_p1]

#for j in range(1992, 2021):
for j in range(2009, 2021):	
	print(j)
	cond= (hazard_polygons["Status_C_1"] > j).tolist() or (hazard_polygons["Status_1"]!="Expired").tolist()
	hazard_temp=hazard_polygons.loc[cond, ].dissolve(by="country")
	geom_p2=[shape(feat) for feat in hazard_temp["geometry"]]
	g2 = geom_p2[0]
	pct_covered = []
	for i, g1 in enumerate(geom_p1):
		a = (g1.intersection(g2).area/g1_area[i]) * 100
		pct_covered = pct_covered + [a]
	adm2["pct_covered_{}".format(j)]=pct_covered

adm2.to_file("/Users/christianbaehr/Downloads/district_pctcovered.geojson", driver="GeoJSON")


dat2=dat.merge(adm2, left_on="gid_2", right_on="GID_2")

dat2.to_csv("/Users/christianbaehr/Downloads/district_panel_withpercents.csv", index=False)










 





