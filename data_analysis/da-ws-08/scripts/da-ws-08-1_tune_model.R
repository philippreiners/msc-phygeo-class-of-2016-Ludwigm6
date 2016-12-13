source("d:/university/msc-phygeo-class-of-2016-Ludwigm6/fun/init.R")
path <-  Init("da", "08")

library(mgcv)

wood <- read.csv(paste0(path$da$csv, "hessen_holzeinschlag_1997-2014.csv"), skip = 4, sep = ";")
wood <- wood[-19,]



results <- lapply(seq(3,13), function(k){
  
  iterations <- lapply(seq(100), function(i){
    
    set.seed(i)
    s <- sample(nrow(wood), size = nrow(wood)*0.8)
    train <- wood[s,]
    test <- wood[-s,]
    obs <- test$Eiche
    
    modell <- gam(Buche ~ s(Eiche, k = k, fx = TRUE), data = train)
    pred <- predict(modell, newdata = test)
    
    return(data.frame(rmse = sqrt(mean((pred - obs)^2)),
                      adjR = summary(modell)$r.sq))
    
  })
  iterations <- do.call("rbind", iterations)
  
  return(data.frame(k = k,
                    m_rmse = mean(iterations$rmse),
                    rmse_p_sd = mean(iterations$rmse)+sd(iterations$rmse),
                    rmse_m_sd = mean(iterations$rmse)-sd(iterations$rmse),
                    m_adjR = mean(iterations$adjR)))
})
results <- do.call("rbind", results)


plot(results$k, results$m_adjR, ylim = c(0,1.2))
points(results$m_rmse/max(results$m_rmse), col = "red")
points(results$rmse_p_sd/max(results$rmse_p_sd), col = "blue")
points(results$rmse_m_sd/max(results$rmse_m_sd), col = "blue")


plot(results$k, results$m_rmse, ylim = c(min(results$m_adjR)*1000, max(results$rmse_p_sd)))
lines(results$rmse_p_sd, col = "blue")
lines(results$rmse_m_sd, col = "blue")
lines(results$m_adjR*1000)
