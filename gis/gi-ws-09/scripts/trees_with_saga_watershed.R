# gi-ws-09-1
# part 2: identify the trees with SAGA

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "09")

# load preprocessed rasters
input <- readRDS(paste0(path$gi$RData, "muf.rds"))

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
pot_trees[pot_trees < 7] <- NA

writeRaster(pot_trees, filename = paste0(path$gi$temp, "potential_trees.tif"))