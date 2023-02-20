var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [BundleAdjustmentModels]\nPrivate = false","category":"page"},{"location":"reference/#BundleAdjustmentModels.BundleAdjustmentModel","page":"Reference","title":"BundleAdjustmentModels.BundleAdjustmentModel","text":"Represent a bundle adjustement problem in the form\n\nminimize   ½ ‖F(x)‖²\n\nwhere F(x) is the vector of residuals.\n\n\n\n\n\n","category":"type"},{"location":"reference/#BundleAdjustmentModels.BundleAdjustmentModel-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.BundleAdjustmentModel","text":"BundleAdjustmentModel(name::AbstractString; T::Type=Float64)\n\nConstructor of BundleAdjustmentModel, creates an NLSModel with name name from a BundleAdjustment archive with precision T.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.delete_all_ba_artifacts!-Tuple{}","page":"Reference","title":"BundleAdjustmentModels.delete_all_ba_artifacts!","text":"delete_all_ba_artifacts!()\n\nDelete all the BundleAdjustmentModel artifacts from the artifact store.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.delete_ba_artifact!-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.delete_ba_artifact!","text":"delete_ba_artifact!(name::AbstractString)\n\nDelete the artifact name from the artifact store.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.fetch_ba_group-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.fetch_ba_group","text":"fetch_ba_group(group::AbstractString)\n\nGet all the problems with the group name group. Return an array of the paths where the problems are stored. Group possibilities are : \"trafalgar\", \"venice\", \"dubrovnik\" and \"ladybug\".\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.fetch_ba_name-Tuple{AbstractString}","page":"Reference","title":"BundleAdjustmentModels.fetch_ba_name","text":"fetch_ba_name(name::AbstractString)\n\nGet the problem with name name. Return the path where the problem is stored.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BundleAdjustmentModels.problems_df-Tuple{}","page":"Reference","title":"BundleAdjustmentModels.problems_df","text":"problems_df()\n\nReturn a dataframe of the problems and their characteristics.\n\n\n\n\n\n","category":"method"},{"location":"#Home","page":"Introduction","title":"BundleAdjustmentModels documentation","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Julia repository of bundle adjustment problems from the Bundle Adjustment in the Large repository.","category":"page"},{"location":"#Tutorial","page":"Introduction","title":"Tutorial","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"Check an Introduction to BundleAdjustmentModels and more tutorials on the JSO tutorials page.","category":"page"},{"location":"#Bug-reports-and-discussions","page":"Introduction","title":"Bug reports and discussions","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"If you think you found a bug, feel free to open an issue. Focused suggestions and requests can also be opened as issues. Before opening a pull request, start an issue or a discussion on the topic, please.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"If you want to ask a question not suited for a bug report, feel free to start a discussion here. This forum is for general discussion about this repository and the JuliaSmoothOptimizers, so questions about any of our packages are welcome.","category":"page"},{"location":"#Examples","page":"Introduction","title":"Examples","text":"","category":"section"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> using BundleAdjustmentModels","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"problems_df() returns a DataFrame of all the problems, their group and other features.","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> df = problems_df()\n74×5 DataFrame\n Row │ name                     group      nequ      nvar     nnzj      \n     │ String                   String     Int64     Int64    Int64     \n─────┼──────────────────────────────────────────────────────────────────\n   1 │ problem-16-22106-pre     dubrovnik    167436    66462    2009232\n  ⋮  │            ⋮                 ⋮         ⋮         ⋮         ⋮\n  74 │ problem-1778-993923-pre  venice     10003892  2997771  120046704\n                                                         72 rows omitted","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"When you get this dataframe you can sort through it to get the problems that you want. For example, if you want to filter problems based on their size you can apply this filter:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> filter_df = df[ ( df.nequ .≥ 50000 ) .& ( df.nvar .≤ 34000 ), :]\n2×5 DataFrame\n Row │ name                  group    nequ   nvar   nnzj    \n     │ String                String   Int64  Int64  Int64   \n─────┼──────────────────────────────────────────────────────\n   1 │ problem-49-7776-pre   ladybug  63686  23769   764232\n   2 │ problem-73-11032-pre  ladybug  92244  33753  1106928","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"get_first_name_and_group returns a tuple of the name and group in the first row of the dataframe","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> name, group = get_first_name_and_group(filter_df)\n(\"problem-49-7776-pre\", \"ladybug\")","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"fetch_ba_name returns the path to the problem artifact. The artifact will download automatically:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> path = fetch_ba_name(name, group)\n\"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\dd2da5f94014b5f9086a2b38a87f8c1bc171b9c2\"","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can also get an array of the paths to an entire group of problems","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> path = fetch_ba_group(\"ladybug\")\n30-element Vector{String}:\n \"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\dd2da5f94014b5f9086a2b38a87f8c1bc171b9c2\"\n \"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\3d0853a3ca8e585814697fea9cd4d6956692e103\"\n \"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\5c5c938c998d6c083f549bc584cfeb07bd296d89\"\n ⋮\n \"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\00be55410c27068ec73261e122a39258100a1a11\"\n \"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\0303e7ae8256c494c9da052d977277f21265899b\"\n \"C:\\\\Users\\\\xxxx\\\\.julia\\\\artifacts\\\\389ecea5c2f2e2b637a2b4439af0bd4ca98e6d84\"","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can directly construct a nonlinear least-squares model based on NLPModels:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> model = BundleAdjustmentModel(\"problem-49-7776-pre\", \"ladybug\")\nBundleAdjustmentModel{Float64, Vector{Float64}}","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"You can also construct a nonlinear least-squares model by giving the constructor the path to the archive :","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> model = BundleAdjustmentModel(\"../path/to/file/problem-49-7776-pre.txt.bz2\")\nBundleAdjustmentModel{Float64, Vector{Float64}}","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Delete unneeded artifacts and free up disk space with delete_ba_artifact!:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> delete_ba_artifact!(\"problem-49-7776-pre\", \"ladybug\")\n[ Info: The artifact ladybug/problem-49-7776-pre.txt.bz2 has been deleted","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Use  delete_all_ba_artifacts! to delete all artifacts:","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"julia> delete_all_ba_artifacts!()\n[ Info: The artifact dubrovnik/problem-16-22106-pre.txt.bz2 was not found\n[ Info: The artifact dubrovnik/problem-88-64298-pre.txt.bz2 was not found\n ⋮\n[ Info: The artifact ladybug/problem-138-19878-pre.txt.bz2 has been deleted\n[ Info: The artifact ladybug/problem-318-41628-pre.txt.bz2 has been deleted\n ⋮\n[ Info: The artifact venice/problem-1408-912229-pre.txt.bz2 was not found\n[ Info: The artifact venice/problem-1778-993923-pre.txt.bz2 was not found","category":"page"},{"location":"","page":"Introduction","title":"Introduction","text":"Licensed under the MPL-2.0 License ","category":"page"}]
}
