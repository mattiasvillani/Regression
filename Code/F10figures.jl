# Code for plots of Lecture 10 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Dates
using StatsBase, RCall, Statistics, Distributions, LaTeXTabulars #RegressionTables
using StatsBase, HypothesisTests, Lasso
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Slides/figs/"
dataFolder = courseFolder*"Data/"

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=12,
    xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, 
    markersize = 4, markerstrokecolor = :auto, titlefontsize = 14)

gr(legend = :bottomright)


# AR(1) - inflation
# Time series plot - Inflation and repo rate
inflrepo = DataFrame(CSV.File(dataFolder*"InflationReporanta.csv"; header = true))
inflrepo.Datum = Date.(inflrepo.Date,"mm/dd/yyyy")
inflrepo.lag1 = lag(inflrepo.KPIF,1)
inflrepo.lag2 = lag(inflrepo.KPIF,2)
inflrepo.lag3 = lag(inflrepo.KPIF,3)
inflrepo.lag4 = lag(inflrepo.KPIF,4)
inflrepo = inflrepo[5:end,:]

plot(inflrepo.Datum, inflrepo.KPIF, ylabel = L"\mathrm{inflation}_t", legend = :topright,  xlabel = L"\mathrm{month}(t)", label = nothing)
savefig(figFolder*"infl.pdf")


r = round(cor([inflrepo.KPIF inflrepo.lag1])[1,2], digits = 3)
scatter(inflrepo.lag1, inflrepo.KPIF, label = nothing, title = L"r_1 = %$(r)", 
    xlab = "inflation, lag 1", ylab = "inflation")
savefig(figFolder*"inflACFLag1.pdf")

r = round(cor([inflrepo.KPIF inflrepo.lag2])[1,2], digits = 3)
scatter(inflrepo.lag2, inflrepo.KPIF, label = nothing, title = L"r_2 = %$(r)", 
    xlab = "inflation, lag 2", ylab = "inflation")
savefig(figFolder*"inflACFLag2.pdf")

