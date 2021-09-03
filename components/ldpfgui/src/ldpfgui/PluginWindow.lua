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
    
    ----------------------------------------------------------------------------------------------------------
    -- Show Window

    ldpf.setSize(self:getSize())
    self:requestFocus()

    --print(string.format("Native window handle %p\n", self:getNativeHandle()))
end

function PluginWindow:show()
    ldpf.setSize(self:getSize())
    Super.show(self)
end

function PluginWindow:setSize(w, h)
    if not h then
        h = w[2]
        w = w[1]
    end
    Super.setSize(self, w, h)
    ldpf.setSize(w, h)
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
