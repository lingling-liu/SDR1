pro caculate_C_NDVI_LULC_as_histogram

  ;open LULC image
  lc = "C:\SDR\aligned_C_LULC\ENVI\aligned_lulc.dat"
  envi_open_file,lc,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  lc_data = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove

  index = where(lc_data gt 0 and lc_data lt 1000,count)
  array = lc_data[index]
  temp1 = array[UNIQ(array, SORT(array))]
  ;print,temp1
  temp1_str = ['Ag-Corn','Ag-other','Grass','Wetland','Urban','Forest','Swine']

  ;  1 Ag-Corn
  ;  2 Ag-other
  ;  62  Grass
  ;  141 Forest
  ;  87  Wetland
  ;  121 Urban
  ;  401 Swine


  result = fltarr(n_elements(temp1))
  ;result1 = fltarr(n_elements(temp1))
  result1 = fltarr(n_elements(temp1),41)

  ;std
  infile = "C:\SDR\aligned_C_LULC\ENVI\aligned_c_bare_ground_2010.dat"
  envi_open_file,infile,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  data = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove

  for i=0,n_elements(temp1)-1 do begin
    ;print,temp1[i]
    index1 = where(lc_data eq temp1[i],count)
    ;print,count
    temp_data = data[index1]
    index11 = where(temp_data ge 0 and temp_data lt 1)
    enso = temp_data[index11]
    ;    min1 = 0.034
    ;    max1 = 0.184
    ;    range = indgen(round(((max1- min1)/0.01)))*0.01+min1
    binsize = 0.01 ; in dimensionless units of ENSO index.
    h_enso = HISTOGRAM(enso, BINSIZE=binsize, LOCATIONS=binvals,min= 0,max=0.4)
    p_enso = h_enso/(n_elements(enso)-0.0)
    result1[i,*] = p_enso

    ;    p = plot(range,p_enso,title = temp1_str[i],xrange = [0,0.2],yrange = [0,0.4])
    ;    p.Save, 'C:\SDR\aligned_C_LULC\histogram\STD_C_'+temp1_str[i]+".png", BORDER=10, $
    ;      RESOLUTION=300, /TRANSPARENT
    ;    p.close
    ;result[i] = mean(temp_data[index11])
  endfor
  print,result1
  WRITE_CSV,'C:\SDR\aligned_C_LULC\histogram_by_LULC_bare_ground_2010.txt',result1
  ;for i=0,n_elements(temp1)-1 do begin
  ;  result1[i] = (result[i] - min(result))/(max(result) - min(result))
  ;  print,'STD_year ; ',strtrim(string(temp1[i]),2),';',strtrim(string(result[i]),2),';',strtrim(string(result1[i]),2)
  ;endfor

  ;  for i=0,n_elements(temp1)-1 do begin
  ;    ;result1[i] = (result[i] - min(result))/(max(result) - min(result))
  ;    ;print,'STD_year ; ',temp1_str[i],'; ',strtrim(string(result[i]),2)
  ;    print,strtrim(string(result[i]),2)
  ;  endfor


end


