local item = {}

item.ID = 1
item.Name = "MR96"
item.Desc = "A double-action revolver. Fires .357 rounds."
item.Icon = Material("icons/revolver.png")
item.Type = "Firearm"

item.Entity = "cw_mr96"

item.Weight = 6

item.Rarity = {
	["red"] = 80,
	["blue"] = 70,
	["green"] = 35
}

Items:Register(item)