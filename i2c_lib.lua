I2CLib = {}

-- init i2c bus
function I2CLib.init(sda, scl)
    local id = 0
    i2c.setup(id, sda, scl, i2c.SLOW)
    return id
end

-- check if device address exists
function I2CLib.deviceExists(id, dev)
    i2c.start(id)
    exists = i2c.address(id, dev, i2c.TRANSMITTER)
    i2c.stop(id)
    if exists then
        return true
    end
    return false
end

-- detect devices
function I2CLib.detectDevices(id)
    local dev = {}
    for i = 0, 127 do
        if deviceExists(id, i) then
            dev[#dev + 1] = i
        end
    end
    return dev
end

-- read register
function readRegister(id, dev, reg)
    local rv
    i2c.start(id)
    if i2c.address(id, dev, i2c.TRANSMITTER) then
        i2c.write(id, reg)
        i2c.stop(id)
        i2c.start(id)
        if i2c.address(id, dev, i2c.RECEIVER) then
            rv = i2c.read(id, 1)
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
function writeRegister(id, dev, reg, data)
    local rv
    i2c.start(id)
    if i2c.address(id, dev, i2c.TRANSMITTER) then
        if i2c.write(id, reg, data)
        rv = true
    else
        rv = false
    end
    i2c.stop(id)
    return rv
end
