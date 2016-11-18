## Filter function

filepath <- "D:/Uni/forest_caldern/data/aerial/478000_5630000.tif"


filter <- function(filepath, targetpath = dirname(filepath), prefix = "file_", window = c(21,29,33)){
  library(glcm)
  library(raster)
  
  
  filepath_rds <- paste0(substr(filepath,1,nchar(filepath)-3),"rds")
  # read indice tif and rds file
  indices <- readRDS(filepath_rds
  stack <- stack(filepath)
  
  # get number of layers from stack
  n_indices <- nlayers(r)
  
  
  
  all_indices <- lapply(1:n_indices, function(i){
    r <- stack[[i]]
    ## hier lapply schleife über die filter (von funktion übergeben)
    # glcm(r, statistics = f, window = c(w,w))
    filter_same_windowsize <- lapply(window, function(w){
      
      temp_homogeneity <- glcm(r, statistics = "homogeneity", window = c(w,w))
      temp_contrast <- glcm(r, statistics = "contrast", window = c(w,w))
      temp_correlation <- glcm(r, statistics = "correlation", window = c(w,w))
      temp_mean <- glcm(r, statistics = "mean", window = c(w,w))
      temp_stack <- stack(temp_homogeneity, temp_contrast, temp_correlation, temp_mean)
      return(temp_stack)
    })
    stack(filter_same_windowsize)
  })
  
  
  #for loop mit writeRaster(all_indices[[i]]) und writeRDS mit Legende
  
  
  
  
  
  
  
  # execute filter for all indices 
  homogeneity <- lapply(seq(1,n_indices), function(x){
    r <- stack[[x]]
    temp_homogeneity <- glcm(r, statistics = "homogeneity", window = c(21,21))
    return(temp_homogeneity)
  })
  
  contrast <- lapply(seq(1,n_indices), function(x){
    r <- stack[[x]]
    temp_contrast <- glcm(r, statistics = "contrast", window = c(29,29))
    return(temp_contrast)
  })
  
  correlation <- lapply(seq(1,n_indices), function(x){
    r <- stack[[x]]
    temp_correlation <- glcm(r, statistics = "correlation", window = c(33,33))
    return(temp_correlation)
  })
  
  mean <- lapply(seq(1,n_indices), function(x){
    r <- stack[[x]]
    temp_mean <- glcm(r, statistics = "mean", window = c(33,33))
    return(temp_mean)
  })
  
  for(i in 1:n_indices){
    stacknames <- indices$Index
    filterstack <- 
  }
  
  writeRaster()
}