# gi-ws-08-1 forest density

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "08")

library(raster)

# load ground returns and above ground returns
# list.files(path$gi$input)
pcag <- raster(paste0(path$gi$input, "lidar_pcag_01m.tif"))
pcgr <- raster(paste0(path$gi$input, "lidar_pcgr_01m.tif"))

# forest density can be determinated as the ratio of above ground returns to all returns:
dens <- pcag/(pcgr+pcag)
plot(dens)

# writeRaster(dens_muf, filename = paste0(path$gi$output, "density.tif"), overwrite = TRUE)
