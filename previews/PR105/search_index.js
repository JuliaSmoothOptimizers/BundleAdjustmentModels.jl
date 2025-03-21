var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [BundleAdjustmentModels]\nPrivate = false","category":"page"},{"location":"reference/#BundleAdjustmentModels.BundleAdjustmentModel","page":"Reference","title":"BundleAdjustmentModels.BundleAdjustmentModel","text":"Represent a bundle adjustement problem in the form\n\nminimize   ½ ‖F(x)‖²\n\nwhere F(x) is the vector of residuals.\n\n\n\n\n\n","category":"type"},{"location":"reference/#BundleAdjustmentModels.BundleAdjustmentModel-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.BundleAdjustmentModel","text":"BundleAdjustmentModel(name::AbstractString; T::Type=Float64)\n\nConstructor of BundleAdjustmentModel, creates an NLSModel with name name from a BundleAdjustment archive with precision T.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.delete_all_ba_artifacts!-Tuple{}","page":"Reference","title":"BundleAdjustmentModels.delete_all_ba_artifacts!","text":"delete_all_ba_artifacts!()\n\nDelete all the BundleAdjustmentModel artifacts from the artifact store.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.delete_ba_artifact!-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.delete_ba_artifact!","text":"delete_ba_artifact!(name::AbstractString)\n\nDelete the artifact name from the artifact store.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.fetch_ba_group-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.fetch_ba_group","text":"fetch_ba_group(group::AbstractString)\n\nGet all the problems with the group name group. Return an array of the paths where the problems are stored. Group possibilities are : \"trafalgar\", \"venice\", \"dubrovnik\" and \"ladybug\".\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.fetch_ba_name-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.fetch_ba_name","text":"fetch_ba_name(name::AbstractString)\n\nGet the problem with name name. Return the path where the problem is stored.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.problems_df-Tuple{}","page":"Reference","title":"BundleAdjustmentModels.problems_df","text":"problems_df()\n\nReturn a dataframe of the problems and their characteristics.\n\n\n\n\n\n","category":"method"},{"location":"#Home","page":"Introduction","title":"BundleAdjustmentModels documentation","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Julia repository of bundle adjustment problems from the Bundle Adjustment in the Large repository","category":"page"},{"location":"#How-to-Cite","page":"Introduction","title":"How to Cite","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"If you use BundleAdjustmentModels.jl in your work, please cite using the format given in CITATION.cff.","category":"page"},{"location":"#Tutorial","page":"Introduction","title":"Tutorial","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Check an Introduction to BundleAdjustmentModels and more tutorials on the JSO tutorials page.","category":"page"},{"location":"#Bug-reports-and-discussions","page":"Introduction","title":"Bug reports and discussions","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"If you think you found a bug, feel free to open an issue. Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"If you want to ask a question not suited for a bug report, feel free to start a discussion here. This forum is for general discussion about this repository and the JuliaSmoothOptimizers, so questions about any of our packages are welcome.","category":"page"},{"location":"#Examples","page":"Introduction","title":"Examples","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"using BundleAdjustmentModels, DataFrames","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"problems_df() returns a DataFrame of all the problems, their group and other features.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"df = problems_df()","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"When you get this dataframe you can sort through it to get the problems that you want. For example, if you want to filter problems based on their size you can apply this filter:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"filter_df = df[ ( df.nequ .≥ 50000 ) .& ( df.nvar .≤ 34000 ), :]","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can get the problem name directly from the dataframe:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"name = filter_df[1, :name]","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"fetch_ba_name returns the path to the problem artifact. The artifact will download automatically:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"path = fetch_ba_name(name)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can also get an array of the paths to an entire group of problems","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"path = fetch_ba_group(\"ladybug\")","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can directly construct a nonlinear least-squares model based on NLPModels:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"model = BundleAdjustmentModel(\"problem-49-7776\")","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can then evaluate the residual and jacobian (or their in-place version) from NLPModels:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"using NLPModels","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"residual(model, model.meta.x0)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"meta_nls = nls_meta(model)\nFx = similar(model.meta.x0, meta_nls.nequ)\nresidual!(model, model.meta.x0, Fx)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You need to call jac_structure_residual! at least once before calling jac_op_residual!.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"meta_nls = nls_meta(model)\nrows = Vector{Int}(undef, meta_nls.nnzj)\ncols = Vector{Int}(undef, meta_nls.nnzj)\njac_structure_residual!(model, rows, cols)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You need to call jac_coord_residual! everytime before calling jac_op_residual!.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"vals = similar(model.meta.x0, meta_nls.nnzj)\njac_coord_residual!(model, model.meta.x0, vals)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Jv = similar(model.meta.x0, meta_nls.nequ)\nJtv = similar(model.meta.x0, meta_nls.nvar)\nJx = jac_op_residual!(model, rows, cols, vals, Jv, Jtv)","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"There is no second order information available for problems in this module.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Delete unneeded artifacts and free up disk space with delete_ba_artifact!:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"delete_ba_artifact!(\"problem-49-7776-pre\")","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Use  delete_all_ba_artifacts! to delete all artifacts:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"delete_all_ba_artifacts!()","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Licensed under the MPL-2.0 License ","category":"page"},{"location":"internals/#Internal-functions","page":"Internals","title":"Internal functions","text":"","category":"section"},{"location":"internals/","page":"Internals","title":"Internals","text":"These functions may or may not be exported. They are used internally.","category":"page"},{"location":"internals/","page":"Internals","title":"Internals","text":"BundleAdjustmentModels.readfile\nBundleAdjustmentModels.get_filename\nBundleAdjustmentModels.get_group\nBundleAdjustmentModels.ba_download_artifact\nBundleAdjustmentModels.ba_ensure_artifact_installed\nBundleAdjustmentModels.P1!\nBundleAdjustmentModels.P2!\nBundleAdjustmentModels.JP1!\nBundleAdjustmentModels.JP3!\nBundleAdjustmentModels.JP2!","category":"page"},{"location":"internals/#BundleAdjustmentModels.readfile","page":"Internals","title":"BundleAdjustmentModels.readfile","text":"readfile(filename::String; T::Type=Float64)\n\nReads the .txt.bzip2 file specified in filename and extracts data.  Returns:\n\ncam_indices: Vector of camera indices (Int)\npnt_indices: Vector of point indices (Int)\npt2d: Observed 2D points (Vector{T})\nx0: Combined vector of 3D points and camera parameters (Vector{T})\nncams: Number of cameras (Int)\nnpnts: Number of 3D points (Int)\nnobs: Number of observations (Int)\n\nExpected file structure:\n\nFirst line: ncams npnts nobs\nFollowing nobs lines: cam_index point_index xcoord ycoord\nCamera parameters: 9 lines per camera\n3D points: 3 lines per point\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.get_filename","page":"Internals","title":"BundleAdjustmentModels.get_filename","text":"get_filename(name::AbstractString)\n\nAnalyze the name given to check if it matches one of the known names. Return the full name with \"-pre.txt.bz2\" extension.\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.get_group","page":"Internals","title":"BundleAdjustmentModels.get_group","text":"get_group(name::AbstractString)\n\nGet the group corresponding to the given name of the problem.\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.ba_download_artifact","page":"Internals","title":"BundleAdjustmentModels.ba_download_artifact","text":"ba_download_artifact(tree_hash::SHA1, tarball_url::String, tarball_hash::String;\n                  verbose::Bool = false, io::IO=stderr)\n\nDownload/install an artifact into the artifact store.  Returns true on success. The modifications from the original functions are here to avoid unpacking the archive and avoid checking from official repository since these files are not official artifacts.\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.ba_ensure_artifact_installed","page":"Internals","title":"BundleAdjustmentModels.ba_ensure_artifact_installed","text":"ba_ensure_artifact_installed(filename::String, artifact_name::String, artifacts_toml::String;\n                                platform::AbstractPlatform = HostPlatform(),\n                                pkg_uuid::Union{Base.UUID,Nothing}=nothing,\n                                verbose::Bool = false,\n                                quiet_download::Bool = false,\n                                io::IO=stderr)\n\nEnsures an artifact is installed, downloading it via the download information stored in artifacts_toml if necessary.  Throws an error if unable to install. The modifications from the original functions are here to avoid unpacking the archive and avoid checking from official repository since these files are not official artifacts.\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.P1!","page":"Internals","title":"BundleAdjustmentModels.P1!","text":"First step in camera projection\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.P2!","page":"Internals","title":"BundleAdjustmentModels.P2!","text":"Second step in camera projection\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.JP1!","page":"Internals","title":"BundleAdjustmentModels.JP1!","text":"Jacobian of the first step of the projection\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.JP3!","page":"Internals","title":"BundleAdjustmentModels.JP3!","text":"Jacobian of the third step of the projection\n\n\n\n\n\n","category":"function"},{"location":"internals/#BundleAdjustmentModels.JP2!","page":"Internals","title":"BundleAdjustmentModels.JP2!","text":"Jacobian of the second step of the projection\n\n\n\n\n\n","category":"function"}]
}
