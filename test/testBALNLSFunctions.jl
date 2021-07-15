@testset "test fetch_bal_name" begin
    problems = [["dubrovnik","problem-16-22106-pre"], ["trafalgar","problem-21-11315-pre"], ["ladybug","problem-49-7776-pre"], ["venice","problem-52-64053-pre"]]
    for (group, name) ∈ problems
        path = fetch_bal_name(name, group)
        @test isdir(path)
        @test isfile(joinpath(path, "$name.txt.bz2"))
    end
end

# Change this test to very_small group
@testset "test fetch_bal_group" begin
    groups = ["trafalgar"]
    for group ∈ groups
        group_paths = fetch_bal_group(group)
        for path ∈ group_paths
            @test isdir(path)
        end
    end
end

@testset "test generate_NLSModel" begin
    name = "problem-49-7776-pre.txt.bz2"
    group = "ladybug"
    model = BALNLSModel(name, group)
    meta_nls = nls_meta(model)
    @test meta_nls.nvar == 23769
    @test meta_nls.nequ == 63686
end
