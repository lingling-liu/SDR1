"""Run LL's branch of SDR that uses a hard coded c-factor."""
import sys
import logging

import natcap.invest.sdr

logging.basicConfig(stream=sys.stdout, level=logging.DEBUG)

args = {
    u'biophysical_table_path': u'C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/biophysical_SDR.csv',
    u'dem_path': u'C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/DEM/fillFinalSaga.tif',
    u'drainage_path': u'',
    u'erodibility_path': u'C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/erodibility.tif',
    u'erosivity_path': u'C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/erosivity.tif',
    u'ic_0_param': u'0.5',
    u'k_param': u'2',
    u'lulc_path': u'C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/LULC.tif',
    u'results_suffix': u'',
    u'sdr_max': u'0.8',
    u'threshold_flow_accumulation': u'200',
    u'watersheds_path': u'C:/SDR/CapeFear_SDR_Inputs/CapeFear_SDR_Inputs/Subsheds/Polysheds123.shp',
    u'workspace_dir': u'C:\\Users\\Lingling-Thinkpad\\Documents\\test_bare_ground_2010',
    'c_factor_path': r"C:\SDR\CapeFear_SDR_Inputs\CapeFear_SDR_Inputs\data_bare_ground\data_bare_ground_2010_40N_80W_90W_resize_LULC_flt"
}


if __name__ == '__main__':
    natcap.invest.sdr.execute(args)
