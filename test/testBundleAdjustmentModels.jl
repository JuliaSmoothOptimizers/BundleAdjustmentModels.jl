delete_all_ba_artifacts!()

@testset "test fetch_ba_name" begin
  df = problems_df()
  for group ∈ BundleAdjustmentModels.ba_groups
    filter_df = sort!(df[(df.group .== string(group)), :], [:nequ, :nvar])
    name = filter_df[1, :name]
    path = fetch_ba_name(name)
    @test isdir(path)
    @test isfile(joinpath(path, "$name.txt.bz2"))
  end
end

@testset "test fetch_ba_group" begin
  group = "trafalgar"
  group_paths = fetch_ba_group(group)
  for path ∈ group_paths
    @test isdir(path)
  end
end

@testset "tests BundleAdjustmentModel" begin
  model = BundleAdjustmentModel("problem-16-22106-pre.txt.bz2")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 66462
  @test meta_nls.nequ == 167436
  @test model.meta.name == "problem-16-22106"

  model = BundleAdjustmentModel("problem-21-11315-pre.txt")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 34134
  @test meta_nls.nequ == 72910

  model = BundleAdjustmentModel("problem-49-7776-pre")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 23769
  @test meta_nls.nequ == 63686

  model = BundleAdjustmentModel("problem-52-64053")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 192627
  @test meta_nls.nequ == 694346
end

@testset "test residual" begin
  df = problems_df()
  filter_df = df[(df.name .== "problem-16-22106-pre"), :]
  name = filter_df[1, :name]
  model = BundleAdjustmentModel(name)

  @test 4.18565951824972266331e+06 ≈ obj(model, model.meta.x0)

  filter_df = df[(df.name .== "problem-21-11315-pre"), :]
  name = filter_df[1, :name]
  model = BundleAdjustmentModel(name)

  @test 4.41323931443221028894e+06 ≈ obj(model, model.meta.x0)

  filter_df = df[(df.name .== "problem-49-7776-pre"), :]
  name = filter_df[1, :name]
  model = BundleAdjustmentModel(name)

  @test 8.50912460680839605629e+05 ≈ obj(model, model.meta.x0)
end

@testset "test jacobian" begin
  df = problems_df()
  filter_df = df[(df.name .== "problem-16-22106-pre"), :]
  name = filter_df[1, :name]
  model = BundleAdjustmentModel(name)
  Fx = residual(model, model.meta.x0)
  S = typeof(model.meta.x0)
  meta_nls = nls_meta(model)
  rows = Vector{Int}(undef, meta_nls.nnzj)
  cols = Vector{Int}(undef, meta_nls.nnzj)
  vals = S(undef, meta_nls.nnzj)
  Jv = S(undef, meta_nls.nequ)
  Jtv = S(undef, meta_nls.nvar)
  jac_structure_residual!(model, rows, cols)
  jac_coord_residual!(model, model.meta.x0, vals)
  Jx = jac_op_residual!(model, rows, cols, vals, Jv, Jtv)

  @test 1.70677551536496222019e+08 ≈ norm(Jx' * Fx)

  filter_df = df[(df.name .== "problem-21-11315-pre"), :]
  name = filter_df[1, :name]
  model = BundleAdjustmentModel(name)
  Fx = residual(model, model.meta.x0)
  S = typeof(model.meta.x0)
  meta_nls = nls_meta(model)
  rows = Vector{Int}(undef, meta_nls.nnzj)
  cols = Vector{Int}(undef, meta_nls.nnzj)
  vals = S(undef, meta_nls.nnzj)
  Jv = S(undef, meta_nls.nequ)
  Jtv = S(undef, meta_nls.nvar)
  jac_structure_residual!(model, rows, cols)
  jac_coord_residual!(model, model.meta.x0, vals)
  Jx = jac_op_residual!(model, rows, cols, vals, Jv, Jtv)

  @test 1.64335338754470020533e+08 ≈ norm(Jx' * Fx)

  filter_df = df[(df.name .== "problem-49-7776-pre"), :]
  name = filter_df[1, :name]
  model = BundleAdjustmentModel(name)
  Fx = residual(model, model.meta.x0)
  S = typeof(model.meta.x0)
  meta_nls = nls_meta(model)
  rows = Vector{Int}(undef, meta_nls.nnzj)
  cols = Vector{Int}(undef, meta_nls.nnzj)
  vals = S(undef, meta_nls.nnzj)
  Jv = S(undef, meta_nls.nequ)
  Jtv = S(undef, meta_nls.nvar)
  jac_structure_residual!(model, rows, cols)
  jac_coord_residual!(model, model.meta.x0, vals)
  Jx = jac_op_residual!(model, rows, cols, vals, Jv, Jtv)

  @test 2.39615629098822921515e+07 ≈ norm(Jx' * Fx)
end

@testset "test delete_ba_artifact!()" begin
  df = problems_df()
  sort!(df, [:nequ, :nvar])
  name = df[1, :name]
  path = fetch_ba_name(name)
  @test isdir(path)
  @test isfile(joinpath(path, "$name.txt.bz2"))
  delete_ba_artifact!(name)
  @test !isdir(path)
  @test !isfile(joinpath(path, "$name.txt.bz2"))
end

@testset "delete_all_ba_artifacts!()" begin
  group = "trafalgar"
  group_paths = fetch_ba_group(group)
  delete_all_ba_artifacts!()
  for path ∈ group_paths
    @test !isdir(path)
  end
end
