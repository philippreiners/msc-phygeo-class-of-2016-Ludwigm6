green_leaf_index <- function(rgb){
  
  if(nlayers(rgb) < 3)
    stop("Argument 'rgb' has to be a raster* with at least 3 layers")

red <- rgb[[1]]
green <- rgb[[2]]
blue <- rgb[[3]]
  
  
gli <- (2*green - red - blue)/
        (2*green + red + blue)



return(gli)  
  
}