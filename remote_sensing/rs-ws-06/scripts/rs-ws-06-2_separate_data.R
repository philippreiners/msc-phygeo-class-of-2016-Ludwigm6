# rs-ws-06-2 train and test separation

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- fun_init("rs", "06")
path$samples <- paste0(path$rs$run, "samples/")


library(caret)
library(rgdal)
library(raster)

# load training sites 
train_sites <- readOGR(paste0(path$rs$run, "training_sites.shp"))

# write each polygon in a list
separate <- lapply(seq(length(train_sites)), function(i) train_sites[i,])

# get 80 % of the index numbers (6 times)
sites_sample <- createDataPartition(train_sites@data$ID, p = 0.80, list = FALSE, times = 6)


# samples is a list with 6 entries. each entry contains two spatialpolygondataframes: train and test
samples <- lapply(seq(ncol(sites_sample)), function(x){
  
  # get 80% of the polygons based on the numbers in sites_sample
  train <- lapply(sites_sample[,x], function(i) rbind(separate[[i]]))
  train <- do.call("rbind", train)
  
  # get the remaining 20%
  test <- lapply(seq(length(train_sites))[-sites_sample[,x]], function(j) rbind(separate[[j]]))
  test <- do.call("rbind", test)  
  
  return(list(train = train, test = test))
  
})

# create output folder
dir.create(paste0(path$samples))

# save each list entry as shapefile 
for(k in seq(6)){
  writeOGR(samples[[k]]$train, dsn = paste0(path$sample, "train_", as.character(k), ".shp"), driver = "ESRI Shapefile", layer = "train")
  writeOGR(samples[[k]]$test, dsn = paste0(path$sample, "test_", as.character(k), ".shp"), driver = "ESRI Shapefile", layer = "test")
}

