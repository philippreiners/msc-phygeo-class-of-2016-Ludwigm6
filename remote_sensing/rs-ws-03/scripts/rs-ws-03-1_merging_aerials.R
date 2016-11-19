library(raster)

#Datenpfade definieren
filepath_base <- "D:/Uni/remote_sensing/"
path_temp <- paste0(filepath_base, "temp/")
path_data <- paste0(filepath_base, "data/forest_caldern_tif/raster/")
path_target <- paste0(filepath_base, "data/forest_caldern_tif/raster_merged/")
rasterOptions(tmpdir = path_temp)

r1 <- stack(paste0(path_data, "476000_5632000_1.tif"))
r2 <- stack(paste0(path_data, "476000_5632000.tif"))
plotRGB(r1)
plotRGB(r2)

r3 <- r1+r2 - 255
plotRGB(r3)
setwd(path_target)
writeRaster(r3, "476000_5632000.tif")

setwd(path_data)
file.rename("476000_5632000_1.tif", "deprc_476000_5632000_1.tif")
file.rename("476000_5632000.tif", "deprc_476000_5632000.tif")
