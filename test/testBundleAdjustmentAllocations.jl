if VERSION > VersionNumber(1, 6, 0)
  @testset "residual allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name, group = get_first_name_and_group(filter_df)
    model = BundleAdjustmentModel(name, group)
    r = typeof(model.meta.x0)(undef, model.nls_meta.nequ)
  
    bench = @benchmark residual!($model, $model.meta.x0, $r)
    @test allocs(bench) ≤ 10
  end
  
  @testset "jac_structure allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name, group = get_first_name_and_group(filter_df)
    model = BundleAdjustmentModel(name, group)
  
    bench = @benchmark jac_structure!($model, $model.rows, $model.cols)
    @test allocs(bench) ≤ 10
  end
  
  @testset "jac_coord allocations" begin
    df = problems_df()
    filter_df = df[(df.name .== "problem-49-7776-pre"), :]
    name, group = get_first_name_and_group(filter_df)
    model = BundleAdjustmentModel(name, group)
  
    bench = @benchmark jac_coord!($model, $model.meta.x0, $model.vals)
    @test allocs(bench) ≤ 10
  end
end
