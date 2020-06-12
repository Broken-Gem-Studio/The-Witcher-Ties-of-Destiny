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
lua_table.Player = 0

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
local barrel_particles = 0
local barrel_particles_parent = 0
local script_player = 0
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
	if lua_table.health <= 0 and current_state == state.NORMAL
	then
		Destroyable = lua_table.GameObjectFunctions:FindChildGameObjectFromGO("Destructed",lua_table.parent)
		local script = lua_table.GameObjectFunctions:GetScript(Destroyable)
		script.player_owner = lua_table.Player
		lua_table.GameObjectFunctions:SetActiveGameObject(true,Destroyable)
		
		if lua_table.Player ~= 0 then
			script_player = lua_table.GameObjectFunctions:GetScript(lua_table.Player)
		end
		
		local geralt = lua_table.GameObjectFunctions:FindGameObject("Geralt")
		local jaskier = lua_table.GameObjectFunctions:FindGameObject("Jaskier")

		if jaskier == lua_table.player_owner and jaskier_score ~= nil then
			jaskier_score[5] = jaskier_score[5] + 1
		elseif geralt == lua_table.player_owner and geralt_score ~= nil then
			geralt_score[5] = geralt_score[5] + 1
		end

		playParticles()
		current_state = state.DESTROYED
		lua_table.GameObjectFunctions:SetActiveGameObject(false,lua_table.myUID)
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
			if layer == 2 and lua_table.Player == 0
			then
				lua_table.Player = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
			end
			
			lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_wood_break",lua_table.myUID)
		end
	end
end


	return lua_table
end