# da-ws-06-2 wheat vs barley revisited

# Initialise script
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
# source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/stat_lm.R")
path <- Init("da", "06")

# Load data
harvest <- readRDS(paste0(path$da$csv, "harvest_data.rds"))

# remove NAs
harvest <- harvest[!is.na(harvest$Winter_wheat),]
harvest <- harvest[!is.na(harvest$Winter_barley),]
summary(harvest)


# Cross validation; leave one out
cv_one <- lapply(seq(nrow(harvest)), function(x){
  sample <- harvest[-x, ]
  leave_value <- harvest[x,]
  
  model <- lm(Winter_barley ~ Winter_wheat, data = sample)
  
  prediction <- predict(model, newdata = leave_value)
  observation <- leave_value$Winter_barley
  
  rmse <- round(sqrt(mean((prediction - observation)^2)), 2)
  
  data.frame(prediction = prediction,
             observation = observation,
             rmse = rmse)
})
cv_one <- do.call("rbind", cv_one)


# Cross validation; leave many out; 100 models
all_data <- nrow(harvest)
nr_samples <- round(all_data*0.8,0)

cv_many <- lapply(seq(100), function(x){
  set.seed(x)
  s <- sample(all_data, nr_samples)
  sample <- harvest[s,]
  leave_value <- harvest[-s,]
  
  model <- lm(Winter_barley ~ Winter_wheat, data = sample)
  prediction <- predict(model, newdata = leave_value)
  observation <- leave_value$Winter_barley
  rmse <- round(sqrt(mean((prediction - observation)^2)), 2)
  df <- data.frame(prediction = prediction,
             observation = observation,
             rmse = rmse)
})
cv_many <- do.call("rbind", cv_many)

par(mfrow = c(1,3))
print(boxplot(cv_one$rmse))
title("Leave one out with outliners")
print(boxplot(cv_one$rmse, outline = FALSE))
title("Leave one out without outliners")
print(boxplot(cv_many$rmse))
title("Leave many out 0.8x0.2")

print(summary(cv_one$rmse))
print(summary(cv_many$rmse))