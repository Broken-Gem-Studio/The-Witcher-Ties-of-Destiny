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

local Anim = {
	NONE = "RUN",
	IDLE = "IDLE",
	SUSPICIOUS = "SUSPICIOUS"
}

local attack_colliders = {
	front = { GO_name = "Lumberjack_Front", GO_UID = 0 , active = false}
}


local MinDistance = 30
local MyUID = 0

local Geralt = 0
local Jaskier = 0


---HandlePRE_DETECTION()
local SpawnPosX = 0
local SpawnPosY = 0
local SpawnPosZ = 0

local PlayerSeen = false

local isSelectedSubState = false

local NotSeenIdle_AnimController = false
local NotSeenPatrol_AnimController = false

local CurrentPatrolTargetX = 0
local CurrentPatrolTargetY = 0
local Arrived2PatrolTarget = true
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
lua_table.CurrentSubState = SubState.NONE
lua_table.CurrentAnim = Anim.NONE


-----------------------------------------------------------------------------------------
-- SUB FUNCTIONS
-----------------------------------------------------------------------------------------

function seekPatrolTarget(CurrentPatrolTargetX,CurrentPatrolTargetZ)

	tarX = CurrentPatrolTargetX
	tarZ = CurrentPatrolTargetZ	

	--Now we get the direction vector and then we normalize it and aply a velocity in every component

	vec3x = CurrentPatrolTargetX - SpawnPosX
	vec3z = CurrentPatrolTargetZ - SpawnPosZ  -- Direction
	
	vec3xpow = vec3x * vec3x
	vec3zpow = vec3z * vec3z -- pre calculus
	
	DistanceMagnitude = math.sqrt( vec3xpow + vec3zpow) --y not used
	
	Nvec3x = vec3x / DistanceMagnitude
	Nvec3z = vec3y / DistanceMagnitude -- Normalized values
		
	lua_table.PhysicsSystem:Move(Nvec3x*Speed,Nvec3z*Speed)


end


-----------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
-----------------------------------------------------------------------------------------

function HandlePRE_DETECTION()
	
	if PlayerSeen == false
	then
		---
		if isSelectedSubState == false ---Will enter 1 time to decide SubState
		then
			SelectedSubState = lua_table.SystemFunctions:RandomNumberInRange(0,10)
			if SelectedSubState <= 10 and SelectedSubState >= 5
			then
				lua_table.CurrentSubState = SubState.IDL
			else
				lua_table.CurrentSubState = SubState.PATROL
			end
		end
		---
		if lua_table.CurrentSubState == SubState.IDL ---Will enter every frame if true
		then
			if NotSeenIdle_AnimController == false
			then
				SelectedAnim = lua_table.SystemFunctions:RandomNumberInRange(0,10)
				if SelectedAnim <= 10 and SelectedAnim >= 5
				then
					lua_table.AnimationSystem:PlayAnimation(Anim.IDLE,30) -- IDLE 
					lua_table.SystemFunctions:LOG("IDLE")
				else
					lua_table.AnimationSystem:PlayAnimation(Anim.NONE,30) -- SUSPICIOUS
					lua_table.SystemFunctions:LOG("SUSPICIOUS")
				end		
				NotSeenIdle_AnimController = true
			end
		elseif lua_table.CurrentSubState == SubState.PATROL ---Will enter every frame if true
		then
			--if Aggro() == false
			--then
				if Arrived2PatrolTarget == true
				then
					--choose random target
					Xpos = lua_table.SystemFunctions:RandomNumberInRange(SpawnPosX-10,SpawnPosX+10)
					Ypos = lua_table.SystemFunctions:RandomNumberInRange(SpawnPosY-10,SpawnPosY+10)
					CurrentPatrolTargetX = Xpos
					CurrentPatrolTargetY = Ypos
					Arrived2PatrolTarget = false
				elseif Arrived2PatrolTarget == false
				then
					--seekPatrolTarget(target)
				end	
			--end
		end
		---
	end

end


-----------------------------------------------------------------------------------------
-- Main Code
-----------------------------------------------------------------------------------------

function lua_table:OnTriggerEnter()	
	local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(lua_table.MyUID)

	--lua_table.SystemFunctions:LOG("OnTriggerEnter()".. collider_GO)
end
function lua_table:OnCollisionEnter()
	local collider = lua_table.PhysicsSystem:OnCollisionEnter(lua_table.MyUID)
	--lua_table.SystemFunctions:LOG("T: ".. collider)
end

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

	---GET MY INITIAL POS---
	SpawnPosX = lua_table.TransformFunctions:GetPositionX()
	SpawnPosY = lua_table.TransformFunctions:GetPositionY()
	SpawnPosZ = lua_table.TransformFunctions:GetPositionZ()

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

	if lua_table.CurrentHealth <= 1 
	then
		lua_table.CurrentState = State.DEATH
	end

	if lua_table.CurrentState == State.PRE_DETECTION
	then
		HandlePRE_DETECTION()
	end

end

return lua_table
end