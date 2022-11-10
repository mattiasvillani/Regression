# Code for plots of Lecture 4 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Measures
using StatsBase, RCall, Statistics, Distributions
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



# Cykel temp OCH hum

# BIKE SHARE DATA
# Reading bike share data from file    
bikeDay = DataFrame(CSV.File(dataFolder*"cykeluthyr.csv"; header = true))


# Scatter plot nRides vs temp
fit = lm(@formula(nRides ~ temp), bikeDay)
βhat = coef(fit)
p1 = scatter(bikeDay[!,:temp],bikeDay[!,:nRides], xlabel = "temperatur (normaliserad)", 
    ylabel  = "uthyrda cyklar", title = L"\mathrm{uthyrda\ cyklar} = %$(round(βhat[1], digits = 2)) + %$(round(βhat[2], digits = 2)) \cdot \mathrm{temp}", label = nothing)

# Adding regression line to scatter plot nRides vs temp
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3, label = nothing)

# Scatter plot nRides vs hum
fit = lm(@formula(nRides ~ hum), bikeDay)
βhat = coef(fit)
p2 = scatter(bikeDay[!,:hum],bikeDay[!,:nRides], xlabel = "luftfuktighet (normaliserad)", 
    ylabel  = "uthyrda cyklar", title = L"\mathrm{uthyrda\ cyklar} = %$(round(βhat[1], digits = 2)) %$(round(βhat[2], digits = 2)) \cdot \mathrm{luftfuktighet}", label = nothing, color = colors[6])

# Adding regression line to scatter plot nRides vs temp
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3, label = nothing)

plot(size = (1000, 400), p1,p2, layout = (1,2), margin =5mm)

savefig(figFolder*"cykel_rides_vs_temphum_Line.pdf")

fit = lm(@formula(nRides ~ temp + hum ), bikeDay)
βhat = coef(fit)

# F-distribution
gr(legendfontsize = 16)
fGrid = 0.001:0.001:10; 
plot(fGrid,pdf(FDist(3,727), fGrid), label = L"F(3,727)", legend = :topright, xlab = "F", ylab = "Täthet")
savefig(figFolder*"Fdist.pdf")

