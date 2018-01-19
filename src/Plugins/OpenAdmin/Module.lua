--[[
	OpenAdmin plugin for OpenAdmin.
	
	This is where I implement all of the commands and possibly some groups.
--]]

local OpenAdmin = {}

-- module.GroupManager

function OpenAdmin:Init()
	local GM = OpenAdmin.GroupManager
	GM:Everyone():AddPermission({"perm_name", "perm_name2"}) -- Get the everyone group and add permission.
	-- Adding permissions in the plugin module should not override user specified settings. So that means group settings will be loaded last.
	
	GM:RegisterHandler("Default") -- Name of handler module (place your group manager module in YourPluginFolder.GroupsManagers)

	local Settings = OpenAdmin.Settings
	print(Settings["Test.TestString"])
end

return OpenAdmin
