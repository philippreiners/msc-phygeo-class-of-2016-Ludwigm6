# da-ws-08-1 tune your model
# aim: find the number of k for gam which suits best for this data set


# initialise script
source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  fun_init("da", "08")

# library for generalized additive model
library(mgcv)

# read data
wood <- read.csv(paste0(path$da$csv, "hessen_holzeinschlag_1997-2014.csv"), skip = 4, sep = ";")
wood <- wood[-19,]


# first loop: iterate over different k
results <- lapply(seq(3,13), function(k){
  
  # second loop: for each k calculate 100 cross validations
  iterations <- lapply(seq(100), function(i){
    
    # take an 80% sample of the full dataset
    set.seed(i)
    s <- sample(nrow(wood), size = nrow(wood)*0.8)
    train <- wood[s,]
    # get the 20% test data and the observed values (for rmse)
    test <- wood[-s,]
    obs <- test$Eiche
    
    # calculate gam: Buche depended on Eiche with a number of k
    # fx = TRUE means skipping the penalty for higher k numbers
    modell <- gam(Buche ~ s(Eiche, k = k, fx = TRUE), data = train)
    pred <- predict(modell, newdata = test)
    
    # return the rmse and adjR for one model to the list 'iterations'
    return(data.frame(rmse = sqrt(mean((pred - obs)^2)),
                      adjR = summary(modell)$r.sq))
    
  })
  # transform the list with 100 one-row-dataframes to one dataframe with 100 row
  iterations <- do.call("rbind", iterations)
  
  # normalize RMSE
  rmse <- iterations$rmse / max(iterations$rmse)
  
  # return the number of k, the mean rmse and adjR of the 100 cv, and rmse +- its sd 
  # to the list 'results'
  return(data.frame(k = k,
                    m_rmse = mean(rmse),
                    rmse_p_sd = mean(rmse)+sd(rmse),
                    rmse_m_sd = mean(rmse)-sd(rmse),
                    m_adjR = mean(iterations$adjR)))
})
# transform the list with 100 one-row-dataframes to one dataframe with 100 row
results <- do.call("rbind", results)

# show results

plot(results$k, results$m_rmse,
     type = "l",
     ylim = c(0,1),
     xlim = c(3,13),
     xaxt = "n",
     xlab = "Number of k",
     ylab = " ")


axis(1, at = seq(3,13))

lines(results$k, results$rmse_p_sd, col = "blue")
lines(results$k, results$rmse_m_sd, col = "blue")
lines(results$k, results$m_adjR, col = "red")

legend(x = "bottom",
       col = c("red", "black", "blue"),
       legend = c("adjR", "rmse", "rmse +- sd"),
       xpd = TRUE,
       inset = c(0,0),
       bty = "n",
       pch = 16,
       ncol = 3)


