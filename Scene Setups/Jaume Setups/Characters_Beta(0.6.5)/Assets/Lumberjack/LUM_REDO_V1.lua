function GetTableLUM_REDO_V1()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.AnimationSystem = Scripting.Animations()
lua_table.SoundSystem = Scripting.Audio()
lua_table.ParticleSystem = Scripting.Particles()
lua_table.NavSystem = Scripting.Navigation()


local PrintLogs = true
--if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK x") end

--########################################### STATES ######################################################


local State = {
	NONE = 0,
	PRE_DETECTION = 1,
	SEEK = 2
}
	



--########################################### UTILITY VARIABLES ###########################################


local attack_colliders = {
	jump_attack = { GO_name = "Lumberjack_JA", GO_UID = 0 , active = false},
	front1 = { GO_name = "Lumberjack_FA1", GO_UID = 0 , active = false},
	front2 = { GO_name = "Lumberjack_FA2", GO_UID = 0 , active = false}
}

local particles = {
	alertParticles = { GO_name = "alert_scream_particles_lumberjack", GO_UID = 0 , active = false},
	GroundHitParticles1 = { GO_name = "ground_hit_particles_lumberjack1", GO_UID = 0 , active = false},--smoke
	GroundHitParticles2 = { GO_name = "ground_hit_particles_lumberjack2", GO_UID = 0 , active = false},-- ground crack
	stuntParticles = { GO_name = "stunt_particles_lumberjack", GO_UID = 0 , active = false},
	hitParticles = { GO_name = "hit_particles_lumberjack", GO_UID = 0 , active = false}
}

--Colliders
	local layers = {
		default = 0,
		player = 1,
		player_attack = 2,
		enemy = 3,
		enemy_attack = 4
	}
	local attack_effects = {	
		none = 0,
		stun = 1,
		knockback = 2,
		taunt = 3,
		venom = 4
	}

--ChooseBehaviour() VARIABLES
local PreDetectionBehaviourChosen = false


--################################################ VARIABLES ############################################

lua_table.player_1 = "Geralt"
lua_table.player_2 = "Jaskier"

lua_table.Geralt_UID = 0
lua_table.Jaskier_UID = 0
local GeraltPos = {}
local JaskierPos = {}

local CurrentState = State.NONE

local MyPosition = {}

local GeraltDistance = 0 --updated when call PlayersArround()
local JaskierDistance = 0

local CurrentTarget = 0 -- UID
--#################################################### Utility ###########################################
local function CalculateDistanceTo(Position)
	
	A = Position[1] - MyPosition[1]	
	B = Position[3] - MyPosition[3]
	Distance = math.sqrt(A^2+B^2)
	return Distance
end
--#################################################### MAIN FUNCTIONS ####################################

local function SetDefaultValues()

	CurrentState = State.PRE_DETECTION
end

local function VariablesUpdate()

	MyPosition = lua_table.TransformFunctions:GetPosition(MyUID)
end


local function PlayersArround() --Returns a boolean if players are or not arround
	
	ret = false

	Geralt_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
    Jaskier_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2)

	if Geralt_UID ~= 0
	then
		GeraltPos = lua_table.TransformFunctions:GetPosition(Geralt_UID)
		GeraltDistance = CalculateDistanceTo(GeraltPos)
	end
	if Jaskier_UID ~= 0
	then
		JaskierPos = lua_table.TransformFunctions:GetPosition(Jaskier_UID)
		JaskierDistance = CalculateDistanceTo(JaskierPos)
	end

	if JaskierDistance < 20 or GeraltDistance < 20
	then
		ret = true	
	end

	return ret
end

