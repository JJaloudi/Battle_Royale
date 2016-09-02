PERKS = {}

function GetPerk(id)
	local perk = false
	
	for k,v in pairs(PERKS) do
		if v.ID == id then
			perk = k
			
			break
		end
	end
	 
	return PERKS[perk] || perk
end

function RegisterPerk(tbl)


	PERKS[tbl.ID] = tbl
	
	if SERVER then
		if tbl.Hook then
			hook.Add(tbl.Hook, tbl.Name, function(pl, ...)
			
				local arg = {pl, ...}
				
				local bReturn
			
				if pl:HasActivePerk(tbl.ID) then	
					bReturn = tbl.DoPerk(pl, ...)
					
					if !tbl.DisableAutoToggle then
						pl:TogglePerk(tbl.ID)
					end
				end
				
				if bReturn != nil then
					return bReturn
				end
				
			end)
		end
		
		print("Registered perk " .. tbl.Name .. ", ID: "..tbl.ID)
	end
end