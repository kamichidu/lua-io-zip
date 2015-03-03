--[[
4.3.7  Local file header:

    local file header signature     4 bytes  (0x04034b50)
    version needed to extract       2 bytes
    general purpose bit flag        2 bytes
    compression method              2 bytes
    last mod file time              2 bytes
    last mod file date              2 bytes
    crc-32                          4 bytes
    compressed size                 4 bytes
    uncompressed size               4 bytes
    file name length                2 bytes
    extra field length              2 bytes

    file name (variable size)
    extra field (variable size)
]]--
local local_file_header= {}

local_file_header.signature= 'PK' .. string.char(3) .. string.char(4)

function local_file_header.parse(zfile)
    assert(zfile)

    local data= {}

    data.signature= zfile:_read('u4')
    data.version_needed_to_extract= zfile:_read('u2')
    data.general_purpose_bit_flag= zfile:_read('u2')
    data.compression_method= zfile:_read('u2')
    data.last_mod_file_time= zfile:_read('u2')
    data.last_mod_file_date= zfile:_read('u2')
    data.crc_32= zfile:_read('u4')
    data.compressed_size= zfile:_read('u4')
    data.uncompressed_size= zfile:_read('u4')
    data.file_name_length= zfile:_read('u2')
    data.extra_field_length= zfile:_read('u2')

    data.file_name= zfile:_read_string(data.file_name_length)
    data.extra_field= zfile:_read_string(data.extra_field_length)
    data.compressed_data= zfile:_read_string(data.compressed_size)

    if data.signature ~= 0x04034b50 then
        error('Invalid signature.')
    end

    return data
end

return local_file_header
