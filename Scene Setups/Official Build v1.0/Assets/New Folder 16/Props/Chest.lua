function GetTableChest()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.Scenes = Scripting.Scenes()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.health = 2

-----------------------------------------------------------------------------------------
-- Prop Variables
-----------------------------------------------------------------------------------------

lua_table.myUID = 0
lua_table.player_owner = 0

lua_table.health_potion = 0
lua_table.stamina_potion = 0
lua_table.power_potion = 0

-- Prop position
local state = -- not in use rn
{
	NORMAL = 0,
	OPENING = 1,
	OPENED = 2
}
local current_state = state.NORMAL

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------
local barrel_particles = 0
local barrel_particles_parent = 0
local Sparkle = 0
local timer = 0

-- Main Code
function lua_table:Awake ()
	-- Get my own UID
end

function lua_table:Start ()
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
	barrel_particles_parent = lua_table.GameObjectFunctions:FindChildGameObjectFromGO("Chest_Particles", lua_table.myUID)
	Sparkle = lua_table.GameObjectFunctions:FindChildGameObjectFromGO("Sparkle", lua_table.myUID)
	barrel_particles = lua_table.GameObjectFunctions:GetGOChilds(barrel_particles_parent)
	lua_table.AnimationFunctions:PlayAnimation("Idle",30,lua_table.myUID)
end

local function playParticles()
	for i = 1, #barrel_particles do
		lua_table.ParticlesFunctions:PlayParticleEmitter(barrel_particles[i])
	end
end

local function GimbalLockWorkaroundY(param_rot_y)

    if math.abs(lua_table.Transform:GetRotation(MyUID)[1]) == 180
    then
        if param_rot_y >= 0 then param_rot_y = 180 - param_rot_y
		elseif param_rot_y < 0 then param_rot_y = -180 - param_rot_y
		end
    end

    return param_rot_y
end

local function newPotion(positionx,positiony,type)
	local position = lua_table.TransformFunctions:GetPosition(lua_table.myUID)
	local rotation = lua_table.TransformFunctions:GetRotation(lua_table.myUID)


    local rot_fixed = GimbalLockWorkaroundY(rotation[2])

    local X = math.sin(math.rad(rot_fixed))
    local Z = math.cos(math.rad(rot_fixed))

	local potion = 0		
	local random = lua_table.SystemFunctions:RandomNumberInRange(1, 4)
	if type ~= -1 then
		random = type
	end
	if random < 2 then
		potion = lua_table.Scenes:Instantiate(lua_table.health_potion, position[1] + X * positionx, position[2], position[3] + Z * positiony, 0, rot_fixed - 90, 0)
	elseif random < 3 then
		potion = lua_table.Scenes:Instantiate(lua_table.stamina_potion, position[1] + X * positionx, position[2], position[3] + Z * positiony, 0, rot_fixed - 90, 0)
	elseif random < 4 then
		potion = lua_table.Scenes:Instantiate(lua_table.power_potion, position[1] + X * positionx, position[2], position[3] + Z * positiony, 0, rot_fixed - 90, 0)
	end
end

function lua_table:Update ()
	if lua_table.health <= 0 and current_state == state.NORMAL	then
		timer = lua_table.SystemFunctions:GameTime()
		lua_table.AnimationFunctions:PlayAnimation("Open",30,lua_table.myUID)
		--Assign Chest to Player
		local geralt = lua_table.GameObjectFunctions:FindGameObject("Geralt")
		local jaskier = lua_table.GameObjectFunctions:FindGameObject("Jaskier")
		if script_player ~= nil then
			if jaskier == lua_table.player_owner and script_player.jaskier_score ~= nil then
				script_player.jaskier_score[6] = script_player.jaskier_score[6] + 1
			elseif geralt == lua_table.player_owner and script_player.geralt_score ~= nil then
				script_player.geralt_score[6] = script_player.geralt_score[6] + 1
			end
		end

		playParticles()
		current_state = state.OPENING
	elseif current_state == state.OPENING then
		if lua_table.SystemFunctions:GameTime() - timer > 0.7 then
			lua_table.ParticlesFunctions:PlayParticleEmitter(Sparkle)
			   
			newPotion(-2,0.5,1)
			--newPotion(-0.25,0.5,-1)
			--newPotion(0.25,0.5,-1)
			--newPotion(2,-0.5,1)

			--potion = lua_table.Scenes:Instantiate(lua_table.health_potion, position[1]-2, position[2], position[3] - 0.5, rotation[1], rotation[2], rotation[3])
			--potion = lua_table.Scenes:Instantiate(lua_table.health_potion, position[1]+2, position[2], position[3] - 0.5, rotation[1], rotation[2], rotation[3])
			
			current_state = state.OPENED
		end
	end
end

function lua_table:RequestedTrigger(collider)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 1 --Checks if its player/enemy attack collider layer
	then
		lua_table.player_owner = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		playParticles()
		lua_table.health = lua_table.health - 1
		if lua_table.health <= 0
		then
			lua_table.player_owner = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		end
		lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_hit_wood",lua_table.myUID)
	end
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.myUID)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 2 and current_state == state.NORMAL --Checks if its player/enemy attack collider layer
	then
		lua_table.AnimationFunctions:PlayAnimation("Hit",30,lua_table.myUID)
		playParticles()
		lua_table.health = lua_table.health - 1
		lua_table.AudioFunctions:PlayAudioEventGO("Play_Prop_hit_wood",lua_table.myUID)
		if lua_table.health <= 0
		then
			lua_table.player_owner = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		end
	end
end

return lua_table
end
