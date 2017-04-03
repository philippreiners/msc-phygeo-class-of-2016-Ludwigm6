# rs-ws-06-2 Kappa

source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")

path <- fun_init("rs", "06")
path$samples <- paste0(path$rs$run, "samples/")
source(path$fun$fun_compKappa.R)


matrix_files <- list.files(path$samples, pattern = "*.csv", full.names = TRUE)

kappa_55 <- lapply(seq(length(matrix_files)), function(x){
  
  # load matrix and extract rows and cols
  m <- read.csv(matrix_files[[x]], skip = 0, header = FALSE)
  rows <- unlist(m[1,])
  cols <- unlist(m[2,])
  
  # load matrix again; skip the row index and with cols as header
  m <- read.csv(matrix_files[[x]], skip = 1, header = TRUE)
  
  
  # make the matrix a square
  template <- matrix(nrow = 40, ncol = 40, data = 0)
  for(i in seq(40)){
    for(j in seq(40)){
      if(i %in% rows & j %in% cols){
        template[i,j] <- m[which(rows == i), which(cols == j)]
      }
    }
  }
  return(compKappa(ctable = template))
})




