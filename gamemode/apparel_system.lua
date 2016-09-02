APPAREL_TYPES = {}

APPAREL_TYPES["Hats"] = "ValveBiped.Bip01_Head1"
APPAREL_TYPES["Glasses"] = "ValveBiped.Bip01_Head1"
APPAREL_TYPES["Facial Hair"] = "ValveBiped.Bip01_Head1"
APPAREL_TYPES["Backpacks"] = "ValveBiped.Bip01_Spine"

APPAREL = {}
function RegisterApparel(tbl)
	print("Apparel item "..tbl.Name.." registered.")
	
	APPAREL[tbl.ID] = tbl
end

MODELS = {}

MODEL_CATEGORIES = {
	"Civilian", "Combine", "SWAT", "VIP"
}

function RegisterModel(tbl)
	print("Model "..tbl.Name.." registered.")
	
	MODELS[tbl.ID] = tbl
end

function GetApparel(id)
	return APPAREL[id] or false
end

function GetModel(id)
	return MODELS[id] || false
end
