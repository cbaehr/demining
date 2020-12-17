
path = "/Users/christianbaehr/Box Sync/demining/inputData"


import itertools
import rasterio
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point, shape, box
from shapely.prepared import prep
import fiona
from rasterstats import zonal_stats

hazard = gpd.read_file(path+"/hazard_polygons_32642_trimmed.geojson")
hazard.crs="epsg:32642"
hazard = hazard.loc[hazard["Hazard_Cla"].isin(["CHA", "SHA"]) & hazard["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), : ]

hazard.reset_index(drop=True, inplace=True)
hazard["hazard_id"] = hazard.index+1



###

for i in [1995, 2000, 2008, 2010, 2015, 2020]:
	src_builtup = path+"/LandUseProducts/builtupbinary_"+str(i)+".tif"
	src_farmland = path+"/LandUseProducts/farmlandbinary_"+str(i)+".tif"
	src_prob = path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L5_prob.tif"
	if i>2010:
		src_prob = path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L8_prob.tif"
	builtup = zonal_stats(hazard, src_builtup, stats=["mean"])
	builtup=pd.DataFrame(builtup)
	farmland = zonal_stats(hazard, src_farmland, stats=["mean"])
	farmland=pd.DataFrame(farmland)
	prob = zonal_stats(hazard, src_prob, stats=["mean"])
	prob=pd.DataFrame(prob)
	hazard["builtup"+str(i)] = builtup["mean"]
	hazard["farmland"+str(i)] = farmland["mean"]
	hazard["prob"+str(i)] = prob["mean"]

###

coords = [(x,y) for x, y in zip(hazard.centroid.x, hazard.centroid.y)]

for i in [1995, 2000, 2008, 2010, 2015]:
	temperature = rasterio.open(path+"/airtemp_udel_32642/air_temp_"+str(i)+"_32642.tif")
	precip = rasterio.open(path+"/precip_udel_32642/precip_"+str(i)+"_32642.tif")
	hazard["temperature"+str(i)] = [x[0] for x in temperature.sample(coords)]
	hazard["precipitation"+str(i)] = [x[0] for x in precip.sample(coords)]

###

for i in [1995, 2000, 2008, 2010, 2015]:
	hazard["cleared"+str(i)] = (hazard["Status_C_1"]<=i)*1

hazard["cleared_post2008"] = (hazard["Status_C_1"]>=2008)*1

###

adm = path+"/gadm36_AFG_2_32642.geojson"

hazard = gpd.sjoin(hazard, gpd.read_file(adm), how="left")
hazard = hazard.loc[~hazard["hazard_id"].duplicated(), :]


hazard.to_file("/Users/christianbaehr/Downloads/temp.geojson", driver="GeoJSON")
hazard.drop(["geometry"], axis=1).to_csv("/Users/christianbaehr/Downloads/temp.csv", index=False)






























































