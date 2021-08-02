using Base: Float32
using BundleAdjustmentProblems, DataFrames, JLD2

include("../src/BALProblemsList.jl")

df = DataFrame(name = String[], group = String[], nequ = Int64[], nvar = Int64[], nnzj = Int64[])
for probs_symbol ∈ bal_groups
  problems = eval(probs_symbol)
  group = string(probs_symbol)
  for name in problems
    model = BundleAdjustmentModel(name, group, T = Float32)
    push!(df, (model.meta.name, group, model.nls_meta.nequ, model.meta.nvar, model.nls_meta.nnzj))
  end
end

balprobs_jld2 = joinpath(@__DIR__, "..", "src", "bal_probs_df.jld2")

jldopen(balprobs_jld2, "w") do file
  file["df"] = df
end
