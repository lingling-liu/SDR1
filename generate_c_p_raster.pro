pro generate_C_P_raster

  ;open LULC image
  lc = "C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\LULC.img"
  envi_open_file,lc,r_fid=fid1
  IF (fid1 EQ -1) THEN BEGIN
    ENVI_BATCH_EXIT
    RETURN
  ENDIF

  ENVI_FILE_QUERY,fid1, dims=dims1, nb=nb1,ns=ns1,nl=nl1,bnames=bnames1
  lc_data = envi_get_data(fid=fid1,dims=dims1,pos=0)
  map_info = envi_get_map_info(fid = fid1)
  envi_file_mng,id=fid1,/remove

  ;open biophysical table
  infile2= "C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\biophysical_SDR.txt"
  openr,unit2,infile2,/get_lun
  data2 = fltarr(3,7)
  text_line  = ''
  k=0
  while not EOF(unit2) do begin
    readf,unit2,text_line
    temp = STRSPLIT(text_line, ';',/EXTRACT)
    data2[0,k] = temp[0]
    data2[1,k] = temp[1]
    data2[2,k] = temp[2]
    k++
  endwhile
  close, unit2
  free_lun,unit2

  ns = n_elements(lc_data[*,0])
  nl = n_elements(lc_data[0,*])
  c_value = fltarr(ns,nl)+ 32767
  p_value = fltarr(ns,nl) + 32767


  for i=0,nl-1 do begin
    for j=0,ns-1 do begin
      index = where(data2[0,*] eq lc_data[j,i],count)
      if count eq 1 then begin
        c_value[j,i] = data2[1,index]; c value
        p_value[j,i] = data2[2,index]; p value
      endif
    endfor
  endfor

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