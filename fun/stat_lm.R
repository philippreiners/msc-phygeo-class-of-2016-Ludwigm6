## function: statistics of lm

stat_lm <- function(df, ind, dep){
  
  # remove NAs
  df <- df[!is.na(ind),]
  df <- df[!is.na(dep),]
  
  
  # Cross validation; leave one out
  cv <- lapply(seq(nrow(df)), function(x){
    # Leave one observation out and save it in 'test'
    train <- df[-x, ]
    test <- df[x,]
    
    # linear model
    lmod <- lm(dep ~ ind, data = sample)
    
    # test model by predicting the test value
    pred <- predict(lmod, newdata = test)
    # save the test observation value
    obsv <- test$dep
    # write everything in data frame
    data.frame(pred = pred,
               obsv = obsv,
               model_r_squared = summary(lmod)$r.squared)
  })
  cv <- do.call("rbind", linear_models)
  
  
  
  # sum of squares of all observations
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
  
  MSS <- data.frame(NAME = c("MSS_Observations",
                             "MSS_Model", 
                             "MSS_Rediuals"),
                    VALUE = c(round(mss_obsrv, 2),
                              round(mss_model, 2),
                              round(mss_resid, 2)))
  
  
  # # # # standardizes errors of the model # # # #
  
  # Formular for standard error:
  se <- function(x) sd(x, na.rm = TRUE)/sqrt(length(na.exclude(x)))
  
  
  # mean error
  me <- round(mean(cv$pred - cv$obs, na.rm = TRUE), 2)
  # standard error of mean error
  me_sd <- round(se(cv$pred - cv$obs), 2)
  # mean absolut error; Berechnung verwendet Beträge
  mae <- round(mean(abs(cv$pred - cv$obs), na.rm = TRUE), 2)
  # standard error of absolut error
  mae_sd <- round(se(abs(cv$pred - cv$obs)), 2)
  # Root mean square error
  rmse <- round(sqrt(mean((cv$pred - cv$obs)^2, na.rm = TRUE)), 2)
  # standard error of Root mean square error
  rmse_sd <- round(se((cv$pred - cv$obs)^2), 2)
  
  error <- data.frame(NAME = c("Mean error (ME)", "Std. error of ME", 
                      "Mean absolute error (MAE)", "Std. error of MAE", 
                      "Root mean square error (RMSE)", "Std. error of RMSE"),
             VALUE = c(me, me_sd,
                       mae, mae_sd,
                       rmse, rmse_sd))
  
  stats_lm <- list(MSS = MSS, error = error)
  return(stats_lm)
}