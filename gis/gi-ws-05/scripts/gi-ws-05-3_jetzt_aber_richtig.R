library(gdalUtils)
library(rgdal)
library(raster)

source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/Init.R")
path <- Init("gi", "05")
source(paste0(path$fun, "fuzzy_land_class.R"))

# create filtered DEM
DEM <- raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif"))
DEM_filter <- focal(DEM, w = matrix(1,3,3), fun = mean)
writeRaster(DEM_filter, filename = paste0(path$gi$input, "geonode_las_dtm_01m_filter.tif"), overwrite = TRUE)


# Initialise classification
DEM_paths <- c(paste0(path$gi$input, "geonode_las_dtm_01m.tif"),
               paste0(path$gi$input, "geonode_las_dtm_01m_filter.tif"))

prefix <- c("norm_", "filt_")


r <- lapply(seq(2), function(i){
  classify(DEM = DEM_paths[i],
           work_dir = path$gi$temp,
           output_dir = path$gi$output,
           pre = prefix[i],
           T_SLOPE_MIN = "5",
           T_SLOPE_MAX = "15",
           T_CURVE_MIN = "0.000002",
           T_CURVE_MAX = "0.00005")
})


landform_norm <- r[[1]][[1]]
landform_filt <- r[[2]][[1]]
plot(landform_norm)
plot(landform_filt)

plain_norm <- r[[1]][[2]]
plain_filt <- r[[2]][[2]]

plot(plain_norm)
plot(plain_filt)
