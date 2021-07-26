delete_all_balartifacts!()

@testset "test fetch_bal_name" begin
    df = problems_df()
    for group ∈ bal_groups
        filter_df = sort!(df[ ( df.group .== string(group) ), :], [:nequ, :nvar])
        name, group = get_first_name_and_group(filter_df)
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

@testset "tests BALNLSModel" begin
    df = problems_df()
    sort!(df, [:nequ, :nvar])
    name, group = get_first_name_and_group(df)
    model = BALNLSModel(name, group)
    meta_nls = nls_meta(model)
    @test meta_nls.nvar == 23769
    @test meta_nls.nequ == 63686

    path = fetch_bal_name(name, group)
    filename = joinpath(path, "$name.txt.bz2")
    model = BALNLSModel(filename)
    @test meta_nls.nvar == 23769
    @test meta_nls.nequ == 63686
end

@testset "test delete_balartifact!()" begin
    df = problems_df()
    sort!(df, [:nequ, :nvar])
    name, group = get_first_name_and_group(df)
    path = fetch_bal_name(name, group)
    @test isdir(path)
    @test isfile(joinpath(path, "$name.txt.bz2"))
    delete_balartifact!(name, group)
    @test !isdir(path)
    @test !isfile(joinpath(path, "$name.txt.bz2"))
end

@testset "delete_all_balartifacts!()" begin
    group = "trafalgar"
    group_paths = fetch_bal_group(group)
    delete_all_balartifacts!()
    for path ∈ group_paths
        @test !isdir(path)
    end
end