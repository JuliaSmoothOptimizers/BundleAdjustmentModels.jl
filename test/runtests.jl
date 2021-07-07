#using BALProblems

using Test

function test_fetch()
    matrices = [["dubrovnik","problem-16-22106-pre"], ["trafalgar","problem-21-11315-pre"], ["ladybug","problem-49-7776-pre"], ["venice","problem-52-64053-pre"]]
    @test length(matrices) == 4
    for matrix ∈ matrices
        group = matrix[1]
        name = matrix[2]
        path = fetch_bal(group, name)
        @test isdir(path)
        @test isfile(joinpath(path, "$name.txt.bz2"))
    end
end

test_fetch()