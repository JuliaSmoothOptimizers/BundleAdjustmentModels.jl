using Base: Float32
using BALNLSModels, DataFrames, CSV

df = DataFrame(name = String[], group = String[], nequ = Int64[], nvar = Int64[])
for (problems, group) ∈ total_prob
    for name in problems
        model = BALNLSModel(name, group, T=Float32)
        push!(df, (model.meta.name, group, model.nls_meta.nequ, model.meta.nvar))
    end
end

CSV.write(joinpath(@__DIR__, "..", "src", "problems_df.csv", df)
        