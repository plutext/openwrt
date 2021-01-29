module("luci.controller.yamon3", package.seeall)

function index()
	local page

	page = entry({"admin", "services", "yamon3"}, cbi("yamon3"), _("YAMon Bandwidth"), 64) 
	page.dependent = true
end
