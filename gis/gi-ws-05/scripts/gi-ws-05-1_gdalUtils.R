source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/Init.R")
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/sagaModuleHelp.R")
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/sagaModulecmd.R")
path <- Init("gi", "05")

install.packages("gdalUtils")
library(gdalUtils)
gdal_setInstallation()
valid.install<-!is.null(getOption("gdalUtils_gdalPath"))
print(valid.install)


