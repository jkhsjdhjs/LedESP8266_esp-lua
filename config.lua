config = {
    i2c = {
        sda = 1,
        scl = 2
    },
    websocket = {
        url = "wss://",
        port = 6550,
        timeout = 60
    },
    pca9685 = {
        address = 0x40,
        channel = {
            red = 0,
            green = 1,
            blue = 2
        },
        tmr_ref = 6
    }
}
