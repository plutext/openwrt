#!/usr/bin/lua

function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

if file_exists("/etc/custom") then
	file = io.open("/etc/custom", "r")
	customboard = file:read("*line")
	custommodel = file:read("*line")
	hostname = file:read("*line")
	file:close()
	tfile = io.open("/tmp/sysinfo/model", "w")
	tfile:write(custommodel, "\n")
	tfile:close()
end