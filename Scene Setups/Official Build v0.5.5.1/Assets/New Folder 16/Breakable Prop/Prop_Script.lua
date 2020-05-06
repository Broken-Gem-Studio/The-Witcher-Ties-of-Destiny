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

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on AWAKE")
	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
	lua_table.parent = lua_table.GameObjectFunctions:GetGameObjectParent(lua_table.myUID)
	
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("This Log was called from Camera Script on START")
end

function lua_table:Update ()
	local position = lua_table.TransformFunctions:GetPosition(lua_table.myUID)
	local rotation = lua_table.TransformFunctions:GetRotation(lua_table.myUID)
	if lua_table.health <= 0 and current_state == state.NORMAL
	then
		lua_table.GameObjectFunctions:SetActiveGameObject(false,lua_table.myUID)
		Destroyable = lua_table.GameObjectFunctions:FindChildGameObjectFromGO("Destructed",lua_table.parent)
		lua_table.GameObjectFunctions:SetActiveGameObject(true,Destroyable)
		lua_table.TransformFunctions:SetPosition(position[1],position[2],position[3],Destroyable)
		lua_table.TransformFunctions:SetObjectRotation(rotation[1] + 90,rotation[2],rotation[3],Destroyable)
		if Player ~= 0
		then
		  local playerID = lua_table.GameObjectFunctions:GetGameObjectParent(Player)
				local propTable = lua_table.GameObjectFunctions:GetScript(Destroyable)
				propTable.Player = playerID
		end
		current_state = state.DESTROYED
	end
end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.myUID)
	lua_table.SystemFunctions:LOG("T:" .. collider)

	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)
	if layer == 2 or layer == 4 --Checks if its player/enemy attack collider layer
	then
	
		lua_table.health = lua_table.health - 1
		if lua_table.health > 0
		then
			-- Audio SFX (randomized)
			randy = lua_table.SystemFunctions:RandomNumberInRange(1, 4)
			if (randy < 2)
			then
				lua_table.AudioFunctions:PlayAudioEvent("Play_Hit_Wood_Sound_1")
			elseif (randy < 3)
			then
				lua_table.AudioFunctions:PlayAudioEvent("Play_Hit_Wood_Sound_2")
			else
				lua_table.AudioFunctions:PlayAudioEvent("Play_Hit_Wood_Sound_3")
			end
		elseif lua_table.health == 0
		then
			if layer == 2 and Player == 0
			then
				Player = collider
			end

			randy = lua_table.SystemFunctions:RandomNumberInRange(1, 3)
			if (randy < 2)
			then
				if lua_table.current_type == type.BARREL
				then
					lua_table.AudioFunctions:PlayAudioEvent("Play_Barrel_crush_1")
				elseif lua_table.current_type == type.BOX
				then
					lua_table.AudioFunctions:PlayAudioEvent("Play_Broken_Wood_Sound_1")
				end
			else
				if lua_table.current_type == type.BARREL
				then
					lua_table.AudioFunctions:PlayAudioEvent("Play_Barrel_crush_2")
				elseif lua_table.current_type == type.BOX
				then
					lua_table.AudioFunctions:PlayAudioEvent("Play_Broken_Wood_Sound_2")
				end
			end
		end
	end
end


	return lua_table
end