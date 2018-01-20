local module = {}

local GroupManagerModule

local Handlers = {}

function module:RegisterHandler(handlerName)
	local env = getfenv(2)

	local handlerModule = env["script"].Parent:WaitForChild("GroupManagers"):WaitForChild(handlerName)

	Handlers[handlerModule.Name] = require(handlerModule)
end

function module:LoadGroupManager()
	local ManagerName = "Default" -- TODO: Add this as a setting.
	
	if not Handlers[ManagerName] then
		error(string.format("[OpenAdmin] [GroupManager] Group Manager \"%s\" does not exist or has not been registered using GroupManager:RegisterHandler", ManagerName))
	end

	GroupManagerModule = Handlers[ManagerName]

	-- TODO: Add a way to access settings.

	if type(GroupManagerModule["Initialize"]) == "function" then
		GroupManagerModule:Initialize()
	end

	print(string.format("[OpenAdmin] [GroupManager] Using Group Manager Module \"%s\"!", ManagerName))
end

local function ToUserId(ply)
    if typeof(ply) ~= "Instance" or typeof(ply) ~= "number" then
        return nil
    end

    if typeof(ply) == "Instance" and ply:IsA("Player") then
        return ply.UserId
    elseif typeof(ply) == "number" then
        return ply
    else
        return nil
    end
end

function mt_group_equ(self, other)
    return self.Name == other.Name
end

-- Group Management

function module:AddGroup(groupName)
	return GroupManagerModule:AddGroup(groupName)
end

function module:RemoveGroup(groupName)
	return GroupManagerModule:RemoveGroup(groupName)
end

function module:GetGroups() -- TODO: Copy table given by module
	return GroupManagerModule:GetGroups()
end

-- Player Management

function module:AddPlayerToGroup(userId, groupName)
    return GroupManagerModule:AddPlayerToGroup(userId, groupName)
end

function module:GetPlayersInGroup(groupName)
    return GroupManagerModule:GetPlayersInGroup(groupName)
end

function module:RemovePlayerFromGroup(userId, groupName)
    return GroupManagerModule:RemovePlayerFromGroup(userId, groupName)
end

function module:IsPlayerInGroup(groupName, ply)
    local players = module:GetPlayersInGroup(groupName)
    local uid = ToUserId(ply)

    for _, userid in pairs(players) do
        if userid == uid then
            return true
        end
    end
    return false
end

-- Permission Management

function module:AddPermissionToGroup(permission, groupName)
    return GroupManagerModule:AddPermissionToGroup(userId, groupName)
end

function module:GetPermissions(groupName)
    return GroupManagerModule:GetPermissions(groupName)
end

function module:RemovePermissionFromGroup(permission, groupName)
    return GroupManagerModule:RemovePermissionFromGroup(userId, groupName)
end

function module:DoesGroupHavePermission(groupName, perm)
    local players = module:GetPermissions(groupName)

    for _, permission in pairs(players) do
        if permission == perm then
            return true
        end
    end

    return false
end

-- Object Oriented Programming

function module:AsObject(groupName)
    local group = {}

    group.Name = groupName

    -- Player Management

    function group:AddPlayer(ply)
        return module:AddPlayerToGroup(ToUserId(ply), group.Name)
    end

    function group:IsPlayerIn(ply)
        return module:IsPlayerInGroup(group.Name, ply)
    end

    function group:RemovePlayer(ply)
        return module:RemovePlayerFromGroup(ToUserId(ply), group.Name)
    end

    -- Permissions

    function group:AddPermission(perm)
        return module:AddPermissionToGroup(perm, group.Name)
    end

    function group:RemovePermission(perm)
        return module:RemovePermissionFromGroup(perm, group.Name)
    end

    function group:HasPermission(perm)
        return module:DoesGroupHavePermission(group.Name, perm)
    end

    group["__index"] = function (t, k)
        if k == "Players" then
            return module:GetPlayersInGroup(groupName)
        elseif k == "Permissions" then
            return module:GetPermissionsInGroup(groupName)
        end

		return group[k]
    end

    group["__tostring"] = function (self)
        return "Group[Name=".. group.Name .."]"
    end

    group["__eq"] = mt_group_equ -- Do two groups equal?
    
    return setmetatable({}, group)
end

return module