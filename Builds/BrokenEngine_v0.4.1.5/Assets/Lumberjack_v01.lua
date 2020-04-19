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
	ALERT = 3,			    -- SubState for: SEEK
	SEEK_TARGET = 4,		-- SubState for: SEEK
	JUMP_ATTACK = 5			-- SubState for: SEEK
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
local PatrolWalk_AnimController = false


local CurrentPatrolTargetX = 0
local CurrentPatrolTargetY = 0
local Arrived2PatrolTarget = true
local PatrolSpeed = 2


local DistanceMagnitude = 0


---HandleAggro()
local GeraltDistance = 0
local JaskierDistance = 0

--Players()


--seekPatrolTarget
local FirstSeekCalled = false

--HandleSEEK()
local Alert_AnimController = false
local Run_AnimController = false
local vec3x = 0 --dirvector
local vec3z = 0 --dirvector


--HandleAttack()
local Attack1_AnimController = false
local Attack1_TimeController = 0
local IdleArmed_AnimController = false 

--JumpAttack()
local AfterJumpAttackTimer = 0
local JumpAttack_TimeController = 0
local JumpAttack_AnimController = false
local Aux_TargetPos = {}
local Aux_TargetExist = false
local DistanceMagnitudeAux_Target = 0
local UseAuxVariables = false
-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"

lua_table.player_1_Dead = false
lua_table.player_2_Dead = false

lua_table.collider_damage = 40.0
lua_table.collider_effect = 0

lua_table.MaxHealth = 100
lua_table.CurrentHealth = 0
lua_table.MaxSpeed = 5
lua_table.JumpAttackSpeed = 3.5
lua_table.JumpAttackDone = false

lua_table.CurrentTarget = 0
lua_table.CurrentPatrolTarget = {}

lua_table.AggroDistance = 30

lua_table.CurrentState = State.NONE
lua_table.CurrentSubState = SubState.NONE
lua_table.CurrentAnim = Anim.NONE

lua_table.Pos = 0

lua_table.MinDistanceFromPlayer = 3

-----------------------------------------------------------------------------------------
-- EXTERNAL FUNCTIONS
-----------------------------------------------------------------------------------------
local function PerfGameTime()
	return lua_table.SystemFunctions:GameTime() * 1000
end
local function CalculateDistanceToTarget(target) --distance from a Object, argument is a number (id of the target)

	targetPos = lua_table.TransformFunctions:GetPosition(target) --variable name has nothing in common with function CalculateDistanceToPosition(targetPos)

	vec3x = targetPos[1] - lua_table.Pos[1]  
	vec3z = targetPos[3] - lua_table.Pos[3]  -- Direction
	
	vec3xpow = vec3x * vec3x
	vec3zpow = vec3z * vec3z -- pre calculus
	
	Distance = math.sqrt( vec3xpow + vec3zpow) --y not used

	return Distance
end
local function CalculateDistanceToPosition(targetPos) --distance from a position, argument is a table

	--TargetPos = lua_table.TransformFunctions:GetPosition(target)

	vec3x = targetPos[1] - lua_table.Pos[1]
	vec3z = targetPos[3] - lua_table.Pos[3]  -- Direction
	
	vec3xpow = vec3x * vec3x
	vec3zpow = vec3z * vec3z -- pre calculus
	
	Distance = math.sqrt( vec3xpow + vec3zpow) --y not used

	return Distance
end
local function NormalizeDirVector()
	
	Nvec3x = vec3x / DistanceMagnitude
	Nvec3z = vec3z / DistanceMagnitude -- Normalized values

	lua_table.SystemFunctions:LOG("Nvec3x NormalizeDirVector():"..Nvec3x)
	lua_table.SystemFunctions:LOG("Nvec3z NormalizeDirVector():"..Nvec3z)

end
local function NormalizeDirVector_AuxTarget()
	
	
	Nvec3x = vec3x / DistanceMagnitudeAux_Target
	Nvec3z = vec3z / DistanceMagnitudeAux_Target -- Normalized values for jumpattack
	lua_table.SystemFunctions:LOG("Nvec3x after NormalizedirVector_AuxTarget:------------"..Nvec3x)
	lua_table.SystemFunctions:LOG("Nvec3z after NormalizedirVector_AuxTarget:------------"..Nvec3z)
