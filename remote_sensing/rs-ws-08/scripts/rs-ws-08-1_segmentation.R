# rs-ws-08-1 segmentation

# install.packages("devtools")
# install.packages("RStoolbox")
# install.packages("satellite")

library(satelliteTools)
library(raster)

# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("rs", "08")
satelliteTools::initOTB("C:/GIS/OTB/bin/")


# # # parameters and files
path$seg <- paste0(path$rs$run, "segmentation/")
pca_stack <- paste0(path$rs$input, "geonode_ortho_muf_rgb_idx_pca_scaled.tif")
otb_filter <- paste0(path$seg, "otb_filter.tif")
otb_spatial <- paste0(path$seg, "otb_spatial.tif")
# parameters for step 3
iter <- expand.grid(c(15,30), seq(40, 70, 10))
names(iter) <- c("spec_r", "min_size")
iter$file <- paste0(path$seg, "region_merges/specr", iter$spec_r, "_mins", iter$min_size,"_merge.tif")
iter$shp <- paste0(path$seg, "region_merges/shp/specr", iter$spec_r, "_mins", iter$min_size,"_vector.shp")


# Step 1:
# https://www.orfeo-toolbox.org/CookBook/Applications/app_MeanShiftSmoothing.html

otbcli_MeanShiftSmoothing(x = pca_stack,
                          outfile_filter = otb_filter,
                          outfile_spatial = otb_spatial,
                          spatialr = 5, ranger = 15, thres = 0.1,
                          maxiter = 100, rangeramp = 0, verbose = FALSE, ram = "8192", return_raster = FALSE)

# Step 2:
# https://www.orfeo-toolbox.org/CookBook/Applications/app_LSMSSegmentation.html
# labeled image where neighbor pixels whose range distance is below range radius
# (and optionally spatial distance below spatial radius) will be grouped together into the same cluster
spec_r <- c(15,30)
for(i in seq(2)){
  otbcli_ExactLargeScaleMeanShiftSegmentation(x = otb_filter,
                                              inpos = otb_spatial,
                                              out = paste0(path$seg,"specr", spec_r[i],"_otb_segmentation.tif"),
                                              tmpdir = path$rs$temp, spatialr = 1, ranger = spec_r[i],
                                              minsize = 0, tilesizex = 500, tilesizey = 500, verbose = FALSE) 
}





for(j in seq(nrow(iter))){
  
  # Step 3:
  # https://www.orfeo-toolbox.org/CookBook/Applications/app_LSMSSmallRegionsMerging.html
  # merge regions whose size in pixels is lower than minsize parameter 
  otbcli_LSMSSmallRegionsMerging(x = otb_filter,
                                 inseg = paste0(path$seg,"specr", iter$spec_r[j],"_otb_segmentation.tif"),
                                 out = iter$file[j],
                                 minsize = iter$min_size[j], tilesizex = 500, tilesizey = 500,
                                 verbose = FALSE, return_raster = FALSE, ram = "8192")
  # Step 4:
  # https://www.orfeo-toolbox.org/CookBook/Applications/app_LSMSVectorization.html
  # Each polygon contains additional fields: mean and variance of each channels from input image
  otbcli_LSMSVectorization(x = pca_stack,
                           inseg = iter$file[j],
                           out = iter$shp[j],
                           tilesizex = 500, tilesizey = 500, verbose = FALSE, ram = "8192")
  
}




