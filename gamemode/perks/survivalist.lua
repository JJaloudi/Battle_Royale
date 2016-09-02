local PERK = {}

PERK.ID = 9 // ID of the perk HAS TO BE UNIQUE. 

PERK.Name = "Survivalist" //Name of the perk
PERK.Desc = "Instead of dying when starving, you drain stamina, making you incapable of sprinting." //Description of the perk

PERK.Price = 250 //How much does this perk cost to buy from the store? IF you want a perk to be unbuyable then don't put this in your perk.
PERK.Rarity = 25 //How often does this perk appear from rewards?

PERK.Slot = 3 // What slot of perks does it use?

PERK.Icon = Material("perks/survivalist.png") // Icon for the perk.
PERK.Color = Color(95,155,55) // Color of the background.

PERK.Stackable = true //Can you earn this perk more than once? Similiar to Black Ops III Zombie perk system.

PERK.Hook = "PlayerShouldStarve" //What hook does this function tie to?

//The display system might be a bit confusing, so let me break it down.

//To show the player whenever he/she is actually using the perk, you can display it through hooks OR...
//Like with this perk, we can have it ONLY show when it's triggered through our "DoPerk" function.
//Use Player:TriggerPerk(perk ID) to display it on the players screen.

PERK.DoPerk = function(pl, gametype)
	return true
end

RegisterPerk(PERK) 