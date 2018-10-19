# ALDS1_1_B
x, y = parse.(Int, split(readline()))
mygcd(x,y) = y == 0 ? x : mygcd(y, mod(x,y))
println(div(x*y, mygcd(x,y)))
