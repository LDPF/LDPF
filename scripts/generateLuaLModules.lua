os.setlocale("C")

local output = {}
local function writef(...)
    output[#output + 1] = string.format(...)
end
local function printf(...)
    io.stderr:write(string.format(...))
end

local nargs      = select("#", ...)
local moduleName = select(1, ...)
local baseDir    = select(2, ...)
local firstArg   = 3

local modulePrefix = (#moduleName > 0) and moduleName.."." or ""

local init = ".init"
local luaext = ".lua"
local files = {}
local hasLua = false
local hasNonLua = false
for i = firstArg, nargs do
    local fileName = select(i, ...)
    if fileName:sub(1, #baseDir) == baseDir then
        local file = { fileName = fileName,
                       cname    = "generated_"..((modulePrefix..fileName):sub(#baseDir + 1):gsub("[/.]", "_")) }
        files[i - firstArg + 1] = file
        if fileName:sub(-#luaext) == luaext then
            file.isLua = true
            hasLua = true
            local pkgName = modulePrefix..fileName:sub(#baseDir + 1):gsub("/", "."):gsub("%.lua$", "")
            if pkgName:sub(-#init) == init then
                pkgName = pkgName:sub(1, #pkgName - #init)
            end
            file.pkgName = pkgName
        elseif #moduleName == 0 then -- resourcecs only in main module
            file.isNonLua = true
            hasNonLua = true
            local pkgName = modulePrefix..fileName:sub(#baseDir + 1):gsub("/", ".")
            file.pkgName = pkgName
        end
    end
end

table.sort(files, function(a,b) return a.pkgName < b.pkgName end)

writef('#include "../../ldpf/ldgl/ldgl_base.h"\n\n')
writef('// {\n')
for i = 1, #files do
    local file = files[i]
    writef('extern const LDGL_LuaData LDPF_%s_data;\n', file.cname)
end
writef('// }\n\n')


if #moduleName == 0 then -- resources only in main module
    writef('const LDGL_LuaLSubModule LDPF_generatedMainModuleResources[] = {\n')
    for i = 1, #files do
        local file = files[i]
        if file.isNonLua then
            writef('    { "%s", &LDPF_%s_data }, \n', file.pkgName, file.cname)
        end
    end
    writef('    { NULL, NULL}\n')
    writef('};\n\n')
end

do
    local arrayName
    if #moduleName > 0 then
        arrayName = string.format("LDPF_generatedModulePackages_%s", moduleName)
    else
        arrayName = "LDPF_generatedMainModulePackages"
    end
    writef('const LDGL_LuaLSubModule %s[] = {\n', arrayName)
    for i = 1, #files do
        local file = files[i]
        if file.isLua then
            writef('    { "%s", &LDPF_%s_data }, \n', file.pkgName, file.cname)
        end
    end
    writef('    { NULL, NULL}\n')
    writef('};\n')
end

io.write(table.concat(output))
