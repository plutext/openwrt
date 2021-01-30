require("luci.ip")
require("luci.model.uci")

--luci.sys.call("/usr/lib/wireguard/keygen.sh " .. arg[1])

local m = Map("wireguard", translate("Wireguard Server/Peer Creation"), translate("Set up a Wireguard Server with Peers"))

e = m:section(NamedSection, "settings", "")

m.on_init = function(self)
	luci.sys.call("/usr/lib/wireguard/keygen.sh " .. arg[1])
end

btn = e:option(Button, "_btn", translate(" "))
btn.inputtitle = translate("Back to Main Page")
btn.inputstyle = "apply"
btn.redirect = luci.dispatcher.build_url(
	"admin", "services", "wireguard"
)
function btn.write(self, section, value)
	luci.http.redirect( self.redirect )
end


local s = m:section( NamedSection, arg[1], "wireguard" )

name = s:option( DummyValue, "name", translate("Server Name :"), "=====================================")

ip = s:option(Value, "addr", translate("IP Address :"), translate("Server subnet IP CIDR, for example 10.200.200.1/24 . This will be the subnet of your VPN.")); 
ip.rmempty = true;
ip.optional=false;
ip.default="10.0.0.1/24";
ip.datatype = "ipaddr"

port = s:option(Value, "port", translate("Port :"), translate("Server Port")); 
port.rmempty = true;
port.optional=false;
port.default="51820";

pkey = s:option(DummyValue, "privatekey", translate("Private Key :"), translate("=====================================")); 
pkey.rmempty = true;
pkey.optional=false;

pukey = s:option(DummyValue, "publickey", translate("Public Key :"), translate("=====================================")); 
pukey.rmempty = true;
pukey.optional=false;


sukey = s:option(DummyValue, "sharedkey", translate("Shared Key :"), translate("=====================================")); 
sukey.rmempty = true;
sukey.optional=false;


return m