local module = {}

module.CommandName = "test"
module.DisplayName = "Test"
module.Description = "A test command."

module.Category = "Test Category"

module.PermissionsNeeded = {
	
} -- or just a string
-- The permissions required to use this command.
-- TODO: Allow place owners to specify custom permissions.

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
		["Name"] = "target",
		["Arguments"] = {
			["DisallowSpecial"] = false -- Should we disallow "self"
		}
	},
	{
		["Type"] = "Number",
		["Name"] = "damage",
		["Arguments"] = {
			["Minimum"] = 1
		}
	}
}

function module:Run(sender, args)
	local target = args[1]
	local dmg = args[2]
	
	local char = target.Character

	if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health > 0 then
		char:FindFirstChild("Humanoid").Health = char:FindFirstChild("Humanoid").Health - dmg
		
		sender:TellWithPrefix("Test")
	end	
	
	return true
end

return module
