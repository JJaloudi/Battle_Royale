Config = {}

Config.DefaultGameType = "Deathmatch"

Config.DefaultRunSpeed = 275
Config.DefaultWalkSpeed = 150

Config.StaminaEnabled = true
Config.MaxStamina = 100
Config.StaminaDrainRate = 1

Config.BleedRate = 4
Config.BleedDamage = 1

Config.HurtSoundList = {
	["Female"] = {
		"vo/npc/female01/pain03.wav", 
		"play vo/npc/female01/pain02.wav",
		"vo/npc/female01/pain07.wav",
		"vo/npc/female01/pain08.wav",
		"vo/npc/female01/pain09.wav"
	},
	["Male"] = {
		"vo/npc/male01/pain01.wav",
		"vo/npc/male01/pain03.wav",
		"vo/npc/male01/pain04.wav",
		"vo/npc/male01/pain09.wav"
	}
}

Config.LimbSystem = true
Config.BrokenLegSpeed = 150

Config.DefaultSlots = 3

Config.DefaultMaxWeight = 50

Config.ContainerSpawnChance = 70
Config.ContainerMaxItems = 6
Config.Loot = { // Chance in PERCENT(%) that an item of this level will spawn.
	["Household Food"] = 80,
	["Household Medical"] = 70,
	["Household Weapon"] = 40,
	["Household Melee"] = 60,
	["Household Ammo"] = 50,
	["Hospital Medical"] = 50,
	["Military Medical"] = 30,
	["Military Food"] = 20,
	["Police Weapon"] = 30,
	["Police Melee"] = 40,
	["Military Weapon"] = 10,
	["Military Melee"] = 20,
	["Military Explosive"] = 5,
	["Military Ammo"] = 9
}

Config.Containers = {
	["Weapon Crate"] = {
		Chance = 35,
		
		ItemTypes = {
			"Military Weapon",
			"Military Melee",
			"Military Medical"
		}
	},
	["Military Explosives"] = {
		Chance = 25,
		
		ItemTypes = {
			"Military Explosive"
		}
	},
	["Household Gun"] = {
		Chance = 50,
		
		ItemTypes = {
			"Household Weapon",
			"Household Melee",
			"Household Ammo"
		}
	},
	["Household Fridge"] = {
		Chance = 80,
		
		ItemTypes = {
			"Household Food",
			"Household Medical"
		}
	},
	["Household Cabinet"] = {
		Chance = 80,
		
		ItemTypes = {
			"Household Medical",
			"Household Food"
		}
	},
	["Police Crate"] = {
		Chance = 40,
		
		ItemTypes = {
			"Police Weapon",
			"Police Melee",
			"Hospital Medical"
		}
	},
	["Hospital Supplies"] = {
		Chance = 60,
		
		ItemTypes = {
			"Hospital Medical",
			"Police Melee"
		}
	}
}

Config.MessageTime = 30 // How many seconds does it take for a message to appear.
Config.ServerMessages = { 
	"Welcome to Battle Royale! Enjoy your stay.",
	"Happy killing, everyone!",
	"You're playing Battle Royale, created by Jayzor!"
}

//Add items like so:
//[Item ID] = Amount of Item,
Config.StartingItems = {

}
