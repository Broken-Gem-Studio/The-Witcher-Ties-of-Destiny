function GetTableLUM_REDO_V1()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.AnimationSystem = Scripting.Animations()
lua_table.SoundSystem = Scripting.Audio()
lua_table.ParticleSystem = Scripting.Particles()
lua_table.NavSystem = Scripting.Navigation()



--########################################### UTILITY VARIABLES ###########################################


local attack_colliders = {
	jump_attack = { GO_name = "Lumberjack_JA", GO_UID = 0 , active = false},
	front1 = { GO_name = "Lumberjack_FA1", GO_UID = 0 , active = false},
	front2 = { GO_name = "Lumberjack_FA2", GO_UID = 0 , active = false}
}

local particles = {
	alertParticles = { GO_name = "alert_scream_particles_lumberjack", GO_UID = 0 , active = false},
	GroundHitParticles1 = { GO_name = "ground_hit_particles_lumberjack1", GO_UID = 0 , active = false},--smoke
	GroundHitParticles2 = { GO_name = "ground_hit_particles_lumberjack2", GO_UID = 0 , active = false},-- ground crack
	stuntParticles = { GO_name = "stunt_particles_lumberjack", GO_UID = 0 , active = false},
	hitParticles = { GO_name = "hit_particles_lumberjack", GO_UID = 0 , active = false}
}

--Colliders
	local layers = {
		default = 0,
		player = 1,
		player_attack = 2,
		enemy = 3,
		enemy_attack = 4
	}
	local attack_effects = {	
		none = 0,
		stun = 1,
		knockback = 2,
		taunt = 3,
		venom = 4
	}

--################################################ VARIABLES ############################################

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"



--#################################################### MAIN CODE #########################################

function lua_table:Awake()

---GET PLAYERS ID---
	Geralt = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
    Jaskier = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2) 

	if Geralt == 0 then lua_table.SystemFunctions:LOG ("LUMBERJACK A random Lumberjack Script: Null Geralt id, called from Lumberjack AWAKE")
	end
    if Jaskier == 0 then lua_table.SystemFunctions:LOG ("LUMBERJACK A random Lumberjack Script: Null Jaskier id, called from Lumberjack AWAKE")
    end

	MyUID = lua_table.GameObjectFunctions:GetMyUID()
	if MyUID == 0 then lua_table.SystemFunctions:LOG ("A random Lumberjack Script: Null id for the GameObject that contains the Lumberjack Script, called from Lumberjack AWAKE")
	end

end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end