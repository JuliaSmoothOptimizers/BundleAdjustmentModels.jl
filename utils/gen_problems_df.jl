using BundleAdjustmentModels, DataFrames, JLD2

include("../src/BundleAdjustmentProblemsList.jl")

df = DataFrame(name = String[], group = String[], nequ = Int64[], nvar = Int64[], nnzj = Int64[])
for probs_symbol ∈ ba_groups
  problems = eval(probs_symbol)
  group = string(probs_symbol)
  for name in problems
    @info "Problem $name of the group $group."
    model = BundleAdjustmentModel(name)
    push!(df, (model.meta.name, group, model.nls_meta.nequ, model.meta.nvar, model.nls_meta.nnzj))
  end
end

ba_probs_jld2 = joinpath(@__DIR__, "..", "src", "ba_probs_df.jld2")

jldopen(ba_probs_jld2, "w") do file
  file["df"] = df
end
