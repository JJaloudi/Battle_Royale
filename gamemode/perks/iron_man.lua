local PERK = {}

PERK.ID = 1 // ID of the perk HAS TO BE UNIQUE. 

PERK.Name = "Iron Man" //Name of the perk
PERK.Desc = "Spawn with a random amount of armor from 15-30% on spawn." //Description of the perk

PERK.Price = 250 //How much does this perk cost to buy from the store? IF you want a perk to be unbuyable then don't put this in your perk.
PERK.Rarity = 45 //How often does this perk appear from rewards?

PERK.Slot = 1 // What slot of perks does it use?

PERK.Icon = Material("perks/shield.png") // Icon for the perk.
PERK.Color = Color(55,55,155) // Color of the background.

PERK.Stackable = true //Can you earn this perk more than once? Similiar to Black Ops III Zombie perk system.

PERK.Hook = "RoundStart" //What hook does this function tie to?

PERK.DisplayHook = "PlayerTakeDamage" //What hook would you like to tie the display of the emblem to?

//The display system might be a bit confusing, so let me break it down.

//To show the player whenever he/she is actually using the perk, you can display it through hooks OR...
//Like with this perk, we can have it ONLY show when it's triggered through our "DoPerk" function.
//Use Player:TriggerPerk(perk ID) to display it on the players screen.

PERK.DoPerk = function(pl, gametype)
	pl:SetArmor(math.random(15, 30))
end

RegisterPerk(PERK)