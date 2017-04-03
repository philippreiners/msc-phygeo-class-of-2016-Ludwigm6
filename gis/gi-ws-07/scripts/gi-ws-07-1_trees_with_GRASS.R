# gi-ws-07-1 trees with GRASS


# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "07")


# GRASS stuff
library(rgrass7)
library(raster)


initGRASS(gisBase = "C:/GIS/GRASS7",
          gisDbase = "D:/university/data/gis/grass/grass_temp",
          home = "D:/university/data/gis/grass/grass_temp",
          mapset = "PERMANENT",
          override = TRUE)



execGRASS('g.proj', flags = c('c', 'quiet'), proj4 = proj4string(DEM))

# load data to test if GRASS works
rgrass7::execGRASS('r.import',  
                   flags=c('o',"overwrite","quiet"),
                   input=paste0(path$gi$input, "lidar_dsm_01m.tif"),
                   output="DEM_grass",
                   band=1
)


# load DEM and DSM
DEM <- raster(paste0(path$gi$input, "lidar_dem_01m.tif"))
DSM <- raster(paste0(path$gi$input, "lidar_dsm_01m.tif"))