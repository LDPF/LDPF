local lwtk = require("lwtk")

local extract = lwtk.extract

local LwtkExtension = lwtk.newClass("ldpfgui.LwtkExtension")

function LwtkExtension:new(pluginParams)
    self.pluginParams = pluginParams
end

function LwtkExtension:handleComponentInitParams(component, initParams)
    local onParamChanged = extract(initParams, "onParamChanged")
    if onParamChanged then
        local parName, func = onParamChanged[1], onParamChanged[2]
        self.pluginParams:addListener(parName, component, func)
    end 
end

return LwtkExtension