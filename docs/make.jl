using Documenter
using Printf
using BALNLSModels

# Add index.md file as introduction to navigation menu
pages = ["Introduction" => "index.md", "Reference" => "reference.md"]

makedocs(
  sitename = "BALNLSModels",
  format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
  modules = [BALNLSModels],
  pages = pages,
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/BALNLSModels",
  push_preview = true,
  devbranch = "main",
)
