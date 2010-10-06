require('client')


tclient = osc.client.new()

for i,d in pairs(tclient) do print(i,d) end
print(getmetatable(tclient).send)

tclient:send({'#bundle', os.time() + 0.1, {'/Pitch', 'f', 2.}})


function next_data(astring)
	local pos = 1
	local num_nzero = 0
	local num_zero = 0
	local result = ""
	for m in string.gmatch(astring, ".") do
		pos = pos + 1
		if m ~= '\0' and num_zero = 0 then
			num_nzero = (num_nzero + 1) % 4
			result = result .. m
		elseif m ~= '\0' and (num_zero + num_nzero) % 4 == 0 then
			return result, pos - 1
		elseif m == '\0' then
			num_zero = num_zero + 1
		else
			return nil
		end
	end
end	
