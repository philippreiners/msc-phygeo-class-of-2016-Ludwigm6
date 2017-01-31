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
trees@data$id_crown <- NA

crowns@data$cat <- NULL
crowns@data$NAME <- NULL
crowns@data$ID <- seq(length(crowns))
names(crowns@data) <- c("id_crown", "id_tree")
crowns@data$id_tree <- NA
crowns@data$area <- NA

writeOGR(trees, dsn = paste0(path$gi$run, "trees.shp"), driver = "ESRI Shapefile", layer = "trees" ,overwrite = TRUE)
writeOGR(crowns, dsn = paste0(path$gi$run, "crowns.shp"), driver = "ESRI Shapefile", layer = "crowns", overwrite = TRUE)

# # # tree height and type # # #
# tree height
chm <- input$lidar_dsm_01m.tif - input$lidar_dem_01m.tif
writeRaster(chm, filename = paste0(path$gi$run, "tree_height.tif"), overwrite = TRUE)

# import all needed maps in GRASS
execGRASS("r.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "tree_height.tif"),
                            output = "tree_height"))
execGRASS("r.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "smooth_lcc3.tif"),
                            output = "lcc"))
execGRASS("v.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "trees.shp"),
                            output = "trees"))
execGRASS("v.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "crowns.shp"),
                            output = "crowns"))


# # # querying: get values from raster at points # # #
execGRASS("r.what", flags = c("overwrite", "n"),
          parameters = list(map = c("tree_height","lcc"),
                            points = "trees",
                            output = paste0(path$gi$run, "heights.csv"),
                            separator = "comma"))

heights <- read.csv(paste0(path$gi$run, "heights.csv"), header = TRUE, sep = ",", dec = ".")
# legend for lcc
type <- read.csv(paste0(path$gi$run, "tree_type.csv"), header = TRUE, sep = ",")

# attach the right type, age and height to attribute table
heights$type <- type$type[match(heights$lcc, type$id)]
heights$age <- type$age[match(heights$lcc, type$id)]

trees@data$height <- heights$tree_height
trees@data$tree_type <- heights$type
trees@data$age <- heights$age

head(trees@data)

# # # match crowns with trees # # #
# testing second query possibility which directly updates the column
execGRASS("v.what.vect", parameters = list(map = "trees",
                                           column = "id_crown",
                                           query_map = "crowns",
                                           query_column = "id_crown"))
# only the GRASS vector is updated; we need to update our SPDF
temp_trees <- readVECT(vname = "trees")
trees@data$id_crown <- temp_trees@data$id_crown
crowns@data$id_tree <- trees@data$id_tree[match(crowns@data$id_crown, trees@data$id_crown)]

# save both shapefiles
writeOGR(trees, dsn = paste0(path$gi$output, "trees.shp"), driver = "ESRI Shapefile", layer = "trees" ,overwrite = TRUE)
writeOGR(crowns, dsn = paste0(path$gi$output, "crowns.shp"), driver = "ESRI Shapefile", layer = "crowns", overwrite = TRUE)


# tree density heatmap
execGRASS("v.kernel", parameters = list(input = "trees", output = "tree_dens", radius = 20, kernel = "gaussian"))
execGRASS("r.out.gdal", flags = "overwrite",
          parameters = list(input = "tree_dens",
                            output = paste0(path$gi$output, "tree_denisty.tif"),
                            format = "GTiff"))



