# gi-ws-05-3 classify plains and plateaus with a real structure using a function

library(gdalUtils)
library(rgdal)
library(raster)

# Initialise script; set filepaths and set system variables for SAGA and GDAL
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/Init.R")
path <- Init("gi", "05")

# get a list of the available functions
list.files(pattern = "[.]R$", path = path$fun, full.names = FALSE)
# source script for classification
source(paste0(path$fun, "fuzzy_land_class.R"))

# create filtered DEM with focal filter
DEM <- raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif"))
DEM_filter <- focal(DEM, w = matrix(1,3,3), fun = mean)
writeRaster(DEM_filter, filename = paste0(path$gi$input, "geonode_las_dtm_01m_filter.tif"), overwrite = TRUE)


# # # # Set parameters for classification # # # #
DEM_paths <- c(paste0(path$gi$input, "geonode_las_dtm_01m.tif"),
               paste0(path$gi$input, "geonode_las_dtm_01m_filter.tif"))
# set prefixes for different DEMs to prevent overwriting files in the function
prefix <- c("norm_", "filt_")
# set patameters for 'Fuzzy Landform Element Classification'
slope_min <- "3"
slope_max <- "10"
curve_min <- "0.00000001"
curve_max <- "0.0001"


# # # # Use the sourced function to classify the normal and filtered DEM # # # #
#
# the function runs the SAGA module 'Slope, Aspect, Curvature' to create the input rasters
# for the module 'Fuzzy Landform Element Classification'
# output is the raster 'landform' from 'Fuzzy Landform Element Classificaton'
# plains have a value of 100 in the output raster

landforms <- lapply(seq(2), function(i){
  
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
landform_norm <- landforms[[1]]
landform_filt <- landforms[[2]]


# modal filter with the unfiltered classification
landform_mod_filt <- focal(landform_norm, w = matrix(1,7,7), fun = modal)
writeRaster(landform_mod_filt, filename = paste0(path$gi$output, "landform_mod_filt.tif"))


# Reclassify as plains or plateaus based on height of the DEM
reclass <- lapply(c(landform_norm,
                    landform_filt,
                    landform_mod_filt), function(landform){
  landform <- reclassify(landform, c(0,99,0, 99,100,1,100,200,0 ))                    
  landform[landform == 1 & DEM < 250] <- 1
  landform[landform == 1 & DEM >= 250] <- 2
  return(landform)
})

# Show results
plot(reclass[[1]], sub = "yellow = plain; green = plateau")
title("P&P unfiltered")

plot(reclass[[2]], sub = "yellow = plain; green = plateau")
title("P&P DEM filter")

plot(reclass[[3]], sub = "yellow = plain; green = plateau")
title("P&P modal filter")

# Best would be a combination of filtered DEM and modal filtered Classification
landform_com_filt <- focal(landform_filt, w = matrix(1,5,5), fun = modal)
landform_com_filt <- reclassify(landform_com_filt, c(0,99,0, 99,100,1,100,200,0 ))
landform[landform == 1 & DEM < 250] <- 1
landform[landform == 1 & DEM >= 250] <- 2