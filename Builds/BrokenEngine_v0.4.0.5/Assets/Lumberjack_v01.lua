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
	SUSPICIOUS = "SUSPICIOUS",
	ATTACK1 = "ATTACK_1"
}

local attack_colliders = {
	front = { GO_name = "Lumberjack_Front", GO_UID = 0 , active = false}
}

--Used everywhere
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
local LookLeftRight_AnimController = false
local LookLeftRight_TimeController = 0

local CurrentPatrolTargetX = 0
local CurrentPatrolTargetY = 0
local Arrived2PatrolTarget = true
local PatrolSpeed = 15
local Nvec3x = 0
local Nvec3z = 0
local Nvec3y = 0

local distance2PatrolTarget = 0

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

lua_table.Pos = 0
-----------------------------------------------------------------------------------------
-- EXTERNAL FUNCTIONS
-----------------------------------------------------------------------------------------
local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime() * 1000
end

-----------------------------------------------------------------------------------------
-- SUB FUNCTIONS
-----------------------------------------------------------------------------------------

function seekPatrolTarget(CurrentPatrolTargetX,CurrentPatrolTargetZ)	 	
	
	vec3x = CurrentPatrolTargetX - lua_table.Pos[1]
	vec3z = CurrentPatrolTargetZ - lua_table.Pos[3]  -- Direction
	
	vec3xpow = vec3x * vec3x
	vec3zpow = vec3z * vec3z -- pre calculus
	
	DistanceMagnitude = math.sqrt( vec3xpow + vec3zpow) --y not used
	
	Nvec3x = vec3x / DistanceMagnitude
	Nvec3z = vec3z / DistanceMagnitude -- Normalized values
	
	if DistanceMagnitude > 0.2 --do this because if not then lumberjack shakes
	then
		Nvec3x = Nvec3x*PatrolSpeed
		Nvec3z = Nvec3z*PatrolSpeed
	else
		Nvec3x = 0
		Nvec3y = 0
		Arrived2PatrolTarget = true
	end
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
			SelectedSubState = lua_table.SystemFunctions:RandomNumberInRange(0,4)
			if SelectedSubState <= 10 and SelectedSubState >= 5
			then
				lua_table.CurrentSubState = SubState.IDL
			elseif SelectedSubState <= 5 and SelectedSubState >= 0
			then
				lua_table.CurrentSubState = SubState.PATROL
			end
			isSelectedSubState = true
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
					lua_table.SystemFunctions:LOG("SUB STATE IDLE")
					lua_table.SystemFunctions:LOG("ANIM IDLE")
				else
					lua_table.AnimationSystem:PlayAnimation(Anim.NONE,30) -- SUSPICIOUS
					lua_table.SystemFunctions:LOG("SUB STATE IDLE")
					lua_table.SystemFunctions:LOG("ANIM SUSPICIOUS")
				end		
				NotSeenIdle_AnimController = true
			end
		elseif lua_table.CurrentSubState == SubState.PATROL ---Will enter every frame if true
		then
		--lua_table.SystemFunctions:LOG("SUB STATE PATROL")
			--if Aggro() == false
			--then
				if Arrived2PatrolTarget == true
				then
					--choose random target
					if LookLeftRight_AnimController == false
					then
						lua_table.AnimationSystem:PlayAnimation(Anim.ATTACK1,30)
						LookLeftRight_AnimController = true
						LookLeftRight_TimeController = PerfGameTime()
					end
					Timer = PerfGameTime()
					if Timer - LookLeftRight_TimeController > 5000
					then
						CurrentPatrolTargetX  = lua_table.SystemFunctions:RandomNumberInRange(SpawnPosX-30,SpawnPosX+30)
						CurrentPatrolTargetZ = lua_table.SystemFunctions:RandomNumberInRange(SpawnPosZ-30,SpawnPosZ+30)
						Arrived2PatrolTarget = false
					end

				elseif Arrived2PatrolTarget == false
				then
					seekPatrolTarget(CurrentPatrolTargetX,CurrentPatrolTargetZ)
					LookLeftRight_AnimController = false
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
	local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUID)

	--lua_table.SystemFunctions:LOG("OnTriggerEnter()".. collider_GO)
end
function lua_table:OnCollisionEnter()
	local collider = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
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

	lua_table.Pos = lua_table.TransformFunctions:GetPosition(MyUID)
	lua_table.PhysicsSystem:Move(Nvec3x,Nvec3z,MyUID)
	lua_table.TransformFunctions:LookAt(lua_table.Pos[1] + Nvec3x,lua_table.Pos[2],lua_table.Pos[3] + Nvec3z,true)

end

return lua_table
end