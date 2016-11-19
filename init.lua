timeserver = "timeserver1.rwth-aachen.de"

-- sync time on startup after the esp got an ip address
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function()
    sntp.sync(timeserver)
    wifi.eventmon.unregister(wifi.eventmon.STA_GOT_IP)
end)

-- timesync every hour
tmr.alarm(0, 3600000, tmr.ALARM_AUTO, function()
    if wifi.sta.getip() then
        sntp.sync(timeserver)
    end
end)
