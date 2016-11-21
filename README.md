# lua.led
Simple LED controlling software written in Lua for ESP8266 microcontrollers running NodeMCU with a PCA9685 as PWM-Driver.

### TODO:
- ~~restructure code~~
- ~~find out how to smoothly control the brightness of each color with the PCA9685~~
- ~~add fade functions to fade from one color to another~~
- great, now I need to implement some kind of mutual exclusion for the fade function
- add a basic server to accept json encoded data
- improve readme (add more infos, requirements etc)
