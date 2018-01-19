local module = {}

local cmds = {}

function module:Register(moduleObject)
	local module = require(moduleObject)
	-- TODO: Should we allow overriding commands?
	cmds[module.CommandName] = module
	return true
end

function module:GetByCmdName(cmdName)
	return cmds[cmdName]
end

local function RecursiveLook(par, classType, func)
	for i,v in pairs(par:GetChildren()) do
		if v:IsA(classType) then
			func(v)
		elseif v:IsA("Folder") then
			RecursiveLook(v, classType, func)
		end
	end
end

function module:RegisterInCommandsFolder(folder)
	local pluginName = folder and folder.Parent.Name or "OpenAdmin"	
	
	local c = 0
	
	RecursiveLook(folder or script.Parent.Parent:WaitForChild("Commands"), "ModuleScript",function (m)
		if module:Register(m) then
			c = c + 1
		end
	end)
	
	print(string.format("[OpenAdmin] [CommandManager] Registered %i commands for plugin \"%s\"!", c, pluginName))
end

return module
