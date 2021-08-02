using Documenter
using Printf
using BundleAdjustmentProblems

# Add index.md file as introduction to navigation menu
pages = ["Introduction" => "index.md", "Reference" => "reference.md"]

makedocs(
  sitename = "BundleAdjustmentProblems",
  format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
  modules = [BundleAdjustmentProblems],
  pages = pages,
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/BundleAdjustmentProblems",
  push_preview = true,
  devbranch = "main",
)
