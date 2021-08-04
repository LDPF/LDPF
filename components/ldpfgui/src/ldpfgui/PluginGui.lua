local ldpf    = require("ldpf")
local ldpfgui = require("ldpfgui")
local lwtk    = require("lwtk")

local PluginGui = lwtk.newClass("ldpfgui.PluginGui")

local instance = nil

--------------------------------------------------------------------------------------------------------------
-- Konstruktor 

function PluginGui:new(name, pluginParams)

    ----------------------------------------------------------------------------------------------------------
    -- Setup singleton

    assert(not instance)
    instance = self
    PluginGui.instance = self
    
    ----------------------------------------------------------------------------------------------------------
    -- Create Application with extension

    self.pluginParams = pluginParams

    self.lwtkExtension = ldpfgui.LwtkExtension(pluginParams)

    local app = lwtk.Application {
        name = name,
        extensions = {
            self.lwtkExtension
        }
    }
    self.name = name
    self.app = app

    app:setErrorFunc(function(err)
        io.stderr:write(string.format("**** Error in Lua script ****\n%s\n", err))
    end)


    ----------------------------------------------------------------------------------------------------------
    -- Implement callbacks for LDPF
    
    -- update callback if plugin ui is embedded in host
    function ldpf.idle()
        if lwtk.platform ~= "MAC" then
            app:update(0)
        end
        return app:hasWindows()
    end
    
    -- update loop if plugin is running standalone
    function ldpf.exec(idleCallback)
        while app:hasWindows() do
            app:update(0.030)
            idleCallback()
        end
    end
    
    ----------------------------------------------------------------------------------------------------------
end

--------------------------------------------------------------------------------------------------------------

return PluginGui
