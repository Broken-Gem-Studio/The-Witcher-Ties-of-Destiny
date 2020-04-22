function GetTableKikimoraScript_v2 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio ()
lua_table.AnimationFunctions = Scripting.Animations ()

-----------------------------------------------------------------------------------------
-- Health Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.health = 3000

-- Health Percentages for each phase
lua_table.health_percentage_phase_1 = 100
lua_table.health_percentage_phase_2 = 75
lua_table.health_percentage_phase_3 = 50
lua_table.health_percentage_phase_4 = 25

local damage_received_real = -1
lua_table.damage_received_mod = 1.0
lua_table.damage_received_orig = -1

-----------------------------------------------------------------------------------------
-- Movement Variables
-----------------------------------------------------------------------------------------

-- Distance of player/s to activate the boss
lua_table.activation_distance = 10

lua_table.position_x = 0
lua_table.position_y = 0
lua_table.position_z = 0

-----------------------------------------------------------------------------------------
-- Phases & States Variables
-----------------------------------------------------------------------------------------

local phase = -- not in use rn
{
	CHILL = 0,      -- phase 1
	HURT = 1, 		-- phase 2
	MAD = 2,      	-- phase 3
	ENRAGED = 3     -- phase 4
}
local current_phase = phase.CHILL -- Should initialize at awake(?)

local state =  
{
    UNACTIVE = 0,

	AWAKENING = 1,
	IDLE = 2,
	ATTACKING = 3,
	MOVING = 4,
	JUMPING = 5,
    TAUNTING = 6,
	STUNNED = 7,
	SCREAMING = 8,
	SWAPPING_PHASE = 9,
	SPAWNING_MINIONS = 10,
}
local current_state = state.UNACTIVE -- Should initialize at awake(?)

-----------------------------------------------------------------------------------------
-- Attacks Variables
-----------------------------------------------------------------------------------------
local attack_type =
{
	NONE = 0,
	LEASH = 1,
	SWEEP = 2,
	STOMP = 3,
}
local current_attack_type = attack_type.NONE

lua_table.leash_cooldown = 4
lua_table.sweep_cooldown = 6
lua_table.stomp_cooldown = 5

lua_table.damage_stomp = 150
lua_table.damage_leash = 120
lua_table.damage_sweep = 100

local attack_effect = --Not definitive, but as showcase
{	
	none = 0,
	stun = 1,
	knockback = 2,
	provoke = 3,
	venom = 4
}
-----------------------------------------------------------------------------------------
-- Animation Variables
-----------------------------------------------------------------------------------------
local animations = {
    idle = { anim_name = "idle", anim_speed = 30, anim_blendtime = 0 },
    walk = { anim_name = "walk", anim_speed = 30, anim_blendtime = 0 },
	leash = { anim_name = "leash", anim_speed = 30, anim_blendtime = 0 },
	sweep = { anim_name = "sweep", anim_speed = 30, anim_blendtime = 0 },
	stomp = { anim_name = "stomp", anim_speed = 30, anim_blendtime = 0 },
	scream = { anim_name = "scream", anim_speed = 30, anim_blendtime = 0 }
}

-----------------------------------------------------------------------------------------
-- Collider Variables
-----------------------------------------------------------------------------------------

local attack_colliders = {
	leash = { GO_name = "Leash_Attack", GO_UID = 0, active = false },
	sweep = { GO_name = "Sweep_Attack", GO_UID = 0, active = false },
	stomp = { GO_name = "Stomp_Attack", GO_UID = 0, active = false },
	scream = { GO_name = "Geralt_Right", GO_UID = 0, active = false }
}

-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}	
lua_table.collider_damage = 0
lua_table.collider_effect = attack_effects.none

-----------------------------------------------------------------------------------------
-- Game Objects Variables
-----------------------------------------------------------------------------------------

-- Kikimora GO UID
lua_table.myUID = 0

-- Kikimora target GO names
lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"
lua_table.yennefer_GO = "Yennefer"
lua_table.ciri_GO = "Ciri"

-- P1
local P1_id = 0
lua_table.P1_pos = {}
lua_table.P1_script = {}
local P1_abs_distance = nil 

-- P2
local P2_id = 0
lua_table.P2_pos = {}
lua_table.P2_script = {}
local P2_abs_distance = nil

lua_table.collider_parent_script = {}

-- I use this for visual pleasure (so I can write lua_table.P1_pos[x] instead of lua_table.P1_pos[1])  )
local x = 1
local y = 2
local z = 3

local timer = 0
local timer2 = 0



-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function DoStompAttack()


end


