# dm-ws-07-1
# MOC - Data Analysis (T. Nauss, C. Reudenbach)
# Multiple linear regression, forward feature selection
# Forward feature selection function -------------------------------------------
forward_feature_selection <- function(data, dep, vars, selected_vars = NULL){
  
  fwd_fs <- lapply(seq(length(vars)), function(v){
    if(is.null(selected_vars)){
      formula <- paste(dep, " ~ ", paste(vars[v], collapse=" + "))
    } else {
      formula <- paste(dep, " ~ ", paste(c(selected_vars, vars[v]), collapse=" + "))
    }
    
    lmod <- lm(formula, data = data)
    results <- data.frame(Variable = vars[v],
                          Adj_R_sqrd = round(summary(lmod)$adj.r.squared, 4),
                          AIC = round(AIC(lmod), 4))
    return(results)
  })
  fwd_fs <- do.call("rbind", fwd_fs)
  
  if(!is.null(selected_vars)){
    formula <- paste(dep, " ~ ", paste(selected_vars, collapse=" + "))
    lmod <- lm(formula, data = data)
    results_selected <- data.frame(Variable = paste0("all: ", 
                                                     paste(selected_vars, 
                                                           collapse=", ")),
                                   Adj_R_sqrd = round(summary(lmod)$adj.r.squared, 4),
                                   AIC = round(AIC(lmod), 4))
  } else {
    results_selected <- data.frame(Variable = paste0("all: ", 
                                                     paste(selected_vars, 
                                                           collapse=", ")),
                                   Adj_R_sqrd = 0,
                                   AIC = 1E10)
  }
  
  # best_var <- as.character(fwd_fs$Variable[which(fwd_fs$AIC == min(fwd_fs$AIC))])
  # min_AIC <- min(fwd_fs$AIC)
  # fwd_fs <- rbind(results_selected, fwd_fs)
  # return(list(best_var, min_AIC, fwd_fs))
  
  best_var <- as.character(fwd_fs$Variable[which(fwd_fs$Adj_R_sqrd == max(fwd_fs$Adj_R_sqrd))])
  max_adj_r_sqrd <- max(fwd_fs$Adj_R_sqrd)
  fwd_fs <- rbind(results_selected, fwd_fs)
  return(list(best_var, max_adj_r_sqrd, fwd_fs))
}