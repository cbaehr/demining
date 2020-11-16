
path = "/Users/christianbaehr/Box Sync/demining/inputData"

import fiona
import geopandas as gpd
import rasterio
import pandas as pd
from shapely.geometry import Point, shape, Polygon
from rasterstats import zonal_stats
import numpy as np
import pyproj
import shapely
import shapely.ops as ops
from functools import partial

#empty_grid = gpd.read_file(path+"/empty_grid_afg_trimmed.geojson")
#empty_grid = empty_grid.sample(1000)

empty_grid_geo = fiona.open(path+"/empty_grid_afg_trimmed.geojson")
empty_grid_geom = [shape(feat["geometry"]) for feat in empty_grid_geo]


hazard_polygons = gpd.read_file(path+"/hazard_polygons.geojson")
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Typ"].isin(["MineField", "Suspected Minefield", "Converted From SHA"]), :]
hazard_polygons = hazard_polygons.loc[hazard_polygons["Hazard_Cla"]=="CHA", : ]
hazard_polygons = hazard_polygons[["OBJECTID", "Status_1", "Status_C_1", "geometry"]]
hazard_polygons["country"] = "Afghanistan"

cleared_area = hazard_polygons.loc[hazard_polygons["Status_1"]=="Expired", : ]

###

empty_grid = gpd.read_file(path+"/empty_grid_afg_trimmed.geojson")

for i in range(1992, 2021):
	cleared_area_yr = cleared_area.loc[cleared_area["Status_C_1"]==i, :]
	cleared_area_yr = cleared_area_yr.dissolve(by="country").buffer(0)
	if cleared_area_yr.shape!=(0,):	
		cleared_area_yr_poly = cleared_area_yr.geometry[0]
		temp = []
		for j, g1 in enumerate(empty_grid_geom):
			a = g1.intersection(cleared_area_yr_poly)
			if a.bounds!=():
				geom_area = ops.transform(partial(pyproj.transform, pyproj.Proj(init="EPSG:4326"), pyproj.Proj(proj="aea", lat_1=a.bounds[1], lat_2=a.bounds[3])), a)
				b = a.area
				temp = temp + [b]
			else:
				b = 0
				temp = temp + [b]
		c = pd.DataFrame(temp)
		empty_grid["area_cleared"+str(i)] = c

for i in range(1992, 2021):
	if "area_cleared"+str(i) not in empty_grid.columns:
		empty_grid["area_cleared"+str(i)] = 0



loc_cols = ["area_cleared"+str(i) for i in range(1992, 2021)]
empty_grid = empty_grid[loc_cols]


grid = pd.read_csv(path+"/pre_panel.csv")

grid = pd.concat([grid, empty_grid], axis=1)

grid.drop(["geometry"], axis=1).to_csv(path+"/pre_panel.csv", index=False)

#grid.to_csv(path+"/pre_panel.csv", index=False)
























