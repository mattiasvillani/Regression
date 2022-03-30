# Analys av bike data

library(regkurs)
?cars # help about the built-in mtcars data

# Minsta-kvadratskattning med lm()-funktionen
lmfit = lm(mpg ~ hp, data = mtcars)

# Sammanfatta regression
regsummary(lmfit)

# Konfidensintervall for regressionslinjen och Prediktionsintervall
predict_mtcars =  predict.lm(lmfit, interval = "confidence")

hp_grid = seq(min(mtcars$hp), max(mtcars$hp), length = 100)
predict_mtcars_conf =  predict.lm(lmfit, newdata = data.frame(hp = hp_grid),
                             interval = "confidence")
predict_mtcars_pred =  predict.lm(lmfit, newdata = data.frame(hp = hp_grid),
                             interval = "prediction")

plot(mtcars$hp, mtcars$mpg, pch = 19, xlab = "hp", ylab = "mpg", cex = 0.7,
     main = "Prediktionsintervall - mtcars",
     ylim = c(min(predict_mtcars_conf,predict_mtcars_pred),
              max(predict_mtcars_conf,predict_mtcars_pred)))
abline(lmfit, col = "red", lw = 2)
lines(hp_grid, predict_mtcars_conf[,2], col = "blue", lw = 2)
lines(hp_grid, predict_mtcars_conf[,3], col = "blue", lw = 2)
lines(hp_grid, predict_mtcars_pred[,2], col = "lightblue", lw = 2)
lines(hp_grid, predict_mtcars_pred[,3], col = "lightblue", lw = 2)

# Multipel regression
?mtcars
lmfit = lm(mpg ~ hp, data = mtcars)
regsummary(lmfit)
res.diagnostics(lmfit)
res.diagnostics(lmfit, regressors = T)


lmfit = lm(mpg ~ hp + wt + am, data = mtcars)
regsummary(lmfit)
res.diagnostics(lmfit)
res.diagnostics(lmfit)
res.diagnostics(lmfit, regressors = T)