local function CalculateAggro() --Called only after players() return true

	ret = false

	JaskierScript = lua_table.GameObjectFunctions:GetScript(Jaskier_UID)
	GeraltScript = lua_table.GameObjectFunctions:GetScript(Geralt_UID)

	--if PrintLogs == true then lua_table.SystemFunctions:LOG ("JaskierScript  "..JaskierScript) end

	if CurrentTarget == 0
	then	
		if JaskierDistance < GeraltDistance
		then
			if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
			then
				CurrentTarget = Geralt_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Geralt_UID") end
			else
				CurrentTarget = Jaskier_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Jaskier_UID") end
			end	
			CurrentTarget = Jaskier_UID
		elseif GeraltDistance < JaskierDistance
		then
			if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
			then
				CurrentTarget = Jaskier_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Jaskier_UID") end
			else
				CurrentTarget = Geralt_UID
				ret = true
				if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK CurrentTarget = Geralt_UID") end
			end	
		end		
	elseif CurrentTarget ~= 0
	then 
		if CurrentTarget == Jaskier_UID
		then
			if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
			then
				if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
				then
					ret = false--both on the ground
				else
					CurrentTarget = Geralt_UID
					ret = true
					if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK change CurrentTarget = Geralt_UID") end
				end	
			end
		elseif CurrentTarget == Geralt_UID
		then
			if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
			then
				if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
				then
					ret = false--both on the ground
				else
					CurrentTarget = Jaskier_UID
					ret = true
					if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK change CurrentTarget = Jaskier_UID") end
				end	
			end
		end
	end

	return ret
end

local function ChooseBehaviour() --Called only inside State machine's functions

	if CurrentState == State.PRE_DETECTION
	then
		if PreDetectionBehaviourChosen == false
		then
			Dice = lua_table.SystemFunctions:RandomNumberInRange(0,10)
			if Dice >= 7
			then
				lua_table.AnimationSystem:PlayAnimation("UNARMED_IDLE",30.0,MyUID)
				PreDetectionBehaviourChosen = true
			elseif Dice >= 3 and Dice < 7
			then
				lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0,MyUID)
				PreDetectionBehaviourChosen = true
			elseif Dice < 3
			then
				lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
				PreDetectionBehaviourChosen = true
			end
		end
	end
end


--#################################################### STATE MACHINE FUNCTIONS ###########################

local function HandlePreDetection()
	
	ChooseBehaviour()

	if PlayersArround() == true
	then
		if CalculateAggro() == true
		then
			CurrentState = State.SEEK
		else 
			if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK NO POSSIBLE TARGET AVAIABLE") end
		end
	end

end



--#################################################### MAIN CODE #########################################

function lua_table:Awake()
	
	lua_table.SystemFunctions:LOG("LUMBERJACK AWAKE")

    ---GET PLAYERS ID---
	Geralt_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_1)
    Jaskier_UID = lua_table.GameObjectFunctions:FindGameObject(lua_table.player_2) 

	if Geralt_UID == 0 
	then 
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK A random Lumberjack Script: Null Geralt id, called from Lumberjack AWAKE") end
	end
    if Jaskier_UID == 0 
	then 
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("LUMBERJACK A random Lumberjack Script: Null Jaskier id, called from Lumberjack AWAKE") end
    end

    ---GET LUMBERJACK ID---
	MyUID = lua_table.GameObjectFunctions:GetMyUID()
	if MyUID == 0 
	then 
		if PrintLogs == true then lua_table.SystemFunctions:LOG ("A random Lumberjack Script: Null id for the GameObject that contains the Lumberjack Script, called from Lumberjack AWAKE") end
	end

	---SET COLLIDERS---
	attack_colliders.jump_attack.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.jump_attack.GO_name)
	attack_colliders.front1.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.front1.GO_name)
	attack_colliders.front2.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.front1.GO_name)
end

function lua_table:Start()
	
	SetDefaultValues()

end

function lua_table:Update()

	VariablesUpdate() -- postions for example

	if CurrentState == State.NONE
	then
		if PrintLogs == true then lua_table.SystemFunctions:LOG("LUMBERJACK CurrentState = State.NONE") end
	elseif CurrentState == State.PRE_DETECTION
	then
		--if PrintLogs == true then lua_table.SystemFunctions:LOG("LUMBERJACK CurrentState = State.PRE_DETECTION") end
		HandlePreDetection()
	elseif CurrentState == State.SEEK
	then
		--HandleSeek()
	end

end

return lua_table
end