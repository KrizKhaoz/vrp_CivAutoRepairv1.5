local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local Lang = module("vrp", "lib/Lang")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_CivAutoRepair")

CvRP = {}
--Tunnel.bindInterface("vrp_CivAutoRepair",CvRPc)
Proxy.addInterface("vrp_CivAutoRepair",CvRP)

local cfg = module("vrp", "cfg/base")
local lang = Lang.new(module("vrp", "cfg/lang/"..cfg.lang) or {})
local htmlEntities = module("vrp", "lib/htmlEntities")

--Settings--

enableprice = true -- [Keep this true]
--[[  Prices  ]]
local price = 820 --- Regular Price if you change this be sure to change the price in line
local qprice = 1855 -- Premium Price if you change this be sure to change the price in line

--[[ 
	DO NOT EDIT THIS CODE BELOW!
]]
function CvRP.CheckMoney(user)
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

function CvRP.RepairGuy(user)
  local _source = user
  local player = vRP.getUserId({_source})
  vRP.prompt({_source,"Price $: (Above 750)","",function(player,amount)
    local amountt = tonumber(amount)
    if (amountt and amountt > 750 and amountt < 999999999999) then
	  vRPclient.getNearestPlayer(_source,{6},function(nplayer)
		local nuser_id = vRP.getUserId({nplayer})
		if nuser_id ~= nil then
		  vRPclient.notify(_source,{"Asking person for tha cash."})
		  vRP.request({nplayer,"Would you like to repair your vehicle for $ "..amountt.."?",15,function(nplayer,ok)
			if ok then
			  local playerMoney = vRP.getMoney({nuser_id})	
			  if(playerMoney >= amountt) then
			    vRP.tryPayment({nuser_id, amountt})
				vRP.giveMoney({player, amountt})
			    TriggerClientEvent('Civrepair:successpremium', _source, amountt)
			  else
			    local moneyleft = amountt - playerMoney
				vRPclient.notify(_source,{"~r~The person doesn't have enough money. He has $ "..moneyleft.." left"})
				vRPclient.notify(nplayer,{"~r~You don't have enough money. You have $ "..moneyleft.." left"})
			    --TriggerClientEvent('Civrepair:notenoughmoneypremium', _source, moneyleft)
			  end
			else
			  vRPclient.notify(_source,{lang.common.request_refused()})
			end
		  end})
		else
		  vRPclient.notify(_source,{lang.common.no_player_near()})
		end
	  end)
	else
	  vRPclient.notify(_source,{"~r~The price of the car has to be a number and more then $750."})
	end
  end})
end

RegisterServerEvent("Civrepair:Menu")
AddEventHandler("Civrepair:Menu", function ()
  local _source = source
  local player = vRP.getUserId({_source})
  local menudata = {}

  menudata.name = "Repair Shop"
  menudata.css = {align = 'top-left'}

  if vRP.hasPermission({player,"vehicle.repair"}) then
	menudata["Mechanic Repair Fast"] = {function (choice)
	  CvRP.RepairGuy(_source)
	  vRP.closeMenu({_source})
	end}
  else
	menudata["Normal Repair"] = {function (choice)
	  CvRP.CheckMoney(_source)
	  vRP.closeMenu({_source})
	end}
	menudata["Fast & Premium Repair"] = {function (choice)
	  CvRP.CheckMoneyPremium(_source)
	  vRP.closeMenu({_source})
	end}
  end
	vRP.openMenu({_source, menudata})
end)