end
-----------------------------------------------------------------------------------------
-- SUB FUNCTIONS
-----------------------------------------------------------------------------------------

local function ApplyVelocity( )

	if lua_table.CurrentState == State.PRE_DETECTION and lua_table.CurrentSubState == SubState.PATROL
	then 
		if FirstSeekCalled == true and DistanceMagnitude > 0.3 --do this because if not then lumberjack shakes --error lumberjack
		then
			Nvec3x = Nvec3x*PatrolSpeed
			Nvec3z = Nvec3z*PatrolSpeed
		elseif Arrived2PatrolTarget == false and LookLeftRight_AnimController == false and FirstSeekCalled == true and DistanceMagnitude <= lua_table.MinDistanceFromPlayer 
		then
			Nvec3x = Nvec3x * 0.0001 --this is to don't convert the lookAt vector to 0 but do not move the dir vector
		    Nvec3z = Nvec3z * 0.0001
			Arrived2PatrolTarget = true
		end
	elseif lua_table.CurrentState == State.SEEK
	then
		if DistanceMagnitude > lua_table.MinDistanceFromPlayer and lua_table.CurrentSubState == SubState.SEEK_TARGET 
		then
			Nvec3x = Nvec3x*lua_table.MaxSpeed
			Nvec3z = Nvec3z*lua_table.MaxSpeed
		elseif DistanceMagnitude > lua_table.MinDistanceFromPlayer and lua_table.CurrentSubState == SubState.ALERT
		then
			Nvec3x = Nvec3x * 0.001
			Nvec3z = Nvec3z * 0.001
		elseif lua_table.CurrentSubState == SubState.JUMP_ATTACK
		then
			Nvec3x = Nvec3x*lua_table.JumpAttackSpeed
			Nvec3z = Nvec3z*lua_table.JumpAttackSpeed
		end
	elseif lua_table.CurrentState == State.ATTACK
	then
		Nvec3x = 0
		Nvec3z = 0
	end
end

local function seekPatrolTarget()	 	
	
	FirstSeekCalled = true
	DistanceMagnitude = CalculateDistanceToPosition(lua_table.CurrentPatrolTarget) --y not used
	NormalizeDirVector()
end

local function seekTarget()	 	
	DistanceMagnitude = CalculateDistanceToTarget( lua_table.CurrentTarget) --y not used
	NormalizeDirVector()
end

local function Players()
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

local function HandleAggro()
	ret = true
	if lua_table.CurrentTarget == 0 and Players() == true --sin objetivo inicial y existen players
	then	
			if GeraltDistance < lua_table.AggroDistance  
			then
				lua_table.CurrentTarget = Geralt
				--lua_table.SystemFunctions:LOG("GERALT IN AGGRO")
				return true			
			elseif JaskierDistance < lua_table.AggroDistance  
			then
				lua_table.CurrentTarget = Jaskier
				--lua_table.SystemFunctions:LOG("JASKIER IN AGGRO")
			else
				--lua_table.SystemFunctions:LOG("NO PLAYERS INSIDE AGGRO DISTANCE")
				return false
			end	
	end --TODO when a current target dies need to change current atrget for a new one
	return ret
end

local function jumpAttack()

	--DistanceMagnitude = CalculateDistanceToTarget(lua_table.CurrentTarget)
	DistanceMagnitudeAux_Target = CalculateDistanceToPosition(Aux_TargetPos)--tengo q pasar un target
	NormalizeDirVector_AuxTarget()

	if JumpAttack_AnimController == false
	then
		--lua_table.SystemFunctions:LOG(" JUMP_ATTACK! ")
		lua_table.AnimationSystem:PlayAnimation("JUMP_ATTACK",35.0)
		lua_table.CurrentSubState = SubState.JUMP_ATTACK
		JumpAttack_AnimController = true
		JumpAttack_TimeController = PerfGameTime()
	end
	if DistanceMagnitudeAux_Target <= lua_table.MinDistanceFromPlayer and lua_table.CurrentSubState == SubState.JUMP_ATTACK
	then	
		--cambiar q se ponga aqui el state atack y el sub estate
		lua_table.JumpAttackDone = true
		UseAuxVariables = false
		AfterJumpAttackTimer = PerfGameTime()
	end
