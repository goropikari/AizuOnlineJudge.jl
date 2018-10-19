using Test, AizuOnlineJudge

@test test_sample("ALDS1_1_B", "gcd.jl") == "AC"
@test test_sample("ALDS1_1_B", "gcd.jl", 0.1) == "TLE"
@test test_sample("ALDS1_1_B", "lcm.jl") == "WA"
@test test_sample("ALDS1_1_C", "gcd.jl", 3) == "RE"
@test judge("ALDS1_1_B", "gcd.jl") == "AC"
@test judge("ALDS1_1_B", "gcd.jl", 0.1) == "TLE"
@test judge("ALDS1_1_B", "lcm.jl") == "WA"
@test judge("ALDS1_1_B", "re.jl", 3) == "RE"
