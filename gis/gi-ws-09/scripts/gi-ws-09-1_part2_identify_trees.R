# gi-ws-09-1 forest stuff with GRASS
# part 2: identify the trees

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "09")

library(link2GI)
library(raster)
library(rgrass7)
library(gdalUtils)
library(rgdal)

# load preprocessed rasters
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
writeRaster(chm, filename = paste0(path$gi$run, "chm.tif"), overwrite = TRUE)

# SAGA Channel Network and Drainage Basins
gdalwarp(srcfile = paste0(path$gi$run, "chm.tif"),
         dstfile = paste0(path$gi$run, "chm.sdat"),
         of = "SAGA", overwrite = TRUE)

system(paste0("saga_cmd ta_channels 5",
              " -DEM=", path$gi$run,"chm.sgrd",
              " -CONNECTION=", path$gi$run,"trees.sgrd",
              " -THRESHOLD=1"))

gdalwarp(srcfile = paste0(path$gi$run, "trees.sdat"),
         dstfile = paste0(path$gi$run, "potential_trees.tif"),
         of = "GTiff", overwrite = TRUE)


# # # clean up some false trees # # #
pot_trees <- raster(paste0(path$gi$run, "potential_trees.tif"))

# every pixel with a value larger than 4 is a tree
pot_trees[pot_trees < 6] <- NA

writeRaster(pot_trees, filename = paste0(path$gi$temp, "potential_trees.tif"))



# smooth lcc and compare classes with trees
# forest ids are: 2,3,10,11,12,20,21,22,30,40,41,50,51,52,72
smooth_lcc <- focal(unstack(input$geonode_muf_lcc_prediction.tif)[[1]], matrix(1,3,3), modal)

id_forest <- c(2,3,10,11,12,20,21,22,30,40,41,50,51,52,72)
pot_trees[!(smooth_lcc %in% id_forest)] <- NA
writeRaster(pot_trees, filename = paste0(path$gi$run, "trees.tif"), overwrite = TRUE)

# GRASS: create point vector
execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$run, "trees.tif"),
                            output = "trees"))

execGRASS("r.to.vect", flags = c("overwrite"),
          parameters = list(input = "trees", output = "point_trees", type = "point", column = "nodes"))

execGRASS('v.out.ogr',  flags = c("overwrite"),
          parameters = list(input = "point_trees",
                            output = paste0(path$gi$run, "trees.shp"),
                            format = "ESRI_Shapefile"))

# # # now the crowns # # #

# SAGA Watershed Segmentation
system(paste0("saga_cmd imagery_segmentation 0",
              " -GRID=", path$gi$run, "chm.sgrd",
              " -SEGMENTS=", path$gi$run, "trees_segmentation.sgrd",
              " -BORDERS=NULL",
              " -OUTPUT=0",
              " -DOWN=0",
              " -JOIN=0",
              " -THRESHOLD=0.000000",
              " -EDGE=1",
              " -BBORDERS=0"))
# convert to vector
system(paste0("saga_cmd shapes_grid 6",
              " -GRID=", path$gi$run, "trees_segmentation.sgrd",
              " -POLYGONS=", path$gi$run, "tree_crowns.shp",
              " -CLASS_ALL=1",
              " -SPLIT=0",
              " -ALLVERTICES=0"))

# now we only want crowns that match our trees from earlier
# GRASS v.select
execGRASS("v.import", flags = "overwrite",
          parameters = list(input = paste0(path$gi$run, "tree_crowns.shp"), output = "crowns"))
execGRASS("v.import", flags = "overwrite",
          parameters = list(input = paste0(path$gi$run, "trees.shp"), output = "point_trees"))

# entweder rgeos contains
execGRASS("v.select", flags = "overwrite",
          parameters = list(ainput = "crowns", binput = "point_trees", output = "real_crowns",
                            operator = "contains"))
execGRASS("v.out.ogr", flags = "overwrite",
          parameters = list(input = "real_crowns",
                            output = paste0(path$gi$run, "real_crowns.shp"),
                            format = "ESRI_Shapefile"))


