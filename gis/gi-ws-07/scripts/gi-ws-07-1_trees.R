# gi-ws-07-1 tree trunks

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "07")

library(raster)
library(gdalUtils)
library(rgdal)
library(scales)

# # # parameters and paths# # # 
# window size for mean filter
w_size <- 5

# create directory for comming steps and files
# dir.create(paste0(path$gi$run, "trees/"))
path$trees <- paste0(path$gi$run, "trees/")

# paths for SAGA Watershed Segmentation
path$ws_input <- paste0(path$trees, "trees_upside_down.sdat")
path$ws_output <- paste0(path$trees, "trees_segmentation.sdat")
path$ws_points <- paste0(path$trees, "trees_seeds.shp")
path$segments <- paste0(path$trees, "trees_segmentation.tif")
path$polygon_trees <- paste0(path$trees, "trees.shp")


# load DEM and DSM
DEM <- raster(paste0(path$gi$input, "lidar_dem_01m.tif"))
DSM <- raster(paste0(path$gi$input, "lidar_dsm_01m.tif"))

# get only the "objects" above terrain and invert them
# "trees" are now upside down with their max height at zero
surface_only <- (DSM - DEM)
surface_only <- (surface_only*(-1))+surface_only@data@max



# mean filter to get rid of small "sinks"
surface_only <- focal(surface_only, w = matrix(1, nc = w_size, nr = w_size), max)
plot(surface_only)



writeRaster(surface_only, filename = paste0(path$trees, "trees_upside_down.tif"), overwrite = TRUE)



# convert to saga format
gdalwarp(srcfile = paste0(path$trees, "trees_upside_down.tif"),
         dstfile = path$ws_input, overwrite = TRUE, of = 'SAGA')

# SAGA Watershed Segmentation
system(paste0("saga_cmd imagery_segmentation 0 ",
              "-GRID=", path$ws_input, " ",
              "-SEGMENTS=", path$ws_output," ",
              "-SEEDS=", path$ws_points," ",
              "-BORDERS=NULL ",
              "-OUTPUT=0 ",
              "-DOWN=0 ",
              "-JOIN=0 ",
              "-THRESHOLD=0.000000 ",
              "-EDGE=1 ",
              "-BBORDERS=0"))

# convert back to tif
gdalwarp(srcfile = path$ws_output,
         dstfile = path$segments, overwrite = TRUE, of = 'GTiff')

trees <- raster(path$segments) 

# get only cells that are higher than 5m
trees[trees > max(getValues(trees))-5] <- -99999
writeRaster(trees, filename = path$segments, overwrite = TRUE)
plot(trees)

# convert raster to polygon shapes; ignore NA values
# NOTE: DONT use rasterToPolygons, it takes forever!
# tree_polys <- rasterToPolygons(trees, na.rm = TRUE, dissolve = FALSE)
# so back to SAGA format:
gdalwarp(srcfile = path$segments,
         dstfile = path$ws_output, overwrite = TRUE, of = 'SAGA')

# SAGA Vectorizing Grid Classes
system(paste0("saga_cmd shapes_grid 6 ",
              "-GRID=", path$ws_output," ",
              "-POLYGONS=", path$polygon_trees, " ",
              "-CLASS_ALL=1 ",
              "-SPLIT=0 ",
              "-ALLVERTICES=0"))

# load polygon trees
poly_trees <- readOGR(path$polygon_trees, layer = "trees")

# create spatial Point for every tree
tree_coords <- as.data.frame(coordinates(poly_trees))
tree_coords <- as.data.frame(cbind(tree_coords, poly_trees@data))
coordinates(tree_coords) <- ~ V1 + V2
projection(tree_coords) <- projection(poly_trees)

writeOGR(tree_coords, dsn = paste0(path$trees, "tree_points.shp"), driver = "ESRI Shapefile", layer = "trees")
tree_points <- readOGR(paste0(path$trees, "tree_points.shp"))


# Number of trees in MUF:
print(nrow(poly_trees@data))

plot(DEM)
points(tree_points, pch = ".", col = alpha("black", alpha = 0.4))




