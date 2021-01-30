-- Copyright 2016-2017 Dan Luedtke <mail@danrl.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.wireguard", package.seeall)

function index()
  entry({"admin", "status", "wireguard"}, template("wireguard"), _("WireGuard Status"), 92)
  entry({"admin", "services", "wireguard"}, cbi("wireguard"), _("Wireguard"), 63)
  entry( {"admin", "services", "wireguard", "basic"},    cbi("wireguard-basic"),    nil ).leaf = true
end
