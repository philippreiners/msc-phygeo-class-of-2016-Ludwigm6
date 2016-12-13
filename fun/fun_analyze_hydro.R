# fun: Hydrological properties of a DEM

analyze_hydro <- function(DEM, workdir, sink_min_slope = "0.1", channels_threshold){
 
  library(gdalUtils)
  library(rgdal)
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
                "-BASINS=watershed_basins.shp ", 
                "-NODES=nodes.shp ", 
                "-THRESHOLD=",channels_threshold))
  
  
  # 3. Stream Power Index
  # 3.1 Slope, Aspect, Curvature
  #system(paste0("saga_cmd ta_morphometry 0 ",
  #              "-ELEVATION=DEM_no_sinks.sdat ",
  #              "-SLOPE=slope.sdat ",
  #              "-METHOD=6 -UNIT_SLOPE=0 -UNIT_ASPECT=0"))
  
  # 3.2 Stream Power Index
  #system(paste0("saga_cmd ta_hydrology 21 ",
  #              "-SLOPE=slope.sdat ",
  #              "-AREA=watershed.sgrd ",
  #              "-SPI=stream_power_index.sdat ",
  #              "-CONV=0"))
  
  
  # 3.3 Convert to tif
  #gdalwarp(srcfile = paste0(workdir, "stream_power_index.sdat"), dstfile = paste0(workdir, "stream_power_index.tif"), overwrite = TRUE, of = 'GTiff')
  
  
  
  output <- list(channels = readOGR(paste0(workdir, "channels.shp")),
                 watershed = readOGR(paste0(workdir, "watershed_basins.shp")),
                 #spi = raster(paste0(workdir, "stream_power_index.tif")),
                 filepath = workdir)
  
  return(output)
  
}


