import arcpy, os, sys, string
import pdb
from arcpy import env
from arcpy.sa import *
arcpy.CheckOutExtension("spatial")
def CreateDirectory(DBF_dir):
    if not os.path.exists(DBF_dir):
        os.mkdir(DBF_dir)
        print "created directory {0}".format(DBF_dir)

def ZonalStasAsTable(fc,DBF_dir,raster,zoneField):

    for row in arcpy.SearchCursor(fc):       
        lyr = "Zone_{0}_lyr".format(row.OBJECTID)
        pdb.set_trace()
        tempTable = DBF_dir + os.sep + "zone_{0}.dbf".format(row.OBJECTID)
        arcpy.MakeFeatureLayer_management(fc, lyr, "\"OBJECTID\" = {0}".format(row.OBJECTID))
        print "Creating layer {0}".format(lyr)
        out_layer = DBF_dir + os.sep + lyr + ".lyr"
        arcpy.SaveToLayerFile_management(lyr, out_layer, "ABSOLUTE")
        print "Saved layer file"
        #arcpy.FeatureClassToShapefile_conversion(out_layer,"C:/TEMP/DBFile")
        #out_layer = "Zone_{0}_lyr".format(row.OBJECTID)+'.shp'
        ZonalStatisticsAsTable_sa(out_layer, zoneField, raster, tempTable, "DATA", "ALL")
        #print "Populating zonal stats for {0}".format(lyr)
    del row, lyr

def MergeTables(DBF_dir,zstat_table):
    arcpy.env.workspace = DBF_dir
    tableList = arcpy.ListTables()
    arcpy.Merge_management(tableList,zstat_table)
    print "Merged tables. Final zonalstat table {0} created. Located at {1}".format(zstat_table,DBF_dir)
    del tableList
if __name__ == "__main__":
    ws = "C:/TEMP"
    DBF_dir = ws + os.sep + "DBFile"
    #DBF_dir = ws + "DBFile"
    fc = "C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/Subsheds/Polysheds123.dbf"
    raster = r"C:/Users/Lingling-Thinkpad/Documents/test1/sed_export_C_5km.tif"
    zoneField = "Stat_id"
    zstat_table = DBF_dir + os.sep + "Zonalstat.dbf"
    #zstat_table = DBF_dir + "Zonalstat.dbf"
    CreateDirectory(DBF_dir)
    ZonalStasAsTable(fc,DBF_dir,raster,zoneField)
    MergeTables(DBF_dir,zstat_table)
