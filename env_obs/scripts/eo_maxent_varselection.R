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
pernis <- sr_br$pernis
# env data
# load all environmental data
env <- stack(readRDS(paste0(path$data$RData, "abiotic.RDS")),
             readRDS(paste0(path$data$RData, "bioclim_selection.rds")),
             readRDS(paste0(path$data$RData, "worldclim.rds")))



# var selection
outdir <- paste0(path$data$maxent, "testrun")
dir.create(outdir)
# maxent model
me <- dismo::maxent(x = env, p = pernis$Fold1$training$occurence, 
                    a = pernis$Fold1$training$background, path = outdir, 
                    factors = "corine", "ftype", removeDuplicates = FALSE)

# get the contribution values
res <- me@results
cont <- res[grepl("contribution$", names(res[,1])),]
cont_imp <- cont[cont > cont["tcd.contribution"]]

# cut off the names
names(cont_imp) <- gsub('.{13}$', '', names(cont_imp))
# get only the layers with matching names
env_imp <- env[[names(cont_imp)]]

saveRDS(env_imp, file = paste0(path$data$RData, "env_model.RDS"))







