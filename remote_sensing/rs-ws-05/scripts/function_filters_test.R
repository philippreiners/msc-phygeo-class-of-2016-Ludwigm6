### Testlauf der 'filter' funktion


#Create short data frame legend as RDS
df <- data.frame(Band = c(1,2,3), Index = c("red", "green", "blue"))
saveRDS(df, file = "D:/university/data/remote_sensing/aerial_final/muf_final.rds")

source('D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/filters.R')
filepath <- "D:/university/data/remote_sensing/aerial_final/muf_final.tif"


filter(filepath, prefix = "muf_", window = c(3,5,7), statistics = c("contrast", "mean"))

red <- raster("D:/university/data/remote_sensing/aerial_final/muf_red.tif")
readRDS("D:/university/data/remote_sensing/aerial_final/muf_red.rds")
plot(red)

r1 <- raster("D:/university/data/remote_sensing/aerial_final/muf_red.tif", band = 1)
r4 <- raster("D:/university/data/remote_sensing/aerial_final/muf_red.tif", band = 4)
r6 <- raster("D:/university/data/remote_sensing/aerial_final/muf_red.tif", band = 6)
plot(r6)







filepath <- "D:/university/data/remote_sensing/aerial_final/muf_final.tif"
targetpath <- dirname(filepath)
prefix <- "muf_"
window <- c(3,5,7)
statistics <- c("contrast", "mean")





rep(statistics[1], length(window))






