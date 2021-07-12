function testBALNLSFunctions()
    @testset "test fetch_bal_name" begin
        problems = [["dubrovnik","problem-16-22106-pre"], ["trafalgar","problem-21-11315-pre"], ["ladybug","problem-49-7776-pre"], ["venice","problem-52-64053-pre"]]
        for problem ∈ problems
            group = problem[1]
            name = problem[2]
            path = fetch_bal_name(name, group)
            @test isdir(path)
            @test isfile(joinpath(path, "$name.txt.bz2"))
        end
    end

    @testset "test fetch_bal_group" begin
        groups = ["dubrovnik", "trafalgar", "ladybug", "venice"]
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
        model = generate_NLSModel(name, group)
        meta_nls = nls_meta(model)
        @test meta_nls.nvar == 23769
        @test meta_nls.nequ == 63686
    end
end

testBALNLSFunctions()