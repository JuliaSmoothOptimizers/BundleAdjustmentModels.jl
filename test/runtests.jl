#using BALProblems

using Test

function test_fetch()
    problems = [["dubrovnik","problem-16-22106-pre"], ["trafalgar","problem-21-11315-pre"], ["ladybug","problem-49-7776-pre"], ["venice","problem-52-64053-pre"]]
    @test length(problems) == 4
    for problem ∈ problems
        group = problem[1]
        name = problem[2]
        path = fetch_bal(group, name)
        println(path)
        @test isdir(path)
        @test isfile(joinpath(path, "$name.txt.bz2"))
    end
end

test_fetch()