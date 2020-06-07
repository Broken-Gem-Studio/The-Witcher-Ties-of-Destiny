function GetTableProp_Script()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.Scene = Scripting.Scenes()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.health = 2

-----------------------------------------------------------------------------------------
-- Prop Variables
-----------------------------------------------------------------------------------------

lua_table.myUID = 0
local Destroyable = 0
lua_table.parent = 0
local Player = 0

-- Prop position

local state = -- not in use rn
{
	NORMAL = 0,
	INSTANCE = 1,
	DESTROYED = 2
}
local current_state = state.NORMAL
local propID = 0
local type = -- not in use rn
{
	BARREL = 0,
	BOX = 1
}
lua_table.current_type = type.BOX

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------
local barrel_particles
local barrel_particles_parent

-- Main Code
function lua_table:Awake ()
	-- Get my own UID
end

function lua_table:Start ()
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
	lua_table.parent = lua_table.GameObjectFunctions:GetGameObjectParent(lua_table.myUID)
	barrel_particles_parent = lua_table.GameObjectFunctions:FindChildGameObjectFromGO("Barrel_Particles", lua_table.parent)
	barrel_particles = lua_table.GameObjectFunctions:GetGOChilds(barrel_particles_parent)
end

local function playParticles()
	for i = 1, #barrel_particles do
		lua_table.ParticlesFunctions:PlayParticleEmitter(barrel_particles[i])
	end
end

function lua_table:Update ()
	local position = lua_table.TransformFunctions:GetPosition(lua_table.myUID)
	local rotation = lua_table.TransformFunctions:GetRotation(lua_table.myUID)
	if lua_table.health <= 0 and current_state == state.NORMAL
	then
		lua_table.GameObjectFunctions:SetActiveGameObject(false,lua_table.myUID)
		Destroyable = lua_table.GameObjectFunctions:FindChildGameObjectFromGO("Destructed",lua_table.parent)
		lua_table.GameObjectFunctions:SetActiveGameObject(true,Destroyable)
		playParticles()
		current_state = state.DESTROYED
	end
end

function lua_table:RequestedTrigger(collider)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 1 --Checks if its player/enemy attack collider layer
	then
		playParticles()
		lua_table.health = lua_table.health - 1
		if lua_table.health > 0
		then
			lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_hit_wood",lua_table.myUID)
		elseif lua_table.health == 0
		then			
			lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_wood_break",lua_table.myUID)
		end
	end
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.myUID)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 2 or layer == 4 --Checks if its player/enemy attack collider layer
	then
		playParticles()
		lua_table.health = lua_table.health - 1
		if lua_table.health > 0
		then
			lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_hit_wood",lua_table.myUID)
		elseif lua_table.health == 0
		then
			if layer == 2 and Player == 0
			then
				Player = collider
			end
			
			lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_wood_break",lua_table.myUID)
		end
	end
end


	return lua_table
end