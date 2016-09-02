local APPAREL = {}

APPAREL.Price = 1500
APPAREL.ID = 3
APPAREL.Name = "Full Beard"
APPAREL.Rarity = 25

APPAREL.Description = "A fully grown beard."
APPAREL.Category = "Facial Hair"
APPAREL.Model = "models/fallout/player/beards/beardfull.mdl"

APPAREL.ApparelData = {
	vecOffset = Vector(0, -2.62, -0.1),
	angOffset = Vector(-90, 90, 1),
	Scale = 0.785,
	Col = Color(255, 0, 0, 255)
}

RegisterApparel(APPAREL)