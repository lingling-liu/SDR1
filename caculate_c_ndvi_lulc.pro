pro caculate_C_NDVI_LULC

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
  
  
  result = fltarr(n_elements(temp1))
  result1 = fltarr(n_elements(temp1))
  
  ;std
  infile = "C:\SDR\aligned_C_LULC\ENVI\aligned_c_std_year.dat"
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
    index1 = where(lc_data eq temp1[i],count)
    temp_data = data[index1]
    index11 = where(temp_data gt 0 and temp_data lt 1)
    enso = temp_data[index11]
    range = indgen(round(((max(enso)- min(enso))/0.01)))*0.01+min(enso)
    binsize = 0.01 ; in dimensionless units of ENSO index.
    h_enso = HISTOGRAM(enso, BINSIZE=binsize, LOCATIONS=binvals)
    p_enso = h_enso/n_elements(enso)
    result = plot(range,p_enso)
    
    ;result[i] = mean(temp_data[index11]) 
  endfor

;for i=0,n_elements(temp1)-1 do begin
;  result1[i] = (result[i] - min(result))/(max(result) - min(result))
;  print,'STD_year ; ',strtrim(string(temp1[i]),2),';',strtrim(string(result[i]),2),';',strtrim(string(result1[i]),2)
;endfor
 

end


