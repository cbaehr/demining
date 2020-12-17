
###

path = "/Users/christianbaehr/Box Sync/demining/inputData"
landuse2020 = rasterio.open(path+"/LandUseProducts/2020/2020_L8_lulc.tif")

array = landuse2020.read(1)

array_1d = array.ravel()
array_1d.mean()

###

path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np

#hazard_polygons = gpd.read_file(path+"/hazard_polygons_32648_trimmed.geojson")
hazard_polygons = gpd.read_file("/Users/christianbaehr/Downloads/hazard_polygons_32642_trimmed.geojson")
hazard_polygons.crs = "epsg:32642"
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
hazard_polygons.loc[hazard_polygons["Status_1"]!="Expired", "Status_C_1"] = 3000

def shrink(dat):
	dat["country"] = "Afghanistan"
	geo = dat.buffer(100)
	df = gpd.GeoDataFrame(dat, crs="epsg:32642", geometry=geo).dissolve(by="country")
	return(df)

hazard_polygons_dissolve=shrink(hazard_polygons)
hazard_earlycleared_dissolve=shrink(hazard_polygons.loc[hazard_polygons["Status_C_1"]<2008, :])
hazard_latecleared_dissolve=shrink(hazard_polygons.loc[hazard_polygons["Status_C_1"]>=2008, :])

###

#ras = rasterio.open(path+"/LandUseProducts/2010/2010_L5_lulc.tif")
#affine = ras.transform
#array_2010 = ras.read(1)


dat=pd.DataFrame()

for k in ["all", "early", "late"]:
	if k=="all":
		poly=hazard_polygons_dissolve
	elif k=="early":
		poly=hazard_earlycleared_dissolve
	else:
		poly=hazard_latecleared_dissolve
	for i in [2010, 2015, 2020]:
		if i!=2010:
			my_ras = rasterio.open(path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L8_lulc.tif")
		else:
			my_ras = rasterio.open(path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L5_lulc.tif")
		affine = my_ras.transform
		array = my_ras.read(1)
		col = []
		for j in range(1, 8):
			array_temp = (array==j)*1
			val = zonal_stats(poly, array_temp, affine=affine, stats=["mean"])
			col = col + [val[0]["mean"]]
		dat[str(i)+k] = col

dat.index=["Bare earth", "Built-up", "Farmland", "Forest", "Grassland", "Snow", "Water"]

dat = dat.round(4)*100
dat*100

dat.to_latex("/Users/christianbaehr/Downloads/temp_1kmbuf.tex")


########################################


path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape
from rasterstats import zonal_stats
import numpy as np

#hazard_polygons = gpd.read_file(path+"/hazard_polygons_32648_trimmed.geojson")
hazard_polygons = gpd.read_file("/Users/christianbaehr/Downloads/hazard_polygons_32642_trimmed.geojson")
hazard_polygons.crs = "epsg:32642"
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"].isin(["CHA", "SHA"]), : ]
hazard_polygons.loc[hazard_polygons["Status_1"]!="Expired", "Status_C_1"] = 3000

def shrink(dat):
	dat["country"] = "Afghanistan"
	geo = dat.buffer(0)
	df = gpd.GeoDataFrame(dat, crs="epsg:32642", geometry=geo).dissolve(by="country")
	return(df)

#hazard_polygons_dissolve=shrink(hazard_polygons)
hazard_early2010s_dissolve=shrink(hazard_polygons.loc[hazard_polygons["Status_C_1"].isin(range(2010, 2015)), :])
hazard_late2010s_dissolve=shrink(hazard_polygons.loc[hazard_polygons["Status_C_1"].isin(range(2015, 2021)), :])





dat=pd.DataFrame()

for k in ["early2010", "late2010"]:
	if k=="early2010":
		poly=hazard_early2010s_dissolve
	else:
		poly=hazard_late2010s_dissolve
	for i in [2010, 2015, 2020]:
		if i!=2010:
			my_ras = rasterio.open(path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L8_lulc.tif")
		else:
			my_ras = rasterio.open(path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L5_lulc.tif")
		affine = my_ras.transform
		array = my_ras.read(1)
		col = []
		for j in range(1, 8):
			array_temp = (array==j)*1
			val = zonal_stats(poly, array_temp, affine=affine, stats=["mean"])
			col = col + [val[0]["mean"]]
		dat[str(i)+k] = col

dat.index=["Bare earth", "Built-up", "Farmland", "Forest", "Grassland", "Snow", "Water"]

dat = dat.round(4)*100
dat*100

dat.to_latex("/Users/christianbaehr/Downloads/temp_nobuf_add.tex")






