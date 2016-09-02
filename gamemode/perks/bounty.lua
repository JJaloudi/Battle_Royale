local PERK = {}

PERK.ID = 13 // ID of the perk HAS TO BE UNIQUE. 

PERK.Name = "Bounty Hunter" //Name of the perk
PERK.Desc = "Receive an extra 25 credits when killing another player." //Description of the perk

PERK.Price = 500 //How much does this perk cost to buy from the store? IF you want a perk to be unbuyable then don't put this in your perk.
PERK.Rarity = 15 //How often does this perk appear from rewards?

PERK.Slot = 3 // What slot of perks does it use?

PERK.Icon = Material("perks/bounty.png") // Icon for the perk.
PERK.Color = Color(125,55,55) // Color of the background.

PERK.Stackable = true //Can you earn this perk more than once? Similiar to Black Ops III Zombie perk system.

PERK.Hook = "PlayerDeath" //What hook does this function tie to?
PERK.DisableAutoToggle = true

//The display system might be a bit confusing, so let me break it down.

//To show the player whenever he/she is actually using the perk, you can display it through hooks OR...
//Like with this perk, we can have it ONLY show when it's triggered through our "DoPerk" function.

PERK.DoPerk = function(victim, killer)
	if victim != killer then
		killer:AddMoney(25)
	
		killer:TogglePerk(13)
	end
end

RegisterPerk(PERK)  