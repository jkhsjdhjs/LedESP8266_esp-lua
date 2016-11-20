dofile("i2c_config.lua")
dofile("pca9685.lua")

-- initialize i2c
i2c_id = I2CLib.initialize(i2c_config.sda, i2c_config.scl)

print("Listing I2C Devices:")
for k, v in pairs(I2CLib.detectDevices(i2c_id)) do
    print(k .. ": Device at 0x" ..  string.format("%02X", v) .. " (" .. v .. ")");
end

PCA9685.setLEDBrightness(i2c_id, 1, 0xFFF)
