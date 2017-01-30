# gi-ws-09-1 forest stuff with GRASS
# part 3: some information about the trees

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

# load trees and crowns from part 2
trees <- readOGR(paste0(path$gi$input, "trees.shp"))
crowns <- readOGR(paste0(path$gi$input, "crowns.shp"))

# init GRASS
linkGRASS7(x = input$lidar_dem_01m.tif, searchPath = "C:\\GIS\\QGIS")

# clean up attribute df
names(trees@data) <- c("id_tree", "nodes")

# match trees with crowns
# v.what





# # # tree height and type # # #
chm <- input$lidar_dsm_01m.tif - input$lidar_dem_01m.tif
writeRaster(chm, filename = paste0(path$gi$run, "tree_height.tif"))
execGRASS("r.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "tree_height.tif"),
                            output = "tree_height"))
execGRASS("r.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "smooth_lcc3.tif"),
                            output = "lcc"))
execGRASS("v.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "trees.shp"),
                            output = "trees"))

execGRASS("r.what", flags = c("overwrite", "n"),
          parameters = list(map = c("tree_height","lcc"),
                            points = "trees",
                            output = paste0(path$gi$run, "heights.csv"),
                            separator = "comma"))

heights <- read.csv(paste0(path$gi$run, "heights.csv"), header = TRUE, sep = ",", dec = ".")
type <- read.csv(paste0(path$gi$run, "tree_type.csv"), header = TRUE, sep = ",")

heights$type <- type$type[match(heights$lcc, type$id)]
heights$age <- type$age[match(heights$lcc, type$id)]


trees@data$height <- heights$tree_height
trees@data$tree_type <- heights$type
trees@data$age <- heights$age


# tree density heatmap
execGRASS("v.kernel", parameters = list(input = "trees", output = "tree_dens", radius = 20, kernel = "gaussian"))
execGRASS("r.out.gdal", flags = "overwrite",
          parameters = list(input = "tree_dens",
                            output = paste0(path$gi$output, "tree_denisty.tif"),
                            format = "GTiff"))



