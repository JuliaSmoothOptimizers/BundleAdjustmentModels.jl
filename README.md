# BundleAdjustmentModels

| **Documentation** | **CI** | **Coverage** | **Release** | **DOI** |
|:-----------------:|:------:|:------------:|:-----------:|:-------:|
| [![docs-stable][docs-stable-img]][docs-stable-url] [![docs-dev][docs-dev-img]][docs-dev-url] | [![build-ci][build-ci-img]][build-ci-url] | [![codecov][codecov-img]][codecov-url] | [![release][release-img]][release-url] | [![doi][doi-img]][doi-url] |

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliasmoothoptimizers.github.io/BundleAdjustmentModels/stable/
[docs-dev-img]: https://img.shields.io/badge/docs-dev-purple.svg
[docs-dev-url]: https://juliasmoothoptimizers.github.io/BundleAdjustmentModels/dev/
[build-ci-img]: https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels/workflows/CI/badge.svg?branch=main
[build-ci-url]: https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels/actions
[codecov-img]: https://codecov.io/gh/JuliaSmoothOptimizers/BundleAdjustmentModels/branch/main/graph/badge.svg
[codecov-url]: https://app.codecov.io/gh/JuliaSmoothOptimizers/BundleAdjustmentModels
[release-img]: https://img.shields.io/github/v/release/JuliaSmoothOptimizers/BundleAdjustmentModels.svg?style=flat-square
[release-url]: https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels/releases
[doi-img]: https://img.shields.io/badge/DOI-none-inactive
[doi-url]: about:blank

Julia repository of [bundle adjustment](https://en.wikipedia.org/wiki/Bundle_adjustment) problems from the [Bundle Adjustment in the Large](http://grail.cs.washington.edu/projects/bal/) repository

## Examples

```julia
julia> using BundleAdjustmentModels
```

`problems_df()` returns a DataFrame of all the problems, their group and other features.

```julia
julia> df = problems_df()
74×5 DataFrame
 Row │ name                     group      nequ      nvar     nnzj      
     │ String                   String     Int64     Int64    Int64     
─────┼──────────────────────────────────────────────────────────────────
   1 │ problem-16-22106-pre     dubrovnik    167436    66462    2009232
  ⋮  │            ⋮                 ⋮         ⋮         ⋮         ⋮
  74 │ problem-1778-993923-pre  venice     10003892  2997771  120046704
                                                         72 rows omitted
```

When you get this dataframe you can sort through it to get the problems that you want. For example, if you want to filter problems based on their size you can apply this filter:

```julia
julia> filter_df = df[ ( df.nequ .≥ 50000 ) .& ( df.nvar .≤ 34000 ), :]
2×5 DataFrame
 Row │ name                  group    nequ   nvar   nnzj    
     │ String                String   Int64  Int64  Int64   
─────┼──────────────────────────────────────────────────────
   1 │ problem-49-7776-pre   ladybug  63686  23769   764232
   2 │ problem-73-11032-pre  ladybug  92244  33753  1106928
```

`get_first_name_and_group` returns a tuple of the name and group in the first row of the dataframe

```julia
julia> name, group = get_first_name_and_group(filter_df)
("problem-49-7776-pre", "ladybug")
```

`fetch_ba_name` returns the path to the problem artifact. The artifact will download automatically:

```julia
julia> path = fetch_ba_name(name, group)
"C:\\Users\\xxxx\\.julia\\artifacts\\dd2da5f94014b5f9086a2b38a87f8c1bc171b9c2"
```

You can also get an array of the paths to an entire group of problems

```julia
julia> path = fetch_ba_group("ladybug")
30-element Vector{String}:
 "C:\\Users\\xxxx\\.julia\\artifacts\\dd2da5f94014b5f9086a2b38a87f8c1bc171b9c2"
 "C:\\Users\\xxxx\\.julia\\artifacts\\3d0853a3ca8e585814697fea9cd4d6956692e103"
 "C:\\Users\\xxxx\\.julia\\artifacts\\5c5c938c998d6c083f549bc584cfeb07bd296d89"
 ⋮
 "C:\\Users\\xxxx\\.julia\\artifacts\\00be55410c27068ec73261e122a39258100a1a11"
 "C:\\Users\\xxxx\\.julia\\artifacts\\0303e7ae8256c494c9da052d977277f21265899b"
 "C:\\Users\\xxxx\\.julia\\artifacts\\389ecea5c2f2e2b637a2b4439af0bd4ca98e6d84"
```

You can directly construct a nonlinear least-squares model based on [NLPModels](http://juliasmoothoptimizers.github.io/NLPModels.jl/latest/):

```julia
julia> model = BundleAdjustmentModel("problem-49-7776-pre", "ladybug")
BundleAdjustmentModel{Float64, Vector{Float64}}
```

You can also construct a nonlinear least-squares model by giving the constructor the path to the archive :

```julia
julia> model = BundleAdjustmentModel("../path/to/file/problem-49-7776-pre.txt.bz2")
BundleAdjustmentModel{Float64, Vector{Float64}}
```

Delete unneeded artifacts and free up disk space with `delete_ba_artifact!`:

```julia
julia> delete_ba_artifact!("problem-49-7776-pre", "ladybug")
[ Info: The artifact ladybug/problem-49-7776-pre.txt.bz2 has been deleted
```

Use  `delete_all_ba_artifacts!` to delete all artifacts:

```julia
julia> delete_all_ba_artifacts!()
[ Info: The artifact dubrovnik/problem-16-22106-pre.txt.bz2 was not found
[ Info: The artifact dubrovnik/problem-88-64298-pre.txt.bz2 was not found
 ⋮
[ Info: The artifact ladybug/problem-138-19878-pre.txt.bz2 has been deleted
[ Info: The artifact ladybug/problem-318-41628-pre.txt.bz2 has been deleted
 ⋮
[ Info: The artifact venice/problem-1408-912229-pre.txt.bz2 was not found
[ Info: The artifact venice/problem-1778-993923-pre.txt.bz2 was not found
```

Licensed under the MPL-2.0 [License](LICENSE.md) 
