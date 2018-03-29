-- HookObject

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

return { ["new"] = function ()
    local hooks = {}

    local Hook = {}

    function Hook:Add(uniqueId, func)
        hooks[uniqueId] = func
        return uniqueId
    end

    function Hook:Remove(uniqueId)
        if not hooks[uniqueId] then
            return false
        end
        hooks[uniqueId] = nil
        return true
    end

    function Hook:Call(...)
        for i,func in pairs(hooks) do
            if type(func) == "function" then
                local returnValues = {func(...)}
                if #returnValues > 0 then
                    return unpack(returnValues)
                end
            end
        end
        return nil
    end

    Hook["__index"] = function (t, key)
        if IsPrivate(key) then -- If the key should not be accessed using Hook[key], then error.
            error("Invalid key")
        end
        
        return Hook[key]
    end

    Hook["__newindex"] = function (t, key, value)
        error("HookObject is read-only.")
    end

    return setmetatable({}, Hook)
end }
