# gi-ws-07-1 waterflow

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- Init("gi", "07")

library(raster)
library(rgdal)
library(gdalUtils)
library(scales)


source(paste0(path$fun, "fun_hy_analysis.R"))

# load DEM and get the filepath
DEM <- raster(paste0(path$gi$input, "geonode_las_dtm_01m.tif"))
path_DEM <- DEM@file@name



# preprocess DEM: fill sinks (Wang & Liu)
# hy_pre <- hy_basic_analysis(DEM_path = path_DEM, workdir = paste0(path$gi$saga, "hydrology/"))

# saveRDS(hy_pre, file = paste0(path$gi$saga , "hydrology/analysis.rds"))
hy_pre <- readRDS(paste0(path$gi$saga , "hydrology/analysis.rds"))

# create spatial point at gauge (= Pegel)
gauge <- data.frame(y = 50.840860, x = 8.684456)
coordinates(gauge) <- ~ x + y

# WGS84 because of the coordinate format; then transform to format of our rasters
projection(gauge) <- CRS("+init=epsg:4326")
gauge <- spTransform(gauge, CRS("+init=epsg:25832"))

# extrahiere die abflusswerte in einem 25m radius um den punkt
gauge_buffer <- as.data.frame(extract(hy_pre$catchment_area, gauge, buffer = 25, cellnumbers = TRUE)[[1]])

# Koordinate mit dem groessten Abflusswert im Puffergebiet ist der neue Pegel
gauge <- xyFromCell(DEM, gauge_buffer$cell[which.max(gauge_buffer$value)])

# Pegel speichern als Spatial Point
sp_gauge <- as.data.frame(gauge)
sp_gauge$name <- "gauge"
coordinates(sp_gauge) <- ~ x + y
projection(sp_gauge) <- CRS("+init=epsg:25832")
writeOGR(sp_gauge, dsn = paste0(path$gi$saga, "hydrology/gauge.shp"), driver = "ESRI Shapefile", layer = "gauge")

# Berechnen des Einzugsgebietes des Pegels
# (SAGA) Upslope Area
system(paste0("saga_cmd ta_hydrology 4 ",
              " -TARGET_PT_X ",gauge[1,1],
              " -TARGET_PT_Y ",gauge[1,2],
              " -ELEVATION DEM_no_sinks.sdat",
              " -AREA catchment_gauge.sdat",
              " -METHOD 0", 
              " -CONVERGE=1.100000"))

gdalwarp(srcfile = paste0(path$gi$saga, "hydrology/catchment_gauge.sdat"),
         dstfile = paste0(path$gi$saga, "hydrology/catchment_gauge.tif"),
         overwrite = TRUE,
         of = "GTiff")
catchment_gauge <- raster(paste0(path$gi$saga, "hydrology/catchment_gauge.tif"))
plot(catchment_gauge)


# DEM auf catchment_gauge zuschneiden
catchment_gauge[catchment_gauge < 100] <- NA
catchment_gauge <- trim(catchment_gauge)
DEM_gauge <- crop(DEM, catchment_gauge)


# ? # ? # ?
writeRaster(DEM_gauge, filepath = paste0(path$gi$saga, "hydrology/DEM_gauge.tif"))
