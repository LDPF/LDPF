local ldpfgui = {}

setmetatable(ldpfgui, {
    __index = function(t,k)
        local m = require("ldpfgui."..k)
        t[k] = m
        return m
    end
})


return ldpfgui
