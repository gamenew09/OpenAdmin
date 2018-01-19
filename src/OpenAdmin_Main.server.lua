local SModules = script.Parent:WaitForChild("Modules")

local ChatManager = require(SModules:WaitForChild("ChatManager"))
local ChatModule = script.Parent:WaitForChild("ChatModules"):WaitForChild("OpenAdmin_ChatModule")
local CmdManager = require(SModules:WaitForChild("CommandManager"))
local GroupManager = require(SModules:WaitForChild("GroupManager"))

local BanManager = require(SModules:WaitForChild("BanManager"))

local PluginManager = require(SModules:WaitForChild("PluginManager"))

-- Register groups

GroupManager:CreateSystemGroups()

local DEBUG_OWNERSHIP = false

game.Players.PlayerAdded:connect(function (ply)
	if DEBUG_OWNERSHIP or game.PlaceId == 0 then
		GroupManager:Owner():AddPlayer(ply) -- Add player to owner for debugging purposes.
		print(string.format("[OpenAdmin] [Main] For debugging purposes, \"%s\" is now an owner.", ply.Name))
	end
	
	GroupManager:Everyone():AddPlayer(ply)
end)

if game.CreatorType == Enum.CreatorType.User then
	GroupManager:Owner():AddPlayer(game.CreatorId)
end

PluginManager:LoadPlugins() -- Load OpenAdmin plugins.

ChatModule.Parent = game.Chat:WaitForChild("ChatModules") -- Move ChatModule that is used for handling players sending commands to game.Chat.ChatModules