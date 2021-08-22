local ldpf = require("ldpf")
local lwtk = require("lwtk")

local PluginParams = lwtk.newClass("PluginParams")

local instance = nil

--------------------------------------------------------------------------------------------------------------
-- Konstruktor 

function PluginParams:new(defs)

    ----------------------------------------------------------------------------------------------------------
    -- Setup singleton

    assert(not instance)
    instance = self
    PluginParams.instance = self
    
    ----------------------------------------------------------------------------------------------------------

    self.pars = {}
    for i, def in ipairs(defs) do
        local name, type, default = table.unpack(def)
        local par = {
            name  = name,
            index = i-1, 
            type  = type,
            value = default,
            listeners = lwtk.WeakKeysTable()
        }
        self.pars[name] = par
        self.pars[i-1]  = par
    end

    ----------------------------------------------------------------------------------------------------------
    -- Implement callback for LDPF
    
    function ldpf.parameterChanged(index, value)
        instance:onParamChanged(index, value)
    end
    
end

--------------------------------------------------------------------------------------------------------------

function PluginParams:onParamChanged(index, value)
    local par = self.pars[index]
    assert(par, string.format("unknown parameter index %d", index))
    if par.type == "boolean" then
        if type(value) ~= "number" then
            error(string.format("unexpected type '%s' received for parameter '%s' at index %d", type(value), par.name, par.index))
        end
        value = (value >= 0.5) and true or false
    end
    if par.value ~= value then
        par.value = value
        for obj, func in pairs(par.listeners) do
            func(obj, value)
        end
    end
end

--------------------------------------------------------------------------------------------------------------

function PluginParams:setParam(parName, value)
    local par = self.pars[parName]
    assert(par, string.format("unknown parameter '%s'", parName))
    if par.type == "boolean" then
        if type(value) ~= "boolean" then
            error(string.format("unexpected type '%s' for boolean parameter '%s'", type(value), parName))
        end
        ldpf.setParameterValue(par.index, value and 1 or 0)
    else
        ldpf.setParameterValue(par.index, value)
    end
    if par.value ~= value then
        par.value = value
        for obj, func in pairs(par.listeners) do
            func(obj, value)
        end
    end
end

--------------------------------------------------------------------------------------------------------------

function PluginParams:toggleParam(parName, value)
    local par = self.pars[parName]
    self:setParam(parName, not par.value)
end

--------------------------------------------------------------------------------------------------------------

function PluginParams:addListener(parName, obj, func)
    local par = self.pars[parName]
    if not par then
        error(string.format("unknown PluginParam: %s", tostring(parName)))
    end
    par.listeners[obj] = func
    func(obj, par.value)
end

--------------------------------------------------------------------------------------------------------------

return PluginParams
