## Initialise any R Script

Init <- function(lecture, lecturenumber){
  
  # change backslashes with regular expression
  #filepath_base <- gsub("\\\\", "/", path.expand(filepath_base))
  
  # set filepaths
  filepath_base <- "D:/university/"
  path_data <- paste0(filepath_base, "data/")
  path_fun <- paste0(filepath_base, "msc-phygeo-class-of-2016-Ludwigm6/fun/")
  
  # # Data paths
  # save paths in list
  rs <- list( aerial = paste0(path_data, "remote_sensing/aerial/"),
              aerial_merged = paste0(path_data, "remote_sensing/aerial_merged/"),
              aerial_croped = paste0(path_data, "remote_sensing/aerial_croped/"),
              aerial_final = paste0(path_data, "remote_sensing/aerial_final/"),
              rdata = paste0(path_data, "remote_sensing/RData/"),
              temp = paste0(path_data, "remote_sensing/temp/"),
              input = paste0(path_data, "remote_sensing/input/"),
              run = paste0(path_data, "remote_sensing/run/"),
              saga = paste0(path_data, "remote_sensing/saga/"))
  
  gi <- list(input = paste0(path_data, "gis/input/"),
             output = paste0(path_data, "gis/output/"),
             rdata = paste0(path_data, "gis/RData/"),
             run = paste0(path_data, "gis/run/"),
             temp = paste0(path_data, "gis/temp/"))
  
  da <- list(csv = paste0(path_data, "data_analysis/csv/"),
             raw = paste0(path_data, "data_analysis/raw/"),
             rdata = paste0(path_data, "data_analysis/RData/"),
             temp = paste0(path_data, "data_analysis/temp/"))
  
  # create list with all paths
  path <- list(fun = path_fun, rs = rs, gi = gi, da = da)
  
  # create GIT directory for scripts and rmd
  # check lecture for sub directory
  if(lecture == "da"){
    lecture_full <- "data_analysis"
    path_temp <- da$temp
  }else if(lecture == "gi"){
    lecture_full <- "gis"
    path_temp <- gi$temp
  }else if(lecture == "rs"){
    lecture_full <- "remote_sensing"
    path_temp <- rs$temp
  }
  
  # create folders based on lecture and lecture_number
  path_scripts <- paste0(filepath_base, "msc-phygeo-class-of-2016-Ludwigm6/",lecture_full,"/", lecture, "-ws-", lecturenumber,"/")
  if(!file.exists(file.path(path_scripts))){
    dir.create(file.path(path_scripts), recursive = TRUE)
    dir.create(paste0(file.path(path_scripts), "/rmds/"), recursive = TRUE)
    dir.create(paste0(file.path(path_scripts), "/scripts/"), recursive = TRUE)
  }
  
  # set rasteroptions to working directory
  
  raster::rasterOptions(tmpdir = path.expand(path_temp))
  
  # setting R environ temp folder to the current working directory
  Sys.setenv(TMPDIR = file.path(path_temp))
  
  # initialise SAGA 3.0.0 shell and gdal
  saga_path <- "C:\\Program Files\\SAGA-GIS"
  gdal_path <- "C:\\Program Files\\QGIS 2.18\\bin"
  Sys.setenv(PATH=paste0(gdal_path, ";", saga_path,";",Sys.getenv("PATH")))
  
  # return the list of paths
  return(path)
  
}