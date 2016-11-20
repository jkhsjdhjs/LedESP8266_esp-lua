dofile("i2c_lib.lua")

PCA9685 = {}

PCA9685.setPWM = function (i2c_id, channel, val)
    register = 0x06 + 0x04 * channel
    if not I2CLib.writeRegister(i2c_id, 0x40, register, bit.band(bit.rshift(val, 3 * 4), 0xFF)) then
        return false
    end
    if not I2CLib.writeRegister(i2c_id, 0x40, register + 1, bit.band(bit.rshift(val, 5 * 4), 0x0F)) then
        return false
    end
    if not I2CLib.writeRegister(i2c_id, 0x40, register + 2, bit.band(val, 0xFF)) then
        return false
    end
    if not I2CLib.writeRegister(i2c_id, 0x40, register + 3, bit.band(bit.rshift(val, 2 * 4), 0x0F)) then
        return false
    end
    return true
end

PCA9685.setLEDBrightness = function (i2c_id, channel, val)
    return PCA9685.setPWM(i2c_id, channel, bit.band(val, 0xFFF))
end