plot(1:10, autocor(inflrepo.KPIF, collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = L"\mathrm{Autokorrelationsfunktionen}, r_k")
savefig(figFolder*"inflACF.pdf")

model = @formula(KPIF ~ lag1);
fit = lm(model, inflrepo);
inflpred = inflrepo.KPIF[end]
nHorizons = 24
preds = zeros(nHorizons)
for h = 1:nHorizons
    testdata = DataFrame(:lag1 => [inflpred])
    inflpred = predict(fit, testdata)[1]
    preds[h] = inflpred
end

datesForecast = zeros(eltype(inflrepo.Datum),nHorizons)
for h = 1:nHorizons
    datesForecast[h] = inflrepo.Datum[end] + Dates.Month(h)
end
plot(inflrepo.Datum[60:end], inflrepo.KPIF[60:end], ylabel = L"\mathrm{inflation}_t", legend = :topright,  xlabel = L"\mathrm{month}(t)", label = "tidsserie")
plot!(datesForecast, preds, color = colors[4], linestyle = :dot, label = "prognos", lw = 3)
savefig(figFolder*"inflpred.pdf")

function SimAR1(T, ??, ?????)
    x = zeros(2*T)
    for t = 2:length(x)
        x[t] = ??*x[t-1] + ?????*randn(1)[1]
    end
    return x[(T+1):end]
end

# Realizations from AR1
?? = 0.8
p1 = plot(SimAR1(100, ??, 1), label = nothing, xlab = L"t", ylab = L"y_t", title = L"\beta = %$(??)")
?? = -0.8
p2 = plot(SimAR1(100, ??, 1), label = nothing, xlab = L"t", ylab = L"y_t", title = L"\beta = %$(??)")
?? = 1.01
p3 = plot(SimAR1(100, ??, 1), label = nothing, xlab = L"t", ylab = L"y_t", title = L"\beta = %$(??)")
?? = 1.05
p4 = plot(SimAR1(100, ??, 1), label = nothing, xlab = L"t", ylab = L"y_t", title = L"\beta = %$(??)")
plot(p1,p2,p3,p4, layout = (2,2))
savefig(figFolder*"simulateAR1.pdf")

?? = 0.8
p1 = plot(1:20,??.^(1:20), label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k", xlab = L"\mathrm{lag,} k", markershape = :circle)
?? = -0.8
p2 = plot(1:20,??.^(1:20), label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k", xlab = L"\mathrm{lag,} k", markershape = :circle)
?? = 0.0
p3 = plot(1:20,??.^(1:20), label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k", xlab = L"\mathrm{lag,} k", markershape = :circle)
?? = 0.95
p4 = plot(1:20,??.^(1:20), label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k", xlab = L"\mathrm{lag,} k", markershape = :circle)
plot(p1,p2,p3,p4, layout = (2,2))
savefig(figFolder*"ACF_theo_AR1.pdf")

?? = 0.8
p1 = plot(1:20,[??;zeros(19)], label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k^\star", xlab = L"\mathrm{lag,} k", markershape = :circle)
?? = -0.8
p2 = plot(1:20,[??;zeros(19)], label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k^\star", xlab = L"\mathrm{lag,} k", markershape = :circle)
?? = 0.0
p3 = plot(1:20,[??;zeros(19)], label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k^\star", xlab = L"\mathrm{lag,} k", markershape = :circle)
?? = 0.95
p4 = plot(1:20,[??;zeros(19)], label = nothing, title = L"\beta = %$(??)", ylab = L"\rho_k^\star", xlab = L"\mathrm{lag,} k", markershape = :circle)
plot(p1,p2,p3,p4, layout = (2,2))
savefig(figFolder*"PACF_theo_AR1.pdf")

????? = 0.7
????? = -0.2
p1 = plot(1:20,[?????/(1-?????);?????;zeros(18)], label = nothing, title = L"\beta_1 = %$(?????)"*" and  "*L"\beta_2 = %$(?????)", ylab = L"\rho_k^\star", xlab = L"\mathrm{lag,} k", markershape = :circle)
savefig(figFolder*"PACF_theo_AR2.pdf")

# bikeshare data
bikeDay = DataFrame(CSV.File(dataFolder*"bikeDayDummy.csv"))
plot(bikeDay.dteday, bikeDay.nRides, xlab = "dag (t)", ylab = "antal uthyrningar", label = nothing)
savefig(figFolder*"cykeltidsserie.pdf")

bikeDay.lag1 = lag(bikeDay.nRides,1);
bikeDay.lag2 = lag(bikeDay.nRides,2);
bikeDay.lag3 = lag(bikeDay.nRides,3);
bikeDay.lag4 = lag(bikeDay.nRides,4);
bikeDay.lag5 = lag(bikeDay.nRides,5);
bikeDay.lag6 = lag(bikeDay.nRides,6);
bikeDay = bikeDay[8:end,:]
bikeDay.time = 1:size(bikeDay,1)

ylimits = (-0.2,1)


r = round(cor([bikeDay.nRides bikeDay.lag1])[1,2], digits = 3)
scatter(bikeDay.lag1, bikeDay.nRides, label = nothing, title = "r = $(r)", 
    xlab = "antal uthyrningar, lag 1", ylab = "antal uthyrningar")
savefig(figFolder*"bikesACFLag1.pdf")

r = round(cor([bikeDay.nRides bikeDay.lag2])[1,2], digits = 3)
scatter(bikeDay.lag1, bikeDay.nRides, label = nothing, title = "r = $(r)", 
    xlab = "antal uthyrningar, lag 2", ylab = "antal uthyrningar")
savefig(figFolder*"bikesACFLag2.pdf")

plot(1:10, autocor(bikeDay.nRides, collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = L"\mathrm{Autokorrelationsfunktionen}, r_k", ylims = ylimits)
savefig(figFolder*"bikeACF.pdf")


# Train test split
bikeDayTrain = bikeDay[bikeDay.dteday .< Date("2012-09-01"),:]
bikeDayTest = bikeDay[bikeDay.dteday .>= Date("2012-09-01"),:]

plot(bikeDayTrain.dteday, bikeDayTrain.nRides, label = "tr??ningsdata", ylab ="antal uthyrningar", xlab = "dag", legend = :topleft)
plot!(bikeDayTest.dteday, bikeDayTest.nRides, label = "testdata", color = colors[4])
savefig(figFolder*"cykeldataTrainTestSplit.pdf")



##### only temp
model = @formula(nRides ~ temp);
fit = lm(model, bikeDay);
plot(residuals(fit), title = "enbart temp", xlab = "dag (t)", 
    ylab = "antal uthyrningar", label = "residualer", legend = :topleft)
savefig(figFolder*"bikeRes_temp.pdf")

plot(1:10, autocor(residuals(fit), collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = "enbart temp", ylims = ylimits)
savefig(figFolder*"bikeACFres_temp.pdf")

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")
X = Matrix([ones(size(bikeDay,1)) bikeDay[!,[:temp]]]);
DW = DurbinWatsonTest(X, residuals(fit))

##### alla kovariater utan laggar
model = @formula(nRides ~ temp + hum + windspeed + holiday + workingday + spring + summer + fall + yr);
fit = lm(model, bikeDay);
plot(residuals(fit), title = "alla f??rklarande - inga laggar", xlab = "dag (t)", 
    ylab = "antal uthyrningar", label = "residualer", legend = :topleft)
savefig(figFolder*"bikeRes_AllNoLags.pdf")

plot(1:10, autocor(residuals(fit), collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = "alla f??rklarande variabler - inga laggar", ylims = ylimits)
savefig(figFolder*"bikeACFres_AllNoLags.pdf")

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")
X = Matrix([ones(size(bikeDay,1)) bikeDay[!,[:temp,:hum,:windspeed,:holiday,:workingday,:spring,:summer,:fall,:yr]]]);
DW = DurbinWatsonTest(X, residuals(fit))


##### only lag1
model = @formula(nRides ~ lag1);
fit = lm(model, bikeDay);
plot(residuals(fit), title = "enbart lag1", xlab = "dag (t)", 
    ylab = "antal uthyrningar", label = "residualer", legend = :topleft)
savefig(figFolder*"bikeRes_lag1.pdf")

plot(1:10, autocor(residuals(fit), collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = "enbart lag1", ylims = ylimits)
savefig(figFolder*"bikeACFres_lag1.pdf")

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")

##### only lag1-2
model = @formula(nRides ~ lag1 + lag2);
fit = lm(model, bikeDay);

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")



##### only lag1-4
model = @formula(nRides ~ lag1 + lag2 + lag3 + lag4);
fit = lm(model, bikeDay);

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")



##### only lag1-6
model = @formula(nRides ~ lag1 + lag2 + lag3 + lag4 + lag5 + lag6);
fit = lm(model, bikeDay);

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")




##### alla kovariater + lag1 
model = @formula(nRides ~ temp + hum + windspeed + holiday + workingday + spring + summer + fall + yr + lag1);
fit = lm(model, bikeDay);

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")


##### alla kovariater + lag1-4
model = @formula(nRides ~ temp + hum + windspeed + holiday + workingday + spring + summer + fall + yr + lag1 +lag2 + lag3 + lag4);
fit = lm(model, bikeDay);

plot(residuals(fit), title = "alla f??rklarande + lag1-4", xlab = "dag (t)", 
    ylab = "antal uthyrningar", label = "residualer", legend = :topleft)
savefig(figFolder*"bikeRes_AllLag14.pdf")

plot(1:10, autocor(residuals(fit), collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = "alla f??rklarande variabler + lag1-4", ylims = ylimits)
savefig(figFolder*"bikeACFres_AllLag14.pdf")

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")



##### alla kovariater + lag1-6
model = @formula(nRides ~ temp + hum + windspeed + holiday + workingday + spring + summer + fall + yr + lag1 +lag2 + lag3 + lag4 +lag5 +lag6);
fit = lm(model, bikeDay);

plot(residuals(fit), title = "alla f??rklarande + lag1-6", xlab = "dag (t)", 
    ylab = "antal uthyrningar", label = "residualer", legend = :topleft)
savefig(figFolder*"bikeRes_AllLag16.pdf")

plot(1:10, autocor(residuals(fit), collect(1:10)), ylab = L"\mathrm{Korr}(y_t,y_{t-k})", 
    xlab = L"\mathrm{lag,} k", label = nothing, linestyle = :solid, markershape = :circle, 
    title = "alla f??rklarande variabler + lag1-6")
savefig(figFolder*"bikeACFres_AllLag16.pdf")

# Training-test split and evaluation of RMSE_test
fitTrain = lm(model, bikeDayTrain);
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- predict(fitTrain, bikeDayTest)).^2 ) );
print(model)
print("R?? = $(r2(fit)))")
print("RMSEtest = $RMSEtest")
print("sum of abs first 10 autocorr: $(sum(abs.(autocor(residuals(fit), collect(1:10)))))")

# Lasso
X = [ones(size(bikeDayTest,1)) bikeDayTest[!,[:temp, :hum, :windspeed, :holiday, :workingday, :spring, :summer, :fall, :yr,  :lag1, :lag2, :lag3, :lag4, :lag5, :lag6]]]
lassoFit = Lasso.fit(LassoModel, model, bikeDayTrain)
??hat = coef(lassoFit)
RMSEtest = sqrt( mean( (bikeDayTest.nRides .- Matrix(X)*??hat).^2 ) );
print("RMSEtest Lasso = $RMSEtest")

