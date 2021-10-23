using Plots, LaTeXStrings, CSV, DataFrames
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Figs/"
dataFolder = courseFolder*"Data/"
giturl = "https://github.com/mattiasvillani/Regression/"

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=12,
    xtickfontsize=14, ytickfontsize=14, xguidefontsize=14, yguidefontsize=14, markersize = 2)


# Reading bike share data from file    
bikeDay = DataFrame(CSV.File(dataFolder*"cykeluthyr.csv"; header = true))
