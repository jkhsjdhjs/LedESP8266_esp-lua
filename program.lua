require "i2c_config"
require "pca9685_config"
require "i2c_lib"
require "pca9685"

function initialize()
    -- initialize i2c
    local i2cBus = I2CLib:initialize(i2c_config.sda, i2c_config.scl)

    -- initialize pca9685
    local pca = PCA9685:initialize(i2cBus, pca9685_config.address, pca9685_config.channel, pca9685_config.tmr_ref)

    if not pca then
        print("Failed to initialize PCA9685!")
        return false
    end

    return pca
end

pca = initialize()
