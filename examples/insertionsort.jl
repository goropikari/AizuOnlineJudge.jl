# ALDS1_1_A
n = parse(Int, readline())
v = parse.(Int, split(readline()))

function print_vec(v)
    n = length(v)
    for i in 1:n
        if i == 1
            print(v[i])
        else
            print(" ", v[i])
        end
    end
    println()
end

print_vec(v)
for i in 2:n
    a = v[i]
    j = i-1
    while j > 0 && v[j] > a
        v[j], v[j+1] = v[j+1], v[j]
        j -= 1
    end
    v[j+1] = a
    print_vec(v)
end

