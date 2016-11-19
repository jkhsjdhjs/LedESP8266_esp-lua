dofile("i2c_config.lua")
dofile("i2c_lib.lua")

-- initialize i2c
i2c_id = I2CLib.init(i2c_config.sda, i2c_config.scl)

print("Listing I2C Devices:")
for k, v in pairs(detectDev(i2c_config.id)) do
    print(k .. ": Device at 0x" ..  string.format("%02X", v) .. " (" .. v .. ")");
end

dev = 0x40
reg = 0x10
val = 0x01

while true do
    for i = 0x000, 0xFFF do
        I2CLib.writeRegister(i2c_config.id, dev, 0x08, bit.band(i, 0xFF))
        writeReg(i2c_config.id, dev, 0x09, bit.band(bit.rshift(i, 3), 0x0F))
        print("Setting: 0x" .. string.format("%03X", i))
        tmr.delay(1000000)
    end
    for i = 0xFFF, 0x000, -1 do
        writeReg(i2c_config.id, dev, 0x08, bit.band(i, 0xFF))
        writeReg(i2c_config.id, dev, 0x09, bit.band(bit.rshift(i, 3), 0x0F))
        print("Setting: 0x" .. string.format("%03X", i))
        tmr.delay(1000000)
    end
end


--while true do
--    for i = 0x00, 0xFF, 1 do
--        writeReg(i2c_config.id, dev, reg, i)
--        print("Incrementing brightness: " .. string.format("%02X", i))
--        tmr.delay(20000)
--    end
--    for i = 0x00, 0xFF, 1 do
--        writeReg(i2c_config.id, dev, reg + 2, i)
--        print("Incrementing darkness: " .. string.format("%02X", i))
--        tmr.delay(20000)
--    end
--    for i = 0xFF, 0x00, -1 do
--        writeReg(i2c_config.id, dev, reg, i)
--        print("Decrementing brightness: " .. string.format("%02X", i))
--        tmr.delay(20000)
--    end
--    for i = 0xFF, 0x00, -1 do
--        writeReg(i2c_config.id, dev, reg + 2, i)
--        print("Decrementing darkness: " .. string.format("%02X", i))
--        tmr.delay(20000)
--    end
--end

--writeReg(i2c_config.id, dev, 0x00, 0x00)

--while true do
--    for i = 0x07, 0x0F, 4 do
--        writeReg(i2c_config.id, dev, i, 0x10)
--        writeReg(i2c_config.id, dev, i + 2, 0x01)
--        tmr.delay(1000000)
--    end
--    for i = 0x0F, 0x07, -4 do
--        writeReg(i2c_config.id, dev, i, 0x01)
--        writeReg(i2c_config.id, dev, i + 2, 0x10)
--        tmr.delay(1000000)
--    end
--end

if deviceExists(i2c_config.id, dev) then
    if val then
        writeReg(i2c_config.id, dev, reg, val)
    end
    if deviceExists(i2c_config.id, dev) then
        val = readReg(i2c_config.id, dev, reg)
        print("Value of reg 0x" .. string.format("%02X", reg) .. " at device 0x" .. string.format("%02x", dev) .. ": 0x" .. string.format("%02X", string.byte(val)) .. " (" .. string.byte(val) .. ")")
    else
        print("Failed to read! Device 0x" .. string.format("%02X", dev) .. " doesn't exist!")
    end
else
    print("Failed to write! Device 0x" .. string.format("%02X", dev) .. " doesn't exist!")
end