function HandlePlayerPosition()

	if P1_id ~= 0
	then
		-- Gets position from Player 1 gameobject Id
		lua_table.P1_pos = lua_table.TransformFunctions:GetPosition(P1_id)

		if lua_table.P1_pos[x] == nil or lua_table.P1_pos[y] == nil or lua_table.P1_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 position nil")
		else
			-- Checks player proximity 
			if current_state == state.UNACTIVE
			then
				-- Calculates distance
				P1_abs_distance = math.sqrt((lua_table.P1_pos[x] * lua_table.P1_pos[x]) + (lua_table.P1_pos[z] * lua_table.P1_pos[z]))

				if P1_abs_distance ~= nil and P1_abs_distance <= lua_table.activation_distance
				then
					current_state = state.AWAKENING
					lua_table.SystemFunctions:LOG ("Kikimora: AWAKENED")
				end 
			end
		end
	end

	if P2_id ~= 0
	then
		-- Gets position from Player 2 gameobject Id
		lua_table.P2_pos = lua_table.TransformFunctions:GetPosition(P2_id)

		if lua_table.P2_pos[x] == nil or lua_table.P2_pos[y] == nil or lua_table.P2_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 position nil")
		else
			-- Checks player proximity 
			if current_state == state.UNACTIVE
			then
				--Calculates distance
				P2_abs_distance = math.sqrt((lua_table.P2_pos[x] * lua_table.P2_pos[x]) + (lua_table.P2_pos[z] * lua_table.P2_pos[z]))

				if P2_abs_distance ~= nil and P2_abs_distance <= lua_table.activation_distance
				then
					current_state = state.AWAKENING
					lua_table.SystemFunctions:LOG ("Kikimora: AWAKENED")
				end 
			end
		end
	end
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Kikimora Script on AWAKE")
	
	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()

	---------------------------------------------------------------------------
	-- Player UIDs
	---------------------------------------------------------------------------

	-- Player 1 id
	P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)	-- first checks if Geralt available

	if P1_id ~= 0
	then 
		lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Geralt)")

		-- Player 1 script (only if successfull id)
		lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) --If Geralt available checks for Jaskier as player 2

		if P2_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 2 id, check name of game object inside script")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 id successfully recieved (Jaskier)")

			-- Player 2 script (only if successfull id)
			lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)
		end
	else
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) -- If Geralt not available checks for Jaskier

		if P1_id ~= 0
		then 
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Jaskier)")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 1 id")
		end
	end
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Kikimora Script on START")
	--lua_table.ParticlesFunctions:ActivateParticlesEmission(lua_table.myUID)

	HandlePlayerPosition()

end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()

	HandlePlayerPosition()

end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.myUID)

	local collider_parent_GO
	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)

	if layer == layers.player_attack  --Checks if its player attack collider layer
	then
		collider_parent_GO = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		lua_table.collider_parent_script = lua_table.GameObjectFunctions:GetScript(collider_parent_GO)

		damage_received = lua_table.collider_parent_script.collider_damage

		lua_table.SystemFunctions:LOG ("Kikimora: damage received: ".. damage_received)

		lua_table.health = lua_table.health - damage_received
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
	local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.myUID)
	-- lua_table.SystemFunctions:LOG("T:" .. collider)
end



	return lua_table
end

--Particle Functions
-- ActivateParticlesEmission()
-- DeactivateParticlesEmission()
-- ActivateParticlesEmission_GO()
-- DeactivateParticlesEmission_GO()

-- PlayParticleEmitter()
-- StopParticlEmitter()
-- SetEmissionRate(ms)
-- SetParticlesPerCreation(num)

-- SetExternalAcceleration(x,y,z)
-- SetParticlesVelocity(x,y,z)
-- SetRandomParticlesVelocity(x,y,z)

-- SetParticlesLooping(bool)
-- SetParticlesDuration(ms)
-- SetParticlesLifeTime(ms)

-- function ParticleSmallExplosion()
-- 	lua_table.ParticlesFunctions:SetParticlesLooping(false)

-- 	lua_table.ParticlesFunctions:SetParticlesPerCreation(50)
-- 	lua_table.ParticlesFunctions:SetParticlesLifetime(1000)
-- 	lua_table.ParticlesFunctions:SetEmissionRate(1000)

-- 	lua_table.ParticlesFunctions:PlayParticleEmitter()
-- end

-- function ParticleIdle()
-- 	lua_table.ParticlesFunctions:SetParticlesLooping(true)

-- 	lua_table.ParticlesFunctions:SetEmissionRate(500)
-- 	lua_table.ParticlesFunctions:SetParticlesPerCreation(1)
-- 	lua_table.ParticlesFunctions:SetParticlesLifeTime(2000) 

-- 	lua_table.ParticlesFunctions:SetExternalAcceleration(0, 6, 0)
-- 	lua_table.ParticlesFunctions:SetParticlesVelocity(0, 5, 0)
-- 	lua_table.ParticlesFunctions:SetRandomParticlesVelocity(3, 1.5, 3)

-- 	lua_table.ParticlesFunctions:PlayParticleEmitter()

-- end
-- function HandleHit()
-- 	ParticleSmallExplosion()
-- end
-- function HandleDeath()
-- 	ParticleBigExplosion()
-- end

