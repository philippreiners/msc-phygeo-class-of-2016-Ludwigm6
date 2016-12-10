# gi-ws-06-1 local drainage direction

# Initialize script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- Init("gi", "06")

library(raster)
library(gdalUtils)

# source SAGA Toolchain
source(paste0(path$fun, "fun_analyze_hydro.R"))

########################################
# Cutting the DEM to get analyzing area
DEM_full <- raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif")) 

plot(DEM_full)
points(477782.77, 5632175.60)

# Getting the part around the marked spot
DEM_cut <- crop(DEM, c(477782-1000, 477782+1000, 5632175-1000, 5632175+1000))
plot(DEM_cut)
writeRaster(DEM_cut, filename = paste0(path$gi$run, "geonode_las_dtm_01m_cut.tif"), overwrite = TRUE)
##########################################

# Initialize SAGA Modules
workdir <- paste0(path$gi$saga, "hydrology/")
DEM <- paste0(path$gi$run, "geonode_las_dtm_01m_cut.tif")
sink_min_slope <- "0.00085"
channels_threshold <- "7"

analyze_hydro(DEM = DEM,
              workdir = workdir,
              sink_min_slope = sink_min_slope,
              channels_threshold = channels_threshold)



