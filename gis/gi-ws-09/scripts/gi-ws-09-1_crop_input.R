# gi-ws-09-1 forest related stuff
# preprocessing rasters: crop all to the same extent

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("gi", "09")

library(raster)

# load input rasters
input <- lapply(list.files(path$gi$input, full.names =  TRUE), function(x){
  stack(x)
})
names(input) <- list.files(path$gi$input)

# crop every raster to the extend of the aerial
crops <- lapply(seq(length(input)), function(i){
  if(input[[i]]@extent != input$geonode_ortho_muf_1m.tif@extent){
    return(crop(input[[i]], input$geonode_ortho_muf_1m.tif))
  }else{
    return(input[[i]])
  }
})
names(crops) <- names(input)

saveRDS(crops, file = paste0(path$gi$RData, "muf.rds"))
