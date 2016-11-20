# da-ws-05-2 wheat vs barley

# initialise script and get filepaths
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- Init("da", "05")

library(car)

# load data
harvest <- readRDS(paste0(path$da$csv, "harvest_data.rds"))


# only get rows with no NA in Winter_wheat or Winter_barley
harvest <- harvest[!is.na(harvest$Winter_wheat),]
harvest <- harvest[!is.na(harvest$Winter_barley),]
summary(harvest)

# linear model
attach(harvest)
model <- lm(Winter_barley ~ Winter_wheat)
plot(Winter_wheat, Winter_barley)
regLine(model, col = "red")

# Normal distribution of residuals
plot(model, which = 1)
# Heteroscedacity
plot(model, which = 2)



############# 

# decide level of significance
alpha <- 0.05


 
# testing 100 samples with 50 values on normal distribution with shapiro wilk test
# H0: residuals are normal distributed
# set seed for reproducability
# get 50 random rows from dataframe
normal_dist_50 <- lapply(seq(100), function(x){
                  set.seed(x)
                  random_sample <- harvest[sample(seq(1:nrow(harvest)), 50, replace = FALSE),]
                  random_lm <- lm(random_sample$Winter_barley ~ random_sample$Winter_wheat)
                  random_shapiro <- shapiro.test(random_lm$residuals)

                  # reject H0 ?
                  if(random_shapiro$p.value < alpha){
                    return("reject")
                  }else{
                    return("no_reject")
                  }
})


# testing 100 samples with 100 values on normal distribution with shapiro wilk test
# H0: residuals are normal distributed
# set seed for reproducability
# get 50 random rows from dataframe
normal_dist_100 <- lapply(seq(100), function(x){
                   set.seed(x)
                   random_sample <- harvest[sample(seq(1:nrow(harvest)), 100, replace = FALSE),]
                   random_lm <- lm(random_sample$Winter_barley ~ random_sample$Winter_wheat)
                   random_shapiro <- shapiro.test(random_lm$residuals)
                    
                   # reject H0 ?
                   if(random_shapiro$p.value < alpha){
                     return("reject")
                   }else{
                     return("no_reject")
                   }
})

rejections_50 <- 0
rejections_100 <- 0
for(i in seq(100)){
  if(normal_dist_50[[i]] == "reject"){
    rejections_50 <- rejections_50 + 1
  }
  
  if(normal_dist_100[[i]] == "reject"){
    rejections_100 <- rejections_100 + 1
  }
}
print(rejections_50)
print(rejections_100)

