function GetTableKikimoraScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.health = 3000

-- Distance of player/s to activate the boss
lua_table.activation_distance = 10

lua_table.health_percentage_phase_1 = 100
lua_table.health_percentage_phase_2 = 66
lua_table.health_percentage_phase_3 = 33

lua_table.position_x = 0
lua_table.position_y = 0
lua_table.position_z = 0

lua_table.damage_stomp = 150
lua_table.damage_leash = 120
lua_table.damage_sweep = 100

-----------------------------------------------------------------------------------------
-- Kiki Variables
-----------------------------------------------------------------------------------------

lua_table.myUID = 0

local damage_received = 0

local combo_1 = false
local combo_2 = false
local combo_3 = false

local phase = -- not in use rn
{
	CHILL = 0,      -- phase 1
	HURT = 1,       -- phase 2
	ENRAGED = 2     -- phase 3
}
local current_phase = phase.CHILL -- Should initialize at awake(?)

local state =  
{
    UNACTIVE = 0,

	AWAKENING = 1,
    COOLDOWN = 2,
    SWEEPING = 3,
    STOMPING = 4,
    LASHING = 5,
    TAUNTING = 6,
	STUNNED = 7,
	SCREAMING = 8,
	SWAPPING_PHASE = 9
}
local current_state = state.UNACTIVE -- Should initialize at awake(?)

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

-- I use this for visual pleasure (so I can write lua_table.P1_pos[x] instead of lua_table.P1_pos[1])  )
local x = 1
local y = 2
local z = 3

local timer = 0
local timer2 = 0



-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

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

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) --If Geralt available checks for Jaskier as player 2

		if P2_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 2 id, check name of game object inside script")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 id successfully recieved (Jaskier)")

			-- Player 1 script (only if successfull id)
			lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

			if P1_script == nil
			then
				lua_table.SystemFunctions:LOG ("Camera: Null Player 1 script")
			else
				lua_table.SystemFunctions:LOG ("Camera: Player 1 script successfully recieved")
			end
		end
	else
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) -- If Geralt not available checks for Jaskier

		if P1_id ~= 0
		then 
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Jaskier)")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 1 id")
			
			-- Player 2 script (only if successfull id)
			lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)

			if P2_script == nil
			then
				lua_table.SystemFunctions:LOG ("Camera: Null Player 2 script")
			else
				lua_table.SystemFunctions:LOG ("Camera: Player 2 script successfully recieved")
			end
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
	if lua_table.GameObjectFunctions:GetGameObjectParent(collider) == lua_table.P1_id
	then
		lua_table.SystemFunctions:LOG("Hit by Player 1")
		-- damage_received = lua_table.P1_script.collider_damage

	elseif lua_table.GameObjectFunctions:GetGameObjectParent(collider) == lua_table.P2_id
	then
		lua_table.SystemFunctions:LOG("Hit by Player 2")

	else
		lua_table.SystemFunctions:LOG("T:" .. collider)
	end

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 2  --Checks if its player attack collider layer
	then
		--local parent_UID = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		--local parent_script = lua_table.GameObjectFunctions:GetScript(parent_UID)
		--local damage = parent_script.collider_damage

		-- lua_table.Health = lua_table.Health - damage
		lua_table.SystemFunctions:LOG("Kikimora: HIT")
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
	local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.myUID)
	lua_table.SystemFunctions:LOG("T:" .. collider)
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

