local module = {}

local groups = {}

function module:Create(groupName, displayName, rank)
	if groups[groupName] then
		return false
	end	
	
	local group = {}
	
	group.DevName = groupName
	group.DisplayName = displayName
	
	group.Rank = rank or 1

	group.Permissions = {}
	group.ImmunityTags = {}	
	
	group.SuperAdmin = false -- Does this group always have ALL PERMISSIONS and IMMUNITY TAGS?	
	
	group.Players = {}
	
	group["__index"] = function (t, k)
		return group[k]
	end	

	function group:CanTargetPlayer(ply)
		
	end
	
	function group:AddPlayer(ply)
		if type(ply) == "userdata" and ply:IsA("Player") then
			ply = ply.UserId
		elseif type(ply) ~= "number" then
			error("Argument \"ply\" must be a Player or number.")
		end

		if group:IsPlayerIn(ply) then
			return false
		end		
		
		table.insert(group.Players, ply)
		return true
	end
	
	function group:IsPlayerIn(ply)
		if type(ply) == "userdata" and ply:IsA("Player") then
			ply = ply.UserId
		elseif type(ply) ~= "number" then
			error("Argument \"ply\" must be a Player or number.")
		end
		
		for i,v in pairs(group.Players) do
			if v == ply then
				return true
			end
		end
		return false
	end	
	
	function group:RemovePlayer(ply)
		if type(ply) == "userdata" and ply:IsA("Player") then
			ply = ply.UserId
		elseif type(ply) ~= "number" then
			error("Argument \"ply\" must be a Player or number.")
		end
		
		if not group:IsPlayerIn(ply) then
			return false
		end				
		
		table.remove(group.Players, ply)
		return true
	end
	
	function group:AddPermission(perm) 
		if type(perm) ~= "string" and type(perm) ~= "table" then error("Argument \"perm\" must be a string or a table.") end		
		
		if group.SuperAdmin then
			return false
		end
		
		if type(perm) == "table" then
			local tbl = {}
			for i,v in pairs(perm) do
				table.insert(tbl, group:AddPermission(v))
			end
			return tbl
		else
			if group:HasPermission(perm) then
				return false
			end
			table.insert(group.Permissions, perm)
			return true
		end
	end
	
	function group:RemovePermission(perm)
		if type(perm) ~= "string" then error("Argument \"perm\" must be a string.") end			
		
		if group.SuperAdmin then
			return false
		end			
		
		for i,v in pairs(group.Permissions) do
			if v == perm then
				table.remove(group.Permissions, i)
				return true
			end
		end
		return false
	end
	
	function group:HasPermission(perm)
		if type(perm) ~= "string" then error("Argument \"perm\" must be a string.") end			
		
		if group.SuperAdmin then
			return true -- No matter what, Super Admin groups always have all permissions.
		end			
		
		for i,v in pairs(group.Permissions) do
			if v == perm then
				return true
			end
		end
		return false
	end
	
	group["__newindex"] = function (t, k, v)
		if k == "DisplayName" then
			if type(v) == "string" then
				group[k] = v
				return
			else
				error(string.format("Property \"%s\" must be a string.", k))
			end
		elseif k == "SuperAdmin" then
			if type(v) == "boolean" then
				group[k] = v
				return
			else
				error(string.format("Property \"%s\" must be a boolean.", k))
			end
		end
		error("Group is read-only.")
	end	
	
	groups[groupName] = setmetatable({}, group)
	
	return groups[groupName]
end

function module:GetGroupsPlayerIsIn(ply)
	if type(ply) == "userdata" and ply:IsA("Player") then
		ply = ply.UserId
	elseif type(ply) ~= "number" then
		error("Argument \"ply\" must be a Player or number.")
	end
	
	local tbl = {}	
	
	for i,group in pairs(groups) do
		if group:IsPlayerIn(ply) then
			table.insert(tbl, group)
		end
	end
	
	return tbl
end

function moudle:CanGroupTargetPlayer(group, ply)
	local groups = module:GetGroupsPlayerIsIn(ply)

	table.sort(groups, function (a, b)
		return (a.Rank < b.Rank)
	end)

	local highestRank = groups[1].Rank

	print(highestRank)
end

function module:CreateSystemGroups()
	local ownerGroup = module:Create("owner", "Owner")

	ownerGroup.SuperAdmin = true -- Tells OpenAdmin that this group has all permissions and immunity tags.
	
	local everyoneGroup = module:Create("everyone", "Everyone")
	local adminGroup = module:Create("admin", "Admin")
end

function module:Everyone()
	return module:Get("everyone")
end

function module:Owner()
	return module:Get("owner")
end

function module:Admin()
	return module:Get("admin")
end

function module:Get(groupName)
	return groups[groupName]
end

-- Functions that allow plugins to extend group functionality

function module:RegisterHandler(moduleName)

end

return module
