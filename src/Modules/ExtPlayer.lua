local m = {}

local GroupManager = require(script.Parent:WaitForChild("GroupManager"))
local Settings = require(script.Parent:WaitForChild("Settings"))

function m.new(speaker, channelName)
	local pl = {}
	
	pl.SpeakerObject = speaker
	
	function pl:GetPlayer()
		return pl.SpeakerObject:GetPlayer() -- If there is "no" speakerobject, then there will only be this function.
	end	
	
	function pl:GetGroupsIn()
		return GroupManager:GetGroupsPlayerIsIn(pl:GetPlayer())
	end	
	
	function pl:HasPermission(perm)
		if type(perm) ~= "string" then
			error("Argument \"perm\" must be a Group or string.")
		end			
		
		for i,group in pairs(pl:GetGroupsIn()) do
			if group:HasPermission(perm) then
				return true
			end
		end
		return false
	end	
	
	function pl:IsInOAGroup(name) -- OpenAdmin Group
		if type(name) == "userdata" and name.DevName then
			name = name.DevName
		elseif type(name) ~= "string" then
			error("Argument \"name\" must be a Group or string.")
		end		
		
		for i,group in pairs(pl:GetGroupsIn()) do
			if group.DevName == name then
				return true
			end
		end
		return false
	end	
	
	local ch = channelName
	
	function pl:Tell(msg)
		if not ch then
			return false
		end
		pl.SpeakerObject:SendSystemMessage(msg, ch)
		return true
	end

	--[[
		Tells a user a message. The prefix for the Admin Commands (Most likely "[OpenAdmin]" unless you changed a setting) will be added to the message.
	--]]
	function pl:TellWithPrefix(msg)
		return pl:Tell(string.format("[%s] %s", Settings["BrandingName"] or "OpenAdmin", msg))
	end
	
	pl["__index"] = function (t, k)
		return pl[k]
	end		
	
	pl["__newindex"] = function (t, k, v)
		error("ExtPlayer is read-only.")
	end
	
	return setmetatable({}, pl)
end

function m.fromPlayer(ply, chatService)
	if chatService then
		return m.new(chatService:GetSpeaker(ply.Name))
	else
		return m.new({["GetPlayer"] = function () return ply end }) -- Yes, I just did a hack for a hack of metatables.
	end
end

return m