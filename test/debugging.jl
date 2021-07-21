using BALNLSModels, DataFrames

include("../src/BALProblemsList.jl")

df = problems_df()
for group ∈ bal_groups
    filter_df = sort!(df[ ( df.group .== string(group) ), :], [:nequ, :nvar])
    name, group = get_first_name_and_group(filter_df)
    path = fetch_bal_name(name, group)
    println(path)
end