local module = {}

local DataStore
local s, r = pcall(function ()
	DataStore = game:GetService("DataStoreService"):GetDataStore("OpenAdmin")
end)

local function GetBans()
	local s, r = pcall(function ()
		return DataStore:GetAsync("Bans") or {}
	end)
	if s then
		return r
	else
		warn("[OpenAdmin] [BanManager] Could not get key \"Bans\" in DataStore \"OpenAdmin\".")
		return {}
	end
end

if not s then
	warn("[OpenAdmin] [BanManager] Could not get DataStore by the name of \"OpenAdmin\", bans will currently not save.")
end

function module:GetBans()
	return GetBans()
end

function module:HasBan(ply)
	return module:GetBanFor(ply) ~= nil
end

local function HasBanToDelete(ply)
	local bans = GetBans()
	
	for i,v in pairs(bans) do
		local banExpired = false
		if v.Length == -1 or not v.Length then
			banExpired = true
		end
		local unbanTime = v.DateBanned + v.Length
		if ply.UserId == v.Player then
			return banExpired -- If the ban expired, it should be deleted.
		end
	end
	return false
end

function module:GetBanFor(ply)
	local bans = GetBans()
	
	for i,v in pairs(bans) do
		local banExpired = false
		if v.Length == -1 or not v.Length then
			banExpired = true
		end
		local unbanTime = v.DateBanned + v.Length
		if ply.UserId == v.Player then
			if banExpired then
				break -- The ban expired and we found the player's ban, so we shouldn't search for the ban.
			else
				return v
			end
		end
	end
	return nil
end

-- length: seconds
function module:AddBan(userId, length, reason)
	if typeof(userId) == "Instance" and userId:IsA("Player") then
		userId = userId.UserId
	end

	local s, r = pcall(function ()
		DataStore:UpdateAsync("Bans", function (old)
			local new = type(old) == "table" and old or {}
			table.insert(new, {
				["Player"] = userId,
				["Length"] = length,
				["DateBanned"] = os.time(), -- The current date banned.
				["Reason"] = reason or ""
			})
			return new
		end)
	end)
	
	return s
end

function module:RemoveBan(userId)
	if typeof(userId) == "Instance" and userId:IsA("Player") then
		userId = userId.UserId
	end

	local s, r = pcall(function ()
		DataStore:UpdateAsync("Bans", function (old)
			local new = type(old) == "table" and old or {}
			
			local removeIndex = 0
			for i, banObj in pairs(new) do
				if banObj.Player == userId then
					removeIndex = i
					break
				end
			end

			if removeIndex ~= 0 then
				table.remove(new, removeIndex)
			end

			return new
		end)
	end)
	
	return s
end

game.Players.PlayerAdded:connect(function (ply)
	if HasBanToDelete(ply) then
		-- We need to remove the player's ban since it is expired.
		module:RemoveBan(ply)
	else
		if module:HasBan(ply) then
			local ban = module:GetBanFor(ply)
			ply:Kick(ban.Reason or "")
		end
	end
end)

return module
