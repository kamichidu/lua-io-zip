package.path=package.path .. ';./lib/?.lua'

local zip= require 'io.zip'

if not (#arg > 0) then
    print(table.concat({
        'Usage:',
        table.concat({arg[-1], arg[0], '{zipfile list}', '[{filename in zip}]'}, ' '),
    }, "\n"))
    os.exit(0)
end

local file= zip.open(arg[1])

if arg[2] then
    local data, err= file:open(arg[2])
    if not data then
        error(err)
    end

    for k, v in pairs(data) do
        if k ~= 'compressed_data' then
            print(k, v)
        end
    end
else
    for fname in file:files() do
        print(fname)
    end
end

file:close()
