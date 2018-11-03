using Test, AizuOnlineJudge

AizuOnlineJudge.settest(true)
t = 3
@test test_sample("ALDS1_1_B", "gcd.jl", t) == "AC"
@test test_sample("ALDS1_1_B", "gcd.jl", 0.1) == "TLE"
@test test_sample("ALDS1_1_B", "lcm.jl", t) == "WA"
@test test_sample("ALDS1_1_C", "gcd.jl", t) == "RE"
@test judge("ALDS1_1_B", "gcd.jl", t) == "AC"
@test judge("ALDS1_1_B", "gcd.jl", 0.1) == "TLE"
@test judge("ALDS1_1_B", "lcm.jl", t) == "WA"
@test judge("ALDS1_1_B", "re.jl", t) == "RE"
