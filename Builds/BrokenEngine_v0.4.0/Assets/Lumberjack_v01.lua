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
	NONE = "NONE",
	UNARMED_IDLE = "UNARMED_IDLE",
	LOOKING_ARROUND = "LOOKING_ARROUND",
	SIT_DOWN = "SIT_DOWN",
	STAND_UP = "STANDUP",
	JUMP_ATTACK = "JUMP_ATTACK",
	ATTACK_1 = "ATTACK_1",
	ATTACK_2 = "ATTACK_2",
	WALK_BACK = "WALK_BACK",
	RUN = "RUN",
	ARMED_IDLE = "IDLE",
	DEATH = "DEATH",
	WALK_FRONT = "WALK_FRONT",
	ALERT = "ALERT",
	HIT = "HIT"
}

local attack_colliders = {
	front = { GO_name = "Lumberjack_Front", GO_UID = 0 , active = false}
}

--Used everywhere
local MinDistance = 4
local MyUID = 0

local Geralt = 0
local Jaskier = 0

local Nvec3x = 0
local Nvec3z = 0  -->Movement
local Nvec3y = 0

---HandlePRE_DETECTION()
local SpawnPos = 0
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
local PatrolSpeed = 2


local DistanceMagnitude = 0


---HandleAggro()
local GeraltDistance = 0
local JaskierDistance = 0

--Players()


-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"

lua_table.collider_damage = 40.0
lua_table.collider_effect = 0

lua_table.MaxHealth = 100
lua_table.CurrentHealth = 0
lua_table.MaxSpeed = 4
lua_table.CurrentTarget = 0

lua_table.AggroDistance = 30

lua_table.CurrentState = State.NONE
lua_table.CurrentSubState = SubState.NONE
lua_table.CurrentAnim = Anim.NONE

lua_table.Pos = 0

lua_table.MinDistanceFromPlayer = 20

-----------------------------------------------------------------------------------------
-- EXTERNAL FUNCTIONS
-----------------------------------------------------------------------------------------
local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime() * 1000
end

-----------------------------------------------------------------------------------------
-- SUB FUNCTIONS
-----------------------------------------------------------------------------------------

function ApplyVelocity( )

	if lua_table.CurrentState == State.PRE_DETECTION and lua_table.CurrentSubState == PATROL
	then 
		if DistanceMagnitude > 0.2 --do this because if not then lumberjack shakes
		then
			Nvec3x = Nvec3x*PatrolSpeed
			Nvec3z = Nvec3z*PatrolSpeed
		else
			Nvec3x = 0
			Nvec3y = 0
			Arrived2PatrolTarget = true
		end
	elseif lua_table.CurrentState == State.SEEK
	then
		if DistanceMagnitude > lua_table.MinDistanceFromPlayer 
		then
			Nvec3x = Nvec3x*lua_table.MaxSpeed
			Nvec3z = Nvec3z*lua_table.MaxSpeed
		else
			Nvec3x = 0
			Nvec3y = 0
			Arrived2PatrolTarget = true
		end
	end
end

function seekPatrolTarget(CurrentPatrolTargetX,CurrentPatrolTargetZ)	 	
	
	vec3x = CurrentPatrolTargetX - lua_table.Pos[1]
	vec3z = CurrentPatrolTargetZ - lua_table.Pos[3]  -- Direction
	
	vec3xpow = vec3x * vec3x
	vec3zpow = vec3z * vec3z -- pre calculus
	
	DistanceMagnitude = math.sqrt( vec3xpow + vec3zpow) --y not used
	
	Nvec3x = vec3x / DistanceMagnitude
	Nvec3z = vec3z / DistanceMagnitude -- Normalized values
end

function seekTarget()	 	
	
	CurrentTargetPos = lua_table.TransformFunctions:GetPosition(lua_table.CurrentTarget)

	vec3x = CurrentTargetPos[1] - lua_table.Pos[1]
	vec3z = CurrentTargetPos[3] - lua_table.Pos[3]  -- Direction
	
	vec3xpow = vec3x * vec3x
	vec3zpow = vec3z * vec3z -- pre calculus
	
	DistanceMagnitude = math.sqrt( vec3xpow + vec3zpow) --y not used
	
	Nvec3x = vec3x / DistanceMagnitude
	Nvec3z = vec3z / DistanceMagnitude -- Normalized values
end

