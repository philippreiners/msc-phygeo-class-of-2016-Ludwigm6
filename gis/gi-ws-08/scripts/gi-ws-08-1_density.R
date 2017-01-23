# gi-ws-08-1 forest density

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "08")

library(raster)

# load ground returns and above ground returns
list.files(path$gi$input)
pcag <- raster(paste0(path$gi$input, "lidar_pcag_01m.tif"))
pcgr <- raster(paste0(path$gi$input, "lidar_pcgr_01m.tif"))

# visible vegetation index
vvi <- raster(paste0(path$gi$input, "geonode_ortho_muf_vvi.tif")) 

# forest density can be determinated as the ratio of ground returns to above ground returns:
dens <- pcgr/pcag
plot(dens)

# test with visible vegetation index:
dens_muf <- crop(dens, vvi)
# weighted with vvi
dens_vvi <- dens_muf*vvi
plot(dens_vvi)
writeRaster(dens_vvi, filename = paste0(path$gi$output, "density_vvi.tif"))
writeRaster(dens_muf, filename = paste0(path$gi$output, "density.tif"))
