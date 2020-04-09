function GetTablePropScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.health = 200

-----------------------------------------------------------------------------------------
-- Prop Variables
-----------------------------------------------------------------------------------------

lua_table.myUID = 0

--local collided_attack = false

-- Prop position
local prop_position_x = 0
local prop_position_y = 0 
local prop_position_z = 0

local state = -- not in use rn
{
	DESTROYED = 0,
	FULL = 1,
	HURT = 2
}
local current_state = state.FULL -- Should initialize at awake(?)

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- SetParticlesScale(x,y)
-- SetRandomParticlesScale(num)
-- function ParticleSmallExplosion()
-- 	lua_table.ParticlesFunctions:SetParticlesLooping(false)

-- 	lua_table.ParticlesFunctions:SetParticlesPerCreation(50)
-- 	lua_table.ParticlesFunctions:SetParticlesLifetime(1000)
-- 	lua_table.ParticlesFunctions:SetEmissionRate(1000)

-- 	lua_table.ParticlesFunctions:PlayParticleEmitter()
-- end
function ParticleBigExplosion()
	lua_table.ParticlesFunctions:SetParticlesLooping(false)
	lua_table.ParticlesFunctions:SetParticlesDuration(800)

	lua_table.ParticlesFunctions:SetEmissionRate(50)
	lua_table.ParticlesFunctions:SetParticlesPerCreation(50)
	lua_table.ParticlesFunctions:SetParticlesLifeTime(1000)

	lua_table.ParticlesFunctions:SetExternalAcceleration(0, 10, 0)
	lua_table.ParticlesFunctions:SetParticlesVelocity(0, 30, 0)
	lua_table.ParticlesFunctions:SetRandomParticlesVelocity(50,50,50)
	
	lua_table.ParticlesFunctions:SetParticlesScale(1, 1)
	lua_table.ParticlesFunctions:SetRandomParticlesScale(15, 15)

	lua_table.ParticlesFunctions:PlayParticleEmitter()
end
function ParticleIdle()
	lua_table.ParticlesFunctions:SetParticlesLooping(true)

	lua_table.ParticlesFunctions:SetEmissionRate(500)
	lua_table.ParticlesFunctions:SetParticlesPerCreation(1)
	lua_table.ParticlesFunctions:SetParticlesLifeTime(2000) 

	lua_table.ParticlesFunctions:SetExternalAcceleration(0, 6, 0)
	lua_table.ParticlesFunctions:SetParticlesVelocity(0, 5, 0)
	lua_table.ParticlesFunctions:SetRandomParticlesVelocity(2.5, 1.5, 2.5)

	lua_table.ParticlesFunctions:PlayParticleEmitter()

end
-- function HandleHit()
-- 	ParticleSmallExplosion()
-- end
-- function HandleDeath()
-- 	ParticleBigExplosion()
-- end


-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")
	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")
	-- set particles parameters
	lua_table.ParticlesFunctions:ActivateParticlesEmission()

	-- ParticleIdle()
	ParticleBigExplosion()
	-- lua_table.ParticlesFunctions:StopParticleEmitter()
end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()
	-- do something over time?
	-- check players proximity to start doing something when close
	-- item generator?	
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.UID)
	lua_table.SystemFunctions:LOG("T:" .. collider)

	local layer = lua_table.GameObjectFunctions:GetGameObjectLayer(collider)
	if layer == 2 or layer == 4 --Checks if its player/enemy attack collider layer
	then

		local parent_UID = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		local parent_script = lua_table.GameObjectFunctions:GetScript(parent_UID)
		local damage = parent_script.collider_damage

		lua_table.Health = lua_table.Health - damage

		if lua_table.Health > 0
		then 
			-- HandleHit()
		elseif luatable.Health <= 0
		then
			-- HandleDeath()
			ParticleBigExplosion()
		end
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

