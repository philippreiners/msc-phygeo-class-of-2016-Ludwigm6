# gi-ws-07-1: correction of gi-ws-06-1

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- Init("gi", "07")

library(raster)
library(gdalUtils)
library(scales)

source(paste0(path$fun, "fun_analyze_hydro.R"))


DEM <- raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif"))
DEM_path <- paste0(path$gi$input, "geonode_las_dtm_01m.tif")
# pfad alternativ mit: DEM@file@name


hydro <- analyze_hydro(DEM = DEM_path,
                       workdir = paste0(path$gi$saga, "hydrology_03m/"),
                       channels_threshold = "8")



# Position aus aufgabenstellung:
lat <- 50.840860
lon <- 8.684456


# create an sp object of estimated gauge position
punkt <- data.frame(y = lat, x = lon)
coordinates(punkt) <- ~ x + y

# (R) assign the coordinate system (WGS84)
projection(punkt) <- CRS("+init=epsg:4326")
estpoint <- spTransform(punkt, CRS("+init=epsg:25832"))

plot(DEM)
plot(estpoint, add = TRUE)

# the gauge position is not very accurate- a straightforward buffering approach may help to find the correct outlet/gauge position
# (R) buffer the gauge point for finding the  maximum  catchment value within 25 m radius


# sauberer: catchment area berechnen und einlesen
catchmentarea <- raster(paste0(path$gi$run, "catchment_area_1512.tif"))
plot(catchmentarea)

# extrahiere die abflusswerte in einem 25m radius um den punkt
gaugeBuffer <- as.data.frame(raster::extract(catchmentarea, estpoint, buffer = 25, cellnumbers = TRUE)[[1]])


# id (Zellennummer) mit dem groessten Abflusswert im Puffergebiet
id <- gaugeBuffer$cell[which.max(gaugeBuffer$value)]

# coordinaten der Zellennummer
gaugeLoc <- xyFromCell(DEM, id)


system(paste0("saga_cmd ta_hydrology 4 ",
              " -TARGET_PT_X ",gaugeLoc[1,1],
              " -TARGET_PT_Y ",gaugeLoc[1,2],
              " -ELEVATION DEM_no_sinks.sgrd",
              " -AREA catch_point.sgrd",
              " -METHOD 0", 
              " -CONVERGE=1.100000"))


# DEM zuschneiden
DEM_catchpoint <- raster(paste0(path$gi$run, "catchment_point.tif"))

plot(DEM_catchpoint)

DEM_catchment_crop <- DEM_catchpoint
DEM_catchment_crop[DEM_catchment_crop < 100] <- NA
DEM_catchment_crop <- trim(DEM_catchment_crop)
DEM_catchment <- crop(DEM, DEM_catchment_crop)
plot(DEM_catchment)

writeRaster(DEM_catchment, filename = paste0(path$gi$run, "DEM_catchment.tif"))

plot(DEM_catchment_crop)

summary(DEM_catchment)

