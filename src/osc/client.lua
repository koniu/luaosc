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
module("osc.client")

local meta_client = {
	send = function (self, message)
		self.socket:send(osc.encode(message))
	end
}

function new( data )
	local instance = {}
	if data then 
		instance.host = data.host or "localhost" 
		instance.port = data.port or 7123
		instance.name = data.name or "OSC Client attached to " .. instance.host .. ":" .. instance.port
	else
		-- just ensure that if no data is passed we still
		-- return a valid client instance
		return new{}
	end
	instance.socket = socket.udp() or error('error could not create lua socket object')
	instance.socket:setpeername(instance.host, instance.port) 
	base.setmetatable(instance, meta_client)
	meta_client.__index = meta_client
	return instance
end


