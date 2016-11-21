PCA9685 = {}

PCA9685.i2c = nil
PCA9685.address = nil
PCA9685.channel = {}


-- converts a channel number to the address of the first register which belongs to the specified channel (each channel has 4 registers)
-- params: channel
-- returns the first register for the specified channel
function PCA9685.channelToRegister(channel)
    return 0x06 + 0x04 * channel
end

-- write a value in a register of the pca
-- params: register to read from
-- returns value from 0x00 to 0xFF on success, false otherwise
function PCA9685:readRegister(reg)
    return self.i2c:readRegister(self.address, reg)
end

-- write a value in a register of the pca
-- params: register to write in, value
-- returns true on success, false otherwise
function PCA9685:writeRegister(reg, val)
    return self.i2c:writeRegister(self.address, reg, val)
end

-- initialize the PCA9685 module
-- params: i2c bus object (from I2CLib.initialize()), device address, channels (for exmaple {red = 0, green = 1, blue = 2})
-- returns self on success, false otherwise
function PCA9685:initialize(i2c, address, channel)
    self.i2c = i2c
    self.address = address
    self.channel = channel
    if not self:writeRegister(0x00, 0x00) then
        return false
    end
    -- initialize specified channels
    for k, v in pairs(self.channel) do
        v = self.channelToRegister(v)
        for l = v, v + 3 do
            if not self:writeRegister(l, 0x00) then
                return false
            end
        end
    end
    return self
end

-- set the LED brightness of a specific channel
-- params: channel, brightness (value from 0x000 to 0xFFF)
-- returns true on success, false otherwise
function PCA9685:setChannelBrightness(channel, brightness)
    local register = self.channelToRegister(channel)
    if self:writeRegister(register + 3, bit.band(bit.rshift(brightness, 2 * 4), 0x0F)) and self:writeRegister(register + 2, bit.band(brightness, 0xFF)) then
        return true
    end
    return false
end

-- get the LED brightness of a specific channel
-- params: channel
-- returns brightness (from 0x000 to 0xFFF) on success, false otherwise
function PCA9685:getChannelBrightness(channel)
    local register = self.channelToRegister(channel)
    msb = bit.lshift(self:readRegister(register + 3), 2 * 4)
    lsb = self:readRegister(register + 2)
    if msb and lsb then
        return bit.bor(msb, lsb)
    end
    return false
end

-- set rgb color
-- params: red, green, blue (each value from 0x000 to 0xFFF)
-- returns true on success, false otherwise
function PCA9685:setColor(red, green, blue)
    if self:setChannelBrightness(self.channel.red, red) and self:setChannelBrightness(self.channel.green, green) and self:setChannelBrightness(self.channel.blue, blue) then
        return true
    end
    return false
end

-- function to smoothly fade from the current color to the specified
-- params: red, green, blue, time (red, green and blue from 0x000 to 0xFFF and time nil or from 0 to infinity)
-- returns true on success, false otherwise
function PCA9685:fadeToColor(red, green, blue, time)
    if not time or time == 0 then
        return self:setColor(red, green, blue)
    end
    local c_red = self:getChannelBrightness(self.channel.red)
    local c_green = self:getChannelBrightness(self.channel.green)
    local c_blue = self:getChannelBrightness(self.channel.blue)
    return true
end
