--[[
	OpenAdmin_ChatModule
	Usage:
		Handles passing commands to ChatManager for parsing.
--]]

local OpenAdmin = game.ServerScriptService:WaitForChild("OpenAdmin")
local ChatManager = require(OpenAdmin:WaitForChild("Modules"):WaitForChild("ChatManager"))

return function (ChatService)
	local function onOpenAdminCommand(speakerName, message, channelName)
		local speaker = ChatService:GetSpeaker(speakerName)
		local channel = ChatService:GetChannel(channelName)
		
		return ChatManager:OnChat(speaker, message, channel)
	end

	ChatManager:SetChatService(ChatService) -- Give an instance of the ChatService to ChatManager.
 
	ChatService:RegisterProcessCommandsFunction("OpenAdminCommand", onOpenAdminCommand)
end