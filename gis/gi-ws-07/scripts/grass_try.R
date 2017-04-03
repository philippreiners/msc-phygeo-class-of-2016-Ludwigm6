# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "07")


# GRASS stuff
library(rgrass7)
#source(paste0(path$fun$initGRASS2_reudenbach.R))
source(paste0(path$fun$initGRASS_reudenbach.R))


library(raster)

DEM <- raster(paste0(path$gi$input, "lidar_dem_01m.tif"))

initGrass4R(x = DEM)


# load data to test if GRASS works
rgrass7::execGRASS('r.import',  
                   flags=c('o',"overwrite","quiet"),
                   input=paste0(path$gi$input, "lidar_dsm_01m.tif"),
                   output="DEM_grass",
                   band=1
)




# GRASS stuff
#library(rgrass7)
#source(paste0(path$fun$initGRASS_reudenbach.R))
#DEM <- raster(paste0(path$gi$input, "lidar_dem_01m.tif"))
#initGrass4R(x = DEM)


# load data to test if GRASS works
# rgrass7::execGRASS('r.import',  
#                   flags=c('o',"overwrite","quiet"),
#                   input=paste0(path$gi$input, "lidar_pcag_01m.tif"),
#                   output="pcag_grass",
#                   band=1
#)


initGRASS(gisBase = "C:/GIS/GRASS7",
          gisDbase = "D:/university/data/gis/grass/grass_temp",
          home = "D:/university/data/gis/grass/grass_temp",
          location = "D:/university/data/gis/grass/caldern",
          mapset = "PERMANENT",
          override = TRUE)
