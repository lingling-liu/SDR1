import ee 
# authenticate earth engine api access (not required on every run)
ee.Authenticate()
ee.Initialize()

import geemap
import math

#import latest Landsat 8 data (GEE often update data source)
L8 = ee.ImageCollection("LANDSAT/LC08/C02/T1_L2")

#select study area
world = ee.FeatureCollection("FAO/GAUL/2015/level0")
country = world.filterMetadata('ADM0_NAME', 'equals', 'Costa Rica')

# EVI2 Expressions
f_evi = '2.5 * ((nir - red) / (nir + 2.4 * red + 1))'; # EVI2 formula (two-band version)

# VegIndex calculator. Calculate the EVI2 index (two-band versiob)
# https://www.usgs.gov/faqs/how-do-i-use-a-scale-factor-landsat-level-2-science-products?qt-news_science_products=0#qt-news_science_products 
# band names were updated
def calcIndex(image):
    evi = image.expression(
      f_evi,
        {
          'red': image.select('SR_B4').multiply(0.0000275).subtract(0.2), #RED; applied scale and offset
          'nir': image.select('SR_B5').multiply(0.0000275).subtract(0.2) #NIR; applied scale and offset
         })
    return image.addBands((evi.rename('EVI2')).multiply(10000).int16())



# Function to mask clouds in Landsat imagery
# need updated if data scource got updated including band names and bits
def maskClouds(image):
  # bit positions: find by raising 2 to the bit flag code
    cloudBit = math.pow(2, 3); 
    shadowBit = math.pow(2, 4); 
    snowBit = math.pow(2, 5); 
    fillBit = math.pow(2,0); 
    # extract pixel quality band
    qa = image.select('QA_PIXEL')
    # create and apply mask
    mask = qa.bitwiseAnd(cloudBit).eq(0).And(  # no clouds
              qa.bitwiseAnd(shadowBit).eq(0)).And( # no cloud shadows
              qa.bitwiseAnd(snowBit).eq(0)).And(   # no snow
              qa.bitwiseAnd(fillBit).eq(0))   ; # no fill
    return image.updateMask(mask)


# Function to mask excess EVI2 values defined as > 10000 and < 0
def maskExcess(image):
    hi = image.lte(10000)
    lo = image.gte(0)
    masked = image.mask(hi.And(lo))
    return image.mask(masked)



start_date = '2014-01-01'
end_date = '2014-12-31'

#preprocessing L8 images
landsat_evi2 = L8.filter(ee.Filter.date(start_date, end_date)) \
                      .filterBounds(country) \
                      .map(maskClouds) \
                      .map(calcIndex) \
                      .map(maskExcess) \
                      .select('EVI2')

print(landsat_evi2)

#calcuate 4 variables
evi2_min = (landsat_evi2.min()).int16()

#export image
task = ee.batch.Export.image.toDrive(image=evi2_min.clip(country),
                                     description='CR_Landsat8_C2_EVI2_2014',
                                     scale=30,
                                     maxPixels = 1e13,
                                     region=country.geometry())
task.start()
task.status()
