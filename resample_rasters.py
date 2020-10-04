
path = "/Users/christianbaehr/Box Sync/demining/inputData"

from osgeo import gdal, gdalconst

match_filename = path+"/ntl/dmsp_afg_2000.tif"
match_ds = gdal.Open(match_filename, gdalconst.GA_ReadOnly)
match_proj = match_ds.GetProjection()
match_geotrans = match_ds.GetGeoTransform()
wide = match_ds.RasterXSize
high = match_ds.RasterYSize

for i in [2000, 2005, 2010, 2015, 2020]:
	src_filename = path+"/pop/pop_density/gpw_popdensity_"+str(i)+".tif"
	src = gdal.Open(src_filename, gdalconst.GA_ReadOnly)
	src_proj = src.GetProjection()
	src_geotrans = src.GetGeoTransform()
	dst_filename = path+"/pop/pop_density/gpw_popdensity_resample_"+str(i)+".tif"
	dst = gdal.GetDriverByName("GTiff").Create(dst_filename, wide, high, 1, gdalconst.GDT_Float32)
	dst.SetGeoTransform( match_geotrans )
	dst.SetProjection(match_proj)
	gdal.ReprojectImage(src, dst, src_proj, match_proj, gdalconst.GRA_Bilinear)
	del dst

for i in [2000, 2005, 2010, 2015, 2020]:
	src_filename = path+"/pop/pop_count/gpw_popcount_"+str(i)+".tif"
	src = gdal.Open(src_filename, gdalconst.GA_ReadOnly)
	src_proj = src.GetProjection()
	src_geotrans = src.GetGeoTransform()
	dst_filename = path+"/pop/pop_density/gpw_popdensity_resample_"+str(i)+".tif"
	dst = gdal.GetDriverByName("GTiff").Create(dst_filename, wide, high, 1, gdalconst.GDT_Float32)
	dst.SetGeoTransform( match_geotrans )
	dst.SetProjection(match_proj)
	gdal.ReprojectImage(src, dst, src_proj, match_proj, gdalconst.GRA_Bilinear)
	del dst

