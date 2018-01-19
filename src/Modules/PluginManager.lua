local module = {}

local Plugins = script.Parent.Parent:WaitForChild("Plugins")
local CmdManager = require(script.Parent:WaitForChild("CommandManager"))
local GroupManager = require(script.Parent:WaitForChild("GroupManager"))
local Settings = require(script.Parent:WaitForChild("Settings"))

local plugins = {}

local function AttemptCall(tbl, funcName, ...)
	if tbl[funcName] then
		return tbl[funcName](...)
	end
end

local SETTING_DELIM = "."

function split_str(self, sep)
   local sep, fields = sep or ".", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

local OpenAdminRootSettings = script.Parent.Parent:WaitForChild("Settings")

local function LoadPlugin(v, isOpenAdmin) -- v: PLugin Folder. isOpenAdmin: Is the plugin the OpenAdmin plugin?
	print(string.format("[OpenAdmin] [PluginManager] Attempting to load OpenAdmin plugin \"%s\"!", v.Name))
	plugins[v.Name] = require(v.Module)

	if plugins[v.Name].Disabled then
		warn(string.format("[OpenAdmin] [PluginManager] Not loading \"%s\", plugin is disabled!", v.Name))
		return
	end
	
	-- Inject values into plugin module.	
	
	plugins[v.Name].DevName = v.Name
	
	-- Inject common modules that most plugins will want to use.
	plugins[v.Name].GroupManager = GroupManager
	plugins[v.Name].Settings = Settings
	
	if v:FindFirstChild("Commands") then
		CmdManager:RegisterInCommandsFolder(v.Commands)	
	end

	local configSchemaValue = v:FindFirstChild("SettingsSchema.json") or v:FindFirstChild("SettingsSchema")

	if configSchemaValue then
		-- Parse the ConfigSchema and create the values

		local Settings = v:FindFirstChild("Settings")
		if not Settings then
			Settings = Instance.new("Folder", v)
			Settings.Name = "Settings"
		end

		local settingsTable = game:GetService("HttpService"):JSONDecode(configSchemaValue.Value)

		if settingsTable then
			for _, setting in pairs(settingsTable) do -- TODO: Error Handling
				local split = split_str(setting.Name, SETTING_DELIM)

				local parent = Settings

				if setting.Root and isOpenAdmin then -- Only the OpenAdmin plugin can create a root setting (a settings in the OpenAdmin folder)
					parent = OpenAdminRootSettings
				end

				local found = false

				for i,v in pairs(split) do
					if i ~= #split then
						-- Create folder if none exists
						local folder = parent:FindFirstChild(v)
						if not folder then
							folder = Instance.new("Folder", parent)
							folder.Name = v
						end

						parent = folder
					elseif parent:FindFirstChild(v) then
						found = true
					end
				end

				if not found then
					local Value = Instance.new(setting.Type .. "Value")
					
					Value.Name = split[#split] -- Get last value in table.
					
					if setting.Default then
						Value.Value = setting.Default
					end

					Value.Parent = parent
				end
			end
		else
			warn(string.format("[OpenAdmin] [PluginManager] Could not parse Settings Schema in \"%s\"", v.Name))
		end
	end
	
	local args = {}
	local s, r = pcall(function ()
		AttemptCall(plugins[v.Name], "Init", unpack(args))
	end)
	if not s then
		warn(string.format("[OpenAdmin] [PluginManager] Plugin function \"%s:%s\" did not run properly: %s", v.Name, "Init", r))
	end
	
	print(string.format("[OpenAdmin] [PluginManager] Loaded OpenAdmin plugin \"%s\"!", v.Name))
end

function module:GetPluginFolders()
	return Plugins:GetChildren()
end

function module:LoadPlugins()
	LoadPlugin(Plugins:WaitForChild("OpenAdmin"), true) -- Make sure that OpenAdmin plugin loads first!	
	
	for i,v in pairs(Plugins:GetChildren()) do -- Should I create a load order for plugins?
		if v.Name ~= "OpenAdmin" then -- Do not load OpenAdmin plugin again
			LoadPlugin(v)
		end
	end
end

function module:CallAllPlugins(funcName, ...)
	for i,v in pairs(plugins) do
		local args = {...}
		local s, r = pcall(function ()
			AttemptCall(v, funcName, unpack(args))
		end)
		if not s then
			warn(string.format("[OpenAdmin] [PluginManager] Plugin function \"%s:%s\" did not run properly: %s", i, funcName, r))
		end
	end
end

return module
