@testset "test fetch_bal_name" begin
    df = problems_df()
    for group ∈ bal_groups
        sort!(df[ ( df.group .== string(group) ), :], [:nequ, :nvar])
        name, group = get_first_name_and_group(df)
        path = fetch_bal_name(name, group)
        @test isdir(path)
        @test isfile(joinpath(path, "$name.txt.bz2"))
    end
end

@testset "test fetch_bal_group" begin
    group = "trafalgar"
    group_paths = fetch_bal_group(group)
    for path ∈ group_paths
        @test isdir(path)
    end
end

@testset "test generate_NLSModel" begin
    df = problems_df()
    sort!(df, [:nequ, :nvar])
    name, group = get_first_name_and_group(df)
    model = BALNLSModel(name, group)
    meta_nls = nls_meta(model)
    @test meta_nls.nvar == 23769
    @test meta_nls.nequ == 63686
end
