library(raster)
library(tools)


#Datenpfade definieren
filepath_base <- "D:/Uni/remote_sensing/"
path_temp <- paste0(filepath_base, "temp/")
path_data <- paste0(filepath_base, "data/forest_caldern_tif/raster/")
path_target <- paste0(filepath_base, "data/forest_caldern_tif/rdata/")
path_scripts <- paste0(filepath_base, "scripts/")
rasterOptions(tmpdir = path_temp)

source(paste0(path_scripts, "green_leaf_index.R"))

files <- c("474000_5632000.tif", "474000_5630000.tif", "476000_5632000.tif",
           "476000_5630000.tif", "478000_5632000.tif", "478000_5630000.tif")

#### Green Leave Index ####
i = 1
res <- list()
for(i in 1:6){
  rgb <- stack(paste0(path_data, files[i]))
  res[[i]] <- green_leaf_index(rgb)
  
}
plot(res[[1]])  
  

