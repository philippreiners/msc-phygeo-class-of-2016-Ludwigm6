## Initialise any R Script

fun_init <- function(lecture, lecturenumber){

 
  da <- list.dirs("D:/university/data/data_analysis", recursive = FALSE)
  names_da <- sapply(strsplit(da, split = "/"), "[", 5)
  da <- sapply(X = da, FUN = paste0, "/")
  da <- as.list(da)
  names(da) <- names_da
  
  gi <- list.dirs("D:/university/data/gis", recursive = FALSE)
  names_gi <- sapply(strsplit(gi, split = "/"), "[", 5)
  gi <- sapply(X = gi, FUN = paste0, "/")
  gi <- as.list(gi)
  names(gi) <- names_gi
  
  rs <- list.dirs("D:/university/data/remote_sensing", recursive = FALSE)
  names_rs <- sapply(strsplit(rs, split = "/"), "[", 5)
  rs <- sapply(X = rs, FUN = paste0, "/")
  rs <- as.list(rs)
  names(rs) <- names_rs
  
  fun_path <- as.list(list.files("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun", full.names = TRUE))
  names(fun_path) <- list.files("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun")
  
  
  path <- list(da = da, gi = gi, rs = rs, fun = fun_path)
  

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
  path_scripts <- paste0("D:/university/msc-phygeo-class-of-2016-Ludwigm6/",lecture_full,"/", lecture, "-ws-", lecturenumber,"/")
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
  saga_path <- "C:\\GIS\\SAGA"
  gdal_path <- "C:\\GIS\\QGIS\\bin"
  Sys.setenv(PATH=paste0(gdal_path, ";", saga_path,";",Sys.getenv("PATH")))
  
  # return the list of paths
  return(path)
  
}