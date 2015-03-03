local buffer= {}

function buffer.wrap(bytes)
    assert(bytes)

    local data
    if type(bytes) == type('') then
        data= bytes
    else
        error('Unsupported type ' .. type(bytes))
    end

    local object= {}

    object.__data= data
    object.__size= string.len(data)
    object.__char2byte= {}

    function object:byte(offset)
        local c= self:char(offset)
        if not self.__char2byte[c] then
            self.__char2byte[c]= c:byte()
        end
        return self.__char2byte[c]
    end

    function object:char(offset)
        assert(offset)

        return string.sub(self.__data, offset, offset)
    end

    function object:string(offset, length)
        assert(offset)
        length= length or 1

        return string.sub(self.__data, offset, offset + length - 1)
    end

    function object:len()
        return self.__size
    end

    return setmetatable(object, {
        __newindex= function(t, k, v)
            error('Unsupported operation.')
        end,
        __index= function(t, k)
            return t:byte(k)
        end,
        __len= function(t)
            return t:len()
        end,
    })
end

return buffer
