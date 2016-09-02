include("shared.lua")
include("config.lua")
include("gametypes.lua")
include("sv_eventhandler.lua")
include("br_func.lua")
include("meta.lua")
include("resource.lua") 
include("lootsystem.lua")
include("perk_system.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_gm_data.lua")

AddCSLuaFile("shared.lua") 
AddCSLuaFile("config.lua")
AddCSLuaFile("gametypes.lua")
AddCSLuaFile("apparel_system.lua")

AddCSLuaFile("cl_inventory.lua")
AddCSLuaFile("cl_network.lua")
AddCSLuaFile("perk_system.lua")
AddCSLuaFile("cl_mainmenu.lua")

include("items.lua")
include("item_config.lua")
include("buffs.lua") 
include("apparel_system.lua")

AddCSLuaFile("items.lua")
AddCSLuaFile("item_config.lua")
AddCSLuaFile("buffs.lua")

AddCSLuaFile("vgui/inventory.lua")
AddCSLuaFile("vgui/item.lua")
AddCSLuaFile("vgui/button.lua") 
AddCSLuaFile("vgui/limb.lua")
AddCSLuaFile("vgui/brframe.lua")
AddCSLuaFile("vgui/perk.lua")
AddCSLuaFile("vgui/mButton.lua")
AddCSLuaFile("vgui/apparel.lua")
AddCSLuaFile("vgui/player.lua")

include("editor/sv_editor.lua")
include("editor/sh_editor.lua")
AddCSLuaFile("editor/cl_editor.lua")
AddCSLuaFile("editor/sh_editor.lua")

local path = GM.FolderName
files, dir = file.Find(path.."/gamemode/HUD/*","LUA")
for k,v in pairs(files) do
	AddCSLuaFile("HUD/"..v)
end

files, dir = file.Find(path.."/gamemode/gametypes/*","LUA")
for k,v in pairs(files) do
	include("gametypes/"..v)
	AddCSLuaFile("gametypes/"..v)
end

files, dir = file.Find(path.."/gamemode/apparel/*","LUA")
for k,v in pairs(files) do
	include("apparel/"..v)
	AddCSLuaFile("apparel/"..v)
end

files, dir = file.Find(path.."/gamemode/perks/*","LUA")
for k,v in pairs(files) do
	include("perks/"..v)
	AddCSLuaFile("perks/"..v)
end

files, dir = file.Find(path.."/gamemode/items/*","LUA")
for k,v in pairs(files) do
	include("items/"..v)
	AddCSLuaFile("items/"..v)
end

concommand.Add("rungame", function()
	if pl then return end
	
	BattleRoyale:SetGameType("Deathmatch")
	BattleRoyale:StartGame()
end)

concommand.Add("SpawnTest", function(pl)

	local ent = ents.Create("ent_container")
	ent:SetPos(pl:GetPos())
	ent:Spawn()
	
	ent:SCType("Random")
end)

require( "tmysql4" )
db,err = tmysql.initialize("127.0.0.1","root","llamas11","broyale",3306)
hook.Add("Initialize","Do SQL",function()
	if db then
		print("[SQL] Database connected, prepared to retrieve information.")
	else
		print("[SQL] ERROR! Couldn't connect to DB!")
		error(err)
	end
	
	err = nil
end) 