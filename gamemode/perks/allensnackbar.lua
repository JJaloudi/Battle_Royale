local PERK = {}

PERK.ID = 12 // ID of the perk HAS TO BE UNIQUE. 

PERK.Name = "Allen Snackbar" //Name of the perk
PERK.Desc = "When killed, your body detonates 2 seconds after death." //Description of the perk

PERK.Price = 950 //How much does this perk cost to buy from the store? IF you want a perk to be unbuyable then don't put this in your perk.
PERK.Rarity = 25 //How often does this perk appear from rewards?

PERK.Slot = 2 // What slot of perks does it use?

PERK.Icon = Material("perks/allen.png") // Icon for the perk.
PERK.Color = Color(155, 0, 155) // Color of the background.

PERK.Stackable = true //Can you earn this perk more than once? Similiar to Black Ops III Zombie perk system.

PERK.Hook = "PlayerDeath" //What hook does this function tie to?

//The display system might be a bit confusing, so let me break it down.

//To show the player whenever he/she is actually using the perk, you can display it through hooks OR...
//Like with this perk, we can have it ONLY show when it's triggered through our "DoPerk" function.
//Use Player:TriggerPerk(perk ID) to display it on the players screen.

PERK.DoPerk = function(pl)
	local pos = pl:GetPos()
	
	timer.Simple(2, function()
		local boom = ents.Create( "env_explosion" )
		boom:SetPos(pos)
		boom:SetOwner(pl)
		boom:Spawn()
		
		boom:SetKeyValue("iMagnitude", "200")
		boom:Fire("Explode", 0, 0)
	end)
end

RegisterPerk(PERK) 