require "config"
require "WebsocketHandler"
require "I2CLib"
require "PCA9685"

-- json communication via wss://
-- {
--      receiver: uuid of the receiver (string),
--      type: "info" / "warning" / "error",
--      msg: the actual message (string),
--      data: another json object
-- }

local ws = websocket.createClient()

ws:on("receive", function(_, msg, opcode)
    wsh = WebsocketHandler:initialize(ws, json.sender)
    if json.reqtype == "get" then
        ws:send(cjson.encode({
            receiver = json.receiver,
            type = "info",
            msg = nil,
            data = {
                red = pca:getChannelBrightness(pca.channel.red, wsh),
                green = pca:getChannelBrightness(pca.channel.green, wsh),
                blue = pca:getChannelBrightness(pca.channel.blue, wsh)
            }
        }))
    elseif json.reqtype == "set" then
        if data.data.red >= 0x000 and data.data.red <= 0xFFF and data.data.green >= 0x000 and data.data.green <= 0xFFF
        and data.data.blue >= 0x000 and data.data.green <= 0xFFF and data.data.fade_time >= 0 and data.data.fade_time <= 60000 then
            pca:fadeToColor(data.data.red, data.data.green, data.data.blue, data.data.fade_time, wsh:send)
        else
            wsh:send("error", "invalid_arguments", json)
        end
    else
        wsh:send("error", "invalid_reqtype")
    end
end)
ws:connect(config.websocket.url)

-- initialize pca9685
local pca = PCA9685:initialize(I2Clib:initialize(config.i2c.sda, config.i2c.scl), config.pca9685.address, config.pca9685.channel, config.pca9685.tmr_ref, function(type, msg, data)
    ws:send(cjson.encode({
        receiver = nil,
        type = type,
        msg = msg,
        data = data
    }))
end)
