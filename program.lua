require "i2c_config"
require "pca9685_config"
require "server_config"
require "i2c_lib"
require "pca9685"

function initialize()
    -- initialize i2c
    local i2cBus = I2CLib:initialize(i2c_config.sda, i2c_config.scl)

    -- initialize pca9685
    local pca = PCA9685:initialize(i2cBus, pca9685_config.address, pca9685_config.channel, pca9685_config.tmr_ref)

    if not pca then
        return false
    end

    return pca
end

pca = initialize()

if pca then
    sv = net.createServer(net.TCP, server_config.timeout)
    sv:listen(server_config.port, function(c)
        c:on("receive", function(c, pl)
            data = cjson.decode(pl)
            if data.reqtype == "get" then
                c:send(cjson.encode({
                    red = pca:getChannelBrightness(pca.channel.red),
                    green = pca:getChannelBrightness(pca.channel.green),
                    blue = pca:getChannelBrightness(pca.channel.blue)
                }))
            elseif data.reqtype == "set" then
                if data.data.red >= 0x000 and data.data.red <= 0xFFF and data.data.green >= 0x000 and data.data.green <= 0xFFF
                and data.data.blue >= 0x000 and data.data.green <= 0xFFF and data.data.fade_time >= 0 and data.data.fade_time <= 60000 then
                    if pca:fadeToColor(data.data.red, data.data.green, data.data.blue, data.data.fade_time) then
                        c:send("success")
                    else
                        c:send("error")
                    end
                else
                    c:send("wrong_argument_range")
                end
            end
            c:close()
        end)
    end)
else
    print("Failed to initialize PCA9685!")
end
