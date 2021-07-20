# BALNLSModels

Julia repository of BAL problems

## Examples

```julia
julia> using BALNLSModels
```

if you don't know the problem names you can call problems_df() that will return a dataframe of all the problems, thair group and some other characteristics.

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

When you get this dataframe you can sort through it to get the problem that you want. For example, if you want the problem with the smallest jacobian, you can do this :

```julia
julia> sort!(df, [:nequ, :nvar])
74×5 DataFrame
 Row │ name                     group      nequ      nvar     nnzj      
     │ String                   String     Int64     Int64    Int64     
─────┼──────────────────────────────────────────────────────────────────
   1 │ problem-49-7776-pre      ladybug       63686    23769     764232
  ⋮  │            ⋮                 ⋮         ⋮         ⋮         ⋮
  74 │ problem-1778-993923-pre  venice     10003892  2997771  120046704
                                                         72 rows omitted
```

Now that you know the problem name, you can either get the path to the archive to do whatever you want with it afterwards. The artifact will automatically be downloaded if it has never been before :

```julia
julia> path = fetch_bal_name("problem-49-7776-pre", "ladybug")
"C:\\Users\\xxxx\\.julia\\artifacts\\dd2da5f94014b5f9086a2b38a87f8c1bc171b9c2"
```

You can also get an array of the paths of an entire group of problems

```julia
julia> path = fetch_bal_group("ladybug")
30-element Vector{String}:
 "C:\\Users\\xxxx\\.julia\\artifacts\\dd2da5f94014b5f9086a2b38a87f8c1bc171b9c2"
 "C:\\Users\\xxxx\\.julia\\artifacts\\3d0853a3ca8e585814697fea9cd4d6956692e103"
 "C:\\Users\\xxxx\\.julia\\artifacts\\5c5c938c998d6c083f549bc584cfeb07bd296d89"
 ⋮
 "C:\\Users\\xxxx\\.julia\\artifacts\\00be55410c27068ec73261e122a39258100a1a11"
 "C:\\Users\\xxxx\\.julia\\artifacts\\0303e7ae8256c494c9da052d977277f21265899b"
 "C:\\Users\\xxxx\\.julia\\artifacts\\389ecea5c2f2e2b637a2b4439af0bd4ca98e6d84"
```

Or you can directly construct a non linear least squares model based on NLPModels :

```julia
julia> model = BALNLSModel("problem-49-7776-pre", "ladybug")
BALNLSModel{Float64, Vector{Float64}}
```
<!--   Problem name: problem-49-7776-pre
   All variables: ████████████████████ 23769  All constraints: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0        All residuals: ████████████████████ 63686
            free: ████████████████████ 23769             free: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0               linear: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
           lower: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                lower: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0            nonlinear: ████████████████████ 63686
           upper: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                upper: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                 nnzj: ( 99.95% sparsity)   764232        
         low/upp: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0              low/upp: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                 nnzh: (  0.00% sparsity)   282494565     
           fixed: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                fixed: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
          infeas: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0               infeas: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
            nnzh: (  0.00% sparsity)   282494565          linear: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
                                                    nonlinear: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
                                                         nnzj: (------% sparsity)

  Counters:
             obj: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                 grad: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                 cons: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0     
            jcon: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                jgrad: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                  jac: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
           jprod: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0               jtprod: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                 hess: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
           hprod: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0                jhess: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0               jhprod: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
        residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0         jac_residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0       jprod_residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
 jtprod_residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0        hess_residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0       jhess_residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
  hprod_residual: ⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅⋅ 0
 -->

If you want to leave some space and properly delete and artifact before uninstalling the package you can use this function :

```julia
julia> delete_balartifact!("problem-49-7776-pre", "ladybug")
[ Info: The artifact ladybug/problem-49-7776-pre.txt.bz2 has been deleted
```

Or delete all the problems' artifacts :

```julia
julia> delete_all_balartifacts!()
[ Info: The artifact dubrovnik/problem-16-22106-pre.txt.bz2 has not been found
[ Info: The artifact dubrovnik/problem-88-64298-pre.txt.bz2 has not been found
 ⋮
[ Info: The artifact ladybug/problem-138-19878-pre.txt.bz2 has been deleted
[ Info: The artifact ladybug/problem-318-41628-pre.txt.bz2 has been deleted
 ⋮
[ Info: The artifact venice/problem-1408-912229-pre.txt.bz2 has not been found
[ Info: The artifact venice/problem-1778-993923-pre.txt.bz2 has not been found
```