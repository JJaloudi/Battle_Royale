GameTypes = {}

function RegisterGametype(tbl)
	table.insert(GameTypes, tbl)
end

function GetGameType(name)
	for k,v in pairs(GameTypes) do
		if v.Name == name then
			return k
		end 
	end
end