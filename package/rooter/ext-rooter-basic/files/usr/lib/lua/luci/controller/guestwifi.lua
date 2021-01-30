module("luci.controller.guestwifi", package.seeall)

function index()
	local page
	if not nixio.fs.access("/etc/config/wireless") then
		return
	end
	
	page = entry({"admin", "network", "guestwifi"}, cbi("guestwifi", {hidesavebtn=true, hideresetbtn=true}), "Guest Wifi", 22)
	page.dependent = true
end
