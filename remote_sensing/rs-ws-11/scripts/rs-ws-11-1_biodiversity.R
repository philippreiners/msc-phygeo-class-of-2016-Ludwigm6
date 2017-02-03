# rs-ws-11-1 biodiversity

# init script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("rs", "11")

library(rgdal)
library(vegan)
library(raster)



trees <- readOGR(paste0(path$gi$output, "trees.shp"))
lcc <- raster(paste0(path$rs$run, "lcc_final.tif"))


buffersize <- 50

types <- lapply(seq(length(trees)), function(x){
  
  tile <- crop(trees, y = c(trees@coords[x,1] - buffersize, trees@coords[x,1] + buffersize, 
                            trees@coords[x,2] - buffersize, trees@coords[x,2] + buffersize))
  
  type <- data.frame(t(as.data.frame(summary(tile@data$tree_type))))
  type$NA.s <- NULL
  type$shannon <- diversity(type, index = "shannon")
  return(type)
})
types <- do.call(rbind, types)





