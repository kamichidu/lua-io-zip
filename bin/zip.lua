package.path=package.path .. ';./lib/?.lua'

local zip= require 'io.zip'

if not (#arg > 0) then
    print(table.concat({
        'Usage:',
        table.concat({arg[-1], arg[0], '{zipfile list}', '[{filename in zip}]'}, ' '),
    }, "\n"))
    os.exit(0)
end

local zfile= zip.open(arg[1])

if arg[2] then
    local file, err= zfile:open(arg[2])
    if not file then
        error(err)
    end

    print(file:read('*a'))
    -- for l in file:lines() do
    --     print(l)
    -- end
else
    for fname in zfile:files() do
        print(fname)
    end
end

zfile:close()
