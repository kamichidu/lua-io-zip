--[[
4.3.16  End of central directory record:

    end of central dir signature    4 bytes  (0x06054b50)
    number of this disk             2 bytes
    number of the disk with the
    start of the central directory  2 bytes
    total number of entries in the
    central directory on this disk  2 bytes
    total number of entries in
    the central directory           2 bytes
    size of the central directory   4 bytes
    offset of start of central
    directory with respect to
    the starting disk number        4 bytes
    .ZIP file comment length        2 bytes
    .ZIP file comment       (variable size)
]]--
local end_of_central_directory_record= {}

end_of_central_directory_record.signature= 'PK' .. string.char(5) .. string.char(6)

function end_of_central_directory_record.parse(zfile)
    assert(zfile)

    local data= {}

    data.signature= zfile:_read('u4')
    data.number_of_disks= zfile:_read('u2')
    data.disk_numer_start= zfile:_read('u2')
    data.number_of_disk_entries= zfile:_read('u2')
    data.number_of_entries= zfile:_read('u2')
    data.central_directory_size= zfile:_read('u4')
    -- zero-origin to one-origin
    data.central_directory_offset= zfile:_read('u4') + 1
    data.file_comment_length= zfile:_read('u2')
    data.file_comment= zfile:_read_string(data.file_comment_length)

    if data.signature ~= 0x06054b50 then
        error('Invalid signature.')
    end

    return data
end

return end_of_central_directory_record