end
local function Attack()
	Time = PerfGameTime()
	if Attack1_AnimController == false and Time - AfterJumpAttackTimer > 1500 --delay para q caiga y no insta ataque
	then
		Attack1_TimeController = PerfGameTime()
		lua_table.AnimationSystem:PlayAnimation("ATTACK_1",30.0)
		Attack1_AnimController = true
	end

	Time = PerfGameTime()
	TimeSinceLastAttack = Time - Attack1_TimeController

	if TimeSinceLastAttack >= 1800
	then
		if IdleArmed_AnimController == false
		then 
			lua_table.AnimationSystem:PlayAnimation("IDLE",30.0)
		    IdleArmed_AnimController = true
		end	
	end
	if TimeSinceLastAttack >= 2500
	then
		Attack1_AnimController = false
		IdleArmed_AnimController = false
	end
		
end

-----------------------------------------------------------------------------------------
-- MAIN FUNCTIONS
-----------------------------------------------------------------------------------------

local function HandlePRE_DETECTION()
	
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
					lua_table.AnimationSystem:PlayAnimation("UNARMED_IDLE",30.0) -- IDLE 
					--lua_table.SystemFunctions:LOG("SUB STATE IDLE")
					--lua_table.SystemFunctions:LOG("ANIM UNARMED_IDLE")
				else
					lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0) -- SUSPICIOUS
					--lua_table.SystemFunctions:LOG("SUB STATE IDLE")
					--lua_table.SystemFunctions:LOG("ANIM LOOKING_ARROUND")
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
					lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0)
					--lua_table.SystemFunctions:LOG("SUB STATE PATROL")
					LookLeftRight_AnimController = true
					LookLeftRight_TimeController = PerfGameTime()
				end
				Timer = PerfGameTime()
				if Timer - LookLeftRight_TimeController > 6000 --TODO change value for a animation duration
				then
					lua_table.CurrentPatrolTarget[1] = lua_table.SystemFunctions:RandomNumberInRange(SpawnPos[1]-10,SpawnPos[1]+10)
					lua_table.CurrentPatrolTarget[3] = lua_table.SystemFunctions:RandomNumberInRange(SpawnPos[3]-10,SpawnPos[3]+10)
					Arrived2PatrolTarget = false
					PatrolWalk_AnimController = false
				end
			elseif Arrived2PatrolTarget == false
			then		
				if PatrolWalk_AnimController == false
				then
					lua_table.AnimationSystem:PlayAnimation("WALK_FRONT",30.0)
					--lua_table.SystemFunctions:LOG("PATROLING")
					PatrolWalk_AnimController = true
					LookLeftRight_AnimController = false
				end	
				seekPatrolTarget()
			end	
			--end
		end
		---
		PlayerSeen = HandleAggro()
		---
	elseif PlayerSeen == true
	then
		DistanceMagnitude = CalculateDistanceToTarget(lua_table.CurrentTarget) 
		lua_table.CurrentState = State.SEEK
		lua_table.CurrentSubState = SubState.ALERT	
	end
end

