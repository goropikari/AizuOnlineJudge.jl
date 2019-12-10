module AizuOnlineJudge
export judge, test_sample

import HTTP, JSON, SHA, Dates
const endpoint = "https://judgedat.u-aizu.ac.jp"

# API Reference
# http://developers.u-aizu.ac.jp/api?key=judgedat%2Ftestcases%2F%7BproblemId%7D%2F%7Bserial%7D_GET
# http://developers.u-aizu.ac.jp/api?key=judgedat%2Ftestcases%2F%7BproblemId%7D%2Fheader_GET
# http://developers.u-aizu.ac.jp/api?key=judgedat%2Ftestcases%2F%7BproblemId%7D%2F%7Bserial%7D_GET
#
# sample case
# https://judgedat.u-aizu.ac.jp/testcases/samples/ALDS1_1_A
#
# 問題数を知る
# https://judgedat.u-aizu.ac.jp/testcases/ALDS1_1_A/header
#
# 各問題の入出力
# https://judgedat.u-aizu.ac.jp/testcases/ALDS1_1_A/1

const OUTPUT_PATH = if haskey(ENV, "JULIA_AOJ_PATH")
    ENV["JULIA_AOJ_PATH"]
elseif Sys.isunix() || Sys.islinux()
    joinpath(ENV["HOME"], ".juliaAOJ")
elseif Sys.iswindows()
    joinpath(ENV["HOMEPATH"], ".juliaAOJ")
end
@enum STATUS AC WA TLE RE

function jsonbody(res::HTTP.Messages.Response)
    JSON.parse(String(res.body))
end

function aoj_get(uri)
    HTTP.get(HTTP.safer_joinpath(endpoint, uri))
end

function validate_problemid(problemid)
    if ! isnothing(match(r"[^a-zA-Z0-9_]", problemid))
        error("Invalid Problem ID: $problemid")
    end
end

function get_samplecases(problemid)
    validate_problemid(problemid)
    uri = "testcases/samples/$(problemid)"
    res = retry(aoj_get, delays=Base.ExponentialBackOff(n=3))(uri)
    return jsonbody(res)
end

function get_header(problemid)
    validate_problemid(problemid)
    uri = "testcases/$(problemid)/header"
    res = retry(aoj_get, delays=Base.ExponentialBackOff(n=3))(uri)
    return jsonbody(res)
end

function get_testcases(problemid)
    validate_problemid(problemid)
    ncases = length(get_header(problemid)["headers"])
    testcases = sizehint!(Dict{String, Any}[], ncases)
    for id in 1:ncases
        uri = "testcases/$(problemid)/$(id)"
        res = retry(aoj_get, delays=Base.ExponentialBackOff(n=3))(uri)
        push!(testcases, jsonbody(res))
    end

    return testcases
end

function write_testcase(case, suffix="", force=false)
    problemid = case["problemId"]
    serial    = case["serial"]
    input     = case["in"]
    output    = case["out"]

    d = joinpath(OUTPUT_PATH, problemid * suffix, lpad(serial, 3, '0'))
    if !force && isdir(d)
        return nothing
    end
    mkpath(d)

    open(joinpath(d, "in.txt"), "w") do io
        print(io, input)
    end

    open(joinpath(d, "out.txt"), "w") do io
        print(io, output)
    end
end

function download_all_testcases(problemid, force=false)
    validate_problemid(problemid)
    (case -> write_testcase(case, "_sample", force)).(get_samplecases(problemid))
    (case -> write_testcase(case, "", force)).(get_testcases(problemid))
    println("Download all test cases for $(problemid)")
    return nothing
end

function compare_files(file1::String, file2::String)
    f1 = open(file1) do f
       SHA.sha2_256(f)
    end
    f2 = open(file2) do f
       SHA.sha2_256(f)
    end
    return f1 == f2
end

program = "ex.jl"
f = eval(quote
            function $(Symbol(randstring()))()
                include($(program))
            end
        end)


function judge(io, problemid, program; timelimit_sec = 3, issample = false) end
function test_sample(io, problemid, program) end

end # module
