-- This lib is an extension for the NodeMCU i2c module and still requires it to run.

I2CLib = {}

-- init i2c bus
-- params: sda pin, scl pin (for pin numbers see: https://nodemcu.readthedocs.io/en/master/en/modules/gpio/)
-- returns the i2c id (always 0)
I2CLib.initialize = function (sda, scl)
    local id = 0
    i2c.setup(id, sda, scl, i2c.SLOW)
    return id
end

-- check if a specific device exists
-- params: i2c id, device address
-- returns true if device exists, false otherwise
I2CLib.deviceExists = function (id, dev)
    i2c.start(id)
    exists = i2c.address(id, dev, i2c.TRANSMITTER)
    i2c.stop(id)
    if exists then
        return true
    end
    return false
end

-- list connected devices
-- params: i2c id
-- returns a table with addresses of connected devices
I2CLib.detectDevices = function (id)
    local dev = {}
    for i = 0, 127 do
        if I2CLib.deviceExists(id, i) then
            dev[#dev + 1] = i
        end
    end
    return dev
end

-- read register
-- params: i2c id, device address, register
-- returns value from 0 - 255 on success and false on fail
I2CLib.readRegister = function (id, dev, reg)
    local rv
    i2c.start(id)
    if i2c.address(id, dev, i2c.TRANSMITTER) then
        i2c.write(id, reg)
        i2c.stop(id)
        i2c.start(id)
        if i2c.address(id, dev, i2c.RECEIVER) then
            rv = i2c.read(id, 1):byte()
            i2c.stop(id)
        else
            rv = false
        end
    else
        rv = false
    end
    return rv
end

-- write register
-- params: i2c id, device address, register, data to write
-- returns true on success, false otherwise
I2CLib.writeRegister = function (id, dev, reg, data)
    local rv
    i2c.start(id)
    if i2c.address(id, dev, i2c.TRANSMITTER) then
        if i2c.write(id, reg, data) - 1 == (data == 0 and 1 or math.ceil(data / 0xFF)) then
            rv = true
        else
            rv = false
        end
    else
        rv = false
    end
    i2c.stop(id)
    return rv
end
