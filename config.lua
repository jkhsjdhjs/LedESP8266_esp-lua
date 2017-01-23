config = {
    i2c = {
        sda = 1,
        scl = 2
    },
    websocket = {
        url = "ws://192.168.0.17:14795",
        reconnect_interval = 10000
    },
    pca9685 = {
        address = 0x40,
        channel = {
            red = 0,
            green = 1,
            blue = 2
        }
    }
}
