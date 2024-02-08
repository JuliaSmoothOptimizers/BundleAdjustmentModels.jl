# [BundleAdjustmentModels documentation](@id Home)

Julia repository of [bundle adjustment](https://en.wikipedia.org/wiki/Bundle_adjustment) problems from the [Bundle Adjustment in the Large](http://grail.cs.washington.edu/projects/bal/) repository

## How to Cite

If you use BundleAdjustmentModels.jl in your work, please cite using the format given in [`CITATION.cff`](https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/blob/main/CITATION.cff).

# Tutorial

Check an [Introduction to BundleAdjustmentModels](https://juliasmoothoptimizers.github.io/tutorials/introduction-to-bundleadjustmentmodels/) and more tutorials on the [JSO tutorials page](https://juliasmoothoptimizers.github.io/tutorials/).

# Bug reports and discussions

If you think you found a bug, feel free to open an [issue](https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/issues).
Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.

If you want to ask a question not suited for a bug report, feel free to start a discussion [here](https://github.com/JuliaSmoothOptimizers/Organization/discussions). This forum is for general discussion about this repository and the [JuliaSmoothOptimizers](https://github.com/JuliaSmoothOptimizers), so questions about any of our packages are welcome.

## Examples

```@example ex1
using BundleAdjustmentModels, DataFrames
```

`problems_df()` returns a DataFrame of all the problems, their group and other features.

```@example ex1
df = problems_df()
```

When you get this dataframe you can sort through it to get the problems that you want. For example, if you want to filter problems based on their size you can apply this filter:

```@example ex1
filter_df = df[ ( df.nequ .≥ 50000 ) .& ( df.nvar .≤ 34000 ), :]
```

You can get the problem name directly from the dataframe:

```@example ex1
name = filter_df[1, :name]
```

`fetch_ba_name` returns the path to the problem artifact. The artifact will download automatically:

```@example ex1
path = fetch_ba_name(name)
```

You can also get an array of the paths to an entire group of problems

```@example ex1
path = fetch_ba_group("ladybug")
```

You can directly construct a nonlinear least-squares model based on [NLPModels](http://juliasmoothoptimizers.github.io/NLPModels.jl/latest/):

```@example ex1
model = BundleAdjustmentModel("problem-49-7776")
```

You can then evaluate the residual and jacobian (or their in-place version) from NLPModels:

```@example ex1
using NLPModels
```

```@example ex1
residual(model, model.meta.x0)
```

```@example ex1
meta_nls = nls_meta(model)
Fx = similar(model.meta.x0, meta_nls.nequ)
residual!(model, model.meta.x0, Fx)
```

You need to call `jac_structure_residual!` at least once before calling `jac_op_residual!`.

```@example ex1
meta_nls = nls_meta(model)
rows = Vector{Int}(undef, meta_nls.nnzj)
cols = Vector{Int}(undef, meta_nls.nnzj)
jac_structure_residual!(model, rows, cols)
```

You need to call `jac_coord_residual!` everytime before calling `jac_op_residual!`.

```@example ex1
vals = similar(model.meta.x0, meta_nls.nnzj)
jac_coord_residual!(model, model.meta.x0, vals)
```

```@example ex1
Jv = similar(model.meta.x0, meta_nls.nequ)
Jtv = similar(model.meta.x0, meta_nls.nvar)
Jx = jac_op_residual!(model, rows, cols, vals, Jv, Jtv)
```

There is no second order information available for problems in this module.

Delete unneeded artifacts and free up disk space with `delete_ba_artifact!`:

```@example ex1
delete_ba_artifact!("problem-49-7776-pre")
```

Use  `delete_all_ba_artifacts!` to delete all artifacts:

```@example ex1
delete_all_ba_artifacts!()
```

Licensed under the MPL-2.0 [License](https://github.com/JuliaSmoothOptimizers/BundleAdjustmentModels.jl/blob/main/LICENSE.md) 
