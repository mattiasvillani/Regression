# AR och ARMA modeller för svensk inflation
prettycol = RColorBrewer::brewer.pal(12, "Paired")[c(1,2,7,8,3,4,5,6,9,10,11,12)]
library(regkurs)
library(SUdatasets)

# AR(1)
arfit = arima(swedinfl$KPIF, order = c(1,0,0))
arima_coef_summary(arfit)
T = length(swedinfl$KPIF) # Sista tidsperioden i datamaterialet

phi = arfit$coef[1]
mu = arfit$coef[2]

pred1 = mu + phi*(swedinfl$KPIF[T] - mu) # Prediktion för y(T+1)
pred2 = mu + phi*(pred1 - mu) # Prediktion för y(T+2)
pred3 = mu + phi*(pred2 - mu) # Prediktion för y(T+2)
pred4 = mu + phi*(pred3 - mu) # Prediktion för y(T+2)
c(pred1,pred2,pred3,pred4)

# Bättre sätt: använda predict-funktionen för arima i R:
predAR1 = predict(arfit, 4)
predAR1$pred # Samma resultat som vi fick "för hand" ovan.
predAR1$se   # Men vi kan också får standardfel för prediktionen.

# Plotta data, prognosen och prognosintervall
plot(250:T,swedinfl$KPIF[250:T], type = "l", col = prettycol[2], lwd = 3)
lines((T+1):(T+4), predAR1$pred, col = prettycol[4], lwd = 3)
lines((T+1):(T+4), predAR1$pred - 1.96*predAR1$se, col = prettycol[6], lwd = 3)
lines((T+1):(T+4), predAR1$pred + 1.96*predAR1$se, col = prettycol[6], lwd = 3)

# AR(4)
arfit = arima(swedinfl$KPIF, order = c(4,0,0))
arima_coef_summary(arfit)
predAR4 = predict(arfit, 4)
predAR4$pred

# ARMA(2,2)
arfit = arima(swedinfl$KPIF, order = c(2,0,2))
arima_coef_summary(arfit)
predARMA22 = predict(arfit, 4)
predARMA22$pred

