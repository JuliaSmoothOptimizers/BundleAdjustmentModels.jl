using Documenter
using Printf
using BundleAdjustmentModels

# Add index.md file as introduction to navigation menu
pages = ["Introduction" => "index.md", "Reference" => "reference.md"]

makedocs(
  sitename = "BundleAdjustmentModels.jl",
  format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
  modules = [BundleAdjustmentModels],
  pages = pages,
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl",
  push_preview = true,
  devbranch = "main",
)
