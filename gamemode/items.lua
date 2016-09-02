//You don't modify item tables here! This is for developers only!

//Enumerations for consumable types
CONSUME_BANDAGE = "Bandage"
CONSUME_BROKEN = "Splint"
CONSUME_HUNGER = "Hunger"
CONSUME_BUFF = "Buff"
CONSUME_MEDICAL = "Medical"

CONSUME_TYPES = {
	["Bandage"] = {
		Medical = true,
		OnUse = function(pl, it_id, slot, bone)
			local bUse = false
		
			local invRef = pl.Inventory[slot]
			local itemRef = GetItemByKey(it_id)
			local boneRef
			
			if bone then
			
				boneRef = pl.Limbs[bone]
				
			else
			
				for k,v in pairs(pl.Limbs) do
					if v["Bleeding"] then
						boneRef = pl.Limbs[k]
						bone = k
						
						break
					end
				end
				
			end
			
			if boneRef then
				if boneRef["Bleeding"] then
					pl:SetLimbBuff(bone, "Bleeding", false)
					pl:Notify(NOTIFY_WARNING, "Stopped Bleeding", "Your "..string.lower(bone).." is no longer bleeding.", Color(25, 195, 25, 255), color_white, 5)
					
					bUse = true
				end
			end
			
			return bUse
		end
	},
	["Splint"] = {
		Medical = true,
		OnUse = function(pl, it_id, slot, bone)
			local bUse = false
		
			local invRef = pl.Inventory[slot]
			local itemRef = GetItemByKey(it_id)
			local boneRef
			
			if bone then
			
				boneRef = pl.Limbs[bone]
				
			else
			
				for k,v in pairs(pl.Limbs) do
					if v["Broken"] then
						boneRef = pl.Limbs[k]
						bone = k
						
						break
					end
				end
				
			end
			
			if boneRef then
				if boneRef["Broken"] then
					pl:SetLimbBuff(bone, "Broken", false)
					pl:Notify(NOTIFY_WARNING, "Healed Bone", "Your "..string.lower(bone).." is no longer impairing you.", Color(25, 195, 25, 255), color_white, 5)
					
					if !pl:IsImpaired() then
						pl:SetRunSpeed(Config.DefaultRunSpeed)
						pl:SetWalkSpeed(Config.DefaultWalkSpeed)
					end
					
					bUse = true
				end
			end
			
			return bUse
		end
	},
	["Hunger"] = {
		HotbarUse = true,
		OnUse = function(pl, id, slot, bone)
		
			pl:EmitSound("npc/barnacle/barnacle_crunch2.wav")
			hook.Call("PlayerEat", GAMEMODE, pl, id)
			
			return true
		end
	},
	["Buff"] = {
	
	},
	["Medical"] = {
		Medical = true,
		HotbarUse = true, 
		OnUse = function(pl, id, slot, bone)
			local bUse = false
		
			local invRef = pl.Inventory[slot]
			local itemRef = GetItemByKey(it_id)
			local boneRef = false
			
			if bone then
			
				boneRef = pl.Limbs[bone]
				
			else
			
				for k,v in pairs(pl.Limbs) do
					if v["Bleeding"] || v["Broken"] then
						boneRef = pl.Limbs[k]
						bone = k
						
						break
					end
				end
				
			end
			
			if boneRef then
				if boneRef["Bleeding"] then
					pl:SetLimbBuff(bone, "Bleeding", false)
					pl:Notify(NOTIFY_WARNING, "Stopped Bleeding", "Your "..string.lower(bone).." is no longer bleeding.", Color(25, 195, 25, 255), color_white, 5)
					
					bUse = true
				end
				
				if boneRef["Broken"] then
					pl:SetLimbBuff(bone, "Broken", false)
					pl:Notify(NOTIFY_WARNING, "Healed Bone", "Your "..string.lower(bone).." is no longer impairing you.", Color(25, 195, 25, 255), color_white, 5)
					
					if !pl:IsImpaired() then
						pl:SetRunSpeed(Config.DefaultRunSpeed)
						pl:SetWalkSpeed(Config.DefaultWalkSpeed)
					end
					
					bUse = true
				end
			end
			
			return bUse
		end
	}
}

Items = {
	_Items = {}
}

function Items:Register(tbl)
	if tbl.ID then
		self._Items[tbl.ID] = tbl
	
		print("[Item System] Created item " .. tbl.Name .. ". [ID: ".. tbl.ID .. "]")
	else
		error("Error creating item.  No idea was specified.")
	end
end

function Items:GetTable()
	return self._Items || {}
end

function Items:GetItem(item)
	local it = nil
	
	for k,v in pairs(self._Items) do
		if v.Name == item then
			it = k
			
			break
		end
	end
	
	return it
end

function Items:GetItemByKey(key)
	return self._Items[key] || false
end