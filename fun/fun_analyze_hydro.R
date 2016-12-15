# fun: Hydrological properties of a DEM

analyze_hydro <- function(DEM, workdir, sink_min_slope = "0.1", channels_threshold = "5"){
 
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
  
  # 3. Catchment area
  system(paste0("saga_cmd garden_learn_to_program 7 ",
                " -ELEVATION=DEM_no_sinks.sgrd ",
                " -AREA=catchmentarea.sgrd ",
                " -METHOD=0"))
  
  

  
  # Convert every sgrd to tif
  i <- 1
  files_path <- list.files(path = workdir, pattern = "*.sgrd", full.names = TRUE)
  files_name <- list.files(path = workdir, pattern = "*.sgrd", full.names = FALSE)
  files_name <- substr(files_name, 1, nchar(files_name)-5)
  
  for(i in length(files_path)){
    gdalwarp(srcfile = files_path[i], dstfile = paste0(workdir, files_name[i], ".tif"), overwrite = TRUE, of = 'GTiff')  
  }
  
  
  
  
  output <- list(channels = readOGR(paste0(workdir, "channels.shp")),
                 watershed = readOGR(paste0(workdir, "watershed_basins.shp")),
                 #spi = raster(paste0(workdir, "stream_power_index.tif")),
                 filepath = workdir)
  
  return(output)
  
}


