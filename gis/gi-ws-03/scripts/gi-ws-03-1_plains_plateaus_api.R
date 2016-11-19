#gi-ws-03-1_plains_plateaus_APIcalls

source_file <- "D:/Uni/forest_caldern/data/tif/raster/caldern_slopes_ETRS89UTM.tif"
target_file <- ""
setwd("D:/Uni/forest_caldern/data/tif/raster/")
#Convert .tif to .sdat
shell('gdalwarp -s_srs EPSG:25832 -of SAGA D:/Uni/forest_caldern/data/tif/raster/caldern_slopes_ETRS89UTM.tif D:/Uni/forest_caldern/data/tif/raster/dem2.sdat', shell = 'cmd.exe')



## SAGA_cmd path
path_saga <- "C:/Program Files/QGIS 2.18/apps/saga/saga_cmd.exe"
modul <- 'ta_morphometry "Fuzzy Landform Element Classification"'


  
  
  
shell('saga_cmd ta_morphometry "Fuzzy Landform Element Classification" -SLOPE=D:/Uni/forest_caldern/data/tif/raster/dem.sdat -MINCURV=NULL -MAXCURV=NULL -PCURV=NULL -TCURV=NULL -PLAIN=NULL -PIT=NULL -PEAK=NULL -RIDGE=NULL -CHANNEL=NULL -SADDLE=NULL -BSLOPE=NULL -FSLOPE=NULL -SSLOPE=NULL -HOLLOW=NULL -FHOLLOW=NULL -SHOLLOW=NULL -SPUR=NULL -FSPUR=NULL -SSPUR=NULL -FORM=NULL -MEM=NULL -ENTROPY=NULL -CI=NULL -SLOPETODEG=0 -T_SLOPE_MIN=5.000000 -T_SLOPE_MAX=15.000000 -T_CURVE_MIN=0.000002 -T_CURVE_MAX=0.000050', shell = 'cmd.exe')
