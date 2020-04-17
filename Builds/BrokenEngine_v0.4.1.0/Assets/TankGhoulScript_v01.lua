function GetTableTankGhoulScript_v01()
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
	IDLE = 0,
	SEEK = 1,
	JUMP = 2, 
	COMBO = 3,
	DEATH = 4
}

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
lua_table.minDistance = 3 -- If entity is inside this distance, then attack

-- Combo attack values
local Punch = 10
local Swipe = 50
local Crush = 150

-- Time management
local start_jump = false
local jump_timer = 0

local start_combo = false
local combo_timer = 0

-- Flow control conditionals
local jumping = false
local stunning = false
local punching = false
local swiping = false
local crushing = false

-- ______________________SCRIPT FUNCTIONS______________________
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
		
	if lua_table.is_stunned == false
	then 
		if lua_table.currentTargetDir <= lua_table.AggroRange
		then
			lua_table.currentState = State.SEEK
			lua_table.System:LOG("Tank Ghoul state: SEEK (1)") 
		end

	end
	
end
	
local function Seek()
	
	--Now we get the direction vector and then we normalize it and aply a velocity in every component
	
	if lua_table.currentTargetDir < lua_table.AggroRange and lua_table.currentTargetDir > lua_table.minDistance then
			
		local dis = math.sqrt(lua_table.MoveVector[1] ^ 2 + lua_table.MoveVector[3] ^ 2)
	
		-- Normalize the vector
		vec = { 0, 0, 0 }
		vec[1] = lua_table.MoveVector[1] / dis
		vec[2] = lua_table.MoveVector[2]
		vec[3] = lua_table.MoveVector[3] / dis
			
			-- Apply movement vector to move character
		lua_table.Physics:Move(vec[1] * lua_table.speed, vec[3] * lua_table.speed, lua_table.MyUID)
	else 
		currentState = State.IDLE	
	end
	
	if lua_table.currentTargetDir <= lua_table.minDistance then
		lua_table.currentState = State.JUMP
			
			--lua_table.System:LOG("Tank Ghoul state: JUMP (2)")
		lua_table.System:LOG("Tank Ghoul state: COMBO (3)")  
	end
end

local function ResetJumpStun()
	-- Timer
	if start_jump == true then start_jump = false end
	if jump_timer > 0 then jump_timer = 0 end
	-- Control bools
	if jumping == true then jumping = false end
	if stunning == true then stunning = false end
end

local function ResetCombo()
	-- Combo Timer
	if start_combo == true then start_combo = false end
	if combo_timer > 0 then combo_timer = 0 end
	-- Combo control bools
	if punching == true then punching = false end
	if swiping == true then swiping = false end
	if crushing == true then crushing = false end
end
	
local function JumpStun() -- Smash the ground with a jump, then stun
	
	
	if not start_jump then 
		jump_timer = lua_table.System:GameTime() * 1000
		start_jump = true
	end

	if jump_timer + 500 <= lua_table.System:GameTime() * 1000 and not jumping then
		lua_table.System:LOG("Jump")
		jumping = true
	end
	if jump_timer + 1500 <= lua_table.System:GameTime() * 1000 and not stunning then
		lua_table.System:LOG("Land and stun")
		stunning = true
	end
	if jump_timer + 2000 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.COMBO
		lua_table.System:LOG("Tank Ghoul state: COMBO (3)")  
		ResetCombo()
	end
	
		-- local tmp = lua_table.System:GameTime() * 1000
		-- end
	
		-- if start_timer and then 
		-- 	time = tmp
		-- 	lua_table.System:LOG("Jump")
		-- 	start_timer = false
		-- 	jumping = true
		-- end
	
		-- elapsed_time = tmp - time
		-- if elapsed_time > 2000 and not stunning then
		-- 	lua_table.System:LOG("Smash the ground and stun")
		-- 	stunning = true
		-- 	lua_table.currentState = State.PUNCH
		-- 	lua_table.System:LOG("Tank Ghoul state: PUNCH (3)") 
		-- else 
		-- 	-- jumping = false
		-- 	-- stunning = false
		-- end
	
		
end
	

	
local function Combo() -- Stoppable attack 1/2

	-- -- -- Punch and swipe that can be stopped
	-- if not damaged then -- Checks if target is being damaged by the players
	
	-- end
	-- 	Start timer
	if not start_combo then 
		combo_timer = lua_table.System:GameTime() * 1000
		start_combo = true
	end

	
	if combo_timer + 500 <= lua_table.System:GameTime() * 1000 and not punching then
		lua_table.System:LOG("Punch to target")
		punching = true
	end
	if combo_timer + 1500 <= lua_table.System:GameTime() * 1000 and not swiping then
		lua_table.System:LOG("Swipe to target")
		swiping = true
	end
	if combo_timer + 2500 <= lua_table.System:GameTime() * 1000 and not crushing then
		lua_table.System:LOG("Crush to target")
		crushing = true
	end
	
	-- After he finished, switch state and reset jump values
	if combo_timer + 3000 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.JUMP	
		lua_table.System:LOG("Tank Ghoul state: JUMP (2)")  
		ResetJumpStun()
	end
	
end

local function Die()
	--Die shit
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
	lua_table.System:LOG("Tank Ghoul state: IDLE (0)") 
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
	elseif lua_table.currentState == State.JUMP
	then    	
		JumpStun()
	elseif lua_table.currentState == State.COMBO
	then    	
		Combo()
	-- elseif lua_table.currentState == State.SWIPE
	-- then    	
	-- 	Swipe()
	-- elseif lua_table.currentState == State.CRUSH
	-- then    	
	-- 	Crush()
	elseif lua_table.currentState == State.DEATH
	then	
		Die()
	end
	
end

return lua_table
end