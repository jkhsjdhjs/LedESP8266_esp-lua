# lua.led
Simple LED controlling software written in Lua for ESP8266 microcontrollers running NodeMCU with a PCA9685 as PWM-Driver.

### TODO:
- ~~restructure code~~
- ~~find out how to smoothly control the brightness of each color with the PCA9685~~
- ~~add fade functions to fade from one color to another~~
- ~~great, now I need to implement some kind of mutual exclusion for the fade function~~ < no I actually don't have to cause every fade uses the same tmr_ref. that means if a fade is running and a second one starts, the previously running one will just stop and the new fade will start to fade where the other one stopped
- add a basic server to accept json encoded data
- improve readme (add more infos, requirements etc)
