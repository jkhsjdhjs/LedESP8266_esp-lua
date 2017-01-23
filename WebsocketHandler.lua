WebsocketHandler = {}

WebsocketHandler.websocket = nil
WebsocketHandler.receiver = nil

function WebsocketHandler:initialize(websocket, receiver)
    self.websocket = websocket
    self.receiver = receiver
    return self
end

function WebsocketHandler:send(type, msg, data)
    self.websocket:send(cjson.encode({
        receiver = self.receiver,
        type = type,
        msg = msg,
        data = data
    }))
end

function WebsocketHandler:broadcast(type, msg, data)
    self.websocket:send(cjson.encode({
        receiver = nil,
        type = type,
        msg = msg,
        data = data
    }))
end
