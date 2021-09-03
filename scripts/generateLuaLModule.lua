os.setlocale("C")

local output = {}
local function writef(...)
    output[#output + 1] = string.format(...)
end
local function printf(...)
    io.stderr:write(string.format(...))
end
local function errorf(formatString, ...)
    error(string.format(formatString, ...), 2)
end

local moduleName, fileName, cname = ...

local luaext = ".lua"


local bytes

if fileName:sub(-#luaext) == luaext then
    local chunk, err = loadfile(fileName)
    if not chunk then
        errorf("Error loading file '%s': %s", fileName, err)
    end
    bytes = string.dump(chunk)
elseif #moduleName == 0 then -- resourcecs only in main module
    local f = io.open(fileName, "rb")
    bytes = f:read("a")
    f:close()
end

if bytes then
    writef('#include "../../ldpf/src/ldpf_base.h"\n\n')
    writef('static const unsigned char LDPF_%s_bytes[] = {\n    ', cname)
    for j = 1, #bytes do
        if j > 1 and (j - 1) % 20 == 0 then
            writef('\n    ')
        end
        local b = bytes:byte(j)
        writef('0x%02x', b)
        if j < #bytes then
            writef(', ')
        end
    end
    writef('\n};\n\n')
    writef('const LDPF_Data LDPF_%s_data = {\n', cname)
    writef('    %d, LDPF_%s_bytes\n', #bytes, cname)
    writef('};\n')
end
io.write(table.concat(output))
