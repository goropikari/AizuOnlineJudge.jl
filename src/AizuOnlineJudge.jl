module AizuOnlineJudge
export judge, test_sample

using HTTP, JSON, SHA, Dates
const endpoint = "https://judgedat.u-aizu.ac.jp/testcases"
const julia = Base.julia_cmd().exec[1]
if haskey(ENV, "JULIA_AOJ_PATH")
    const PATH = ENV["JULIA_AOJ_PATH"]
else
    if Sys.isunix() || Sys.islinux()
        const PATH = joinpath(ENV["HOME"], ".juliaAOJ")
    elseif Sys.iswindows()
        const PATH = joinpath(ENV["HOMEPATH"], ".juliaAOJ")
    end
end
@enum STATUS AC WA TLE RE

function expandpath(path::String)
    if Sys.isunix() || Sys.islinux()
        path = replace(path, "~" => homedir())
    end
    return normpath(path)
end

aojurl(arg...) = joinpath(endpoint, arg...)
get_body!(r) = JSON.parse(String(r.body))

function clean()
    rm(PATH, force=true, recursive=true)
end

"""
    download_header(problemId::String)
"""
function download_header(problemId::String)
    r = HTTP.request("GET", aojurl(problemId, "header"))
    get_body!(r)
end

"""
    download_testcase(problemId::String, serial::Int)
Download a test case
"""
function download_testcase(problemId::String, serial::Int)
    r = HTTP.request("GET", aojurl(problemId, string(serial)))
    body = get_body!(r)
    open(joinpath(PATH, problemId, "in$serial.txt"), "w") do fp
        print(fp, body["in"])
    end
    open(joinpath(PATH, problemId, "out$serial.txt"), "w") do fp
        print(fp, body["out"])
    end
end

"""
    download_samplecases(problemId::String)
"""
function download_samplecases(problemId::String)
    store_path = joinpath(PATH, problemId, "samples")
    ispath(store_path) && return
    mkpath(store_path)

    r = HTTP.request("GET", aojurl("samples", problemId))
    body = get_body!(r)
    for item in body
        serial = item["serial"]
        open(joinpath(store_path, "in$serial.txt"), "w") do fp
            print(fp, item["in"])
        end
        open(joinpath(store_path, "out$serial.txt"), "w") do fp
            print(fp, item["out"])
        end
    end
end

"""
    download_testcases(problemId::String)
Download test cases associated with `problemId`.
"""
function download_testcases(problemId::String)
    store_path = joinpath(PATH, problemId)
    (ispath(store_path) && length(readdir(store_path)) >= 2) && return
    mkpath(store_path)

    header = download_header(problemId)
    n = length(header["headers"]) # thu number of test cases
    for serial in 1:n
        download_testcase(problemId, serial)
    end
    return
end

"""
    compare_files(file1::String, file2::String)
"""
function compare_files(file1::String, file2::String)
    f1 = open(file1) do f
       sha2_256(f)
    end
    f2 = open(file2) do f
       sha2_256(f)
    end
    return f1 == f2
end

"""
    run_file(filename::String,
             tlimit::Real,
             serial::Int,
             testcases_dir::String,
             myoutput_dir::String)
Execute your program.

# Return value:
- execution time: if result is AC or WA.
- RE            : if result is RE.
- TLE           : if resulit is TLE.
"""
function run_file(filename::String,
                  tlimit::Real,
                  serial::Int,
                  testcases_dir::String,
                  myoutput_dir::String)
    filename = expandpath(filename)
    ispath(filename) || error("could not open file $filename")
    c = Channel{String}(1)
    time_start = now()

    input_test = joinpath(testcases_dir, "in$(serial).txt")
    output_test = joinpath(myoutput_dir, "myout$(serial).txt")
    pipe = pipeline(`$julia $filename`, stdin=input_test, stdout=output_test, stderr=devnull)
    proc = run(pipe, wait=false)
    @async begin
        wait(proc)
        if proc.exitcode == 0
            time_finish = now()
            put!(c, string(time_finish - time_start))
        elseif proc.exitcode == 1
            put!(c, "RE")
        end
    end
    @async begin
        sleep(tlimit)
        put!(c, "TLE")
        kill(proc)
    end

    return take!(c)
end

function show_each_result(io::IO, serial::Int, issamefile::Bool, result::String, total_result::Int)
    problem_serial = lpad(serial, 5)
    print(io, problem_serial, " | ")
    if issamefile
        printstyled(io, "  AC   ", color=:light_green)
        println(io, "| ", result)
    elseif result == "TLE"
        printstyled(io, "  TLE  ", color=:light_red)
        println(io, "| ")
        total_result = Int(TLE)
    elseif result == "RE"
        printstyled(io, "  RE   ", color=:light_red)
        println(io, "| ")
        total_result = Int(RE)
    else
        printstyled(io, "  WA   ", color=:light_red)
        println(io, "| ", result)
        total_result = Int(WA)
    end
    return total_result
end

"""
    judge(problemId::String, filename::String, tlimit::Real=1, issample::Bool=false)
    judge(io::IO, problemId::String, filename::String, tlimit::Real=1, issample::Bool=false)
"""
function judge(io::IO, problemId::String, filename::String, tlimit::Real=1, issample::Bool=false)
    filename = expandpath(filename)
    ispath(filename) || error("could not open file $filename")

    testcases_dir = if issample
        download_samplecases(problemId)
        joinpath(PATH, problemId, "samples")
    else
        download_testcases(problemId)
        joinpath(PATH, problemId)
    end

    num_testcases = sum(occursin.("txt", readdir(testcases_dir))) >> 1
    myoutput_dir = joinpath(testcases_dir, "mysubmission")
    mkpath(myoutput_dir)

    # Judge
    total_result = 0
    println(io, "--------------------------------")
    println(io, " Test | Status | Exec Time      ")
    println(io, "  No. |        |                ")
    println(io, "--------------------------------")
    for serial in 1:num_testcases
        result = run_file(filename, tlimit, serial, testcases_dir, myoutput_dir)
        correctresult = joinpath(testcases_dir, "out$(serial).txt")
        myresult = joinpath(myoutput_dir, "myout$(serial).txt")
        issamefile = compare_files(correctresult, myresult)
        total_result = show_each_result(io, serial, issamefile, result, total_result)
    end

    println(io)
    print(io, "Status :" )
    total_result == 0 && printstyled(io, " AC ", color=:light_green)
    total_result == Int(TLE) && printstyled(io, " TLE ", color=:light_red)
    total_result == Int(WA) && printstyled(io, " WA ", color=:light_red)
    total_result == Int(RE) && printstyled(io, " RE ", color=:light_red)
    println(io)
    return string(STATUS(total_result))
end
function judge(problemId::String, filename::String, tlimit::Real=1, issample::Bool=false)
    judge(stdout, problemId, filename, tlimit, issample)
end

"""
    test_sample(problemId::String, filename::String, tlimit::Real=1)
    test_sample(io::IO, problemId::String, filename::String, tlimit::Real=1)
"""
function test_sample(io::IO, problemId::String, filename::String, tlimit::Real=1)
    judge(io, problemId, filename, tlimit, true)
end
function test_sample(problemId::String, filename::String, tlimit::Real=1)
    test_sample(stdout, problemId, filename, tlimit)
end

end # module
