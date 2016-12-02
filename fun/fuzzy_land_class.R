# Saga Fuzzy Land Classification

classify <- function(DEM,
                     work_dir,
                     output_dir,
                     pre,
                     T_SLOPE_MIN,
                     T_SLOPE_MAX,
                     T_CURVE_MIN,
                     T_CURVE_MAX){
  library(gdalUtils)
  library(raster)
  
  gdalwarp(srcfile = DEM, dstfile = paste0(work_dir, pre, "DEM.sdat"), overwrite = TRUE, of = 'SAGA')
  
  setwd(work_dir)
  system(paste0("saga_cmd ta_morphometry 0 ",
                "-ELEVATION=",pre,"DEM.sdat ",
                "-SLOPE=",pre,"slope ",
                "-ASPECT=",pre,"aspect ",
                "-C_PROF=",pre,"profil ",
                "-C_TANG=",pre,"tangential ",
                "-C_MINI=",pre,"minimum ",
                "-C_MAXI=",pre,"maximum ",
                "-METHOD=6 -UNIT_SLOPE=1 -UNIT_ASPECT=1"))
  
  
  system(paste0("saga_cmd ta_morphometry 25 ",
                "-SLOPE ",pre,"slope.sgrd ",
                "-MINCURV ",pre,"minimum.sgrd ",
                "-MAXCURV ",pre,"maximum.sgrd ",
                "-PCURV ",pre,"profil.sgrd ",
                "-TCURV ",pre,"tangential.sgrd ",
                "-FORM ",pre,"class_landform ",
                "-MEM ",pre,"class_membership ",
                "-ENTROPY ",pre,"class_entropy ",
                "-CI ",pre,"class_confusion ",
                "-SLOPETODEG 0 ",
                "-T_SLOPE_MIN=",T_SLOPE_MIN, " ",
                "-T_SLOPE_MAX=",T_SLOPE_MAX, " ",
                "-T_CURVE_MIN=",T_CURVE_MIN, " ",
                "-T_CURVE_MAX=",T_CURVE_MAX))
  
  
  gdalwarp(srcfile = paste0(work_dir, pre,"class_landform.sdat"), 
           dstfile = paste0(output_dir, pre,"class_landform.tif"), 
           overwrite = TRUE)
  landform <- raster(paste0(output_dir, pre,"class_landform.tif"))
  return(landform)
}