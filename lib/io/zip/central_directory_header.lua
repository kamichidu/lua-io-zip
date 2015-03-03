--[[
4.3.12  Central directory structure:

    [central directory header 1]
    .
    .
    .
    [central directory header n]
    [digital signature]

    File header:

    central file header signature   4 bytes  (0x02014b50)
    version made by                 2 bytes
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
    file comment length             2 bytes
    disk number start               2 bytes
    internal file attributes        2 bytes
    external file attributes        4 bytes
    relative offset of local header 4 bytes

    file name (variable size)
    extra field (variable size)
    file comment (variable size)
]]--
local central_directory_header= {}

central_directory_header.signature= 'PK' .. string.char(1) .. string.char(2)

function central_directory_header.parse(zfile)
    assert(zfile)

    local data= {}

    data.signature= zfile:_read('u4')
    data.version_made_by= zfile:_read('u2')
    data.version_needed_to_extract= zfile:_read('u2')
    data.general_purpose_bit_flag= zfile:_read('u2')
    data.compression_method= zfile:_read('u2')
    data.last_mod_file_time= zfile:_read('u2')
    data.last_mod_file_date= zfile:_read('u2')
    data.crc32= zfile:_read('u4')
    data.compressed_size= zfile:_read('u4')
    data.uncompressed_size= zfile:_read('u4')
    data.file_name_length= zfile:_read('u2')
    data.extra_field_length= zfile:_read('u2')
    data.file_comment_length= zfile:_read('u2')
    data.disk_number_start= zfile:_read('u2')
    data.internal_file_attributes= zfile:_read('u2')
    data.external_file_attributes= zfile:_read('u4')
    -- zero-origin to one-origin
    data.relative_offset_of_local_header= zfile:_read('u4') + 1

    data.file_name= zfile:_read_string(data.file_name_length)
    data.extra_field= zfile:_read_string(data.extra_field_length)
    data.file_comment= zfile:_read_string(data.file_comment_length)

    if data.signature ~= 0x02014b50 then
        error('Invalid signature.')
    end

    return data
end

return central_directory_header
