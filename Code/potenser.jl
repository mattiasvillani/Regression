using Plots, LaTeXStrings, LinearAlgebra, Measures
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Slides/figs/"
dataFolder = courseFolder*"Data/"
giturl = "https://github.com/mattiasvillani/Regression/"

a = 100
b = 1.05
plot(0:3, a*b.^(0:3), color = colors[2], xlab = "år", ylab = "kapital, kr", label = "", 
    lw = 3, xticks = 0:3, yticks = 100:5:120, title = "Första 3 åren")
savefig(figFolder*"potensbank.pdf")
plot(0:50, a*b.^(0:50), color = colors[2], xlab = "år", ylab = "kapital, kr", label = "", 
    lw = 3, xticks = 0:5:50, yticks = 0:100:1100, title = "Första 50 åren")
savefig(figFolder*"potensbanklong.pdf")