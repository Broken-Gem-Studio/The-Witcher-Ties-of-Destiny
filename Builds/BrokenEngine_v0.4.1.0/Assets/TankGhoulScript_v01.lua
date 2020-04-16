function GetTableTankGhoulScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics =  Scripting.Physics()
lua_table.Animations = Scripting.Animations()
-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Possible targets
lua_table.geralt = 0 
lua_table.jaskier = 0
lua_table.currentTarget = 0
lua_table.currentTargetDir = 0
lua_table.currentTargetPos = 0

lua_table.GeraltDistance = 0
lua_table.JaskierDistance = 0

local State = {
	IDLE = 1,
	SEEK = 2,
	JUMP = 3, 
	PUNCH = 4,
	SWIPE = 5,
	CRUSH = 6,
	DEATH = 7
}

------------   All the values below are placeholders, will change them when testing
-- Ghoul values 
lua_table.MyUID = 0 --Entity UID
lua_table.max_hp = 500
lua_table.health = 0
lua_table.speed = 5 
lua_table.currentState = 0
lua_table.is_stunned = false
lua_table.is_dead = false

-- Aggro values 
lua_table.AggroRange = 100
lua_table.minDistance = 5 -- If entity is inside this distance, then attack
lua_table.distance_to_target = 0

-- Combo attack values
local Punch = 10
local Swipe = 50
local Crush = 150

-- Time management
local start_timer = true
local time = 0

-- Flow control conditionals
local running = false

local jumping = false
local stunning = false

local punching = false
local swiping = false
local crushing = false

-- ______________________SCRIPT FUNCTIONS______________________
local function NormalizeVector(vector)
	local module = math.sqrt(vector[1] ^ 2 + vector[3] ^ 2)

    newVector = {0, 0, 0}
    newVector[1] = vector[1] / module
    newVector[2] = vector[2]
    newVector[3] = vector[3] / module
    return newVector
end

local function SearchPlayers() -- Check if targets are within range

	lua_table.GeraltPos = lua_table.Transform:GetPosition(lua_table.geralt)
	lua_table.JaskierPos = lua_table.Transform:GetPosition(lua_table.jaskier)
	lua_table.GhoulPos = lua_table.Transform:GetPosition(lua_table.MyUID)
	
	local GC1 = lua_table.GeraltPos[1] - lua_table.GhoulPos[1]
	local GC2 = lua_table.GeraltPos[3] - lua_table.GhoulPos[3]
    lua_table.GeraltDistance = math.sqrt(GC1 ^ 2 + GC2 ^ 2)

	local JC1 = lua_table.JaskierPos[1] - lua_table.GhoulPos[1]
	local JC2 = lua_table.JaskierPos[3] - lua_table.GhoulPos[3]
	lua_table.JaskierDistance =  math.sqrt(JC1 ^ 2 + JC2 ^ 2)
	

	lua_table.currentTarget = lua_table.geralt
	lua_table.currentTargetDir = lua_table.GeraltDistance
	lua_table.currentTargetPos = lua_table.GeraltPos
				
	if lua_table.JaskierDistance < lua_table.GeraltDistance then
		lua_table.currentTarget = lua_table.jaskier
		lua_table.currentTargetDir = lua_table.JaskierDistance
		lua_table.currentTargetPos = lua_table.JaskierPos

		lua_table.System:LOG("Jaskier in aggro range")
	end 
	
	lua_table.MoveVector = {0, 0, 0}
  	lua_table.MoveVector[1] = lua_table.currentTargetPos[1] - lua_table.GhoulPos[1]
    lua_table.MoveVector[2] = lua_table.currentTargetPos[2] - lua_table.GhoulPos[2]
    lua_table.MoveVector[3] = lua_table.currentTargetPos[3] - lua_table.GhoulPos[3]
end

local function Idle() 
	
	-- if lua_table.is_stunned == false
	-- then 
		if lua_table.currentTargetDir <= lua_table.AggroRange
		then
			lua_table.currentState = State.SEEK
			lua_table.System:LOG("Ghoul state is SEEK") 
		end

	--end

