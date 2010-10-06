local base = _G
local string = require("string")
local table = require("table")
-- local socket = require("socket") -- only needed in client / server
local lpack = require("pack")
local pack = string.pack
local upack = string.unpack

--------------------------------
-- Module declaration
--------------------------------
module("osc")

--------------------------------
-- Declare Version
--------------------------------

_VERSION = "OSC 1.0.0"

--------------------------------
-- some constants
--------------------------------

PROTOCOL = "OSC/1.0"

ADJUSTMENT_FACTOR = 2208988800

IMMEDIATE = string.rep('0', 31) .. '1'

-- the following should match exactly one part of
-- a given osc message, including filiing zeros
-- TODO: this is ugly, make it more convenient if possible
OSC_MATCH_ZEROS = "(([^%z][^%z][^%z][^%z])*(([^%z][^%z][^%z]%z)|([^%z][^%z]%z%z)|([^%z]%z%z%z)|(%z%z%z%z)))"

--------------------------------
-- interface functions: 
--     decode(string) 
-- and encode(table)
--------------------------------

function decode(data) 
---[[
	if #data == 0 then
		return nil
	end
	if string.match(data, "^#bundle") then
		return decode_bundle(data)
	else
		return decode_message(data)
	end
--]]
end

function encode(data)
	local msg = ""
	local idx = 1
	if data == nil then
		return nil
	end
		
	if data[1] == "#bundle" then
		msg = msg .. encode_string(data[1])
		msg = msg .. encode_timetag(data[2])
		idx = 3
		while idx <= #data do
			local submsg = encode(data[idx])
			msg = msg .. encode_int(#submsg) .. submsg
			idx = idx + 1
		end
		return msg
	else
		local typestring = ","
		local encodings = ""
		idx = idx + 1
		msg = msg .. encode_string(data[1])
		for t, d in iter_pairwise(data, idx) do
			typestring = typestring .. t
			encodings = encodings .. collect_encoding_for_message(t, d)
		end
		return msg .. encode_string(typestring) .. encodings
	end
end

--------------------------------
-- auxilliary functions
--------------------------------

function next_data(astring)
	-- this is a workaraound because the lua pttern matching is 
	-- not as powerful as pcre and I did not want to include another
	-- dependecy to an external re lib
	local pos = 1
	local num_nzero = 0
	local num_zero = 0
	local result = ""
	for m in string.gmatch(astring, ".") do
		pos = pos + 1
		if m ~= '\0' and num_zero == 0 then
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


function iter_pairwise(atable, startvalue)
	local index = startvalue - 2
	return function()
		index = index + 2
		return atable[index], atable[index+1]
	end
end

function collect_encoding_for_message(t, data)
	if t == 'i' then
		return encode_int(data)
	elseif t == 'f' then
		return encode_float(data)
	elseif t == 's' then
		return encode_string(data)
	elseif t == 'b' then
		return encode_blob(data)
	end
end

function collect_decoding_from_message(t, data, message)
	if t == 'i' then
		table.insert(message, decode_int(data))
		return string.sub(data, 4)
	elseif t == 'f' then
		table.insert(message, decode_float(data))
		return string.sub(data, 4)
	elseif t == 's' then
		local matches = string.match(data, OSC_MATCH_ZEROS .. "(.*)")
		table.insert(message, matches[1])
		return matches[#matches]
	elseif t == 'b' then
		local length = decode_int(data)
		table.insert(message, string.sub(data, 4, length))
		return string.sub(data, 4 + length)
	end
end

function get_addr_from_data(data)
	local matches = {string.match(data, OSC_MATCH_ZEROS .. "(.*)")}
	local typestring = matches[1] -- first match should be the type string
	local result = ""
	for t in string.gmatch(typestring, "[^%z]") do
		result = result .. t
	end
	return result, matches[#matches]
end

function get_types_from_data(data)
	local matches = {string.match(data, OSC_MATCH_ZEROS .. "(.*)")}
	local typestring = matches[1] -- first match should be the type string
	local result = {}
	for t in string.gmatch(typestring, "[^,%z]") do
		table.insert(result, t)
	end
	return result, matches[#matches]
end

--------------------------------
-- decoding functions
--------------------------------

function decode_message(data)
	local types, addr, tmp_data = nil
	local message = {}
	addr, tmp_data = get_addr_from_data(data)
	types, tmp_data = get_types_from_data(tmp_data)
	-- ensure that there was something found
	if addr == nil or types == nil then
		return nil
	end
	for _,t in ipairs(itypes) do
		tmp_data = collect_decoding_from_message(t, tmp_data, message)
	end
	return message
end


function decode_bundle(data) 
	local tmp_data = {string.match(data, OSC_MATCH_ZEROS .. "(.*)")}
	local msg = {}
	local sec, frac
	tmp_data = tmp_data[#tmp_data]
	-- check whether we found something
	if not tmp_data then
		return nil
	end
	table.insert(msg, "#bundle")	
	sec, frac = upack(">L>L", string.sub(tmp_data, 1,4))
	frac = string.format("%c", frac)
	if sec == 0 and frac == IMMEDIATE then
		table.insert(msg, 0)
	else
		table.insert(msg, secs - NTP_ADJUSTMENT + decode_frac(frac) )
	end
	while #tmp_data ~= 0 do
		local length = decode_int(tmp_data)
		table.insert(msg, decode(string.sub(tmp_data, 4 + length)))
		tmp_data = string.sub(tmp_data, 4 + length)
	end
	return msg
end

function decode_frac(bin)
	local frac = 0
	for i=#bin,1 do
		frac = (frac + string.sub(bin, i-1, i)) / 2
	end
	return frac
end	

function decode_float(bin)
	return upack(">f", bin)
end

function decode_int(bin)
	return upack(">I", bin)
end

--------------------------------
-- encoding
--------------------------------

function encode_string(astring) 
	local fillbits = (4 - #astring % 4)
	return astring .. string.rep('\0', fillbits)
end

function encode_int(num)
	return pack(">L", num) -- former was string.format("%c", num)
end

function encode_blob(blob)
	return encode_int(#blob) .. encode_string(#blob)
end

function encode_timetag(tpoint)
	if tpoint == 0 then
		return IMMEDIATE
	else
		local sec = base.math.floor(tpoint)
		local frac = tpoint - sec
		return pack(">L>L", sec + ADJUSTMENT_FACTOR, encode_frac(frac))
	end
end

function encode_frac(num) 
	local bin = ""
	local frac = num
	while #bin < 32 do
		bin = bin .. base.math.floor(frac * 2)
		frac = (frac * 2) - base.math.floor(frac * 2)
	end
	return bin
end

function encode_float(num)
	return pack(">f", num)
end
