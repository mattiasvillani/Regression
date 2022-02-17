# SAS-like summary of regression
# Author: Mattias Villani
lmsummary <- function(lmobject, vif_factors = F, anova = T, conf_intervals = F){
  
  lmsummary = summary(lmobject)
  df_regr = lmsummary$df[1] - 1
  df_error = lmsummary$df[2]
  df_total = df_error + df_regr 
  sse = (lmsummary$sigma^2)*df_error
  sst = var(lmobject$model[,1])*df_total
  ssr = sst - sse
  
  # Anova table
  anova_table = NA
  if (anova){
    anova_table = matrix(rep(NA,5*3),3,5)
    anova_table[,1] = c(df_regr,df_error,df_total)
    anova_table[,2] = c(ssr,sse,sst)
    anova_table[1:2,3] = c(ssr/df_regr, sse/df_error)
    anova_table[1,4] = lmsummary$fstatistic[1]
    anova_table[1,5] = pf(lmsummary$fstatistic[1], lmsummary$fstatistic[2], lmsummary$fstatistic[3], lower.tail = F)
    rownames(anova_table) <- c("Regr","Error","Total")
    colnames(anova_table) <- c("df","SS","MS","F","Pr(>F)")
  }
  
  rsqr_row = c(sqrt(sse/df_error), lmsummary$r.squared, lmsummary$adj.r.squared)
  names(reg_tables$rsqr_row) <- c("Root MSE","R2","R2-adj")
  
  # Confidence intervals on parameters
  if (conf_intervals){
    param_table = cbind(lmsummary$coefficients, confint(lmobject))
  }else
  {
    param_table = lmsummary$coefficients
  }
  
  # Variance inflation factors
  if (vif_factors){
    X = lmobject$model[,2:(df_regr+1)]
    vif = rep(NA,df_regr)
    for (j in 1:df_regr){
      vif[j] = 1/summary(lm(X[,j] ~ data.matrix(X[,-j])))$r.squared
    }
    param_table = cbind(param_table,c(NA,vif))
    colnames(param_table)[ncol(param_table)] = "VIF"
  }
  
  message("\nAnalysis of variance - ANOVA\n------------------------------------------------")
  print(reg_tables$anova_table, digits = 5, na.print = "")
  message("\n")
  print(reg_tables$rsqr_row, digits = 5)
  message("\n")
  message("Parameter estimates\n------------------------------------------------")
  print(reg_tables$param_table, digits = 5, na.print = "")
  
  return(list(param_table = param_table, rsqr_row = rsqr_row, anova_table = anova_table))
  
}

# Load bike share data to replicate SAS-output on Slide nr 8 here: https://github.com/mattiasvillani/Regression/raw/master/Slides/Regression_L4.pdf
bike = read.csv(file = "https://raw.githubusercontent.com/mattiasvillani/Regression/master/Data/cykeluthyr.csv")
lmfit = lm(nRides ~ temp + hum + windspeed, data = bike)
reg_tables = lmsummary(lmfit, vif_factors = T, anova = T, conf_intervals = T)


