# Code for plots of Lecture 11 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Dates
using StatsBase, RCall, Statistics, Distributions, LaTeXTabulars, RegressionTables, StatsBase, Measures
import ColorSchemes: Paired_12; colors = Paired_12
colors = Paired_12[[1,2,7,8,3,4,5,6,9,10,11,12]]
courseFolder = "/home/mv/Dropbox/Teaching/Regression/"
figFolder = courseFolder*"Slides/figs/"
dataFolder = courseFolder*"Data/"

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=12,
    xtickfontsize=12, ytickfontsize=12, ztickfontsize = 12, xguidefontsize=12, yguidefontsize=12, 
    markersize = 4, markerstrokecolor = :auto, titlefontsize = 14)

gr(legend = :bottomright)

# Logistic Regression
β = 1
x = -5:0.01:5
θ = exp.(x*β)./(1 .+ exp.(x*β))
plot(x, θ, xlab = L"x", ylab = L"\mathrm{P(y=1 \vert x)}", title = L"\mathrm{Sannolikhet\  for\ } y = 1", label =  nothing)
savefig(figFolder*"LogisticFunc.pdf")

plot(x, θ./(1 .- θ), xlab = L"x", ylab = L"\mathrm{Odds\ }(y=1 \vert x)", c = colors[6], title = "Odds", label =  nothing)
savefig(figFolder*"OddsFunc.pdf")

plot(x, log.(θ./(1 .- θ)), xlab = L"x", ylab = L"\mathrm{LogOdds\ }(y=1 \vert x)", c = colors[10], title = "LogOdds", label =  nothing)
savefig(figFolder*"LogOddsFunc.pdf")

""" 
    p(x,β) 

Pr(y=1|x) logistic regression 

# Examples, ylab = L"\beta", xlab = L"\alpha"
```
""" 
p(x,β) = exp.(x⋅β)/(1 .+ exp.(x⋅β))


""" 
    ℓ_logistic(β, X, y) 

Log-likelihood for logistic regression
""" 
function ℓ_logistic(β, X, y) 
    θs = [p(X[i,:], β) for i in 1:n]
    sum(y.*log.(θs) + (1 .- y).*log.(1 .- θs))
end



n = 200
β = [1,2]
X = [ones(n) randn(n)]
y = zeros(Int, n)
for i = 1:n
    y[i] = rand(Bernoulli(p(X[i,:],β)))
end

β₀grid = -1:0.01:4
β₁grid = -1:0.01:4
ℓ(β₀,β₁) = ℓ_logistic([β₀,β₁], X, y)
p1 = plot(β₀grid, β₁grid, ℓ, st=:surface, opacity = 0.8, c = :viridis, title = "log-likelihood - ytplot", colorbar = false, ylab = L"\beta", xlab = L"\alpha", zlab = L"\ell(\alpha,\beta)", label = nothing)
p2 = heatmap(β₀grid, β₁grid, ℓ, c = :viridis, colorbar = true,  title = "log-likelihood - konturplot", ylab = L"\beta", xlab = L"\alpha", legend = nothing)
plot!(β₀grid, β₁grid, ℓ, st = :contour, linecolor = :black, lw = 0.5)
scatter!([β[1]],[β[2]], label = "population", color = colors[8])
plot(size = (1000,400), p1, p2, layout = (1,2), margin = 5mm)
savefig(figFolder*"LogisticLogLik.pdf")



Xgrid = [ones(1000) range(-4,4, length = 1000)]
θ = exp.(Xgrid*β)./(1 .+ exp.(Xgrid*β))
plot(x, θ, xlab = L"x", ylab = L"\mathrm{P}(y=1 \vert x)", title = L"\mathrm{Sannolikhet\  for\ } y = 1", label =  L"P(y=1|x)", legend = :bottomright, legendfontsize = 10)
scatter!(X[:,2],y, c = colors[1], label = "data")
savefig(figFolder*"LogisticFuncWithData.pdf")


Xgrid = [ones(1000) range(-4,4, length = 1000)]
θ = exp.(Xgrid*β)./(1 .+ exp.(Xgrid*β))
plot(xlab = L"x", ylab = L"\mathrm{P}(y=1 \vert x)", legend = :right, legendfontsize = 8)
scatter!(X[:,2],y + 0.05*randn(n), label = "data + jitter", color = colors[1])
plot!(x, θ, label = L"\alpha = 1, \beta = 2. \ell = %$(round(ℓ(1,2), digits = 1))", color = colors[2])
plot!(x, exp.(Xgrid*[1,1])./(1 .+ exp.(Xgrid*[1,1])), label = L"\alpha = 1, \beta = 1. \ell = %$(round(ℓ(1,1), digits = 1))", color = colors[4])
plot!(x, exp.(Xgrid*[-3,2])./(1 .+ exp.(Xgrid*[-3,2])), label = L"\alpha = -3, \beta=2. \ell = %$(round(ℓ(1,-1), digits = 1))", color = colors[6])
savefig(figFolder*"LogisticFuncWithDataJitter.pdf")