end

function Seek()

	--Now we get the direction vector and then we normalize it and aply a velocity in every component

	if lua_table.currentTargetDir < lua_table.AggroRange and lua_table.currentTargetDir > lua_table.minDistance then
		local velocity = NormalizeVector(lua_table.MoveVector)
		lua_table.Physics:Move(velocity[1] * lua_table.speed, velocity[3] * lua_table.speed, lua_table.MyUID)
		lua_table.currentState = State.JUMP -- Begin jumping attack when it reaches the target      >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> CHANGE TO JUMP
	else 
		currentState = State.IDLE	
	end
end

function JumpStun() -- Smash the ground with a jump, then stun
	-- Reset combo conditionals
	
	-- local tmp = PerfGameTime()

	-- if start_timer and not jumping then 
	-- 	time = tmp
	-- 	lua_table.System:LOG("Jump")
	-- 	start_timer = false
	-- 	jumping = true
	-- end

	-- elapsed_time = tmp - time
	-- if elapsed_time > 2000 and not stunning then
	-- 	lua_table.System:LOG("Smash the ground and stun")
	-- 	stunning = true
	-- 	lua_table.currentState = State.COMBO
	-- else 
	-- 	-- jumping = false
	-- 	-- stunning = false
	-- end

	
end

function Punch() -- Stoppable attack 1/2

	-- -- Punch and swipe that can be stopped
	-- if not damaged then -- Checks if target is being damaged by the players
	-- 	local tmp = PerfGameTime()

	-- 	-- Do combo shit
	-- 	if not start_timer then 
	-- 		time = tmp
	-- 		start_timer = true
			
	-- 	end

	-- 	lua_table.tmp_time = tmp - time
		
	-- 	if lua_table.tmp_time > 1000 and not punching then
	-- 		lua_table.System:LOG("Punch to target")
	-- 		if lua_table.tmp_time > 2000 and not swiping then
	-- 			lua_table.System:LOG("Swipe to target")
	-- 			if lua_table.tmp_time > 3000 and not crushing then
	-- 				lua_table.System:LOG("Crush to target")
	-- 				lua_table.currentState = State.SEEK
	-- 			end
	-- 		end 
	-- 	else 
	-- 		punching = true
	-- 		swiping = true
	-- 		crushing =  true
	-- 	end
	-- end
	-- -- When combo is done, then switch state
	
end

-- ______________________MAIN CODE______________________
function lua_table:Awake()
    lua_table.System:LOG("TankGhoul AWAKE")
end

function lua_table:Start()
    lua_table.System:LOG("TankGhoul START")

	-- Getting Entity and Player UIDs
	lua_table.MyUID = lua_table.GameObject:GetMyUID()
	lua_table.geralt = lua_table.GameObject:FindGameObject("Geralt")
	lua_table.jaskier = lua_table.GameObject:FindGameObject("Jaskier")

    -- Check if both players are in the scene
	if lua_table.geralt == 0 then 
		lua_table.System:LOG ("Geralt not found in scene, add it")
	else 
		lua_table.System:LOG ("Geralt detected")
	end
	   
	if lua_table.jaskier == 0 then 
		lua_table.System:LOG ("Jaskier not found in scene, add it")
	else 
		lua_table.System:LOG ("Jaskier detected")
	end

	lua_table.currentState = State.IDLE
	lua_table.health = lua_table.max_hp
	
end

function lua_table:Update()

    -- Check if our entity is dead
	if lua_table.health <= 0
	then 
		lua_table.currentState = State.DEATH
	end

	SearchPlayers()

	-- Check which state the entity is in and then handle them accordingly
    if lua_table.currentState == State.IDLE -- Initial state is always idle
    then
    	Idle()
    elseif lua_table.currentState == State.SEEK
    then
		Seek()
	-- elseif lua_table.currentState == State.JUMP
    -- then    	
    --     JumpStun()
    -- elseif lua_table.currentState == State.PUNCH
    -- then    	
	-- 	Punch()
	elseif lua_table.currentState == State.DEATH
	then	
		Die()
	end
    
end

return lua_table
end