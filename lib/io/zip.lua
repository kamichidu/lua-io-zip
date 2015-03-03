local bitwise= require 'bitwise'
local byte_buffer= require 'io.byte_buffer'
local zip_entry= require 'io.zip.entry'
local central_directory_header= require 'io.zip.central_directory_header'
local end_of_central_directory_record= require 'io.zip.end_of_central_directory_record'
local local_file_header= require 'io.zip.local_file_header'

local zip= {}

function zip.open(filename)
    assert(filename)

    local file, err= io.open(filename, 'rb')
    if not file then
        return nil, err
    end

    local fsize, err= file:seek('end')
    if not fsize then
        return nil, err
    end

    local pos, err= file:seek('set')
    if not pos then
        return nil, err
    end

    local content, err= file:read(fsize)
    if not content then
        return nil, err
    end

    file:close()

    local zfile= {}

    zfile.__pos= pos
    zfile.__fsize= fsize
    zfile.__content= content
    zfile.__char2byte= {}

    function zfile:files()
        if not self.__data then
            self:_parse()
        end

        local i= 0
        local headers= self.__data.central_directory_header
        local function itr()
            i= i + 1
            local header= headers[i]
            if header then
                return header.file_name, i
            else
                return nil
            end
        end
        return itr
    end

    function zfile:open(filename, mode)
        assert(filename)

        local idx
        for name, i in self:files() do
            if name == filename then
                idx= i
                break
            end
        end
        if not idx then
            return nil, 'No such file.'
        end

        local central_directory_header= self.__data.central_directory_header[idx]

        self.__pos= central_directory_header.relative_offset_of_local_header
        local local_file_header= local_file_header.parse(self)
        return zip_entry.open(local_file_header, mode)
    end

    function zfile:close()
        return true
    end

    function zfile:_read(fmt)
        assert(fmt)

        local nbytes
        if fmt == 'u1' then
            nbytes= 1
        elseif fmt == 'u2' then
            nbytes= 2
        elseif fmt == 'u4' then
            nbytes= 4
        elseif fmt == 'u8' then
            nbytes= 8
        else
            error('Unknown format `' .. fmt .. "'")
        end

        local shiftbits= 0
        local read= 0x00000000
        for idx= self.__pos, self.__pos + nbytes - 1 do
            read= bitwise.bor(read, bitwise.lshift(self:_at(idx), shiftbits))

            shiftbits= shiftbits + 8
        end
        self.__pos= self.__pos + nbytes
        return read
    end

    function zfile:_read_string(length)
        assert(length)
        if length < 0 then
            error('Invalid length.')
        end
        if length == 0 then
            return ''
        end

        local s= string.sub(self.__content, self.__pos, self.__pos + length - 1)
        self.__pos= self.__pos + length
        return s
    end

    function zfile:_at(idx)
        if not (idx >= 1 and idx <= self.__fsize) then
            error('Illegal index `' .. (idx or 'nil') .. "'")
        end
        local char= string.sub(self.__content, idx, idx)
        if not self.__char2byte[char] then
            self.__char2byte[char]= char:byte()
        end
        return self.__char2byte[char]
    end

    function zfile:_fsize(idx)
        return self.__fsize
    end

    function zfile:_parse()
        local data= {}

        self.__pos= zfile:_find_signature(end_of_central_directory_record.signature)
        data.end_of_central_directory_record= end_of_central_directory_record.parse(self)

        self.__pos= data.end_of_central_directory_record.central_directory_offset
        data.central_directory_header= {}
        while #(data.central_directory_header) < data.end_of_central_directory_record.number_of_entries do
            table.insert(data.central_directory_header, central_directory_header.parse(self))
        end

        self.__data= data
    end

    function zfile:_find_signature(signature)
        assert(signature)

        return string.find(self.__content, signature, 1, true)
    end

    return zfile
end

return zip
