function GetTableKikimoraScript_v0 ()
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

    COOLDOWN = 1,
    SWEEPING = 2,
    STOMPING = 3,
    LASHING = 4,
    TAUNTING = 5,
    STUNNED = 6
}
local current_state = state.UNACTIVE -- Should initialize at awake(?)

-- P1
local P1_id = 0
lua_table.P1_pos = {}

-- P2
local P2_id = 0
lua_table.P2_pos = {}

local timer = 0
local timer2 = 0



-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")
	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")
	--lua_table.ParticlesFunctions:ActivateParticlesEmission(lua_table.myUID)
end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()

end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.myUID)
	lua_table.SystemFunctions:LOG("T:" .. collider)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 2 or layer == 4 --Checks if its player/enemy attack collider layer
	then

		-- local parent_UID = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		-- local parent_script = lua_table.GameObjectFunctions:GetScript(parent_UID)
		-- local damage = parent_script.collider_damage

        -- lua_table.Health = lua_table.Health - damage
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
	local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.UID)
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