function Players()
	ret = true

	if Geralt ~= 0
	then
		GeraltPos = lua_table.TransformFunctions:GetPosition(Geralt)
	else 
		lua_table.SystemFunctions:LOG("This Log was called from a Lumberjack on Players() function because Geralt is not found")
		ret = false
	end

	if Jaskier ~= 0
	then
		JaskierPos = lua_table.TransformFunctions:GetPosition(Jaskier)	
	else 
		lua_table.SystemFunctions:LOG("This Log was called from a Lumberjack on Players() function because Jaskier is not found")
		ret = false
	end
	
	--calculate distances
	Aj = JaskierPos[1] - lua_table.Pos[1]	
	Bj = JaskierPos[3] - lua_table.Pos[3]
	JaskierDistance = math.sqrt(Aj^2+Bj^2)

	Ag = GeraltPos[1] - lua_table.Pos[1]	
	Bg = GeraltPos[3] - lua_table.Pos[3]
	GeraltDistance = math.sqrt(Ag^2+Bg^2)

	return ret
end

function HandleAggro()
	ret = true
	if lua_table.CurrentTarget == 0 and Players() == true --sin objetivo inicial y existen players
	then	
			if GeraltDistance < lua_table.AggroDistance  
			then
				lua_table.CurrentTarget = Geralt
				lua_table.SystemFunctions:LOG("GERALT IN AGGRO")
				return true			
			elseif JaskierDistance < lua_table.AggroDistance  
			then
				lua_table.CurrentTarget = Jaskier
				lua_table.SystemFunctions:LOG("JASKIER IN AGGRO")
			else
				--lua_table.SystemFunctions:LOG("NO PLAYERS INSIDE AGGRO DISTANCE")
				return false
			end	
	end --TODO when a current target dies need to change current atrget for a new one
	return ret
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
					lua_table.AnimationSystem:PlayAnimation("UNARMED_IDLE",1.0) -- IDLE 
					lua_table.SystemFunctions:LOG("SUB STATE IDLE")
					lua_table.SystemFunctions:LOG("ANIM UNARMED_IDLE")
				else
					lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",1.0) -- SUSPICIOUS
					lua_table.SystemFunctions:LOG("SUB STATE IDLE")
					lua_table.SystemFunctions:LOG("ANIM LOOKING_ARROUND")
				end		
				NotSeenIdle_AnimController = true
			end
		elseif lua_table.CurrentSubState == SubState.PATROL ---Will enter every frame if true
		then
			if Arrived2PatrolTarget == true
			then
				--choose random target
				if LookLeftRight_AnimController == false
				then
					lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",1.0)
					LookLeftRight_AnimController = true
					LookLeftRight_TimeController = PerfGameTime()
				end
				Timer = PerfGameTime()
				if Timer - LookLeftRight_TimeController > 5000 --TODO change value for a animation duration
				then
					CurrentPatrolTargetX  = lua_table.SystemFunctions:RandomNumberInRange(SpawnPos[1]-30,SpawnPos[1]+30)
					CurrentPatrolTargetZ = lua_table.SystemFunctions:RandomNumberInRange(SpawnPos[3]-30,SpawnPos[3]+30)
					Arrived2PatrolTarget = false
				end
			elseif Arrived2PatrolTarget == false
			then
				seekPatrolTarget(CurrentPatrolTargetX,CurrentPatrolTargetZ)
				lua_table.AnimationSystem:PlayAnimation("WALK_FRONT",1.0)
				LookLeftRight_AnimController = false
			end	
			--end
		end
		---
		PlayerSeen = HandleAggro()
		---
	elseif PlayerSeen == true
	then
		lua_table.CurrentState = State.SEEK
		lua_table.CurrentSubState = SubState.NONE
		
	end
end

function HandleSEEK()
	
	seekTarget()

	if DistanceMagnitude <= lua_table.MinDistanceFromPlayer
	then
		CurrentState = State.ATTACK
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
	SpawnPos = lua_table.TransformFunctions:GetPosition(MyUID)
	
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

	lua_table.Pos = lua_table.TransformFunctions:GetPosition(MyUID)

	if lua_table.CurrentHealth <= 1 
	then
		lua_table.CurrentState = State.DEATH
	end

	if lua_table.CurrentState == State.PRE_DETECTION
	then
		HandlePRE_DETECTION()	
	elseif lua_table.CurrentState == State.SEEK
	then
		HandleSEEK()
	end

	ApplyVelocity() --decides if move function will move or not in x and z axis
	lua_table.PhysicsSystem:Move(Nvec3x,Nvec3z,MyUID)
	lua_table.TransformFunctions:LookAt(lua_table.Pos[1] + Nvec3x,lua_table.Pos[2],lua_table.Pos[3] + Nvec3z,MyUID) -- PROVISIONAL, QUEDA MUY ARTIFICIAL

end

return lua_table
end