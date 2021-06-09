import ee
import geemap

Map = geemap.Map()

Landsat7_EVI = ee.ImageCollection("LANDSAT/LE07/C01/T1_8DAY_EVI")
countries = ee.FeatureCollection("USDOS/LSIB_SIMPLE/2017")
costa_rica = ee.FeatureCollection(countries.filter(ee.Filter.stringContains('country_na', 'Costa')))

GDriveOutputImgFolder = 'GEEOutputs'
MODIS_LAI_FPAR = Landsat7_EVI

new_list = ee.List([])

for i in range(1999, 2013, 1):
#for i in range(1999, 2001, 1):
    start_date = str(i) + '-01-01'
    end_date = str(i) + '-12-31'

    Fpar_500m1 = MODIS_LAI_FPAR \
                      .filter(ee.Filter.date(start_date, end_date)) \
                      .select('EVI')

    print('Fpar_500m1',Fpar_500m1)
    Fpar_500m_min = (Fpar_500m1.reduce(ee.Reducer.minMax())).select(['EVI_min'],['EVI_min_' + str(i)])
    new_list =_list.add(ee.Image(Fpar_500m_min))

MODIS_Fpar_year = ee.ImageCollection.fromImages(new_list)

print(MODIS_Fpar_year)

img = MODIS_Fpar_year.toBands()
print('img',img)

scale = 30

Export.image.toDrive({
      'image': img ,
      'description': 'Landsat7_EVI_min_2000_2012_CR',
      'region': costa_rica,
      'maxPixels': 1e13,
      'folder': GDriveOutputImgFolder,
      'scale': scale
      #crs: 'EPSG:3571'
    });
Map
