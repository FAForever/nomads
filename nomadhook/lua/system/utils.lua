-- count the number of occurences of val as value in t
function table.count(t, val)
    local n = 0
    for k, v in t do
        if v == val then n = n + 1 end
    end
    return n
end
