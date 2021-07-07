
using ArtifactUtils

dubrovnik_prob = ["dubrovnik/problem-16-22106-pre.txt.bz2", 
                  "dubrovnik/problem-88-64298-pre.txt.bz2", 
                  "dubrovnik/problem-135-90642-pre.txt.bz2", 
                  "dubrovnik/problem-142-93602-pre.txt.bz2", 
                  "dubrovnik/problem-150-95821-pre.txt.bz2", 
                  "dubrovnik/problem-161-103832-pre.txt.bz2", 
                  "dubrovnik/problem-173-111908-pre.txt.bz2", 
                  "dubrovnik/problem-182-116770-pre.txt.bz2", 
                  "dubrovnik/problem-202-132796-pre.txt.bz2", 
                  "dubrovnik/problem-237-154414-pre.txt.bz2", 
                  "dubrovnik/problem-253-163691-pre.txt.bz2", 
                  "dubrovnik/problem-262-169354-pre.txt.bz2", 
                  "dubrovnik/problem-273-176305-pre.txt.bz2", 
                  "dubrovnik/problem-287-182023-pre.txt.bz2", 
                  "dubrovnik/problem-308-195089-pre.txt.bz2", 
                  "dubrovnik/problem-356-226730-pre.txt.bz2"]


trafalgar_prob = ["trafalgar/problem-21-11315-pre.txt.bz2", 
                  "trafalgar/problem-39-18060-pre.txt.bz2", 
                  "trafalgar/problem-50-20431-pre.txt.bz2", 
                  "trafalgar/problem-126-40037-pre.txt.bz2", 
                  "trafalgar/problem-138-44033-pre.txt.bz2", 
                  "trafalgar/problem-161-48126-pre.txt.bz2", 
                  "trafalgar/problem-170-49267-pre.txt.bz2", 
                  "trafalgar/problem-174-50489-pre.txt.bz2", 
                  "trafalgar/problem-193-53101-pre.txt.bz2", 
                  "trafalgar/problem-201-54427-pre.txt.bz2", 
                  "trafalgar/problem-206-54562-pre.txt.bz2", 
                  "trafalgar/problem-215-55910-pre.txt.bz2", 
                  "trafalgar/problem-225-57665-pre.txt.bz2",
                  "trafalgar/problem-257-65132-pre.txt.bz2"]

ladybug_prob = ["ladybug/problem-49-7776-pre.txt.bz2", 
                "ladybug/problem-73-11032-pre.txt.bz2", 
                "ladybug/problem-138-19878-pre.txt.bz2", 
                "ladybug/problem-318-41628-pre.txt.bz2", 
                "ladybug/problem-372-47423-pre.txt.bz2", 
                "ladybug/problem-412-52215-pre.txt.bz2", 
                "ladybug/problem-460-56811-pre.txt.bz2", 
                "ladybug/problem-539-65220-pre.txt.bz2", 
                "ladybug/problem-598-69218-pre.txt.bz2", 
                "ladybug/problem-646-73584-pre.txt.bz2", 
                "ladybug/problem-707-78455-pre.txt.bz2", 
                "ladybug/problem-783-84444-pre.txt.bz2", 
                "ladybug/problem-810-88814-pre.txt.bz2", 
                "ladybug/problem-856-93344-pre.txt.bz2",
                "ladybug/problem-885-97473-pre.txt.bz2", 
                "ladybug/problem-931-102699-pre.txt.bz2", 
                "ladybug/problem-969-105826-pre.txt.bz2", 
                "ladybug/problem-1031-110968-pre.txt.bz2", 
                "ladybug/problem-1064-113655-pre.txt.bz2", 
                "ladybug/problem-1118-118384-pre.txt.bz2", 
                "ladybug/problem-1152-122269-pre.txt.bz2", 
                "ladybug/problem-1197-126327-pre.txt.bz2", 
                "ladybug/problem-1235-129634-pre.txt.bz2", 
                "ladybug/problem-1266-132593-pre.txt.bz2", 
                "ladybug/problem-1340-137079-pre.txt.bz2", 
                "ladybug/problem-1469-145199-pre.txt.bz2", 
                "ladybug/problem-1514-147317-pre.txt.bz2", 
                "ladybug/problem-1587-150845-pre.txt.bz2", 
                "ladybug/problem-1642-153820-pre.txt.bz2", 
                "ladybug/problem-1695-155710-pre.txt.bz2"]

venice_prob = ["venice/problem-52-64053-pre.txt.bz2", 
               "venice/problem-89-110973-pre.txt.bz2", 
               "venice/problem-245-198739-pre.txt.bz2", 
               "venice/problem-427-310384-pre.txt.bz2", 
               "venice/problem-744-543562-pre.txt.bz2", 
               "venice/problem-951-708276-pre.txt.bz2", 
               "venice/problem-1102-780462-pre.txt.bz2", 
               "venice/problem-1158-802917-pre.txt.bz2", 
               "venice/problem-1184-816583-pre.txt.bz2", 
               "venice/problem-1238-843534-pre.txt.bz2", 
               "venice/problem-1288-866452-pre.txt.bz2", 
               "venice/problem-1350-894716-pre.txt.bz2", 
               "venice/problem-1408-912229-pre.txt.bz2", 
               "venice/problem-1778-993923-pre.txt.bz2"]

total_prob = [dubrovnik_prob, trafalgar_prob, ladybug_prob, venice_prob]


const artifacts_toml = joinpath(@__DIR__, "..", "Artifacts.toml")
               
const bal_url = "https://grail.cs.washington.edu/projects/bal/data"

fails = String[]

for problem_categ ∈ total_prob
    for problem ∈ problem_categ
        url = "$bal_url/$problem"
        println(problem)
        println(url)
        try
            add_artifact!(
                artifacts_toml,
                problem,
                url,
                lazy = true,
                force = true,
            )
        catch
            push!(fails, problem)
        end
    end
end
length(fails) > 0 && @warn "the following matrices could not be downloaded" fails
