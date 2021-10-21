var L8 = ee.ImageCollection("LANDSAT/LC08/C01/T1_SR"),
    L7 = ee.ImageCollection("LANDSAT/LE07/C01/T1_SR"),
    L5 = ee.ImageCollection("LANDSAT/LT05/C01/T1_SR"),
    world = ee.FeatureCollection("FAO/GAUL/2015/level0");


Map.setCenter (-84, 10);

//select a country
var country = world.filterMetadata('ADM0_NAME', 'equals', 'Costa Rica');

//L5 and L7 are very similiar, so we callirated L8 to L7 to keep all three sensors consistent
var L8_band_cal = function(img){
  var b4 = img.select('B4');
  var b5 = img.select('B5');
  
  var b4_cal = (b4.divide(10000.0).multiply(0.9372).add(0.0123)).multiply(10000);
  var b5_cal = (b5.divide(10000.0).multiply(0.8339).add(0.0448)).multiply(10000);
  return img.addBands(b4_cal.rename('b3_cal'))
         .addBands(b5_cal.rename('b4_cal'))
         .select(['b3_cal', 'b4_cal', 'pixel_qa'],['B3','B4', 'pixel_qa']);
};

// Expressions
 var f_evi = '2.5 * ((nir - red) / (nir + 2.4 * red + 1))'; // EVI2 formula (two-band version)
//   var f_evi = '2.5 * ((B4 - B3) / (B4 + 2.4 * B3 + 1))'; // EVI2 formula (two-band version)

// VegIndex calculator. Calculate the EVI index (two-band versiob)
function calcIndex(image){
  var evi = image.expression(
      f_evi,
        {
          red: image.select('B3').multiply(0.0001),    // 620-670nm, RED
          nir: image.select('B4').multiply(0.0001)    // 841-876nm, NIR
        //   B3:image.select('B3').multiply(0.0001),    // 620-670nm, RED
        //   B4:image.select('B4').multiply(0.0001)    // 841-876nm, NIR
         });
    // Rename that band to something appropriate
    //var dimage = ee.Date(ee.Number(image.get('system:time_start'))).format();
    //return evi.select([0], [what]).set({'datef': dimage,'system:time_start': ee.Number(image.get('system:time_start'))});
    return image.addBands((evi.rename('EVI2')).multiply(10000).int16());

}

// Function to mask clouds in Landsat imagery.
var maskClouds = function(image){
  // bit positions: find by raising 2 to the bit flag code 
  var cloudBit = Math.pow(2, 5); //32
  var shadowBit = Math.pow(2, 3); // 8
  var snowBit = Math.pow(2, 4); //16
  var fillBit = Math.pow(2,0); // 1
  // extract pixel quality band
  var qa = image.select('pixel_qa');    
  // create and apply mask
  var mask = qa.bitwiseAnd(cloudBit).eq(0).and(  // no clouds
              qa.bitwiseAnd(shadowBit).eq(0)).and( // no cloud shadows
              qa.bitwiseAnd(snowBit).eq(0)).and(   // no snow
              qa.bitwiseAnd(fillBit).eq(0))   ; // no fill
  
  // display orginal, mask and images_updated_with_mask
  //Map.addLayer(image, {bands: ['B5', 'B4', 'B3'], min: 0, max: 3000}, 'image');
  //Map.addLayer(mask, {}, 'mask');
  //Map.addLayer(image.updateMask(mask), {bands: ['B5', 'B4', 'B3'], min: 0, max: 3000}, 'image.updateMask(mask)');
  return image.updateMask(mask);   
};

// Function to mask excess EVI2 values defined as > 10000 and < 0
var maskExcess = function(image) {
    var hi = image.lte(10000);
    var lo = image.gte(0);
    var masked = image.mask(hi.and(lo));
    return image.mask(masked);
  };

for (var i = 2012; i < 2013; i++){
  
  var start_date = i + '-01-01';
  var end_date = i + '-12-31';
  
  
  var landsat_evi2 = L5.merge(L7)
                      .merge(L8.map(L8_band_cal))
                      .filter(ee.Filter.date(start_date, end_date))
                      .filterBounds(country)
                      //.filterBounds(Spain_sites)
                      .map(maskClouds)
                      //.map(getNDVI)
                      .map(calcIndex)
                      .map(maskExcess)
                      .select('EVI2');
                      
    print(landsat_evi2);
    Map.addLayer(landsat_evi2.first(),{}, 'landsat_evi2.first');
    
    var evi2_min = (landsat_evi2.min()).int16()
    var evi2_max = (landsat_evi2.max()).int16()
    var evi2_mean = (landsat_evi2.mean()).int16()
    //var evi2_mean = landsat_evi2.mean()
    var evi2_std = (landsat_evi2.reduce(ee.Reducer.stdDev())).int16()
    
    var evi2_stat = evi2_min.addBands(evi2_max).addBands(evi2_mean).addBands(evi2_std)
    
    Map.addLayer(evi2_mean.clip(country), {min: 0, max: 10000}, 'evi2_mean');
    Export.image(evi2_stat.clip(country),'CR_Landsat_EVI2_statistics_2012', {scale: 30, maxPixels: 1000000000,region: country.geometry().bounds()}) 

    
    }
