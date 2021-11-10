# Code for plots of Lecture 5 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Measures
using StatsBase, RCall, Statistics, Distributions
using Flux: onehot, onehotbatch
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Slides/figs/"
dataFolder = courseFolder*"Data/"
giturl = "https://github.com/mattiasvillani/Regression/"

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=10,
    xtickfontsize=12, ytickfontsize=12, xguidefontsize=12, yguidefontsize=12, 
    markersize = 4, markerstrokecolor = :auto)


# Med USA
healthdata = DataFrame(CSV.File(dataFolder*"healthdata.csv"; header = true))
fit = lm(@formula(lifespan ~ spending), healthdata)
βhat = coef(fit)

p1 = scatter(healthdata.spending, residuals(fit), xlab = "Hälsobudget", ylab = "Residualer (år)", c = colors[2], label = nothing, legend = :bottomright, title = "Residualer vs hälsobudget")

p2 = histogram(residuals(fit), bins = 10, normalize = :pdf, xlab = "Hälsobudget", yticks = nothing, c = colors[2], label = "histogram", linecolor = :white, title = "Histogram residualer", legend = :topleft)
#density!(p2, residuals(fit), color = colors[4])
xGrid = xlims(p2)[1]:0.01:xlims(p2)[2]
plot!(xGrid, pdf(Normal(mean(residuals(fit)), std(residuals(fit))), xGrid), 
    color = colors[4], label = "Normal fit")

p3 = qqplot(Normal, residuals(fit), title = "QQ-plot")

plot(size = (1200,400), p1, p2, p3, layout = (1,3), margin = 7mm)
savefig(figFolder*"healthresiduals.pdf")


# Utan USA
healthdataNoUS = healthdata[Not(30),:]
fitNoUS = lm(@formula(lifespan ~ spending), healthdataNoUS)
βhatNoUS = coef(fitNoUS)

p1 = scatter(healthdataNoUS.spending, residuals(fitNoUS), xlab = "Hälsobudget", ylab = "Residualer (år)", c = colors[2], label = nothing, legend = :bottomright, title = "Residualer vs hälsobudget")

p2 = histogram(residuals(fitNoUS), bins = 10, normalize = :pdf, xlab = "Hälsobudget", yticks = nothing, c = colors[2], label = "histogram", linecolor = :white, title = "Histogram residualer", legend = :topleft)
xGrid = xlims(p2)[1]:0.01:xlims(p2)[2]
plot!(xGrid, pdf(Normal(mean(residuals(fitNoUS)), std(residuals(fitNoUS))), xGrid), 
    color = colors[4], label = "Normal fit")

p3 = qqplot(Normal, residuals(fitNoUS), title = "QQ-plot")

plot(size = (1200,400), p1, p2, p3, layout = (1,3), margin = 7mm)
savefig(figFolder*"healthresidualsNoUS.pdf")




# BIKE SHARE DATA
# Reading bike share data from file    
bikeDay = DataFrame(CSV.File(dataFolder*"cykeluthyr.csv"; header = true))
fit = lm(@formula(nRides ~ temp + hum + windspeed), bikeDay)
βhat = coef(fit)

p1 = scatter(bikeDay.temp, residuals(fit), xlab = "temperatur", ylab = "Residualer", 
    c = colors[2], label = nothing, legend = :bottomright, title = "temperatur")    
    
p2 = scatter(bikeDay.hum, residuals(fit), xlab = "luftfuktighet", ylab = "Residualer", 
    c = colors[4], label = nothing, legend = :bottomright, title = "luftfuktighet")

p3 = scatter(bikeDay.windspeed, residuals(fit), xlab = "vindhastighet", ylab = "Residualer",  c = colors[6], label = nothing, legend = :bottomright, title = "vindhastighet")

plot(size = (1200,400), p1, p2, p3, layout = (1,3), margin = 7mm)
savefig(figFolder*"cykelresidualer.pdf")

p1 = histogram(residuals(fit), bins = 10, normalize = :pdf, xlab = "residualer", yticks = nothing, c = colors[2], label = "histogram", linecolor = :white, legend = :topleft)
xGrid = xlims(p2)[1]:0.01:xlims(p2)[2]
plot!(xGrid, pdf(Normal(mean(residuals(fit)), std(residuals(fit))), xGrid), 
    color = colors[4], label = "Normal fit")

p2 = qqplot(Normal, residuals(fit), title = "QQ-plot")

plot(size = (1200,400), p1, p2, layout = (1,2), margin = 7mm)
savefig(figFolder*"cykelresidualerhistQQ.pdf")

# VIF
fit = lm(@formula(temp ~ hum + windspeed), bikeDay)
r2reg = r2(fit)
VIF = 1/(1-r2reg)
fit = lm(@formula(hum ~  temp + windspeed), bikeDay)
r2reg = r2(fit)
VIF = 1/(1-r2reg)
fit = lm(@formula(windspeed ~ temp + hum), bikeDay)
r2reg = r2(fit)
VIF = 1/(1-r2reg)