local function HandleSEEK()
	lua_table.SystemFunctions:LOG("DistanceMagnitude-->"..DistanceMagnitude)

	if lua_table.CurrentSubState == SubState.ALERT
	then
		if Alert_AnimController == false
		then
			lua_table.AnimationSystem:PlayAnimation("ALERT",30.0)
			Alert_AnimController = true
			Alert_TimeController = PerfGameTime()
		end
		Time = PerfGameTime()
		if Time - Alert_TimeController >= 2000
		then
			lua_table.CurrentSubState = SubState.SEEK_TARGET
		end
	end
	--#####################################################################################   ALERT DONE
	if lua_table.CurrentSubState == SubState.SEEK_TARGET
	then
		if Run_AnimController == false
		then
			lua_table.AnimationSystem:PlayAnimation("RUN",30.0)
			Run_AnimController = true
		end
		lua_table.SystemFunctions:LOG("seekTarget()")
		seekTarget()----------------------------------11111111111111111111111111
	end
	--#####################################################################################   SEEK DONE
	if DistanceMagnitude < 15 and lua_table.JumpAttackDone == false 
	then
		UseAuxVariables = true	
	end

	if UseAuxVariables == true
	then
		lua_table.JumpAttackSpeed = 4
		--lua_table.SystemFunctions:LOG("jumpAttack()")
		if Aux_TargetExist == false
		then 
			Aux_TargetPos = lua_table.TransformFunctions:GetPosition(lua_table.CurrentTarget)
			Aux_TargetExist = true
		end
		lua_table.SystemFunctions:LOG("DistanceMagnitudeAuxTarget-->"..DistanceMagnitudeAux_Target)
		lua_table.SystemFunctions:LOG("jumpAttack()")
		jumpAttack()
	end

	if DistanceMagnitudeAux_Target < 13.5 and lua_table.JumpAttackDone == false --and lua_table.CurrentSubState == SubState.JUMP_ATTACK
	then
		lua_table.JumpAttackSpeed = 7
	end

	--#####################################################################################   JUMP ATTACK DONE

	if DistanceMagnitudeAux_Target <= lua_table.MinDistanceFromPlayer+2 and lua_table.JumpAttackDone == true and lua_table.CurrentSubState == SubState.JUMP_ATTACK
	then
		if DistanceMagnitude <= lua_table.MinDistanceFromPlayer+2
		then
			lua_table.AnimationSystem:PlayAnimation("IDLE",30.0)
			lua_table.CurrentState = State.ATTACK
			lua_table.CurrentSubState = SubState.NONE
			Run_AnimController = false
		    lua_table.SystemFunctions:LOG("SEEK----->ATTACK")
			UseAuxVariables = false
		end
		if DistanceMagnitude > lua_table.MinDistanceFromPlayer+2
		then
			lua_table.AnimationSystem:PlayAnimation("RUN",30.0)
			lua_table.CurrentState = State.SEEK
			lua_table.CurrentSubState = SubState.SEEK_TARGET
			lua_table.SystemFunctions:LOG("SEEK----->SEEK (SEEK_TARGET)")
			UseAuxVariables = false
		end
	end
	--#####################################################################################    PREPARED TO ATTACK
	if DistanceMagnitude <= lua_table.MinDistanceFromPlayer
		then
			lua_table.AnimationSystem:PlayAnimation("IDLE",30.0)
			lua_table.CurrentState = State.ATTACK
			lua_table.CurrentSubState = SubState.NONE
			Run_AnimController = false
		    lua_table.SystemFunctions:LOG("SEEK----->ATTACK")
			UseAuxVariables = false
		end
end

local function HandleAttack()
	
	DistanceMagnitude = CalculateDistanceToTarget(lua_table.CurrentTarget)
	
	
	if DistanceMagnitude <= lua_table.MinDistanceFromPlayer   --   -1 bc lumberjac distance is 2.93
	then
		Attack()
		lua_table.SystemFunctions:LOG("attack()")
	elseif DistanceMagnitude >= lua_table.MinDistanceFromPlayer +2
	then 
		lua_table.CurrentState = State.SEEK
		lua_table.CurrentSubState = SubState.SEEK_TARGET
		lua_table.JumpAttackDone = true
		lua_table.SystemFunctions:LOG("ATTACK----->SEEK")
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
	--lua_table.SystemFunctions:LOG("A random Lumberjack Script: AWAKE") 

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


	--lua_table.SystemFunctions:LOG("MyUID".. MyUID) 

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
	elseif lua_table.CurrentState == State.ATTACK
	then
		HandleAttack()
		Nvec3x = Nvec3x * 0.00001
		Nvec3z = Nvec3z * 0.00001
	elseif lua_table.CurrentSubState
	end

	lua_table.TransformFunctions:LookAt(lua_table.Pos[1] + vec3x,lua_table.Pos[2],lua_table.Pos[3] + vec3z,MyUID) -- PROVISIONAL, QUEDA MUY ARTIFICIAL
	ApplyVelocity() --decides if move function will move or not in x and z axis		
	lua_table.PhysicsSystem:Move(Nvec3x,Nvec3z,MyUID)
end

return lua_table
end