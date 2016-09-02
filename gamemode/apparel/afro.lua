local APPAREL = {}

APPAREL.Price = 10
APPAREL.ID = 5
APPAREL.Name = "Bomberman"
APPAREL.Rarity = 75

APPAREL.Description = "Kaboom"
APPAREL.Category = "Hats"
APPAREL.Model = "models/Combine_Helicopter/helicopter_bomb01.mdl"

APPAREL.ApparelData = {
	vecOffset = Vector(0,1,-5),
	angOffset = Vector(0,-90,90),
	Scale = 0.6
}

RegisterApparel(APPAREL)