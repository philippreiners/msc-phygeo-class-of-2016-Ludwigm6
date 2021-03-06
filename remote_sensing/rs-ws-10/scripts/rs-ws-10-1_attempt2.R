# rs-ws-10-1 model improvement

# init script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("rs", "10")

library(raster)
library(link2GI)
library(rgrass7)
library(gdalUtils)
library(rgdal)
library(rgeos)

# # # Task: # # #
# remove small area classification artefacts

# # # # # QGIS # # # # # #
# convertet the lcc raster to vector; could be accomplished with gdal_polygonize

# load lcc and the polygons
lcc <- raster(paste0(path$gi$input, "geonode_muf_lcc_prediction.tif"))
lcc_vect <- readOGR(paste0(path$rs$run, "lcc_vect.shp"))

# calculate area of each polygon
lcc_vect@data$area <- gArea(lcc_vect, byid = TRUE)

# every polygon smaller 6 gets the placeholder lcc_value 999
lcc_vect@data$value[lcc_vect@data$area < 6] <- 999
writeOGR(lcc_vect, dsn = paste0(path$rs$run, "lcc_vect.shp"), overwrite = TRUE, layer = "lcc", driver = "ESRI Shapefile")

# convert the modified polygons back to a raster
gdal_rasterize(src_datasource = paste0(path$rs$run, "lcc_vect.shp"),
               dst_filename = paste0(path$rs$run, "lcc_999.tiff"),
               a = "value",
               l = "lcc",
               ts = c(lcc@ncols, lcc@nrows))

# load the placeholder raster and convert the 999 to NA
lcc_999 <- raster(paste0(path$rs$run, "lcc_999.tif"))
lcc_999[lcc_999 == 999] <- NA

# perform a mode filter; we had some problems with raster::focal, so we ended up using GRASS
linkGRASS7(x = lcc, searchPath = "C:\\GIS\\QGIS")

execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$input, "geonode_muf_lcc_prediction.tif"),
                            output = "lcc"))

execGRASS("r.neighbors", flags = "overwrite",
          parameters = list(input = "lcc",
                            method = "mode",
                            output = "lcc_mode",
                            size = 7))

execGRASS("r.out.gdal", flags = "overwrite",
          parameters = list(input = "lcc_mode",
                            output = paste0(path$rs$run, "lcc_mode_7.tif"),
                            format = "GTiff"))

lcc_mode_7 <- raster(paste0(path$rs$run, "lcc_mode_7.tif"))

# replace the NA values with the mode_7 values
lcc_new <- cover(lcc_999, lcc_mode_7, filename = paste0(path$rs$run, "lcc_new.tif"), overwrite = TRUE)



#######################################
# Task: clean up some individual classifications
# 0 - 99 = forest
# 101 & 102 = fields
# 201 - 204 = settlements
# 205 = streets
# 206 = gardens
# 301 = shadow_street
# 302 = shadow_meadow
# 303 = shadow_field
# 304 = shadow_forest
# 350 = water

# change shadow street to street
lcc_new[lcc_new == 301] <- 205
# aggregate the fields
lcc_new[lcc_new == 102 |
        lcc_new == 302 |
        lcc_new == 303] <- 101
# aggregate settlement
lcc_new[lcc_new == 202 |
        lcc_new == 203 |
        lcc_new == 204] <- 201

writeRaster(lcc_new, filename = paste0(path$rs$run, "lcc_final.tif"), overwrite = TRUE)





















