require "config"
require "WebsocketHandler"
require "I2CLib"
require "PCA9685"

function print_error(self, type, msg, data)
    print("error type: ", type)
    print("error msg: ", msg)
    print("error data: ", sjson.encode(data))
end

-- initialize pca9685
local pca = PCA9685:initialize(I2CLib:initialize(config.i2c.sda, config.i2c.scl), config.pca9685.address, config.pca9685.channel, config.pca9685.tmr_ref, {
    send = print_error,
    broadcast = print_error
})

local ws = websocket.createClient()
ws:on("receive", function(_, msg, opcode)
    json = sjson.decode(msg)
    wsh = WebsocketHandler:initialize(ws, json.caller)
    if json.msg == "get" then
        wsh:send("info", "color", {
            color = {
                red = pca:getChannelBrightness(pca.channel.red, wsh),
                green = pca:getChannelBrightness(pca.channel.green, wsh),
                blue = pca:getChannelBrightness(pca.channel.blue, wsh)
            }
        })
    elseif json.msg == "set" then
        pca:fadeToColor(json.data.color.red, json.data.color.green, json.data.color.blue, json.data.fade_time, wsh)
    else
        wsh:send("error", "invalid_method")
    end
end)
ws:on("connection", function()
    print("connected to " .. config.websocket.url)
end)
ws:on("close", function(_, status)
    print("connection closed. status: ", status)
    tmr.create():alarm(config.websocket.reconnect_interval, tmr.ALARM_SINGLE, function()
        print("connecting to " .. config.websocket.url)
        ws:connect(config.websocket.url)
    end)
end)
print("connecting to " .. config.websocket.url)
ws:connect(config.websocket.url)
