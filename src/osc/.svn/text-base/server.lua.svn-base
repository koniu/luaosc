--[[
	-- luaosc  Copyright (C) 2009  Jost Tobias Springenberg <k-gee@wrfl.de> --
	
    This file is part of luaosc.

    luaosc is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    luaosc is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.	
--]]

local base = _G
local string = require("string")
local table = require("table")
local socket = require("socket")
local osc = require("osc")
--------------------------------
-- Module declaration
--------------------------------
module("osc.server")

local meta_server = {
	loop = function (self)
		local length = 1024
		while 1 do
			local message, from = self.socket:receivefrom(1024)
			-- invoke handler function
			if message ~= nil then
				local success, result = base.pcall(osc.decode, message)	
				if not success then
					base.io.stderr:write("Error in decoding: \n" .. result)
				else
					success, result = base.pcall(self.handle, from, result)
					if not success then
						base.io.stderr:write("Error in your handler function: \n" .. result)
					end
				end
			end
			if message == "exit" then
				return
			end
		end
	end
}

function new( data )
	local instance = {}
	base.io.write("Port is: " .. data.port .. "\n")
	if data then 
		instance.host = data.host or '*' 
		instance.port = data.port or 7123
		instance.handle = data.handle or function (_, msg) 
											ptable = function(atable, depth) 
												for i,v in base.pairs(atable) do
													if base.type(v) == "table" then
														ptable(v, depth + 1)
													else
														base.print(string.rep("\t", depth), i, v)
													end
												end
											end
											base.io.write("Message received: " .. "\n")
											ptable(msg, 0)
										 end
		instance.name = data.name or "OSC Server at " .. instance.host .. ":" .. instance.port
	else
		-- just ensure that if no data is passed we still
		-- return a valid server instance
		return new{}
	end
	instance.socket = socket.udp() or error('error could not create lua socket object')
	instance.socket:setsockname(instance.host, instance.port) 
	instance.socket:settimeout(10)
	base.setmetatable(instance, meta_server)
	meta_server.__index = meta_server
	return instance
end


