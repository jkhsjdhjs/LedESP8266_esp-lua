require "messages"

PCA9685 = {}

PCA9685.i2c = nil
PCA9685.address = nil
PCA9685.channel = {}
PCA9685.tmr_ref = nil


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
function PCA9685:initialize(i2c, address, channel, tmr_ref)
    self.i2c = i2c
    self.address = address
    self.channel = channel
    self.tmr_ref = tmr_ref
    local rv = self:writeRegister(0x00, 0x00)
    if type(rv) ~= "boolean" or rv == false then
        return rv
    end
    -- initialize specified channels
    for k, v in pairs(self.channel) do
        v = self.channelToRegister(v)
        for l = v, v + 3 do
            rv = self:writeRegister(l, 0x00)
            if type(rv) ~= "boolean" or rv == false then
                return rv
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
    local rv = self:writeRegister(register + 3, bit.band(bit.rshift(brightness, 2 * 4), 0x0F))
    if rv ~= "boolean" or rv == false then
        return rv
    end
    rv = self:writeRegister(register + 2, bit.band(brightness, 0xFF))
    if rv ~= "boolean" or rv == false then
        return rv
    end
    return true
end

-- get the LED brightness of a specific channel
-- params: channel
-- returns brightness (from 0x000 to 0xFFF) on success, false otherwise
function PCA9685:getChannelBrightness(channel)
    local register = self.channelToRegister(channel)
    local rv = self:readRegister(register + 3)
    if rv ~= "boolean" or rv == false then
        return rv
    end
    local msb = bit.lshift(rv, 2 * 4)
    rv = self:readRegister(register + 2)
    if rv ~= "boolean" or rv == false then
        return rv
    end
    return bit.bor(msb, rv)
end

-- set rgb color
-- params: red, green, blue (each value from 0x000 to 0xFFF)
-- returns true on success, false otherwise
function PCA9685:setColor(red, green, blue)
    local rv = self:setChannelBrightness(self.channel.red, red)
    if rv ~= "boolean" or rv == false then
        return rv
    end
    rv = self:setChannelBrightness(self.channel.green, green)
    if rv ~= "boolean" or rv == false then
        return rv
    end
    rv = self:setChannelBrightness(self.channel.blue, blue)
    if rv ~= "boolean" or rv == false then
        return rv
    end
    return true
end

-- function to smoothly fade from the current color to the specified
-- params: red, green, blue, time (red, green and blue from 0x000 to 0xFFF and time nil or from 0 to infinity in miliseconds)
-- returns true on success, false otherwise
function PCA9685:fadeToColor(red, green, blue, time)
    if not time or time == 0 then
        return self:setColor(red, green, blue)
    end
    local c_red = self:getChannelBrightness(self.channel.red)
    local c_green = self:getChannelBrightness(self.channel.green)
    local c_blue = self:getChannelBrightness(self.channel.blue)
    if not c_red or not c_green or not c_blue then
        return false
    end
    local step_red = (red - c_red) / time
    local step_green = (green - c_green) / time
    local step_blue = (blue - c_blue) / time
    local cnt = 0
    -- it takes about 20ms to set a color with :setColor(), so i'm using 30ms as tmr_interval
    local tmr_interval = 30
    if not tmr.alarm(self.tmr_ref, tmr_interval, tmr.ALARM_AUTO, function()
        if cnt >= time - tmr_interval then
            tmr.unregister(self.tmr_ref)
            self:setColor(red, green, blue)
            return
        end
        c_red = c_red + tmr_interval * step_red
        c_green = c_green + tmr_interval * step_green
        c_blue = c_blue + tmr_interval * step_blue
        self:setColor(c_red, c_green, c_blue)
        cnt = cnt + tmr_interval
    end) then
        return false
    end
    return true
end
