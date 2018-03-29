local ExtPlayer = require(script.Parent:WaitForChild("ExtPlayer"))

local function IsPrivate(name)
    if #name < 2 then
        return false
    end
    if string.sub(name, 1, 2) == "__" then
        return true
    else
        return false
    end
end

local function mt_generictarget_equ(self, other)
    if type(other) == "table" or type(other) == "userdata" then
        return self.Object == other.Object
    elseif typeof(other) == "Instance" then
        return self.Object == other
    end
end

return function (targetObject)
    if typeof(targetObject) ~= "Instance" then
        error("targetObject must be an Instance or nil.")
        return
    end

    if typeof(targetObject) ~= "Instance" and targetObject == nil then
        error("targetObject must be an Instance or nil.")
        return
    end
    -- GenericTarget

    local GenericTarget = {}
    GenericTarget.Object = targetObject or nil -- nil or Instance/Player

    --[[
        Returns the target.
    --]]
    function GenericTarget:Get()
        return GenericTarget.Object
    end

    --[[
        Returns the target as ExtPlayer or nil if the object is not a player.
    --]]
    function GenericTarget:AsExtPlayer()
        if not GenericTarget:IsPlayer() then -- If the target object is not a player, return nil.
            return nil
        end
        return ExtPlayer.fromPlayer(GenericTarget.Object) -- Creates a wrapper for the player object.
    end

    --[[
        Simple helper function that determines if the target found is a player.
    --]]
    function GenericTarget:IsPlayer()
        return typeof(GenericTarget.Object) == "Instance" and GenericTarget.Object:IsA("Player")
    end

    --[[
        Simple helper function that determines if the target is valid.
    --]]
    function GenericTarget:IsValid()
        return typeof(GenericTarget.Object) == "Instance"
    end

    --[[
        Simple helper function that checks if the Object is of the type given.
    --]]
    function GenericTarget:IsA(typeName) -- Is the target a certain Roblox Instance type
        if not typeof(GenericTarget.Object) == "Instance" then
            return false
        end
        return GenericTarget.Object:IsA(typeName)
    end

    GenericTarget["__tostring"] = function (t)
        return string.format("GenericTarget: %s", tostring(GenericTarget.Object))
    end

    GenericTarget["__metatable"] = nil

    GenericTarget["__index"] = function (t, key)
        if IsPrivate(key) then -- If the key should not be accessed using GenericTarget[key], then error.
            error("Invalid key")
        end
        if GenericTarget[key] then -- If the GenericTarget table has the key passed in GenericTarget[key], then return that value. If the object has the key, it will get ignored and to get the value of the key you have to get the object. (Using :Get() or another way)
            return GenericTarget[key]
        end

        if GenericTarget.Object ~= nil and GenericTarget.Object[key] then
            if type(GenericTarget.Object[key]) == "function" then
                local obj = GenericTarget.Object
                return function (...) -- We have to wrap functions in an object in a call because when you try and call the original function it is like you are using ply.Kick instead of ply:Kick. The : indicates pass in self in the parameters (That's how the self variable actually gets set in a table.)
                    return GenericTarget.Object[key](obj, ...)
                end
            else
                return GenericTarget.Object[key]
            end
        end
        return nil
    end

    GenericTarget["__newindex"] = function (t, key, value)
        error("GenericTarget is read-only.")
    end

    GenericTarget["__eq"] = mt_generictarget_equ -- Do two groups equal?

    GenericTarget["__call"] = function (t, shouldReturnExtPlayer) -- When the object is called like a function: GenericTarget(). It will return the object.
        if shouldReturnExtPlayer then -- If the value in shouldReturnExtPlayer is true (or a value that translates to true in Lua), then return the ExtPlayer object instead. (May actually default the argument to opposite)
            return GenericTarget:AsExtPlayer()
        else
            return GenericTarget.Object
        end
    end

    return setmetatable({}, GenericTarget)
end