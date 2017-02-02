# rs-ws-10-1 model improvement

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("rs", "10")

library(raster)
library(link2GI)
library(rgrass7)
library(gdalUtils)
library(rgdal)


lcc <- raster(paste0(path$gi$input, "geonode_muf_lcc_prediction.tif"))
lcc_vect <- readOGR(paste0(path$rs$run, "lcc_vect.shp"))

head(lcc_vect@data)
lcc_vect@data$value[as.numeric(lcc_vect@data$area) < 5] <- 999

writeOGR(lcc_vect, dsn = paste0(path$rs$run, "lcc_vect.shp"), overwrite = TRUE, layer = "lcc", driver = "ESRI Shapefile")

gdal_rasterize(src_datasource = paste0(path$rs$run, "lcc_vect.shp"),
               dst_filename = paste0(path$rs$run, "lcc_999.tif"),
               a = "value",
               l = "lcc",
               ts = c(lcc@ncols, lcc@nrows))

lcc_999 <- raster(paste0(path$rs$run, "lcc_999.tif"))
lcc_999[lcc_999 == 999] <- NA

#summary(lcc_999)
lcc_mod_5 <- focal(lcc, matrix(1,3,3), FUN = )
lcc_new <- cover(lcc_999, lcc_mod_5, filename = paste0(path$rs$run, "lcc_new.tif"), overwrite = TRUE)

summary(lcc)
summary(lcc_mod_5)
summary(lcc_new)

lcc_new <- focal(lcc_999, matrix(1,5,5), FUN = modal, NAonly = TRUE,
                 filename = paste0(path$rs$run, "lcc_new.tif"), overwrite = TRUE, na.rm = TRUE)



writeRaster(lcc_new, filename = paste0(path$rs$run, "lcc_new.tif"))









lcc_999_val <- getValues(lcc_999)
lcc_mod_5_val <- getValues(lcc_mod_5)


test999 <- lcc_999_val == 999


replace(lcc_999_val, list = test999, values = lcc_mod_5_val)

lcc_999_val[lcc_999_val == 999] <- lcc_mod_5_val[lcc_999_val == 999]
summary(lcc_999_val)


lcc_new <- setValues(x = lcc_999, values = lcc999_val)

writeRaster(lcc999, filename = paste0(path$rs$run, "lcc_new.tif"))

lcc_cor[lcc_cor == 999] <- lcc_mod_5
plot(lcc_cor)

linkGRASS7(x = lcc, searchPath = "C:\\GIS\\QGIS")












roads <- lcc
roads[roads != 205] <- 0


writeRaster(roads, filename = paste0(path$rs$run, "roads.tif"), overwrite = TRUE)

gdal_translate(src_dataset = paste0(path$rs$run, "roads.tif"),
               dst_dataset = paste0(path$rs$run, "roads_bit.tif"),
               ot = "Int32")


execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$input, "geonode_muf_lcc_prediction.tif"),
                            output = "lcc"))

execGRASS("r.to.vect", flags = "overwrite",
          parameters = list(input = "lcc",
                            output = "lcc_vect",
                            type = "area"))
execGRASS('v.out.ogr',  flags = c("overwrite"),
          parameters = list(input = "lcc_vect",
                            output = paste0(path$rs$run, "lcc_vect.shp"),
                            format = "ESRI_Shapefile"))





# create road network
execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$rs$run, "roads_bit.tif"),
                            output = "roads"))
execGRASS("r.null", parameters = list(map = "roads", setnull = "0"))
execGRASS("r.thin", flags = "overwrite",
          parameters = list(input = "roads",
                            output = "thin_roads"))
execGRASS("r.to.vect", flags = "overwrite",
          parameters = list(input = "thin_roads",
                            output = "roads",
                            type = "line"))
execGRASS('v.out.ogr',  flags = c("overwrite"),
          parameters = list(input = "roads",
                            output = paste0(path$rs$run, "roads2.shp"),
                            format = "ESRI_Shapefile"))




execGRASS("v.clean", flags = c("overwrite"),
          parameters = list(input = "roads",
                            output = "roads_clean",
                            tool = c("snap", "chbridge"),
                            threshold = 10))

execGRASS('v.out.ogr',  flags = c("overwrite"),
          parameters = list(input = "roads_clean",
                            output = paste0(path$rs$run, "roads_clean.shp"),
                            format = "ESRI_Shapefile"))


