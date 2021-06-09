pro c_bare_ground_2010

  ;open 40N_90W 
  left = "C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\bare_ground\40N_090W.dat"
  envi_open_file,lc,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  data_left = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove
  
  ;open 40N_80W
  left = "C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\bare_ground\40N_080W.dat"
  envi_open_file,lc,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  data_right = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove
  
  result = bytarr(80000,80000)
  result[0:39999,*] = left_data
  result[40000:79999,*] = right_data
  
  

  ;write  C factor
  path = 'C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\c_factor.img'
  OPENW, 1, path
  ; Write the data in D to the file:
  WRITEU, 1, c_value
  ; Close file unit 1:
  CLOSE, 1

  ENVI_SETUP_HEAD, fname=strmid(path,0,strlen(path)-4), $
    ns=ns, nl=nl, nb=1,$
    data_type=4,INTERLEAVE =2, $
    offset=0,map_info = map_info,/write

  ;write  P factor
  path = 'C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\p_factor.img'
  OPENW, 1, path
  ; Write the data in D to the file:
  WRITEU, 1, p_value
  ; Close file unit 1:
  CLOSE, 1

  ENVI_SETUP_HEAD, fname=strmid(path,0,strlen(path)-4), $
    ns=ns, nl=nl, nb=1,$
    data_type=4,INTERLEAVE =2, $
    offset=0,map_info = map_info,/write

end