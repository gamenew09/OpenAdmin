local module = {}

local Settings = require(script.Parent:WaitForChild("Settings"))
local CmdManager = require(script.Parent:WaitForChild("CommandManager"))
local ExtPlayer = require(script.Parent:WaitForChild("ExtPlayer"))

--local text = [[I "am" 'the text' and "some more text with '" and "escaped \" text"]]

local function StringToRbxObject(text, startAt)
	local o = startAt
	if typeof(o) ~= "Instance" and o ~= nil then
		return nil
	end
	for str in text:gmatch("%S+") do
		if o == nil then
			o = game
		else
			o = o:FindFirstChild(str)
			if not o then
				return nil
			end
		end
	end
	return o
end

function module:GenerateUsage(cmdModule)
	local cmdName = cmdModule.CommandName
	if not cmdName then
		return nil
	end
	
	if cmdModule.VaradicArguments then
		return string.format("%s%s [...]", Settings["CommandPrefix"], cmdName)
	end	
	
	local schemas = cmdModule.ArgumentSchema
	if schemas then
		local args = ""		
		
		for i,schemaArg in pairs(schemas) do
			if schemaArg.Type == "Number" then
				local apars = schemaArg.Arguments
				local rangeString = ""
				if apars then
					if apars.Minimum and apars.Maximum then
						rangeString = ":"..apars.Minimum.. " to "..apars.Maximum
					elseif apars.Minimum then
						rangeString = ":"..apars.Minimum.."-infinity"
					elseif apars.Maximum then
						rangeString = ":infinity-"..apars.Maximum
					end
				end
				local final = ""
				
				if schemaArg.Name then
					final = final .. schemaArg.Name .. rangeString
				else
					final = final .. i .. rangeString
					warn(string.format("[OpenAdmin] [ChatManager] Argument %i does not have a name! You really should have a name for arguments.", i))
				end
				
				if schemaArg.Optional then
					final = string.format("[%s]", final)
				end
				args = args .. final .. " "
			else
				local final = ""
				if schemaArg.Name then
					final = final .. schemaArg.Name
				else
					final = final .. i
					warn(string.format("[OpenAdmin] [ChatManager] Argument %i does not have a name! You really should have a name for arguments.", i))
				end
				
				if schemaArg.Optional then
					final = string.format("[%s]", final)
				end
				args = args .. final .. " "
			end
		end		
		
		return string.format("%s%s %s", Settings["CommandPrefix"], cmdName, args)
	else
		return string.format("%s%s", Settings["CommandPrefix"])
	end
end

local function ParseStringWithQuotes(text)
	local tbl = {}	
	
	-- Parse the string to allow for quoted arguments.
	
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	for str in text:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then 
			table.insert(tbl, (str:gsub(spat,""):gsub(epat,""))) 
		end
	end
	if buf then
		return false, "Missing Matching Quote for ".. buf
	end
	return tbl
end

local function FindFirstChildCaseInsensitive(parent, name)
	for i,v in pairs(parent:GetChildren()) do
		if string.lower(v.Name) == string.lower(name) then
			return v
		end
	end
	return nil
end

local TextService = game:GetService("TextService")

local function getTextObject(message, fromPlayerId)
	local textObject
	local success, errorMessage = pcall(function()
		textObject = TextService:FilterStringAsync(message, fromPlayerId)
	end)
	if success then
		return textObject
	end
	return false
end
 
local function getBroadcastNonChatFilteredMessage(textObject) -- Filter message for display to specific player
	local filteredMessage
	local success, errorMessage = pcall(function()
		filteredMessage = textObject:GetNonChatStringForBroadcastAsync()
	end)
	if success then
		return filteredMessage
	end
	return false
end

local function getPrivateChatFilteredMessage(textObject, toPlayerId) -- Filter message for display to specific player
	local filteredMessage
	local success, errorMessage = pcall(function()
		filteredMessage = textObject:GetChatForUserAsync(toPlayerId)
	end)
	if success then
		return filteredMessage
	end
	return false
end

