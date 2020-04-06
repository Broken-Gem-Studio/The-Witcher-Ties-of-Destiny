function GetTableLumberjack_v01()

local lua_table = {}

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.AnimationSystem = Scripting.Animations()


-----------------------------------------------------------------------------------------
-- Local Variables
-----------------------------------------------------------------------------------------

local State = {
	NONE = 0,
	PRE_DETECTION = 1,		-- Before seeing the`player state
	SEEK = 2,				-- Seek the player state
	ATTACK = 3,				-- Attack the player state
	DEATH = 4				-- Dead state	
}
local SubState = {
	NONE = 0,
	IDL = 1,				-- SubState for: PRE_DETECTION or maybe ATTACK State
	PATROL = 2,				-- Substate for: PRE_DETECTION
	DETECTION = 3			-- SubState for: SEEK
}

local attack_colliders = {
	front = { GO_name = "Lumberjack_Front", GO_UID = 0 , active = false}
}


local MinDistance = 30
local MyUID = 0

local Geralt = 0
local Jaskier = 0


-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"

lua_table.collider_damage = 40.0
lua_table.collider_effect = 0

lua_table.MaxHealth = 100
lua_table.CurrentHealth = 0
lua_table.MaxSpeed = 150
lua_table.CurrentTarget = 0
lua_table.AggroDistance = 150

lua_table.CurrentState = State.NONE
lua_table.CurrentSubState = Substate.NONE

-----------------------------------------------------------------------------------------
-- Main Code
-----------------------------------------------------------------------------------------

function lua_table:Awake()
	lua_table.SystemFunctions:LOG("A random Lumberjack Script: AWAKE") 

	---GET PLAYERS ID---
	Geralt = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
    Jaskier = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2) 

	if Geralt == 0 then lua_table.SystemFunctions:LOG ("A random Lumberjack Script: Null Geralt id, called from Lumberjack AWAKE")
	end
    if Jaskier == 0 then lua_table.SystemFunctions:LOG ("A random Lumberjack Script: Null Jaskier id, called from Lumberjack AWAKE")
    end

	---GET MY UID---
	MyUID = lua_table.GameObjectFunctions:GetMyUID()
	if MyUID == 0 then lua_table.SystemFunctions:LOG ("A random Lumberjack Script: Null id for the GameObject that contains the Lumberjack Script, called from Lumberjack AWAKE")
	end

end

function lua_table:Start()

	lua_table.SystemFunctions:LOG("A random Lumberjack Script: START") 
	lua_table.CurrentHealth = lua_table.MaxHealth

	if lua_table.CurrentState == State.NONE
	then	
		lua_table.CurrentState = State.PRE_DETECTION
	end
end

function lua_table:Update()

	if CurrentHealth < 1 
	then
		CurrentState = State.DEATH
	 



end

return lua_table
end