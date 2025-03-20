# BundleAdjustmentModels

| **Documentation** | **CI** | **Coverage** | **Release** | **DOI** |
|:-----------------:|:------:|:------------:|:-----------:|:-------:|
| [![docs-stable][docs-stable-img]][docs-stable-url] [![docs-dev][docs-dev-img]][docs-dev-url] | [![build-ci][build-ci-img]][build-ci-url] | [![codecov][codecov-img]][codecov-url] | [![release][release-img]][release-url] | [![doi][doi-img]][doi-url] |

[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg
[docs-stable-url]: https://juliasmoothoptimizers.github.io/BundleAdjustmentModels.jl/stable/
[docs-dev-img]: https://img.shields.io/badge/docs-dev-purple.svg
[docs-dev-url]: https://juliasmoothoptimizers.github.io/BundleAdjustmentModels.jl/dev/
[build-ci-img]: https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/workflows/CI/badge.svg?branch=main
[build-ci-url]: https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/actions
[codecov-img]: https://codecov.io/gh/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/branch/main/graph/badge.svg
[codecov-url]: https://app.codecov.io/gh/JuliaSmoothOptimizers/BundleAdjustmentModels.jl
[release-img]: https://img.shields.io/github/v/release/JuliaSmoothOptimizers/BundleAdjustmentModels.jl.svg?style=flat-square
[release-url]: https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/releases
[doi-img]: https://zenodo.org/badge/383587358.svg
[doi-url]: https://zenodo.org/badge/latestdoi/383587358

Julia repository of [bundle adjustment](https://en.wikipedia.org/wiki/Bundle_adjustment) problems from the repository [Bundle Adjustment in the Large](http://grail.cs.washington.edu/projects/bal/).

## How to Cite

If you use `BundleAdjustmentModels.jl` in your work, please cite using the format given in [`CITATION.cff`](https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/blob/main/CITATION.cff).

## Bug Reports and Discussions

If you think you found a bug, feel free to open an [issue](https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/issues).
Focused suggestions and requests can also be opened as issues. Before opening a pull request, please start an issue or a discussion on the topic.

If you want to ask a question not suited for a bug report, feel free to start a discussion [here](https://github.com/JuliaSmoothOptimizers/Organization/discussions).

## Examples

### Loading and Exploring Problems

```julia
using BundleAdjustmentModels, DataFrames

# Get a DataFrame with all problems
df = problems_df()

# Show first few rows
first(df, 5)
```
```julia
5×5 DataFrame
 Row │ name               group      nequ     nvar    nnzj     
     │ String             String     Int64    Int64   Int64    
─────┼─────────────────────────────────────────────────────────
   1 │ problem-16-22106   dubrovnik   167436   66462   2009232
   2 │ problem-88-64298   dubrovnik   767874  193686   9214488
   3 │ problem-135-90642  dubrovnik  1106672  273141  13280064
   4 │ problem-142-93602  dubrovnik  1131216  282084  13574592
   5 │ problem-150-95821  dubrovnik  1136238  288813  13634856
```

The DataFrame has the following columns:

- **name**: Problem name.
- **group**: Group to which the problem belongs.
- **nequ**: Number of equations (rows).
- **nvar**: Number of variables (columns).
- **nnzj**: Number of non-zero elements in the Jacobian.

### Filtering problems

You can filter problems based on specific criteria. For instance:

```julia
# Select problems with more than 50000 equations and less than 34000 variables
filter_df = filter(pb -> pb.nequ >= 50_000 && pb.nvar <= 34_000, df)
```

### Accessing problem names

Extract the name of the first problem in the filtered DataFrame:

```julia
name = filter_df[1, :name]
```

### Fetching artifacts

Download the problem artifact for the given name:

```julia
path = fetch_ba_name(name)
```

### Nonlinear least-squares models

Create a nonlinear least-squares model:

```julia
using NLPModels
model = BundleAdjustmentModel(name)
```

You can evaluate residuals and Jacobians using functions from `NLPModels`.

```julia
residuals = residual(model, model.meta.x0)
```

Compute the Jacobian structure:

```julia
rows = Vector{Int}(undef, model.nls_meta.nnzj)
cols = Vector{Int}(undef, model.nls_meta.nnzj)
jac_structure_residual!(model, rows, cols)
```

Evaluate Jacobian values:

```julia
vals = Vector{Float64}(undef, length(rows))
jac_coord_residual!(model, model.meta.x0, vals)
```

### Cleaning up artifacts

Delete specific or all downloaded artifacts:

```julia
delete_ba_artifact!(name)  # Delete one artifact
delete_all_ba_artifacts!() # Delete all artifacts
```

Special thanks to Célestine Angla for her initial work on this project during her internship.

## License

Licensed under the MPL-2.0 [License](LICENSE.md).
