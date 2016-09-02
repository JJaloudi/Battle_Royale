function GetItemsByRarity(class)
	local tbl = {}
	
	for k,v in pairs(ITEMS) do
		if v.Rarity == class then
			table.insert(tbl, k)
		end
	end
	
	return tbl
end

function BattleRoyale:SpawnLoot()

	--[[ if self.Config then
		local data = self.Config
	
 		if data["Loot Spawn"] then
			for k,v in pairs(data["Loot Spawn"]) do
				local chance = math.random(1, 100)
				if chance <= Config.Loot[v.Type] then
				
					local loot = ents.Create("ent_item")		
					local itemTbl = {}
						
					for key, val in pairs(ITEMS) do
						if val.Rarity == v.Type then
							itemTbl[#itemTbl + 1] = key 
						end
					end
						
					local selectedItem = table.Random(itemTbl)
						
					local loot = ents.Create("ent_item") 
					loot:SetPos(v.Pos)
					loot:SetAngles( Angle(math.random(1, 180), math.random(1, 180), math.random(1, 180)) )
					loot:Spawn()
					loot:Activate()
					loot:SetItem(selectedItem)
					
				end
			end
			
			print("Spawned ".. #ents.FindByClass("ent_item") .. " out of " .. #data["Loot Spawn"] .. " possible spawns.")
		end 
		
		if data["Container"] then
			for k,v in pairs(data["Container"]) do
				local chance = math.random(1, 100)
				local expectedChance = v.SpawnChance || Config.ContainerSpawnChance
				local cType = v.ContainerType || "Household Cabinet"
				
				local cTbl = Config.Containers[cType]
				local reqChance = v.SpawnChance || cTbl.Chance
				
				if reqChance then
					if chance <= reqChance || v.ForceSpawn then
						local invTbl = {}
						local itemTypes = cTbl.ItemTypes
						local slots = v.ForceSlots || Config.ContainerMaxItems
						
						local container = ents.Create("ent_container")
						if v.ObjPos then
							container:SetPos(v.ObjPos)
						else
							container:SetPos(v.Pos)
						end
						
						if v.Ang then
							container:SetAngles(v.Ang)
						end
						
						container:Spawn()
						container:Activate()
						
						if v.Model then
							container:SetModel(v.Model)
						end
						
						for i = 1, slots do
							local iChance = math.random(1, 100)
							local selectedType = table.Random(itemTypes)
							local itemList = {}
							
							for k,v in pairs(ITEMS) do
								if v.Rarity == selectedType then
									table.insert(itemList, k)
								end
							end
							
							
							local selectedItem
							if #itemList > 0 then
							
								selectedItem = table.Random(itemList)
								
								if iChance <= Config.Loot[selectedType] then
									container:GiveItem(selectedItem, 1)
								end
								
							end
							
						end
						
					end
				else
					print("Ignored spawning container #"..k..", invalid container type was set.")
				end
			end
			
			print("Spawned ".. #ents.FindByClass("ent_container") .. " out of " .. #data["Container"] .. " possible spawns.")
		end
		
		print("Configuration file for "..game.GetMap().." successfully loaded!")
	else
		print("Error loading map "..game.GetMap().."! No configuration file was found.")
	end ]]
end