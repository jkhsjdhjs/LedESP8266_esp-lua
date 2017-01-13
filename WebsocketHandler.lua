local WebsocketHandler = {}

local WebsocketHandler.websocket = nil
local WebsocketHandler.receiver = nil

local function WebsocketHandler:initialize(websocket, receiver)
    self.websocket = websocket
    self.receiver = receiver
    return self
end

local function WebsocketHandler:send(type, msg, data)
    self.websocket:send(cjson.encode({
        receiver = self.receiver,
        type = type,
        msg = msg,
        data = data
    }))
end

local function WebsocketHandler:sendAll(type, msg, data)
    self.websocket:send(cjson.encode({
        receiver = nil,
        type = type,
        msg = msg,
        data = data
    }))
end
