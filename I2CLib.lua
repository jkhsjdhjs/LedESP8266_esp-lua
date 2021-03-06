-- This lib is an extension for the NodeMCU i2c module and still requires it to run.
I2CLib = {}

I2CLib.id = nil

-- init i2c bus
-- params: sda pin, scl pin (for pin numbers see: https://nodemcu.readthedocs.io/en/master/en/modules/gpio/)
-- returns an i2c object
function I2CLib:initialize(sda, scl)
    self.id = 0
    i2c.setup(self.id, sda, scl, i2c.SLOW)
    return self
end

-- check if a specific device exists
-- params: i2c id, device address
-- returns true if device exists, false otherwise
function I2CLib:deviceExists(dev)
    i2c.start(self.id)
    local exists = i2c.address(self.id, dev, i2c.TRANSMITTER)
    i2c.stop(self.id)
    if exists then
        return true
    end
    return false
end

-- list connected devices
-- params: i2c id
-- returns a table with addresses of connected devices
function I2CLib:detectDevices()
    local dev = {}
    for i = 0, 127 do
        if self:deviceExists(i) then
            dev[#dev + 1] = i
        end
    end
    return dev
end

-- read register
-- params: i2c id, device address, register
-- returns value from 0 - 255 on success and false on fail
function I2CLib:readRegister(dev, reg, wsh)
    local rv = false
    i2c.start(self.id)
    if i2c.address(self.id, dev, i2c.TRANSMITTER) then
        i2c.write(self.id, reg)
        i2c.stop(self.id)
        i2c.start(self.id)
        if i2c.address(self.id, dev, i2c.RECEIVER) then
            rv = i2c.read(self.id, 1):byte()
            i2c.stop(self.id)
            return rv
        end
    end
    if wsh then
        wsh:send("error", "device_not_found", { dev = dev })
    end
    i2c.stop(self.id)
    return false
end

-- write register
-- params: i2c id, device address, register, data to write
-- returns true on success, false otherwise
function I2CLib:writeRegister(dev, reg, data, wsh)
    local rv = false
    i2c.start(self.id)
    if i2c.address(self.id, dev, i2c.TRANSMITTER) then
        if i2c.write(self.id, reg, data) - 1 == (data == 0 and 1 or math.ceil(data / 0xFF)) then
            i2c.stop(self.id)
            return true
        else
            if wsh then
                wsh:send("error", "failed_write_register", {
                    dev = dev,
                    reg = reg,
                    data = data
                })
            end
            i2c.stop(self.id)
            return false
        end
    else
        if wsh then
            wsh:send("error", "device_not_found", { dev = dev })
        end
        i2c.stop(self.id)
        return false
    end
end
