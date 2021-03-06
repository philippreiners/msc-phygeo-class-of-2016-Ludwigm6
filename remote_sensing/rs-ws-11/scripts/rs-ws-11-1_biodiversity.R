# rs-ws-11-1 biodiversity

# init script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("rs", "11")

library(rgdal)
library(vegan)
library(raster)
library(rgeos)

# load trees
trees <- readOGR(paste0(path$gi$output, "trees.shp"))

# first loop: iterate different buffer sizes
shannon <- lapply(c(10,30,70,100), function(buffersize){
  
  # buffer trees
  tree_buffers <- gBuffer(trees, byid = TRUE, width = buffersize)
  # get the tree ids within one buffer
  # output is a list with an entry for every tree-buffer; every entry contains the tree ids for the buffer
  contain <- gContains(spgeom1 = tree_buffers, spgeom2 = trees, byid = TRUE, returnDense = FALSE)
  
  # second loop: iterate the tree-buffers
  types <- lapply(contain, function(x){
    # extract the tree type for every id in the list entry
    type <- data.frame(t(as.data.frame(summary(trees[x,]@data$tree_type))))
    # remove NAs
    type$NA.s <- NULL
    return(type)
  })
  # "convert" the list to a dataframe
  types_df <- do.call(rbind, types)
  # calculate shannon index for every row in the dataframe
  sh <- diversity(types_df, index = "shannon")
  return(sh)
})
# in the list 'shannon' are now the four shannon indizes (one for each buffersize) for every tree

# write the indizes in the attribute table
trees@data$shannon_10 <- shannon[[1]]
trees@data$shannon_30 <- shannon[[2]]
trees@data$shannon_70 <- shannon[[3]]
trees@data$shannon_100 <- shannon[[4]]
# save results
writeOGR(trees, dsn = paste0(path$rs$output, "trees_shannon.shp"), driver = "ESRI Shapefile", layer = "trees")



