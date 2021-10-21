import ee 
# authenticate earth engine api access (not required on every run)
ee.Authenticate()
ee.Initialize()

import geemap
import math

#import lANDSAT7
L7 = ee.ImageCollection("LANDSAT/LE07/C01/T1_SR")

#select study area
world = ee.FeatureCollection("FAO/GAUL/2015/level0")
country = world.filterMetadata('ADM0_NAME', 'equals', 'Costa Rica')

# EVI2 Expressions
f_evi = '2.5 * ((nir - red) / (nir + 2.4 * red + 1))'; # EVI2 formula (two-band version)

# VegIndex calculator. Calculate the EVI2 index
def calcIndex(image):
    evi = image.expression(
      f_evi,
        {
          'red': image.select('B3').multiply(0.0001),   # 620-670nm, RED
          'nir': image.select('B4').multiply(0.0001)    # 841-876nm, NIR
         })
    return image.addBands((evi.rename('EVI2')).multiply(10000).int16())


# Function to mask clouds in Landsat imagery
def maskClouds(image):
  # bit positions: find by raising 2 to the bit flag code
    cloudBit = math.pow(2, 5); #32
    shadowBit = math.pow(2, 3); #8
    snowBit = math.pow(2, 4); #16
    fillBit = math.pow(2,0); #1
    #extract pixel quality band
    qa = image.select('pixel_qa');   
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
  

start_date = '2012-01-01'
end_date = '2012-12-31'

#preprocessing L7 images
landsat_evi2 = L7.filter(ee.Filter.date(start_date, end_date)) \
                      .filterBounds(country) \
                      .map(maskClouds) \
                      .map(calcIndex) \
                      .map(maskExcess) \
                      .select('EVI2')

#print(landsat_evi2)

#calcuate 4 variables
evi2_min = (landsat_evi2.min()).int16()
evi2_max = (landsat_evi2.max()).int16()
evi2_mean = (landsat_evi2.mean()).int16()
evi2_std = (landsat_evi2.reduce(ee.Reducer.stdDev())).int16()

# put all 4 variables together
evi2_stat = evi2_min.addBands(evi2_max).addBands(evi2_mean).addBands(evi2_std)

#export image
task = ee.batch.Export.image.toDrive(image=evi2_stat.clip(country),
                                     description='CR_Landsat_EVI2_new',
                                     scale=30,
                                     maxPixels = 1e13,
                                     region=country.geometry())
task.start()
task.status()
