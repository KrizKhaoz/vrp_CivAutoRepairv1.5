local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

CvRP = {}
Tunnel.bindInterface("vrp_CivAutoRepair",CvRP)
Proxy.addInterface("vrp_CivAutoRepair",CvRP)
--vRPclient = Tunnel.getInterface("vRP","vrp_CivAutoRepair") -- not needed here.

--Settings--

enableprice = true -- [Keep this true]
--[[  Prices  ]]
local price = 500 --- Regular Price if you change this be sure to change the price in line
local qprice = 2000 -- Premium Price if you change this be sure to change the price in line

--[[ 
	DO NOT EDIT THIS CODE BELOW!
]]
function CvRP.checkMoney(user)
  local _source = user
  local player = vRP.getUserId({_source})
  local playerMoney = vRP.getMoney({player})		
  if(enableprice == true) then
	if(playerMoney >= price) then
	  vRP.tryPayment({player, price})
	  TriggerClientEvent('Civrepair:success', _source, price)		
	else
	  local moneyleft = price - playerMoney
	  TriggerClientEvent('Civrepair:notenoughmoney', _source, moneyleft)
	end
  else
	TriggerClientEvent('Civrepair:free', _source)
  end
end

function CvRP.CheckMoneyPremium(user)
  local _source = user
  local player = vRP.getUserId({_source})
  local playerMoney = vRP.getMoney({player})			
  if(enableprice == true) then
	if(playerMoney >= qprice) then
	  vRP.tryPayment({player, qprice})
	  TriggerClientEvent('Civrepair:successpremium', _source, qprice)
	else
	  local moneyleft = qprice - playerMoney
	  TriggerClientEvent('Civrepair:notenoughmoneypremium', _source, moneyleft)
	end
  else
	TriggerClientEvent('Civrepair:free', _source)
  end
end


RegisterServerEvent("Civrepair:Menu")
AddEventHandler("Civrepair:Menu", function ()
	local _source = source
	local player = vRP.getUserId({_source})
	local menudata = {}

	menudata.name = "Repair Shop"
	menudata.css = {align = 'top-left'}

	menudata["Normal Repair"] = {function (choice)
	  CvRP.CheckMoney(_source)
	  vRP.closeMenu({_source})
	end}
	menudata["Fast & Premium Repair"] = {function (choice)
	  CvRP.CheckMoneyPremium(_source)
	  vRP.closeMenu({_source})
	end}
	vRP.openMenu({_source, menudata})
end)
