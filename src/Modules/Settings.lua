local settings = {}

local SettingsFolder = script.Parent.Parent:FindFirstChild("Settings")

if not SettingsFolder then
	SettingsFolder = Instance.new("Folder", script.Parent.Parent)
	SettingsFolder.Name = "Settings"
end

local SETTING_DELIM = "."

function split(self, sep)
   local sep, fields = sep or ".", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

local function GetPluginFolders()
	return script.Parent.Parent:WaitForChild("Plugins"):GetChildren()
end

local function GetSettingObjectFromPlugins(setting)
	local e = split(setting, SETTING_DELIM)
	local plugins = GetPluginFolders()
	
	for i,v in pairs(plugins) do
		local obj = v:FindFirstChild("Settings")
		
		if obj then
			for i,v in pairs(e) do
				if obj:FindFirstChild(v) then
					obj = obj:FindFirstChild(v)
				else
					obj = nil
					break
				end
			end
			if obj then
				return obj
			end
		end
	end
	return nil
end

function settings:GetSettingObject(k)
	local e = split(k, SETTING_DELIM)
	local obj = SettingsFolder
	
	for i,v in pairs(e) do
		if obj:FindFirstChild(v) then
			obj = obj:FindFirstChild(v)
		else
			obj = nil
			obj = GetSettingObjectFromPlugins(k)
			if obj then
				return obj.Value
			end
			return nil
		end
	end
end

settings["__index"] = function (t, k)
	if k == "GetSettingObject" then
		return settings["GetSettingObject"]
	end
	local e = split(k, SETTING_DELIM)
	local obj = SettingsFolder
	
	for i,v in pairs(e) do
		if obj:FindFirstChild(v) then
			obj = obj:FindFirstChild(v)
		else
			obj = GetSettingObjectFromPlugins(k)
			if obj then
				return obj.Value
			end
			return nil
		end
	end
	
	return obj.Value
end

settings["__newindex"] = function (t, k, v)
	local e = split(k, SETTING_DELIM)
	local obj = SettingsFolder
	
	for i,v2 in pairs(e) do
		if obj:FindFirstChild(v2) then
			obj = obj:FindFirstChild(v2)
		else
			obj = GetSettingObjectFromPlugins(k)
			if obj then
				obj.Value = v
				return
			end
			error(string.format("Invalid setting \"%s\.", k))
		end
	end
	
	obj.Value = v
end


return setmetatable({}, settings)