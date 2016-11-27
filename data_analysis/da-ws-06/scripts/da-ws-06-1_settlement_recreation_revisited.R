# da-ws-06-1 settlement vs recreation revisited
#
# cross validation

# Initialise script
source("D:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <- Init("da", "06")

# Load data
landuse <- readRDS(paste0(path$da$csv, "landuse_data.rds"))

# remove NAs
landuse <- landuse[!is.na(landuse$rate_residential),]
landuse <- landuse[!is.na(landuse$rate_recreation),]
summary(landuse)


x <- 1
# Cross validation; leave one out
linear_models <- lapply(seq(nrow(landuse)), function(x){
  sample <- landuse[-x, ]
  leave_value <- landuse[x,]
  
  model <- lm(rate_recreation ~ rate_residential, data = sample)
  pred <- predict(model, newdata = leave_value)
  obsv <- leave_value$rate_recreation
  data.frame(pred = pred,
             obsv = obsv,
             model_r_squared = summary(model)$r.squared)
})
cv <- do.call("rbind", linear_models)



# sum of squares observations - mean(observations)
ss_obsrv <- sum((cv$obsv - mean(cv$obsv))**2)
# sum of squares predictions - mean(observations)
ss_model <- sum((cv$pred - mean(cv$obsv))**2)
# sum of squares observation - predictions (RESIDUALS)
ss_resid <- sum((cv$obsv - cv$pred)**2)

# standardized values: sum of squares divided by degrees of freedom
# mean sum of squares observations (VARIANCE of observations):
mss_obsrv <- ss_obsrv / (length(cv$obsv) - 1)
# mean sum of squares predictions - mean(observations) 
mss_model <- ss_model / 1
# mean sum of squares residuals
mss_resid <- ss_resid / (length(cv$obsv) - 2)


# standardizes errors:
se <- function(x) sd(x, na.rm = TRUE)/sqrt(length(na.exclude(x)))


# mean error
me <- round(mean(cv$pred - cv$obs, na.rm = TRUE), 2)
# mean error 
me_sd <- round(se(cv$pred - cv$obs), 2)
mae <- round(mean(abs(cv$pred - cv$obs), na.rm = TRUE), 2)
mae_sd <- round(se(abs(cv$pred - cv$obs)), 2)
rmse <- round(sqrt(mean((cv$pred - cv$obs)^2, na.rm = TRUE)), 2)
rmse_sd <- round(se((cv$pred - cv$obs)^2), 2)

data.frame(NAME = c("Mean error (ME)", "Std. error of ME", 
                    "Mean absolute error (MAE)", "Std. error of MAE", 
                    "Root mean square error (RMSE)", "Std. error of RMSE"),
           VALUE = c(me, me_sd,
                     mae, mae_sd,
                     rmse, rmse_sd))







library(car)
plot(landuse$rate_residential, landuse$rate_recreation) 
predi
for(i in seq(1000)){
  abline(a = linear_models[[i]]$coefficients[1], b= linear_models[[i]]$coefficients[2])  
}
head(linear_models)


plot1 <- ggplot(data = landuse, mapping = aes(landuse$rate_residential, landuse$rate_recreation))
plot1 <- plot1 + geom_point()
plot1 + geom_smooth(method = "lm")
plot2 <- ggplot(data = linear_models[[1]]$)
