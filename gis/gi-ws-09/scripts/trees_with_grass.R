# trees with GRASS
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "09")

library(link2GI)
library(raster)
library(rgrass7)
library(gdalUtils)
library(rgdal)

input <- readRDS(paste0(path$gi$RData, "muf.rds"))
# init GRASS
linkGRASS7(x = input$lidar_dem_01m.tif, searchPath = "C:\\GIS\\QGIS")

# canopy height model
# trees are "hanging" upside down, the smaller the number, the larger the tree!
chm <- input$lidar_dsm_01m.tif - input$lidar_dem_01m.tif
chm[chm < 0] <- 0
chm <- (chm*(-1)) + chm@data@max
# remove structures smaller than 3m
chm[chm > maxValue(chm)-3] <- maxValue(chm)
writeRaster(chm, filename = paste0(path$gi$temp, "chm.tif"), overwrite = TRUE)

execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$temp, "chm.tif"),
                            output = "chm"))

execGRASS("r.watershed", flags = c("s", "overwrite"),
          parameters = list(elevation = "chm",
                            threshold = 1,
                            accumulation = "ws_acc"))
                            #drainage = "ws_drain",
                           # basin = "ws_basin",
                            #stream = "ws_stream"))