library(raster)

#Datenpfade definieren
filepath_base <- "D:/Uni/remote_sensing/"
path_temp <- paste0(filepath_base, "temp/")
path_data <- paste0(filepath_base, "data/forest_caldern_tif/raster/")
path_target <- paste0(filepath_base, "data/forest_caldern_tif/raster_croped/")
rasterOptions(tmpdir = path_temp)


#Zielgebiet einlesen (Maske)
m <- raster(paste0(path_data, "geonode_las_intensity_05.tif"))
plot(m)
#Zuzuschneidende Layer einlesen und pr�fen
r1 <- stack(paste0(path_data, "478000_5632000.tif"))
r2 <- stack(paste0(path_data, "478000_5630000.tif"))
plotRGB(r1)
plotRGB(r2)

#Raster zuschneiden
setwd(path_target)
r1_crop <- crop(r1, m, filename = "r1_croped.tif")
r2_crop <- crop(r2, m, filename = "r2_croped.tif")
plotRGB(r1_crop)
plotRGB(r2_crop)