# Using atemp along with temp
bikeFull = DataFrame(CSV.File("/home/mv/Dropbox/BayesBook/Data/bikeShare/bikesday.csv"))
# VIF
fit = lm(@formula(atemp ~ temp + hum + windspeed), bikeFull)
r2reg = r2(fit)
VIF = 1/(1-r2reg)
fit = lm(@formula(temp ~  atemp + hum + windspeed), bikeFull)
r2reg = r2(fit)
VIF = 1/(1-r2reg)
fit = lm(@formula(hum ~  temp + atemp + windspeed), bikeFull)
r2reg = r2(fit)
VIF = 1/(1-r2reg)
fit = lm(@formula(windspeed ~  temp + atemp + hum), bikeFull)
r2reg = r2(fit)
VIF = 1/(1-r2reg)

# Dummy variables - holiday
scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "antal uthyrningar", color = :lightgray, titlefontsize=14, xticks = 0:0.1:1, legend = :topleft, label = nothing)
fit = lm(@formula(nRides ~ temp + holiday), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[8], lw = 3, label = "holiday = 0")
Plots.abline!(βhat[2], βhat[1] + βhat[3], color = colors[2], lw = 3, label = "holiday = 1")
annotate!([(0.2, 3500, (L"\mathbf{y = %$(round(βhat[1],digits = 2)) + %$(round(βhat[2], digits =  2)) \cdot x}", 10, :bottom, colors[8]))])
annotate!([(0.43, 2000, (L"\mathbf{y = %$(round(βhat[1]+βhat[3],digits = 2)) + %$(round(βhat[2], digits =  2)) \cdot x}", 10, :bottom, colors[2]))])
#annotate!([(0.1, 2000, (L"\Bigg\(", 10, :bottom, colors[10]))])
savefig(figFolder*"cykelHolidayDummy.pdf")

# Dummy variables - holiday
scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "antal uthyrningar", color = :lightgray, titlefontsize=14, xticks = 0:0.1:1, legend = :topleft, label = nothing)
fit = lm(@formula(nRides ~ temp + workingday), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[8], lw = 3, label = "workingday = 0")
Plots.abline!(βhat[2], βhat[1] + βhat[3], color = colors[2], lw = 3, label = "workingday = 1")
annotate!([(0.2, 3500, (L"\mathbf{y = %$(round(βhat[1],digits = 2)) + %$(round(βhat[2], digits =  2)) \cdot x}", 10, :bottom, colors[8]))])
annotate!([(0.35, 2000, (L"\mathbf{y = %$(round(βhat[1]+βhat[3],digits = 2)) + %$(round(βhat[2], digits =  2)) \cdot x}", 10, :bottom, colors[2]))])
savefig(figFolder*"cykelWorkingdayDummy.pdf")


# Dummy variables - holiday

scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "antal uthyrningar", color = :lightgray, titlefontsize=14, xticks = 0:0.1:1, legend = :topleft, label = nothing)
fit = lm(@formula(nRides ~ temp + spring + summer + fall), bikeDay)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[1], lw = 3, label = "vinter")
Plots.abline!(βhat[2], βhat[1]+βhat[3], color = colors[5], lw = 3, label = "vår")
Plots.abline!(βhat[2], βhat[1]+βhat[4], color = colors[4], lw = 3, label = "sommar")
Plots.abline!(βhat[2], βhat[1]+βhat[5], color = colors[12], lw = 3, label = "höst")
savefig(figFolder*"cykelseason.pdf")



# adding seasondummies

# Create binary dummy variables for categorical covariates (one-hot encoding)
Z = onehotbatch(bikeDay[!,:season], [:1, :2, :3, :4])'
for k ∈ 2:size(Z,2)
	bikeDay[!,Symbol("season",k)] = Z[:,k]
end
Z = onehotbatch(bikeDay[!,:weather], [:1, :2, :3])'
for k ∈ 2:size(Z,2)
	bikeDay[!,Symbol("weather",k)] = Z[:,k]
end
Z = onehotbatch(bikeDay[!,:weekday], [:0, :1, :2, :3, :4, :5, :6])'
for k ∈ 1:6
	bikeDay[!,Symbol("weekday",k)] = Z[:,k+1]
end

rename!(bikeDay, :season2=>:spring, :season3=>:summer, :season4=>:fall)


CSV.write(dataFolder*"bikeDayDummy.csv", bikeDay)


fit = lm(@formula(nRides ~ temp + hum + windspeed), bikeDay)
R2_R = r2(fit)

fit = lm(@formula(nRides ~ temp + hum + windspeed + spring + summer + fall), bikeDay)
R2_UR = r2(fit)