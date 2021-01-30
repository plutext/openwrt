module("luci.controller.speedtest", package.seeall)
function index()
	local page
	page = entry({"admin", "services", "speedtest"}, cbi("speedtest"), "Netperf Speed Test", 71)
	page.dependent = true
	
	entry({"admin", "services", "ststatus"}, call("action_ststatus"))
	entry({"admin", "services", "ststart"}, call("action_ststart"))
end

function action_ststatus()
	local rv = {}
	
	local file = io.open("/tmp/dots", "r")
	if file ~= nil then
		rv["result"] = file:read("*all")
		file:close()
	else
		file = io.open("/tmp/speedtest", "r")
		if file ~= nil then
			rv["result"] = file:read("*all")
			file:close()
		else
			rv["result"] = "  Test Not Running"
		end
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_ststart()
	os.execute("/usr/lib/speedtest/speedtest.sh &")
end