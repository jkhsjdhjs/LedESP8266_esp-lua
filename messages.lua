-- current implemented subtypes:
-- failed_read_register
-- failed_write_register
-- device_not_found

function createMessage(type, subtype, info) {
    local m = {}
    m.type = type
    m.subtype = subtype
    m.info = info
    return m
end
