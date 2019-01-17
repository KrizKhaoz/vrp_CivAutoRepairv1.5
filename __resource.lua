resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description "vrp_CivAutoRepair"

dependency "vrp"

client_scripts { 
  "lib/Tunnel.lua",
  "lib/Proxy.lua",
  "client/client.lua"
}

server_scripts { 
  "@vrp/lib/utils.lua",
  "server/server.lua"
}