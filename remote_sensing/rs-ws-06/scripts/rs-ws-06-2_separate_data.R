# rs-ws-06-2 accuarcy assessment
#install.packages("caret")


source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- fun_init("rs", "06")
path$samples <- paste0(path$rs$run, "samples/")


library(caret)
library(rgdal)
library(raster)
source(path$fun$fun_compKappa.R)

train_sites <- readOGR(paste0(path$rs$run, "training_sites.shp"))
separate <- lapply(seq(length(train_sites)), function(i) train_sites[i,])

sites_sample <- createDataPartition(train_sites@data$ID, p = 0.80, list = FALSE, times = 6)



samples <- lapply(seq(ncol(sites_sample)), function(x){
  
  train <- lapply(sites_sample[,x], function(i) rbind(separate[[i]]))
  train <- do.call("rbind", train)
  
  test <- lapply(seq(length(train_sites))[-sites_sample[,x]], function(j) rbind(separate[[j]]))
  test <- do.call("rbind", test)  
  
  return(list(train = train, test = test))
  
})


dir.create(paste0(path$samples))

for(k in seq(6)){
  writeOGR(samples[[k]]$train, dsn = paste0(path$sample, "train_", as.character(k), ".shp"), driver = "ESRI Shapefile", layer = "train")
  writeOGR(samples[[k]]$test, dsn = paste0(path$sample, "test_", as.character(k), ".shp"), driver = "ESRI Shapefile", layer = "test")
}


# load matrix and extract rows and cols
matrix_1 <- read.csv(paste0(path$samples, "matrix_1.csv"), skip = 0, header = FALSE)
rows <- unlist(matrix_1[1,])
cols <- unlist(matrix_1[2,])

# load matrix again; skip the row index and with cols as header
matrix_1 <- read.csv(paste0(path$samples, "matrix_1.csv"), skip = 1, header = TRUE)


# make the matrix a square
template <- matrix(nrow = 40, ncol = 40, data = 0)
for(i in seq(40)){
  for(j in seq(40)){
    if(i %in% rows & j %in% cols){
      template[i,j] <- matrix_1[which(rows == i), which(cols == j)]
    }
  }
}


kappa_1 <- compKappa(ctable = template)



















# repair confMatrix





matrix_1[,][is.na(matrix_1)] <- 0



template <- matrix(nrow = 3, ncol = 3, data = c(1:9))
template[2,2] <- 7
template
                       