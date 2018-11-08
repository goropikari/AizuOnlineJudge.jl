# AizuOnlineJudge.jl

[![Build Status](https://travis-ci.org/goropikari/AizuOnlineJudge.jl.svg?branch=master)](https://travis-ci.org/goropikari/AizuOnlineJudge.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/frbigbvgw3wtl3b9?svg=true)](https://ci.appveyor.com/project/goropikari/aizuonlinejudge-jl)
[![Coverage Status](https://coveralls.io/repos/github/goropikari/AizuOnlineJudge.jl/badge.svg?branch=master)](https://coveralls.io/github/goropikari/AizuOnlineJudge.jl?branch=master)
[![codecov](https://codecov.io/gh/goropikari/AizuOnlineJudge.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/goropikari/AizuOnlineJudge.jl)


This is an unofficial judge system of [Aizu Online Judge](https://onlinejudge.u-aizu.ac.jp/home) (AOJ) for [Julia](https://julialang.org/).

[使い方（日本語）](https://goropikari.hatenablog.com/entry/julia_aoj?_ga=2.228535316.862849271.1540555626-663252211.1540555626)

# Installation
```julia
using Pkg
Pkg.pkg"add https://github.com/goropikari/AizuOnlineJudge.jl"
```

# Usage
```julia
using AizuOnlineJudge
test_sample("ProblemId", "yourfile.jl", timelimit=3)
judge("ProblemId", "yourfile.jl", timelimit=3)
```

or

```bash
./aoj ProblemId yourfile.jl [time_limit] # default time limit is 3 second.
```


# Example
```julia
using AizuOnlineJudge
judge("ALDS1_1_B", "gcd.jl")
```

```julia
# gcd.jl
# ALDS1_1_B
x, y = parse.(Int, split(readline()))
mygcd(x,y) = y == 0 ? x : mygcd(y, mod(x,y))
println(mygcd(x,y))
```

![sample](./pic/sample_gcd.gif)


# Known issues
Some problems can't be evaluated correctly.
If a problem uses floating point number, it fails to evaluate.


# Solutions

https://github.com/goropikari/AizuOnlineJudge_solution_julia
