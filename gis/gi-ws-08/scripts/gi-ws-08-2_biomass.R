# gi-ws-08-2 forest biomass

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "08")

library(raster)
library(rgdal)

# load dem, dtm, ground returns and above ground returns
# list.files(path$gi$input)
dem <- raster(paste0(path$gi$input, "lidar_dem_01m.tif"))
dsm <- raster(paste0(path$gi$input, "lidar_dsm_01m.tif"))
pcag <- raster(paste0(path$gi$input, "lidar_pcag_01m.tif"))
pcgr <- raster(paste0(path$gi$input, "lidar_pcgr_01m.tif"))

# forest density can be determinated as the ratio of above ground returns to all returns:
dens <- pcag/(pcgr+pcag)

# models for biomass from table 2 in He et al. 2013
stem_biomass <- -13.595 + 8.446*mean(dsm-dem) + 20.378*dens
branch_biomass <- -2.447 + 1.367*mean(dsm-dem) + 3.3 *dens
wood <- stem_biomass + branch_biomass


plot(wood)
summary(wood)











