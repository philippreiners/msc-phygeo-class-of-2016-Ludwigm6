# MaxEnt preparation
library(raster)
library(sp)
library(dismo)
library(caret)


# init script
source("D:/habitat_mod/scripts/init_uni.R")
path <- fun_init(data = "D:/habitat_mod/data", scripts = "D:/habitat_mod/scripts")

# load data
fls <- list.files(path$data$RData, full.names = TRUE)
gbif <- readRDS(fls[3])
bg <- readRDS(paste0(path$data$output, "background_random.RDS"))
rm(fls)

# four most frequent species 8,9,12,13
species <- list(milvus_mil = gbif[[8]],
                milvus_mig = gbif[[9]],
                ciconia = gbif[[12]],
                pernis = gbif[[13]])


# background loop
# divide dataset in 4 equal parts
set.seed(210)
parts_bg <- createFolds(y = seq(nrow(bg)), k = 4)

bg_random <- lapply(parts_bg, function(l){
  test_bg <- bg[l,]
  train_bg <- bg[-l,]
  
  tr <- list(background = train_bg)
  te <- list(background = test_bg)
  
  return(list(training = tr,
              test = te))
})


z <- 0
# species loop
sr_br <- lapply(species, function(i){
  names(i) <- "NAME"
 # divide dataset in 4 equal parts
  set.seed(210)
  parts <- createFolds(y = seq(nrow(i)), k = 4)
  cv_random <- lapply(parts, function(j){
    z <- z+1
    test <- i[j,]
    train <- i[-j,]
    
    tr <- list(occurence = train, background = bg_random[[z]]$training$background)
    te <- list(occurence = test, background = bg_random[[z]]$test$background)
    
    return(list(training = tr,
                test = te))
    })
})

saveRDS(sr_br, file = paste0(path$data$output, "sr_br.RDS"))


n <- 0
sr_bbr <- lapply(species, function(m){
  # # # background sample
  n <- n+1
  set.seed(210)
  parts_bg <- createFolds(y = seq(nrow(bbg[[n]])), k = 4)
  bg_random <- lapply(parts_bg, function(l){
    test_bg <- bbg[[n]][l,]
    train_bg <- bbg[[n]][-l,]
    
    tr <- list(background = train_bg)
    te <- list(background = test_bg)
    
    return(list(training = tr,
                test = te))
  })
  
  # # # species sample
  names(i) <- "NAME"
  # divide dataset in 4 equal parts
  set.seed(210)
  parts <- createFolds(y = seq(nrow(i)), k = 4)
  cv_random <- lapply(parts, function(j){
    z <- z+1
    test <- i[j,]
    train <- i[-j,]
    
    tr <- list(occurence = train, background = bg_random[[z]]$training$background)
    te <- list(occurence = test, background = bg_random[[z]]$test$background)
    
    return(list(training = tr,
                test = te))
  })
  
})


saveRDS(sr_bbr, file = paste0(path$data$output, "sr_bbr.RDS"))









