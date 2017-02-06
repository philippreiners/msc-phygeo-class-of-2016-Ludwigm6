# gi-ws-10-1 forest metrics
# part 1: tree crowns and there metrics

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "10")

library(link2GI)
library(raster)
library(rgrass7)
library(gdalUtils)
library(rgdal)
library(rgeos)


# load preprocessed rasters; important are ground returns and above ground returns
input <- readRDS(paste0(path$gi$RData, "muf.rds"))

# chm from gi-ws-09-1
chm <- raster(paste0(path$gi$run, "chm.tif"))
# density like in gi-ws-08-2
dens <- input$lidar_pcag_01m.tif/(input$lidar_pcgr_01m.tif+input$lidar_pcag_01m.tif)
writeRaster(dens, filename = paste0(path$gi$run, "density.tif"))


# init GRASS
linkGRASS7(x = chm, searchPath = "C:\\GIS\\QGIS")
# import chm and density to GRASS
execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$run, "chm.tif"),
                            output = "chm"))
execGRASS("r.import", flags = c("o","overwrite") , 
          parameters = list(input = paste0(path$gi$run, "density.tif"),
                            output = "dens"))

# calculate catchment areas, only important raster will be swatershed = ts_shed
execGRASS("r.terraflow", flags = c("overwrite", "s"),
          parameters = list(elevation = "chm",
                            filled = "tf_filled",
                            direction = "ts_direction",
                            swatershed = "ts_shed",
                            accumulation = "ts_scc",
                            tci = "ts_tci"))

# convert watersheds (=potential crowns) to polygons
execGRASS("r.to.vect", flags = c("overwrite"),
          parameters = list(input = "ts_shed", output = "potential_crowns", type = "area", column = "crown_id"))

# add columns for area, perimeter, compactness to the attribute table
execGRASS("v.db.addcolumn", parameters = list(map = "potential_crowns",
                                              columns = "area DOUBLE PRECISION, perimeter DOUBLE PRECISION, compact DOUBLE PRECISION"))

# calculate area, perimeter and compactness for each polygon and write it to respective column
for(i in c("area", "perimeter", "compact")){
  execGRASS("v.to.db", parameters = list(map = "potential_crowns",
                                         option = i,
                                         columns = i))
  
}

# calculate mean denisty for each crown
execGRASS("v.rast.stats", flags = "c",
          parameters = list(map = "potential_crowns",
                            raster = "dens",
                            column_prefix = "dens",
                            method = "average"))
# problem with the length of the colname; so rename the column:
execGRASS("v.db.renamecolumn", parameters = list(map = "potential_crowns",
                                                 column = "dens_average, dens"))

# save results until now
execGRASS('v.out.ogr',  flags = c("overwrite"),
          parameters = list(input = "potential_crowns",
                            output = paste0(path$gi$run, "potential_crowns.shp"),
                            format = "ESRI_Shapefile"))



############################################################
# decide what's a crown and what not

trees <- readOGR(paste0(path$gi$output, "trees.shp"))
crowns <- readOGR(paste0(path$gi$run, "potential_crowns.shp"))
# which crowns has a stem ?
tree_crowns <- gContains(spgeom1 = crowns, spgeom2 = trees, byid = TRUE, returnDense = FALSE)
not_tree <- unlist(lapply(tree_crowns, is.null))
crowns_with_stems <- crowns[!not_tree,]
# filter some big ones and oddly shaped
crowns_with_stems <- crowns_with_stems[crowns_with_stems@data$area < 150 & crowns_with_stems@data$compact < 2,]

# calculate estimate diameter of the crown
crowns_with_stems@data$diameter <- 2*sqrt((crowns_with_stems@data$area/pi))
summary(crowns_with_stems@data$diameter)

# save the crowns
writeOGR(crowns_with_stems, dsn = paste0(path$gi$run, "crowns_with_stems.shp"), driver = "ESRI Shapefile", layer = "crowns")

# save the information in the stems as well
execGRASS("v.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$rs$output, "trees_shannon.shp"),
                            output = "trees"))
execGRASS("v.import", flags = c("o", "overwrite"),
          parameters = list(input = paste0(path$gi$run, "crowns_with_stems.shp"),
                            output = "crowns"))

# create a column for each new parameter and write values
for(j in c("area", "perimeter", "compact", "diameter", "dens")){
  execGRASS("v.db.addcolumn", parameters = list(map = "trees",
                                                columns = paste0(j, " DOUBLE PRECISION")))
  execGRASS("v.what.vect", parameters = list(map = "trees",
                                             column = j,
                                             query_map = "crowns",
                                             query_column = j))
}
# save the final tree shapefile
execGRASS('v.out.ogr',  flags = c("overwrite"),
          parameters = list(input = "trees",
                            output = paste0(path$gi$output, "trees_final.shp"),
                            format = "ESRI_Shapefile"))

