#using BALProblems
include("../src/BALProblems.jl")
using Test

function test_fetch_bal_name()
    problems = [["dubrovnik","problem-16-22106-pre"], ["trafalgar","problem-21-11315-pre"], ["ladybug","problem-49-7776-pre"], ["venice","problem-52-64053-pre"]]
    @test length(problems) == 4
    for problem ∈ problems
        group = problem[1]
        name = problem[2]
        path = fetch_bal_name(name, group)
        @test isdir(path)
        @test isfile(joinpath(path, "$name.txt.bz2"))
    end
end

function test_fetch_bal_group()
    groups = ["dubrovnik", "trafalgar", "ladybug", "venice"]
    for group ∈ groups
        group_paths = fetch_bal_group(group)
        for path ∈ group_paths
            @test isdir(path)
        end
    end
end

function test_generate_bal_name()
    name = "problem-49-7776-pre.txt.bz2"
    group = "ladybug"
    model = generate_NLSModel(name, group)
    meta_nls = nls_meta(model)
    @test meta_nls.nvar == 23769
    @test meta_nls.nequ == 63686
end

test_fetch_bal_name()
test_fetch_bal_group()
test_generate_bal_name()
