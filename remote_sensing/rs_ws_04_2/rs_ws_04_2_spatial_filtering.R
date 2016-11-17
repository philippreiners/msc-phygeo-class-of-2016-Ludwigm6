# rs_ws_04_2 spatial filtering
#
# https://de.mathworks.com/help/images/ref/graycoprops.html?requestedDomain=www.mathworks.com

# define project folder
filepath_base <- "D:/Uni/forest_caldern/"

# initialise the script and save all filepaths in a list
source("D:/Uni/r_functions/Init.R")
path <- Init(filepath_base)

library(glcm)
library(raster)

# Load raster

r <- raster(paste0(path$aerial, "478000_5630000.tif"), band = 1)

# execute glcm correlation with different window sizes
correlation <- lapply(c(3,11,33,55), function(x){
  glcm_correlation <- glcm(r, statistics = "correlation", window = c(x,x))
  return(glcm_correlation)
})

# check results
par(mfrow = c(2,2))
for(i in seq(4)){
  plot(correlation[[i]])
}

# save to harddrive
writeRaster(correlation[[1]], paste0(path$data, "aerial_filter/478000_5630000_correlation_03.tif"))
writeRaster(correlation[[2]], paste0(path$data, "aerial_filter/478000_5630000_correlation_11.tif"))
writeRaster(correlation[[3]], paste0(path$data, "aerial_filter/478000_5630000_correlation_33.tif"))
writeRaster(correlation[[4]], paste0(path$data, "aerial_filter/478000_5630000_correlation_55.tif"))



