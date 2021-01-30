--[[
luci-app-argon-config
]]--

module("luci.controller.argon-config", package.seeall)

function index()
	if not nixio.fs.access('/www/luci-static/argon/css/cascade.css') then
        return
    end
	entry({"admin", "theme"}, firstchild(), "Themes", 99).dependent=false
	entry({"admin", "theme", "theme"}, cbi("themes"), _("Change GUI Theme"), 61)
	entry({"admin", "theme", "argon-config"}, form("argon-config/configuration"), _("Argon Settings"),90)
end
