# fun: Hydrological properties of a DEM

analyze_hydro <- function(DEM, workdir, sink_min_slope, channels_threshold){
 
  library(gdalUtils)
  library(raster)
  # Create output- and workfolder
  if(!file.exists(file.path(workdir))){
    dir.create(file.path(workdir), recursive = TRUE)
  }
  setwd(workdir)
  
  # 0.5 convert tif to SAGA Format
  gdalwarp(srcfile = DEM, dstfile = paste0(workdir, "DEM.sdat"), overwrite = TRUE, of = 'SAGA')
  
  # 1. Preprocessing the DEM: Fill Sinks (Wang & Liu)
  system(paste0("saga_cmd ta_preprocessor 4 ",
                "-ELEV=DEM.sdat ",
                "-FILLED=DEM_no_sinks.sdat ",
                "-FDIR=flow_direction.sdat ",
                "-WSHED=watershed.sdat ",
                "-MINSLOPE=",sink_min_slope))
  
  # 2. Channel Network and Drainage Basins
  system(paste0("saga_cmd ta_channels 5 ",
                "-DEM=DEM_no_sinks.sdat ", 
                "-DIRECTION=flow_direction_channels.sdat ", 
                "-BASIN=drainage_basins.sdat ",
                "-SEGMENTS=channels.shp ", 
                "-BASINS=basins.shp ", 
                "-NODES=nodes.shp ", 
                "-THRESHOLD=",channels_threshold))
  
}


