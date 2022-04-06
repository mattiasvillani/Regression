using Plots, Distributions
using LaTeXStrings, Measures
using ColorSchemes
import ColorSchemes: Paired_12; colors = Paired_12

Plots.reset_defaults()
gr(legend = nothing, grid = false, color = colors[2], lw = 4,
    xtickfontsize=14, ytickfontsize=14, xguidefontsize=20, yguidefontsize=20,
    legendfontsize=14, titlefontsize = 24)
figFolder = "/home/mv/Dropbox/Teaching/Regression/Misc/"

ν₁ = 5
ν₂ = 30
Fcrit = quantile(FDist(ν₁, ν₂), 0.95)
xGrid = 0.0:0.01:6
xGridFill = Fcrit:0.01:maximum(xGrid)
plot(xGridFill, pdf.(FDist(ν₁, ν₂), xGridFill), fill = (0, 0.5, colors[9]),
    title = "Under "*L"H_0:"*L"F \sim F(k,n-k-1)", 
    background_color = RGB(245/255,245/255,245/255),
    c = colors[10], lw = 3, xlab = L"F", yaxis = false, yticks = [], margin = 3mm)
plot!(xGrid, pdf.(FDist(ν₁, ν₂), xGrid), c = colors[10], lw = 3)
annotate!(Fcrit-0.25, 2.5*pdf(FDist(ν₁, ν₂), Fcrit), L"F_{\mathrm{crit}}")
plot!([Fcrit-0.25, Fcrit], [1.8*pdf(FDist(ν₁, ν₂),Fcrit),0], arrow=true, 
    color=:black, linewidth=1, label="")
plot!([Fcrit+1.3,Fcrit+0.5],[2*pdf(FDist(ν₁, ν₂),Fcrit),0.01], arrow=true, 
    color=:black, linewidth=1, label="")
annotate!(Fcrit+1.3, 2.5*pdf(FDist(ν₁, ν₂),Fcrit),L"\alpha = 0.05")
savefig(figFolder*"Fdist.svg")
