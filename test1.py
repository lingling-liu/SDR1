import arcpy, os, sys, string
import pdb
from arcpy import env
from arcpy.sa import *

# Set environment settings
env.workspace = "C:/TEMP/DBFile"

arcpy.CheckOutExtension("Spatial")
if __name__ == "__main__":
    pdb.set_trace()
    out_layer = 'Zone_1_lyr'
    featureclasses = arcpy.ListFeatureClasses()
    arcpy.AddMessage('Beginning Feature Class to Feature Class conversion...')
    arcpy.FeatureClassToShapefile_conversion([out_layer],"C:/TEMP/DBFile")
    out_layer = 'Zone_1_lyr.shp'
    zoneField = "Stat_id"
    raster = "sed_export_C_5km.tif"
    tempTable = 'zone_1.dbf'
    #ZonalStatisticsAsTable(out_layer, zoneField, raster, tempTable, "DATA", "ALL")
