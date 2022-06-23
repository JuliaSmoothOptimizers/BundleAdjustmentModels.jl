delete_all_ba_artifacts!()

@testset "test fetch_ba_name" begin
  df = problems_df()
  for group ∈ BundleAdjustmentModels.ba_groups
    filter_df = sort!(df[(df.group .== string(group)), :], [:nequ, :nvar])
    name, group = get_first_name_and_group(filter_df)
    path = fetch_ba_name(name, group)
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
  model = BundleAdjustmentModel("problem-16-22106-pre.txt.bz2","dubrovnik")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 66462
  @test meta_nls.nequ == 167436
  model = BundleAdjustmentModel("problem-16-22106-pre.txt.bz2")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 66462
  @test meta_nls.nequ == 167436
  path = fetch_ba_name("problem-16-22106-pre.txt.bz2","dubrovnik")
  filename = joinpath(path, "problem-16-22106-pre.txt.bz2")
  model = BundleAdjustmentModel(filename, Float64)
  @test meta_nls.nvar == 66462
  @test meta_nls.nequ == 167436

  model = BundleAdjustmentModel("problem-21-11315-pre.txt.bz2","trafalgar")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 34134
  @test meta_nls.nequ == 72910
  model = BundleAdjustmentModel("problem-21-11315-pre.txt.bz2")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 34134
  @test meta_nls.nequ == 72910
  path = fetch_ba_name("problem-21-11315-pre.txt.bz2","trafalgar")
  filename = joinpath(path, "problem-21-11315-pre.txt.bz2")
  model = BundleAdjustmentModel(filename, Float64)
  @test meta_nls.nvar == 34134
  @test meta_nls.nequ == 72910

  model = BundleAdjustmentModel("problem-49-7776-pre.txt.bz2","ladybug")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 23769
  @test meta_nls.nequ == 63686
  model = BundleAdjustmentModel("problem-49-7776-pre.txt.bz2")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 23769
  @test meta_nls.nequ == 63686
  path = fetch_ba_name("problem-49-7776-pre.txt.bz2","ladybug")
  filename = joinpath(path, "problem-49-7776-pre.txt.bz2")
  model = BundleAdjustmentModel(filename, Float64)
  @test meta_nls.nvar == 23769
  @test meta_nls.nequ == 63686

  model = BundleAdjustmentModel("problem-52-64053-pre.txt.bz2", "venice")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 192627
  @test meta_nls.nequ == 694346
  model = BundleAdjustmentModel("problem-52-64053-pre.txt.bz2")
  meta_nls = nls_meta(model)
  @test meta_nls.nvar == 192627
  @test meta_nls.nequ == 694346
  path = fetch_ba_name("problem-52-64053-pre.txt.bz2", "venice")
  filename = joinpath(path, "problem-52-64053-pre.txt.bz2")
  model = BundleAdjustmentModel(filename, Float64)
  @test meta_nls.nvar == 192627
  @test meta_nls.nequ == 694346
end

@testset "test residual" begin
  df = problems_df()
  filter_df = df[(df.name .== "problem-16-22106-pre"), :]
  name, group = get_first_name_and_group(filter_df)
  model = BundleAdjustmentModel(name, group)

  @test 4.18565951824972266331e+06 ≈ obj(model, model.meta.x0)

  filter_df = df[(df.name .== "problem-21-11315-pre"), :]
  name, group = get_first_name_and_group(filter_df)
  model = BundleAdjustmentModel(name, group)

  @test 4.41323931443221028894e+06 ≈ obj(model, model.meta.x0)

  filter_df = df[(df.name .== "problem-49-7776-pre"), :]
  name, group = get_first_name_and_group(filter_df)
  model = BundleAdjustmentModel(name, group)

  @test 8.50912460680839605629e+05 ≈ obj(model, model.meta.x0)
end

@testset "test jacobian" begin
  df = problems_df()
  filter_df = df[(df.name .== "problem-16-22106-pre"), :]
  name, group = get_first_name_and_group(filter_df)
  model = BundleAdjustmentModel(name, group)
  Fx = residual(model, model.meta.x0)
  Jx = jac_op_residual(model, model.meta.x0)

  @test 1.70677551536496222019e+08 ≈ norm(Jx' * Fx)

  filter_df = df[(df.name .== "problem-21-11315-pre"), :]
  name, group = get_first_name_and_group(filter_df)
  model = BundleAdjustmentModel(name, group)
  Fx = residual(model, model.meta.x0)
  Jx = jac_op_residual(model, model.meta.x0)

  @test 1.64335338754470020533e+08 ≈ norm(Jx' * Fx)

  filter_df = df[(df.name .== "problem-49-7776-pre"), :]
  name, group = get_first_name_and_group(filter_df)
  model = BundleAdjustmentModel(name, group)
  Fx = residual(model, model.meta.x0)
  Jx = jac_op_residual(model, model.meta.x0)

  @test 2.39615629098822921515e+07 ≈ norm(Jx' * Fx)
end

@testset "test delete_ba_artifact!()" begin
  df = problems_df()
  sort!(df, [:nequ, :nvar])
  name, group = get_first_name_and_group(df)
  path = fetch_ba_name(name, group)
  @test isdir(path)
  @test isfile(joinpath(path, "$name.txt.bz2"))
  delete_ba_artifact!(name, group)
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
