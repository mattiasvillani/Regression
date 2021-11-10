# Code for plots of Lecture 6 in Regression and Time Series Analysis course
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

cars = DataFrame(CSV.File(dataFolder*"cars.csv"))
plot()
fit = lm(@formula(mpg ~ hp), cars)
βhat = coef(fit)
Plots.abline!(βhat[2], βhat[1], color = colors[4], lw = 3)
scatter!(cars.hp, cars.mpg, xlab = "horsepower (hp)", ylab = "miles per gallon (mpg)")
annotate!([(200, 25, (L"\mathbf{\mathrm{mpg} = %$(round(βhat[1],digits = 2)) %$(round(βhat[2],digits = 2)) \cdot \mathrm{hp}}", 12, :top, colors[2]))])
savefig(figFolder*"cars_mpg_vs_hp.pdf")