local function ParseCmd(text, cmd, sender)
	local strArgTbl, msg = ParseStringWithQuotes(text)
	
	if not strArgTbl then
		return strArgTbl, msg
	end	
	
	if cmd.AllowVariableArguments then -- If the command allows for 0-nearly infinite arguments, just return the string table we got.
		return strArgTbl
	end	
	
	local cmdArgSchema = cmd.ArgumentSchema
	
	if not cmdArgSchema then
		return {} -- Ignore arguments given.
	end	
	
	local c = 0
	local maxCount = #cmdArgSchema
	
	--local isOptionalsInOrder = false -- For the command schema, optional parameters MUST BE LAST. So if you require a parameter you must put it before all the optional parameters.
	
	for i,v in pairs(cmdArgSchema) do
		if not v.Optional then
			c = c + 1 -- If the argument in the command is not optional, then add onto count.
		end
	end	
	
	if #strArgTbl < c then
		return false, string.format("You must have at least %i parameter%s.", c, (c == 1 and "" or "s"))
	end
	
	if #strArgTbl > maxCount then
		return false, string.format("You can only have %i parameter%s.", maxCount, (maxCount == 1 and "" or "s"))
	end
	
	local tbl = {}	
	
	for i, v in pairs(strArgTbl) do
		local schemaArg = cmdArgSchema[i]
		if schemaArg.Type == "Target" then
			local usernumid = tonumber(v)
			if usernumid then
				local ply = game.Players:GetPlayerByUserId(usernumid) -- Find player by userid.
				if not ply then
					return false, string.format("Invalid argument %i: Must be a player that is in-game.", i)
				end
				table.insert(tbl, ExtPlayer.fromPlayer(ply))
			else
				if v:lower() == "me" or v == "@me" then -- Check if the sender wants to target his/herself.
					if not sender:GetPlayer() then
						return false, string.format("Invalid argument %i: You must be a valid player!", i)
					end
					table.insert(tbl, ExtPlayer.fromPlayer(sender:GetPlayer()))
				else
					local ply = FindFirstChildCaseInsensitive(game.Players, v) -- Find player by username.
					if not ply then
						return false, string.format("Invalid argument %i: Must be a player that is in-game.", i)
					end
					table.insert(tbl, ExtPlayer.fromPlayer(ply))
				end
			end
		elseif schemaArg.Type == "Number" then
			local number = tonumber(v)
			if number then
				local apars = schemaArg.Arguments
				if apars then
					local rangeString = "INVALID, CONTACT DEVELOPERS OF GAME/OPENADMIN"
					if apars.Minimum and apars.Maximum then
						rangeString = "be in the range of "..apars.Minimum.. " to "..apars.Maximum
					elseif apars.Minimum then
						rangeString = "be at least "..apars.Minimum
					elseif apars.Maximum then
						rangeString = "be at most "..apars.Maximum
					end
					if apars.Minimum and number < apars.Minimum then
						return false, string.format("Invalid argument %i: The number must %s.", i, rangeString)
					end
					if apars.Maximum and number > apars.Maximum then
						return false, string.format("Invalid argument %i: The number must %s.", i, rangeString)
					end
				end
				table.insert(tbl, number)
			else
				return false, string.format("Invalid argument %i: Must be a valid number.", i)
			end
		elseif schemaArg.Type == "String" then
			local apars = schemaArg.Arguments
			if apars then
				if apars.Filtered and not game:GetService("RunService"):IsStudio() then -- The string needs to be filtered.
					-- TODO: Handle filtering.
					local texto = getTextObject(v)
					if not texto then
						return false, string.format("Invalid argument %i: Failed to filter your string, try again.", i)
					else
						local newText = getBroadcastNonChatFilteredMessage(texto)
						if not newText then
							return false, string.format("Invalid argument %i: Failed to filter your string, try again.", i)
						else
							table.insert(tbl, newText)
						end
					end
				else
					table.insert(tbl, v) -- Just pass it in raw.
				end
			else
				table.insert(tbl, v) -- Just pass it in raw.
			end
		elseif schemaArg.Type == "ObjectTarget" then
			local o = StringToRbxObject(v)
			if not o then
				return false, string.format("Invalid argument %i: Must be a valid object target.", i)
			end
			
			table.insert(tbl, o)
		end
	end
	
	return tbl
end

function module:OnChat(speaker, msg, channel)
	local prefix = Settings["CommandPrefix"]
	local cmp = string.sub(msg, 1, string.len(prefix))
	if prefix == cmp then
		local cmdArgStart = string.find(msg, "%s")
		if cmdArgStart then
			cmdArgStart = cmdArgStart - 1
		end
		
		local cmdName = string.sub(msg, string.len(prefix) + 1, (cmdArgStart or string.len(msg)))
		
		local cmdModule = CmdManager:GetByCmdName(cmdName)	
		
		if cmdModule then
			local sendereply = ExtPlayer.new(speaker, channel.Name)
			if cmdModule.PermissionsNeeded and type(cmdModule.PermissionsNeeded) == "table" then
				for i,v in pairs(cmdModule.PermissionsNeeded) do
					if not sendereply:HasPermission(v) then
						speaker:SendSystemMessage(string.format("[OpenAdmin] You must have the permission \"%s\"", v), channel.Name)
						return true -- The command shouldn't appear in chat, but let the user know what went wrong.
					end
				end
			elseif type(cmdModule.PermissionsNeeded) == "string" then
				if not sendereply:HasPermission(cmdModule.PermissionsNeeded) then
					speaker:SendSystemMessage(string.format("[OpenAdmin] You must have the permission \"%s\"", cmdModule.PermissionsNeeded), channel.Name)
					return true -- The command shouldn't appear in chat, but let the user know what went wrong.
				end
			end			
			
			local strArgs = ""
			if cmdArgStart then
				strArgs = string.sub(msg, cmdArgStart + 2)
			end			
			
			local res, msg = ParseCmd(strArgs, cmdModule, speaker)	
			
			local usageString = "\n\tUsage: " .. module:GenerateUsage(cmdModule)			
			
			if not res then
				speaker:SendSystemMessage("[OpenAdmin] " .. msg .. usageString, channel.Name) -- Let the sender know that the command arguments or whatever caused an error.
			else
				local res, msg = cmdModule:Run(sendereply, res)
				if not res then
					speaker:SendSystemMessage("[OpenAdmin] " .. (msg or "An error occured while trying to run \"" .. prefix .. cmdName .. "\"!" .. usageString), channel.Name)
				end
			end
		end
		
		return true -- Prevent the command/chat from being shown in chat.
	end
	return false -- Show the chat.
end

return module
