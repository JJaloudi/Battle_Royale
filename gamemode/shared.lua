BUFFS = {}

GM.Name = "Battle Royale"
GM.Author = "Jayzor"

Limbs = {
	["Head"] = {
		Hitgroup = {HITGROUP_HEAD},
		Scale = 2,
		["Bleeding"] = {
			x = -199,
			y = 17.5
		}
	},
	["Left Arm"] = {
		Hitgroup = {HITGROUP_LEFTARM},
		Scale = 0.5, 
		["Bleeding"] = {
			x = -260,
			y = 60
		}
	},
	["Right Arm"] = {
		Hitgroup = {HITGROUP_RIGHTARM},
		Scale = 0.5,
		["Bleeding"] = {
			x = -140,
			y = 60
		}
	},
	["Torso"] = {
		Hitgroup = {HITGROUP_CHEST, HITGROUP_STOMACH},
		Scale = 1.5,
		["Bleeding"] = {
			x = -199,
			y = 75
		}
	},
	["Left Leg"] = {
		Hitgroup = {HITGROUP_LEFTLEG},
		Scale = 0.75,
		["Bleeding"] = {
			x = -222, 
			y = 125
		},
		["Broken"] = {
			x = -222,
			y = 150
		}
	},
	["Right Leg"] = {
		Hitgroup = {HITGROUP_RIGHTLEG},
		Scale = 0.75,
		["Bleeding"] = {
			x = -176.5,
			y = 125
		},
		["Broken"] = {
			x = -176.5,
			y = 150
		}
	}
}

NOTIFY_WARNING = 1
NOTIFY_INJURY = 2
NOTIFY_BLEEDING = 3
NOTIFY_KILLED = 4
NOTIFY_PICKEDUP = 5

local P = FindMetaTable("Player")

function P:IsSprinting()
	if self:KeyDown(IN_SPEED) && self:GetVelocity():Length() >= 200 then
		return true
	else
		return false
	end 
end