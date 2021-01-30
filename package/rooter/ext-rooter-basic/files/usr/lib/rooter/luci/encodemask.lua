#!/usr/bin/lua

function hasbit(x, p)
	return x % (p + p) >= p
end

function bitor(x, y)
	local p = 1; local z = 0; local limit = x > y and x or y
	while p <= limit do
		if hasbit(x, p) or hasbit(y, p) then
			z = z + p
		end
		p = p + p
	end
	return z
end

mtab = {}
vtab = {1, 2, 4, 8}

for i = 1, 32 do
  mtab[i] = 0
end

numarg = #arg
for argval = 1, numarg do
	band = arg[argval]
	idx = math.floor((band - 1) / 4) + 1
	idxr = 33 - idx
	val = vtab[(band - ((idx - 1) * 4 ))]
	mtab[idxr] = bitor(mtab[idxr], tonumber(val))
end
for i = 1, 32 do
  mtab[i] = string.format("%X", mtab[i])
end
print(table.concat(mtab))
