local module = {}

module.CommandName = "kick"
module.DisplayName = "Kick"
module.Description = "Kick another player"

module.Category = "Administration"

module.PermissionsNeeded = {
	"can_kick"
} -- or just a string
-- The permissions required to use this command.

--[[
	Target - A Player argument, in the cmd you would put in the username or userid.
        Example: 5762824, if the user by the id of 5762824 is in the game it would return the player object in cmd:Run.
        Example: gamenew09, if the user by the username gamenew09 is in the game it would return the player object in cmd:Run.
   		Argument Parameters:
			ImmunityTag - what tag should a target/player have in order to not able to be targeted by this command.
	Number - A number, just put in a number
        Example: 43
    String - A string, or text
        Argument Parameters: (Table keys in an Argument Schema)
            ["Filtered"] - boolean - Tells the command parser to filter this string before sending it to the command. If any string is shown to the screen, you must filter the string as according to ROBLOX's Guidelines.
        Example: "Test 123" - I want to support quoted strings.
    ObjectTarget - String that references a roblox object. 
        Example: game.Workspace.Test - returns the actual object in cmd:Run
--]]

--[[
		{
		["Type"] = "Target",
		["Arguments"] = {
			["ImmunityTag"] = "tag"
		}
	},
--]]

module.ArgumentSchema = {
	{
		["Type"] = "Target",
		["Name"] = "player",
		["Arguments"] = {
			["DisallowSpecial"] = false, -- Should we disallow "me"
			["IgnoreGroupOrder"] = false -- Should we allow users to target anyone? (false, allow targeting anyone)
		}
	},
	{
		["Type"] = "String",
		["Name"] = "reason",
		["Optional"] = true,
		["Arguments"] = {
			["Filtered"] = true -- This will filter the message to broadcast. If you are just wanting a pm system, you will need to do it on your own.
		}
	}
}

function module:Run(sender, args)
	local target = args[1]
	local reason = args[2]
	
	target:GetPlayer():Kick(reason or "You have been kicked.")	
	
	sender:Tell(string.format("Kicked %s for reason \"%s\"", target.Name, reason or "No Reason Specified"))
	
	return true
end

return module
