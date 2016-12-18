local WebsocketHandler = {}

local WebsocketHandler.websocket = nil
local WebsocketHandler.websocketID = nil

local function WebsocketHandler:initialize(websocket, websocketID)
    self.websocket = websocket
    self.websocketID = websocketID
    return self
end

local function WebsocketHandler:replyFunc(type, msg, data)
    self.websocket:send(cjson.encode({
        websocketID = self.websocketID,
        type = type,
        msg = msg,
        data = data
    }))
end
