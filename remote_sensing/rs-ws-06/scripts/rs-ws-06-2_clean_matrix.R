# make matrix squared
# einfach die beiden Begriffe in den Ersten Zeilen der csv löschen und dann als tabelle einladen


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

# jetzt kann compKappa ausgeführt werden