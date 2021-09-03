os.setlocale("C")

local output = {}
local function writef(...)
    output[#output + 1] = string.format(...)
end
local function printf(...)
    io.stderr:write(string.format(...))
end

local dataPtrName, inputFileName = ...

local bytes
do
    local f = io.open(inputFileName, "rb")
    bytes = f:read("a")
    f:close()
end

do
    writef('#include "../../ldpf/src/ldpf_base.h"\n\n')
    writef('static const unsigned char %s_bytes[] = {\n    ', dataPtrName)
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
    writef('const LDPF_Data %s = {\n', dataPtrName)
    writef('    %d, %s_bytes\n', #bytes, dataPtrName)
    writef('};\n')
end
io.write(table.concat(output))
