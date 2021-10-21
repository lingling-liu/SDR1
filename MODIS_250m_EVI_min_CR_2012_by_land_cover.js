

var MODIS_VI = ee.ImageCollection("MODIS/006/MOD13Q1");
var MODIS_LAI_FPAR = MODIS_VI;
var scale = 231.65635826395825;
var GDriveOutputImgFolder = 'GEEOutputs/'; 

var countries = ee.FeatureCollection("USDOS/LSIB_SIMPLE/2017");
var costa_rica = ee.FeatureCollection(countries.filter(ee.Filter.stringContains('country_na', 'Costa')));
Map.addLayer(costa_rica, {min:0, max:1}, 'costa_rica', false);


var new_list = ee.List([]);
var LC_raw_2012 = (ee.Image('MODIS/006/MCD12Q1/2012_01_01')).select('LC_Type2'); 

  var i = 2012;
  var start_date = i + '-01-01';
  var end_date = i + '-12-31';
  
  var Fpar_500m1 = MODIS_LAI_FPAR
                      .filter(ee.Filter.date(start_date, end_date))
                      .select('EVI');
 
  print('Fpar_500m1',Fpar_500m1); 

  var  Fpar_500m_min = ((Fpar_500m1.reduce(ee.Reducer.minMax())).select(['EVI_min'],['EVI_min_' + i])).divide(10000);
  var min_update = Fpar_500m_min.updateMask(Fpar_500m_min.gt(0).and(Fpar_500m_min.lt(1)));
  var new_list = new_list.add(ee.Image(min_update));

 var MODIS_Fpar_year = ee.ImageCollection.fromImages(new_list);
 print(MODIS_Fpar_year);
 var img = MODIS_Fpar_year.toBands();
 print('img',img);
 
 
var new_list1 = ee.List([]);
// generate one image for each land cover type
for (var m = 1; m< 16; m++){ 
 var mask = LC_raw_2012.eq(m);
 var img1 = img.updateMask(mask);
 var new_list1 = new_list1.add(img1);
}

 var merged = ee.ImageCollection.fromImages(new_list1);
 print('merged');
 print(merged);
 
 
 //create function to calculate mean values for each image
var pointsmean = function(image) {
  var means = image.reduceRegions({
    collection: costa_rica, // used to be roi.select(['Id'])
    reducer: ee.Reducer.mean(),
    scale: scale
  });
  return means.copyProperties(image);
};

var finalEVI = merged.map(pointsmean).flatten()
.select(['mean']);
print(finalEVI.limit(100), 'final EVI');


Export.table.toDrive({
collection: finalEVI,
  description:'MODIS_250m_EVI_min_CR_2012_by_land_cover',
fileFormat: 'CSV',
folder: GDriveOutputImgFolder
});
// Export.table.toDrive({
// collection: finalEVI,
//   description: 'EVI_'+startdate+'TO'+enddate,
// fileFormat: 'CSV'
// });


 
 
