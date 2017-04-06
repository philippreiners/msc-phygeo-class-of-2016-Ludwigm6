# maxent variable selection

install.packages("rJava")
install.packages("dismo")

library(dismo)
library(rJava)
library(raster)

source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init_uni.R")
path <- fun_init(data = "D:/university/data/habitat_mod",
                 scripts = "D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun")

# load data
sr_br <- readRDS(paste0(path$data$input, "sr_br.RDS"))
sr_bbr <- readRDS(paste0(path$data$input, "sr_bbr.RDS"))
sgm_bgm <- readRDS(paste0(path$data$input, "sgm_bgm.RDS"))
sgm_bbgm <- readRDS(paste0(path$data$input, "sgm_bbgm.RDS"))

# extract data for one species
pernis <- list(sr_br = sr_br$pernis,
               sr_bbr = sr_bbr$pernis,
               sgm_bgm = sgm_bgm$`Pernis apivorus`,
               sgm_bbgm = sgm_bbgm$`Pernis apivorus`)

# load relevant environmental data
env <- readRDS(paste0(path$data$RData, "env_model.RDS"))
meth_name <- names(pernis)
  

samp_method <- lapply(seq(4), function(s){
  # extract current method data
  cur_meth <- pernis[[s]]

  folds <- lapply(seq(4), function(f){
    # create output dir for every model
    outdir <- paste0(path$data$maxent, meth_name[s], "_fold_",f)
    dir.create(outdir)
    # compute maxent model with current training dataset
    me <- dismo::maxent(x = env, p = cur_meth[[f]]$training$occurence, 
                        a = cur_meth[[f]]$training$background, path = outdir, 
                        factors = "corine", "ftype", removeDuplicates = FALSE)
    
    ev <- dismo::evaluate(x = env, p = cur_meth[[f]]$test$occurence, 
                          a = cur_meth[[f]]$test$background, model = me)
    res_list <- list(model = me, eval = ev)
    saveRDS(res_list, file = paste0(outdir, "res_list.RDS"))
    return(res_list)
  })
  
})











