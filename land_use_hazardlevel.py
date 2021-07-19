
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

########################################

#works!!!

path = "/Users/christianbaehr/Box Sync/demining/inputData"
fp = path+"/LandUseProducts/2000/2000_L5_lulc.tif"

import rasterio
import numpy as np
from rasterio.plot import show
from osgeo import gdal
from osgeo import gdal_array

##########

temp_src="/Users/christianbaehr/Downloads/temp.tif"

landuse_dict = {1:"bareearth", 2:"builtup", 3:"farmland", 4:"forest", 5:"grassland", 6:"snow", 7:"water"}

for i in [1995, 2000, 2008, 2010, 2015, 2020]:
	fp = path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L5_lulc.tif"
	if i>=2015:
		fp = path+"/LandUseProducts/"+str(i)+"/"+str(i)+"_L8_lulc.tif"
	raster = rasterio.open(fp)
	lulc = raster.read(1)
	for key, value in landuse_dict.items():
		myarray = (lulc==key)*1
		src_ds=gdal_array.OpenArray(myarray)
		xmin,ymin,xmax,ymax=raster.bounds
		nrows,ncols=lulc.shape
		xres=(xmax-xmin)/float(ncols)
		yres=(ymax-ymin)/float(nrows)
		geotransform=(xmin,xres,0,ymax,0, -yres)
		dst_ds = gdal.GetDriverByName('GTiff').Create(temp_src,ncols,nrows, 1 ,gdal.GDT_Byte)
		dst_ds.SetGeoTransform(geotransform)
		dst_ds.GetRasterBand(1).WriteArray(myarray)
		del dst_ds
		arr = zonal_stats(hazard, temp_src, stats=["mean"])
		dat = pd.DataFrame(arr)
		hazard[value+str(i)] = dat["mean"]



coords = [(x,y) for x, y in zip(hazard.centroid.x, hazard.centroid.y)]

for i in [1995, 2000, 2008, 2010, 2015]:
	temperature = rasterio.open(path+"/airtemp_udel_32642/air_temp_"+str(i)+"_32642.tif")
	precip = rasterio.open(path+"/precip_udel_32642/precip_"+str(i)+"_32642.tif")
	hazard["temperature"+str(i)] = [x[0] for x in temperature.sample(coords)]
	hazard["precipitation"+str(i)] = [x[0] for x in precip.sample(coords)]

###

for i in [1995, 2000, 2008, 2010, 2015, 2020]:
	hazard["cleared"+str(i)] = ((hazard["Status_C_1"]<=i) & (hazard["Status_1"]=="Expired"))*1



hazard["cleared_post2008"] = (hazard["Status_C_1"]>=2008)*1

###

adm = path+"/gadm36_AFG_2_32642.geojson"

hazard = gpd.sjoin(hazard, gpd.read_file(adm), how="left")
hazard = hazard.loc[~hazard["hazard_id"].duplicated(), :]


hazard.to_file(path+"/full_grid_landuse_hazardlevel.geojson", driver="GeoJSON")
hazard.drop(["geometry"], axis=1).to_csv(path+"/full_grid_landuse_hazardlevel.csv", index=False)

##########


path = "/Users/christianbaehr/Box Sync/demining/inputData"

import os
import pandas as pd
import rasterio

#src = path+"/LandUseProducts/2000/2000_L5_lulc.tif"
src = "/Users/christianbaehr/Downloads/grid_outline_30m.tif"

ras = rasterio.open(src, "r")
ras_array = ras.read()
ras_vals = ras.read(1)

count=0
with open("/Users/christianbaehr/Downloads/empty_grid_30m.csv", "w") as f:
	a=f.write("cell_id,lon,lat\n")
	for i in range(ras.shape[0]):
		for j in range(ras.shape[1]):
			temp = ras_vals[i, j]
			if temp!=65535:
				count = count+1
				x, y = ras.xy(i, j)
				out = [str(count)] + [str(x)] + [str(y)]
				a=f.write(",".join(out)+"\n")





x, y = treecover.xy(i, j)
	for i in range(treecover_array.shape[1]):
		for j in range(treecover_array.shape[2]):
			temp = treecover_vals[i, j]

src = path+"/Hansen_treecover2000_trimmed.tif"

treecover = rasterio.open(src, "r")
treecover_array = treecover.read()
treecover_vals = treecover.read(1)

mask_src = path+"/Hansen_datamask_trimmed.tif"
mask = rasterio.open(mask_src, "r")
mask_vals = mask.read(1)
treecover_vals[mask_vals!=1] = 255

###

treecover2000 = (treecover_vals>25) * 1
treecover2000[treecover_vals==255] = 255

loss_src = path+"/Hansen_lossyear_trimmed.tif"
loss = rasterio.open(loss_src, "r")
loss_vals = loss.read(1)
loss_vals[treecover_vals==255] = 255

tc_mask = ((treecover2000==0) & (loss_vals!=0))
treecover2000[tc_mask] = 255

treecover_dict = {}
treecover_dict["treecover2000"] = treecover2000

for i in range(1, 19):
	temp = (loss_vals==i)*1
	temp[treecover_vals==255] = 0
	treecover_dict["treecover{0}".format(i+2000)] = treecover_dict["treecover{0}".format(i+1999)] - temp

###

count = 1
with open(path+"/hansen_grid.csv", "w") as f:
	a=f.write("cell_id,lon,lat,tc2000,tc2001,tc2002,tc2003,tc2004,tc2005,tc2006,tc2007,tc2008,tc2009,tc2010,tc2011,tc2012,tc2013,tc2014,tc2015,tc2016,tc2017,tc2018\n")
	for i in range(treecover_array.shape[1]):
		for j in range(treecover_array.shape[2]):
			temp = treecover_vals[i, j]
			if (temp!=255 and temp>25):
				tc = [str(treecover_dict["treecover{0}".format(k+2000)][i,j]) for k in range(0, 19)]
				x, y = treecover.xy(i, j)
				out = [str(count)] + [str(x)] + [str(y)] + tc
				a = f.write(",".join(out)+"\n")
				count = count+1



















































