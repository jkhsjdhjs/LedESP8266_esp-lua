dofile("i2c_pca_config.lua")
dofile("i2c_lib.lua")
dofile("pca9685.lua")

function initialize()
    -- initialize i2c
    local i2cBus = I2CLib:initialize(i2c_pca_config.i2c.sda, i2c_pca_config.i2c.scl)

    -- initialize pca9685
    local pca = PCA9685:initialize(i2cBus, i2c_pca_config.pca.address, i2c_pca_config.pca.channel)

    if not pca then
        print("Failed to initialize PCA9685!")
        return false
    end

    return pca
end

pca = initialize()
