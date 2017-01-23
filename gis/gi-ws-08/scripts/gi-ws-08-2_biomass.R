# gi-ws-08-2 forest biomass

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "08")

library(raster)
library(rgdal)

# load DEM and DSM
dem <- raster(paste0(path$gi$input, "lidar_dem_01m.tif"))
dsm <- raster(paste0(path$gi$input, "lidar_dsm_01m.tif"))

trees <- readOGR(paste0(path$gi$run, "trees/trees.shp"))
plot(trees)

# Stem_biomass = -13.595 + 8.446*mean height + 20.378 *cover
# branch = -2.447 + 1.367*mean height + 3.3 *cover

















