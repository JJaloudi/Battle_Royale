local APPAREL = {}

APPAREL.Price = 10
APPAREL.ID = 1
APPAREL.Name = "Bucket Helmet"
APPAREL.Rarity = 75

APPAREL.Description = "The most basic form of armor... Jesus Christ, I don't want to wear this."
APPAREL.Category = "Hats"
APPAREL.Model = "models/props_junk/MetalBucket01a.mdl"

APPAREL.ApparelData = {
	vecOffset = Vector(0,1,-5),
	angOffset = Vector(0,-90,90),
	Scale = 0.75
}

RegisterApparel(APPAREL)