# Code for plots of Lecture 11 in Regression and Time Series Analysis course
# Plot titles and legends in Swedish

using Plots, LaTeXStrings, CSV, DataFrames, GLM, LinearAlgebra, Dates, StatsPlots, Dates
using StatsBase, RCall, Statistics, Distributions, LaTeXTabulars #RegressionTables, StatsBase, Measures
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
plot(x, θ, xlab = L"x", ylab = L"\mathrm{P(y=1 \vert x)}", title = L"\beta = 1 ", label =  nothing)
savefig(figFolder*"LogisticFunc.pdf")

plot(x, θ./(1 .- θ), xlab = L"x", ylab = L"\mathrm{Odds\ }(y=1 \vert x)", c = colors[6], title = L"\beta = 1", label =  nothing)
savefig(figFolder*"OddsFunc.pdf")

plot(x, log.(θ./(1 .- θ)), xlab = L"x", ylab = L"\mathrm{LogOdds\ }(y=1 \vert x)", c = colors[10], title = L"\beta = 1", label =  nothing)
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
savefig(figFolder*"LogisticLogLik.png")


x = range(-4,4, length = 1000)
Xgrid = [ones(1000) x]
θ = exp.(Xgrid*β)./(1 .+ exp.(Xgrid*β))
plot(x, θ, xlab = L"x", ylab = L"\mathrm{P}(y=1 \vert x)", 
    label =  L"P(y=1|x)", legend = :right, legendfontsize = 10)
scatter!(X[:,2],y, c = colors[1], label = "data")
savefig(figFolder*"LogisticFuncWithData.pdf")

jitterish =  0.05*randn(n)
x = range(-4,4, length = 1000)
Xgrid = [ones(1000) x]
θ = exp.(Xgrid*β)./(1 .+ exp.(Xgrid*β))
plot(x, θ, xlab = L"x", ylab = L"\mathrm{P}(y=1 \vert x)", 
    label =  L"P(y=1|x)", legend = :right, legendfontsize = 10)
scatter!(X[:,2], y + jitterish, c = colors[1], label = "data")
savefig(figFolder*"LogisticFuncWithDataJitter.pdf")

gr(legendfontsize = 10)
θ = exp.(Xgrid*β)./(1 .+ exp.(Xgrid*β))
plot(xlab = L"x", ylab = L"\mathrm{P}(y=1 \vert x)", legend = :right, legendfontsize = 6)
scatter!(X[:,2],y + jitterish, label = "data + jitter", color = colors[1])
plot!(x, θ, label = L"\alpha = 1, \beta = 2. \log L = %$(round(ℓ(1,2), digits = 1))", color = colors[2])
plot!(x, exp.(Xgrid*[1,1])./(1 .+ exp.(Xgrid*[1,1])), label = L"\alpha = 1, \beta = 1. \log L = %$(round(ℓ(1,1), digits = 1))", color = colors[4])
plot!(x, exp.(Xgrid*[-3,2])./(1 .+ exp.(Xgrid*[-3,2])), label = L"\alpha = -3, \beta=2. \log L = %$(round(ℓ(1,-1), digits = 1))", color = colors[6])
savefig(figFolder*"LogisticFuncWithDataJitterLike.pdf")

x = 0:0.1:80
X = [ones(length(x)) x]
β = [-0.2091888,-0.0087744]
logisticProb = exp.(X*β)./(1 .+ exp.(X*β))
plot(x, logisticProb, label = nothing, xlabel = "age", ylab = "Sannolikhet för överlevand", lw = 3)
savefig(figFolder*"titanicsimpleProb.pdf")

x = 0:0.1:10
X = [ones(length(x)) x]
β = [-4.9602,1.4887]
logisticProb = exp.(X*β)./(1 .+ exp.(X*β))
plot(0:0.1:10, logisticProb, label = nothing, xlabel = "cellstorlek", ylab = "Sannolikhet för malign cancer", lw = 3)
savefig(figFolder*"breastcancersimpleProb.pdf")


gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=12,
    xtickfontsize=12, ytickfontsize=12, ztickfontsize = 12, xguidefontsize=14, yguidefontsize=14, yscale = :linear,
    markersize = 4, markerstrokecolor = :auto, titlefontsize = 14)
plot(-3:0.01:3, 10 .^ (-3:0.01:3), xlab  =L"x", ylab = L"10^x", title = "Potensfunktionen")
savefig(figFolder*"PotensFunction.pdf")

plot(10 .^ (-3:0.01:3), log10.(10 .^ (-3:0.01:3)), xlab = L"x", ylab = L"\log_{10}(x)", title =  "Logaritmfunktionen med bas 10")
savefig(figFolder*"Log10Function.pdf")

gr(legend = nothing, grid = false, color = colors[2], lw = 2, legendfontsize=12,
    xtickfontsize=12, ytickfontsize=12, ztickfontsize = 12, xguidefontsize=14, yguidefontsize=14, 
    markersize = 4, markerstrokecolor = :auto, titlefontsize = 14)
plot(-3:0.01:3, exp.(-3:0.01:3), xlab  =L"x", ylab = L"\exp(x)", title = "Exponentialfunktionen")
savefig(figFolder*"ExponentialFunction.pdf")

plot(0.01:0.01:3, log.(0.01:0.01:3), xlab  =L"x", ylab = L"\log(x)", title =  "Naturliga logaritmfunktionen")
savefig(figFolder*"LnFunction.pdf")

# Titanic data - odds
age = 0:80
plot(age, 0.30413*13.28098*7.08995*0.97300.^age, label = "kvinna i första klass", xlab = "ålder", ylab = "Odds överleva", title = "Odds att överleva", legend = :topright)
plot!(age, 0.30413*13.28098*0.97300.^age, label = "kvinna ej i första klass", xlab = "ålder", ylab = "Odds överleva", color = colors[8])
plot!(age, 0.30413*7.08995*0.97300.^age, label = "man i första klass", xlab = "ålder", ylab = "Odds överleva", color = colors[4])
plot!(age, 0.30413*0.97300.^age, label = "man ej i första klass", xlab = "ålder", ylab = "Odds överleva", color = colors[6])
savefig(figFolder*"titanicOdds.pdf")

# Titanic data - probs
age = 0:80
odds = 0.30413*13.28098*7.08995*0.97300.^age
plot(age, odds./(1 .+ odds), label = "kvinna i första klass", ylims = [0,1], xlab = "ålder", ylab = "Sannolikhet att överleva", title = "Sannolikhet att överleva", legend = :right)
odds = 0.30413*13.28098*0.97300.^age
plot!(age, odds./(1 .+ odds), label = "kvinna ej i första klass", xlab = "ålder", ylab = "Odds överleva", color = colors[8])
odds = 0.30413*7.08995*0.97300.^age
plot!(age, odds./(1 .+ odds), label = "man i första klass", xlab = "ålder", ylab = "Odds överleva", color = colors[4])
odds = 0.30413*0.97300.^age
plot!(age, odds./(1 .+ odds), label = "man ej i första klass", xlab = "ålder", ylab = "Odds överleva", color = colors[6])
savefig(figFolder*"titanicProbs.pdf")
