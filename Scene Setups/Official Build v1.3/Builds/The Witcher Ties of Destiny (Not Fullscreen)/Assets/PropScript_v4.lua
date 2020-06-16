function GetTablePropScript_v4 ()
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
lua_table.health = 3

lua_table.particles_duration = 1000

-----------------------------------------------------------------------------------------
-- Prop Variables
-----------------------------------------------------------------------------------------

lua_table.myUID = 0
lua_table.parentUID = 0

local timer = 0
local timer2 = 0

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

local function ParticleBigExplosion(particleduration, pUID)
	lua_table.ParticlesFunctions:SetParticlesLooping(false, pUID)
	lua_table.ParticlesFunctions:SetParticlesDuration(particleduration, pUID)

	lua_table.ParticlesFunctions:SetEmissionRate(10, pUID)
	lua_table.ParticlesFunctions:SetParticlesPerCreation(300, pUID)
	lua_table.ParticlesFunctions:SetParticlesLifeTime(2000, pUID)

	lua_table.ParticlesFunctions:SetExternalAcceleration(0, 10, 0, pUID)
	lua_table.ParticlesFunctions:SetParticlesVelocity(0, 30, 0, pUID)
	lua_table.ParticlesFunctions:SetRandomParticlesVelocity(50,50,50, pUID)
	
	lua_table.ParticlesFunctions:SetParticlesScale(1, 1, pUID)
	lua_table.ParticlesFunctions:SetRandomParticlesScale(15, pUID)

	lua_table.ParticlesFunctions:PlayParticleEmitter(pUID)
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")
	
	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
	lua_table.parentUID = lua_table.GameObjectFunctions:GetGameObjectParent(lua_table.myUID)
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")
	-- set particles parameters
	lua_table.ParticlesFunctions:ActivateParticlesEmission(lua_table.parentUID)

	-- ParticleIdle()
	-- ParticleBigExplosion()
	-- lua_table.ParticlesFunctions:StopParticleEmitter()

	lua_table.TransformFunctions:RotateObject(-90, 0, 0, lua_table.myUID)
end

function lua_table:Update ()
	dt = lua_table.SystemFunctions:DT ()

	timer2 = lua_table.SystemFunctions:GameTime()
	-- lua_table.SystemFunctions:LOG("Time: " .. timer2 .. "Saved Time: " .. timer)

	if lua_table.health <= 0 and current_state == state.DESTROYED
	then
		-- HandleDeath()
		if timer + lua_table.particles_duration/1000 <= timer2
		then
			lua_table.SystemFunctions:LOG("Prop: SHOULD DISAPPEAR")
			lua_table.GameObjectFunctions:SetActiveGameObject(false, lua_table.myUID)
			-- lua_table.GameObject:DestroyGameObject(lua_table.myUID)
			-- lua_table.TransformFunctions:SetPosition(-696969,-696969,-696969) --YEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEET
		end
	end
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

		lua_table.health = lua_table.health - 1

		if lua_table.health > 0
		then 
			-- HandleHit()
		elseif lua_table.health <= 0
		then
			-- HandleDeath()
			--lua_table.GameObject:DestroyGameObject(lua_table.myUID)
			if current_state == state.FULL
			then
				timer = lua_table.SystemFunctions:GameTime()
				--  lua_table.SystemFunctions:LOG("BOOM TIME: " .. timer)
				ParticleBigExplosion(lua_table.particles_duration, lua_table.parentUID)
				-- lua_table.AudioFunctions:PlayBrakePropSound()
				current_state = state.DESTROYED
			end
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

