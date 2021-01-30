local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()

local m = Map("wireguard", translate("Wireguard"), translate("Set up a Wireguard VPN Tunnel on your Router"))

local s = m:section( TypedSection, "wireguard", translate("Wireguard Servers"), translate("Below is a list of configured Wireguard Servers and their current state") )
s.template = "cbi/tblsection"
s.template_addremove = "wireguard/cbi-select-input-add"
s.addremove = true
s.extedit = luci.dispatcher.build_url(
	"admin", "services", "wireguard", "basic", "%s"
)

function s.create(self, name)
	name = luci.http.formvalue(
		luci.cbi.CREATE_PREFIX .. self.config .. "." ..
		self.sectiontype .. ".text"
	)
	if #name > 2 and not name:match("[^a-zA-Z0-9_]") then
		local s = uci:section("wireguard", "wireguard", name)
		if s then
			uci:set("wireguard", name, "name", name)
			uci:set("wireguard", name, "port", "51820")
			uci:set("wireguard", name, "addr", "10.0.0.0")
			uci:delete("wireguard", name, "_role")
			uci:delete("wireguard", name, "_description")
			uci:save("wireguard")
			luci.http.redirect( self.extedit:format(name) )
		end
	elseif #name > 0 then
		self.invalid_cts = true
	end

	return 0
end

local port = s:option( DummyValue, "port", translate("Port") )
function port.cfgvalue(self, section)
	local val = AbstractValue.cfgvalue(self, section)
	return val or "1194"
end

local addr = s:option( DummyValue, "addr", translate("IPv4 Address") )
function addr.cfgvalue(self, section)
	local val = AbstractValue.cfgvalue(self, section)
	return val or "10.0.0.1/24"
end

local peer = s:option( DummyValue, "peers", translate("# of Peers") )
function peer.cfgvalue(self, section)
	local val = AbstractValue.cfgvalue(self, section)
	return val or "0"
end

local pub = s:option( DummyValue, "publickey", translate("Public Key") )
function pub.cfgvalue(self, section)
	local val = AbstractValue.cfgvalue(self, section)
	return val or "xxxx"
end

return m