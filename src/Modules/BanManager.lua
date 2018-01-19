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
	local bans = GetBans()
	
	for i,v in pairs(bans) do
		if ply.UserId == v.Player then
			return true
		end
	end
	return false
end

function module:GetBanFor(ply)
	local bans = GetBans()
	
	for i,v in pairs(bans) do
		if ply.UserId == v.Player then
			return v
		end
	end
	return nil
end

function module:AddBan(userId, length, reason)
	local s, r = pcall(function ()
		DataStore:UpdateAsync("Bans", function (old)
			local new = type(old) == "table" and old or {}
			table.insert(new, {
				["Player"] = userId,
				["Length"] = length,
				["Reason"] = reason or ""
			})
			return new
		end)
	end)
	
	return s
end

game.Players.PlayerAdded:connect(function (ply)
	if module:HasBan(ply) then
		local ban = module:GetBanFor(ply)
		ply:Kick(ban.Reason or "")
	end
end)

return module
