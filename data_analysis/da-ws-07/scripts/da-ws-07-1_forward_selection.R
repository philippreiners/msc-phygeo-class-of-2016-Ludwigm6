
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- Init("da", "07")

source(paste0(path$fun, "fun_fwd_fs.R"))

harvest <- readRDS(paste0(path$da$csv, "harvest_data.rds"))
vars <- names(harvest[7:ncol(harvest)])
sel_var <- NULL
run <- TRUE

while(run == TRUE){
ffs <- forward_feature_selection(data = harvest,
                                 dep = "Winter_wheat",
                                 vars = vars,
                                 selected_vars = sel_var)

  vars <- vars[-which(vars == ffs[[1]])]
  sel_var <- rbind(sel_var, ffs[[1]])

  if(ffs[[2]] < max(ffs[[3]]$Adj_R_sqrd)){
    run <- FALSE
  }  
   
}

