# gi-ws-05-3 classify plains and plateaus with a real structure using a function

library(gdalUtils)
library(rgdal)
library(raster)

# Initialise script; set filepaths and set system variables for SAGA and GDAL
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/Init.R")
path <- Init("gi", "05")

# source script for classification
source(paste0(path$fun, "fuzzy_land_class.R"))

# create filtered DEM with focal filter
DEM <- raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif"))
DEM_filter <- focal(DEM, w = matrix(1,3,3), fun = mean)
writeRaster(DEM_filter, filename = paste0(path$gi$input, "geonode_las_dtm_01m_filter.tif"), overwrite = TRUE)

# Initialise classification
DEM_paths <- c(paste0(path$gi$input, "geonode_las_dtm_01m.tif"),
               paste0(path$gi$input, "geonode_las_dtm_01m_filter.tif"))


# # # # Set parameters for classification # # # #
# set prefixes for different DEMs to prevent overwriting files in the function
prefix <- c("norm_", "filt_")
slope_min <- "5"
slope_max <- "15"
curve_min <- "0.000002"
curve_max <- "0.00005"



# classify the normal and filtered DEM
r <- lapply(seq(2), function(i){
  classify(DEM = DEM_paths[i],
           work_dir = path$gi$run,
           output_dir = path$gi$output,
           pre = prefix[i],
           T_SLOPE_MIN = slope_min,
           T_SLOPE_MAX = slope_max,
           T_CURVE_MIN = curve_min,
           T_CURVE_MAX = curve_max)
})

# save classified landform in rasters
landform_norm <- r[[1]]
landform_filt <- r[[2]]

# modal filter with the unfiltered classification
landform_mod_filt <- focal(landform_norm, w = matrix(1,7,7), fun = modal)
writeRaster(landform_mod_filt, filename = paste0(path$gi$output, "landform_mod_filt.tif"))


# Reclassify as plains or plateaus based on height of the DEM
reclass <- lapply(c(landform_norm,
                    landform_filt,
                    landform_mod_filt), function(landform){
  landform[landform == 1 & DEM < 250] <- 1
  landform[landform == 1 & DEM >= 250] <- 2
})

# Show results
plot(reclass[[1]])
title("P&P unfiltered")

plot(reclass[[2]])
title("P&P DEM filter")

plot(reclass[[3]])
title("P&P modal filter")
