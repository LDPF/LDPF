local ldpf    = require("ldpf")
local lwtk    = require("lwtk")


local Super        = lwtk.Window
local PluginWindow = lwtk.newClass("ldpfgui.PluginWindow", Super)

local initialized = false

function PluginWindow:new(gui, winParams)

    ----------------------------------------------------------------------------------------------------------
    -- Setup singleton

    assert(not initialized)
    initialized = true
    PluginWindow.instance = self

    ----------------------------------------------------------------------------------------------------------
    -- Create Window

    winParams.title  = gui.name
    winParams.parent = ldpf.parentWindowId -- nil if running as standalone application

    Super.new(self, gui.app, winParams)
    
    gui.win = self
    
    ----------------------------------------------------------------------------------------------------------
    -- Implement callbacks for LDPF
    
    function ldpf.getNativeWindowHandle()
        return self:getNativeHandle()
    end
    
    function ldpf.getWidth()
        local w,_ = self:getSize()
        return w
    end
    
    function ldpf.getHeight()
        local _,h = self:getSize()
        return h
    end

    function ldpf.close()
        self:close()
    end
    
    ----------------------------------------------------------------------------------------------------------
    -- Show Window

    self:requestFocus()

    --print(string.format("Native window handle %p\n", self:getNativeHandle()))
end

function PluginWindow:interceptMouseDown(...)
    self:requestFocus()
    return ...
end
    
function PluginWindow:interceptKeyDown(...)
    if self.hasFocus then
        return ...
    end
end

function PluginWindow:requestClose()
    if not ldpf.parentWindowId then
        Super.requestClose(self)
    end
end

return PluginWindow
