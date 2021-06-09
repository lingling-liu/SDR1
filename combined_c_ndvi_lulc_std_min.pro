pro combined_C_NDVI_LULC_std_min

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

  ;************************
  ;MIN"
  ;  1 Ag-Corn
  ;  2 Ag-other
  ;  401 Swine
  ;  STD for the rest of natural vegetation
  ;************************
  ;  1 Ag-Corn
  ;  2 Ag-other
  ;  62  Grass
  ;  141 Forest
  ;  87  Wetland
  ;  121 Urban
  ;  401 Swine

  result = fltarr(n_elements(temp1))
  ;result1 = fltarr(n_elements(temp1))
  result1 = fltarr(n_elements(temp1),21)

  ;std
  infile = "C:\SDR\aligned_C_LULC\ENVI\aligned_c_std_year.dat"
  envi_open_file,infile,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  std1 = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove

  ;MIN
  infile = "C:\SDR\aligned_C_LULC\ENVI\aligned_c_min_year.dat"
  envi_open_file,infile,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  min1 = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove

  result = fltarr(ns1,nl1)+32767
  result = std1

  for i=0,nl1-1 do begin
    for j=0,ns1-1 do begin

      if lc_data[j,i] eq 1 or lc_data[j,i] eq 2 or lc_data[j,i] eq 401 then begin
        result[j,i] = min1[j,i]
      endif
    endfor
  endfor

  ;write  C factor
  path = 'C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\C_factor_5km_combined_std_min_monthly_mean_year.img'
  OPENW, 1, path
  ; Write the data in D to the file:
  WRITEU, 1, result
  ; Close file unit 1:
  CLOSE, 1

  ENVI_SETUP_HEAD, fname=strmid(path,0,strlen(path)-4), $
    ns=ns1, nl=nl1, nb=1,$
    data_type=4,INTERLEAVE =2, $
    offset=0,map_info = map_info,/write

end


