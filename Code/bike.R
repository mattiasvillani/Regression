# Analys av bike data

library(regkurs)
?bike # Hjälp om bike data

# Minsta-kvadratskattning med lm()-funktionen
lmfit = lm(nRides ~ temp + hum + windspeed, data = bike)

# Sammanfatta regression - SAS-style
regsummary(lmfit, conf_intervals = T) # Utskrift med 95%-iga konfidensintervall
confint(lmfit, level = 0.99) # Konfidensintervall med annan täckningsgrad

# Residualanalys
res.diagnostics(lmfit)
res.diagnostics(lmfit, regressors = T)

# Korrelation mellan förklarande variabler
library(Hmisc)
X = as.matrix(bike[,c("temp","hum","windspeed")])
rcorr(X)

# Variance Inflation Factors
regsummary(lmfit, conf_intervals = T, vif_factors = T) # Utskrift VIF

# Dummy variabler
lmfit = lm(nRides ~ temp + holiday, data = bike)
regsummary(lmfit, conf_intervals = T, anova = F)

lmfit = lm(nRides ~ temp + workingday, data = bike)
regsummary(lmfit, conf_intervals = T, anova = F)

lmfit = lm(nRides ~ temp + hum + windspeed + workingday +
             workingday + holiday + yr, data = bike)
regsummary(lmfit, conf_intervals = T)

# Kategoriska variabler som k-1 dummies
bike$spring <- bike$season == 2
bike$summer <- bike$season == 3
bike$fall <- bike$season == 4
lmfit = lm(nRides ~ temp + spring + summer + fall, data = bike)
regsummary(lmfit, conf_intervals = T)

# kategoriska variabler med R's faktorvariabler
lmfit = lm(nRides ~ temp + as.factor(season), data = bike)
regsummary(lmfit, conf_intervals = T)

