# gi-ws-09-1 forest related stuff

# # # workflow # # #
# 1. crop rasters to same extent (gi-ws-09-1_crop_input)
# 2. identify trees
#   a. upside down canopy height model
#   b. SAGA Channel network: nodes with 4 or more channels is a tree
# 3. 



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



# # # additional stuff # # # # # # # # # # # # # # # # # # 
# upslope area for crowns
# attributes: tree type, age, height, crown density, biomass? , heatmap of tree-density 

trees <- readOGR(paste0(path$gi$run, "trees.shp"))





# tree density heatmap
execGRASS("v.kernel", parameters = list(input = "point_trees", output = "tree_dens", radius = 20, kernel = "gaussian"))
execGRASS("r.out.gdal", flags = "overwrite",
          parameters = list(input = "tree_dens",
                            output = paste0(path$gi$run, "tree_denisty.tif"),
                            format = "GTiff"))













# GRASS r.flow accumulation
execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$run, "chm.tif"),
                            output = "chm"))


execGRASS("r.out.gdal", flags = "overwrite",
          parameters = list(input = "fl_acc",
                            output = paste0(path$gi$run, "fl_acc.tif"),
                            format = "GTiff"))

execGRASS("r.in.gdal", flags = "o", 
          parameters = list(input = input$lidar_dem_01m.tif@file@name, 
                            output = "DEM"))
execGRASS("r.in.gdal", flags = "o", 
          parameters = list(input = input$lidar_dsm_01m.tif@file@name, 
                            output = "DSM"))


execGRASS("g.list", parameters = list(type = "ras"))

# SAGA local minima and maxima
system(paste0("saga_cmd shapes_grid 9",
              " -GRID=", path$gi$run, "chm.sgrd",
              " -MINIMA=", path$gi$run, "local_min.shp",
              " -MAXIMA=", path$gi$run, "local_max.shp"))

local_min <- readOGR(paste0(path$gi$run, "local_min.shp"))



# SAGA upslope area (devils work)
crowns <- lapply(seq(length(trees)), function(x){
  system(paste0("saga_cmd ta_hydrology 4",
                " -TARGET_PT_X=", trees@coords[x,1],
                " -TARGET_PT_Y=", trees@coords[x,2],
                " -ELEVATION=", path$gi$run, "chm.sgrd",
                " -AREA=", path$gi$run,"crowns/tree_", x, ".sgrd",
                " -METHOD=0", 
                " -CONVERGE=1.100000"))
})