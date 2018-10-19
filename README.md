# AizuOnlineJudge.jl

[![Build Status](https://travis-ci.org/goropikari/AizuOnlineJudge.jl.svg?branch=master)](https://travis-ci.org/goropikari/AizuOnlineJudge.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/frbigbvgw3wtl3b9?svg=true)](https://ci.appveyor.com/project/goropikari/aizuonlinejudge-jl)
[![Coverage Status](https://coveralls.io/repos/github/goropikari/AizuOnlineJudge.jl/badge.svg?branch=master)](https://coveralls.io/github/goropikari/AizuOnlineJudge.jl?branch=master)
[![codecov](https://codecov.io/gh/goropikari/AizuOnlineJudge.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/goropikari/AizuOnlineJudge.jl)


This is a unofficial judge system of [Aizu Online Judge](https://onlinejudge.u-aizu.ac.jp/home) (AOJ) for [Julia](https://julialang.org/).


# Installation
```julia
using Pkg
Pkg.pkg"add https://github.com/goropikari/AizuOnlineJudge.jl"
```

# Usage
```julia
using AizuOnlineJudge
test_sample("ProblemId", "yourfile.jl", timelimit=1)
judge("ProblemId", "yourfile.jl", timelimit=1)
```

or

```bash
./aoj ProblemId yourfile.jl [time_limit] # default time limit is 1 second.
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
