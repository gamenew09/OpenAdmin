--[[
    The default GroupManager extension
--]]

local module = {}

module.DynamicGroups = true -- Can a player that is allowed to create a group, create a group?

module.SettingsSchema = {
    {
        ["Type"] = "String", -- String, Number, Integer
        ["Name"] = "DataStoreName",
        ["DefaultValue"] = "OpenAdmin"
    },
    {
        ["Type"] = "String", -- String, Number, Integer
        ["Name"] = "DataStoreKey",
        ["DefaultValue"] = "Groups"
    }
}

module.GroupSettingsSchema = { -- These settings are per-group.
    {
        ["Type"] = "Integer", -- String, Number, Integer
        ["Name"] = "Rank",
        ["DefaultValue"] = 1 
    }
}

-- If you need to access a setting, use module.Settings

local groups = {}

function module:Initialize()
    module:AddGroup("Everyone")
    module:AddGroup("Admin")
end

-- List of Groups

--[[
    Parameters:
        groupName - String - The name of the group that is going to be added.
--]]
function module:AddGroup(groupName)
    if groups[groupName] then
        return false
    end

    groups[groupName] = {
        ["Permissions"] = { }, -- Permissions as strings
        ["Players"] = { }
    }
    return true
end

function module:RemoveGroup(groupName)
    groups[groupName] = nil
    return true
end

function module:GetGroups()
    -- This has to be returned in a specific format.
    --[[
        return {
            ["GroupName"] = {
                ["Permissions"] = {"perm_name", ...}, -- Permissions as strings
                ["Players"] = { 123456 } -- Players put here should be as a UserId (this will allow for checking targeting even if a player isn't in the game).
            }
        }
    --]]
    return groups
end

-- Player Management

function module:AddPlayerToGroup(userId, groupName)
    if not groups[groupName] then
        return false
    end

    local plys = groups[groupName]["Players"]
    
    for _, userid in pairs(plys) do
        if userid == userId then
            return false
        end
    end

    table.insert(plys, userId)

    return true
end

function module:RemovePlayerFromGroup(userId, groupName)
    if not groups[groupName] then
        return false
    end

    local plys = groups[groupName]["Players"]
    
    local index = 0

    for i, userid in pairs(plys) do
        if userid == userId then
            index = i
        end
    end

    if index == 0 then
        return false
    end

    table.remove(plys, index)

    return true
end

-- Permission Management

function module:AddPermissionToGroup(permission, groupName)
    if not groups[groupName] then
        return false
    end

    local perms = groups[groupName]["Permissions"]
    
    for _, perm in pairs(perms) do
        if permission == perm then
            return false
        end
    end

    table.insert(perms, permission)

    return true
end

function module:HasPermission(groupName, permission)
    return true
end

function module:RemovePermissionFromGroup(permission, groupName)
    if not groups[groupName] then
        return false
    end

    local perms = groups[groupName]["Permissions"]
    
    local index = 0

    for i, perm in pairs(perms) do
        if permission == perm then
            index = i
        end
    end

    if index == 0 then
        return false
    end

    table.remove(perms, index)

    return true
end

-- TODO: Handle a way to prevent groups from targeting other groups

return module