import arcpy
from arcpy import env
from arcpy.sa import *
env.workspace = "C:/sapyexamples/data"
outZSaT = ZonalStatisticsAsTable("zones.shp", "Classes", "valueforzone",
                                  "zonalstattblout", "NODATA", "SUM")
