local byte_buffer= require 'io.byte_buffer'

local entry= {}

function entry.open(local_file_header, mode)
    assert(local_file_header)
    mode= mode or 'r'

    local object= {}

    object.__local_file_header= local_file_header
    object.__buffer= byte_buffer.wrap(local_file_header.compressed_data)
    object.__pos= 0

    function object:close()
        for k, _ in pairs(self) do
            self[k]= nil
        end
        return true
    end

    function object:lines()
        return function()
            return self:read('*l')
        end
    end

    function object:read(fmt)
        fmt= fmt or '*l'

        if self.__pos >= self.__buffer:len() then
            return nil
        end

        if fmt == '*n' then
            error('TODO')
        elseif fmt == '*l' or fmt == '*L' then
            local s= ''
            while self.__pos <= self.__buffer:len() do
                local c= self.__buffer:char(self.__pos)
                if c == "\r" or c == "\n" then
                    break
                end
                s= s .. c
                self.__pos= self.__pos + 1
            end
            if self.__buffer:char(self.__pos) == "\r" then
                if fmt == '*L' then
                    s= s .. "\r"
                end
                self.__pos= self.__pos + 1
            end
            if self.__buffer:char(self.__pos) == "\n" then
                if fmt == '*L' then
                    s= s .. "\n"
                end
                self.__pos= self.__pos + 1
            end
            return s
        elseif fmt == '*a' then
            local s= self.__buffer:string(self.__pos, self.__buffer:len())
            self.__pos= self.__buffer:len()
            return s
        elseif type(fmt) == type(0) then
            if fmt <= 0 then
                return ''
            end
            local s= self.__buffer:string(self.__pos, fmt)
            self.__pos= self.__pos + fmt
            return s
        else
            error('Illegal format `' .. fmt .. "'")
        end
    end

    function object:seek(whence, offset)
        whence= whence or 'cur'
        offset= offset or 0

        if whence == 'set' then
            self.__pos= offset
            return self.__pos
        elseif whence == 'cur' then
            return self.__pos
        elseif whence == 'end' then
            self.__pos= self.__buffer:len()
            return self.__pos
        else
            error('Unknown whence `' .. whence .. "'")
        end
    end

    function object:flush()
        error('Unsupported operation.')
    end

    function object:setvbuf()
        error('Unsupported operation.')
    end

    function object:write()
        error('Unsupported operation.')
    end

    return object
end

return entry
