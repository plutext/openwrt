local fs = require "nixio.fs"
local util = require "nixio.util"

m = Map("speedtest", translate("Netperf Speed Test"), translate("Test Your Internet Speed using NetPerf"))

m.on_after_save = function(self)
	--luci.sys.call("/opt/WRTbmon/process.sh ")
end

m:section(SimpleSection).template = "speedtest/speed"

s=m:section(TypedSection, "test", translate("Options"), translate("Save & Apply to save changes to the Options before running speed test"))
s.addremove=false
s.anonymous=true

dur = s:option(ListValue, "duration", translate("Test Duration :"), translate("Length of time in seconds that speed test runs."))
dur:value("10", "10 seconds")
dur:value("15", "15 seconds")
dur:value("20", "20 seconds")
dur:value("25", "25 seconds")
dur:value("30", "30 seconds")
dur.default = "15"

host = s:option(ListValue, "host", translate("NetPerf Host :"), translate("Server to use for speed test"))
host.rmempty = true
host:value("netperf.bufferbloat.net", "US East (netperf.bufferbloat.net)")
host:value("netperf-west.bufferbloat.net", "US West (netperf-west.bufferbloat.net)")
host:value("netperf-eu.bufferbloat.net", "Europe (netperf-eu.bufferbloat.net)")
host.default = "netperf.bufferbloat.net"

phost = s:option(Value, "ping", translate("Ping Host :"), translate("Server URL or IP Address to ping during test"))
phost:value("gstatic.com", "gstatic.com")
phost:value("google.com", "google.com")
phost:value("1.1.1.1", "1.1.1.1")
phost.default = "gstatic.com"

ipv = s:option(ListValue, "ipv", translate("Network Type :"), translate("Network type to use for test"))
ipv.rmempty = true
ipv:value("4", "IPv4")
ipv:value("6", "IPv6")
ipv.default = "4"

ses = s:option(ListValue, "session", translate("Session Type :"), translate("Test download and upload speeds at same time (concurrent) or separately (sequential)"))
ses.rmempty = true
ses:value("s", "Sequential")
ses:value("c", "Concurrent")
ses.default = "c"

--m:section(SimpleSection).template = "speedtest/speed"

return m