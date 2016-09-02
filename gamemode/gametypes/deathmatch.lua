GameType = {}

GameType.Name = "Deathmatch" // Make sure that there aren't any gamemodes with the same name!
GameType.Description = "Classic Battle Royale. Fight to the last man standing." // What will the players see as a description for the gametype they're voting for?

GameType.HungerEnabled = true // Should hunger be enabled by default?
GameType.BuffsEnabled = true // Should buffs be enabled by default?

GameType.Teams = false

GameType.GasEnabled = true// Enable poisionous gas?
GameType.GasPace = 1// How quickly does the gas close in on the players?

GameType.TimedRounds = false  // Should the rounds be timed?

GameType.RunSpeed = 350
GameType.WalkSpeed = 200




if SERVER then // Only developers should touch this section.

	function GameType.OnPlayerKilled(victim, weapon, killer)
		BattleRoyale:EliminatePlayer(victim)
	
		if victim != killer then
			killer:AddMoney(50)
		end
	
		if BattleRoyale:GetRemainingPlayers() <= 3 then
		
			BattleRoyale:SetPlayerPlacement(victim, BattleRoyale:GetRemainingPlayers() - 1)
			
			if BattleRoyale:GetRemainingPlayers() <= 1 then
				if victim != killer then
					BattleRoyale:SetPlayerPlacement(killer, 1)
				else
				
					for k,v in pairs(player.GetAll()) do
						if BattleRoyale:IsPlayerActive(v) then
							BattleRoyale:SetPlayerPlacement(v, 1)
							
							break
						end
					end
					
					BattleRoyale:SetPlayerPlacement(killer, 2)
				end
				
				BattleRoyale:EndGame(killer)
			end
		end
		
	end
	
end





RegisterGametype(GameType)//Register the gametype by using RegisterGametype(in here put the name of the table, in this instance, GameType.)