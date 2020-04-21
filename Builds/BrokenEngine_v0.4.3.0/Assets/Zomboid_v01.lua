function GetTableZomboid_v01()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics =  Scripting.Physics()
lua_table.Animations = Scripting.Animations()
lua_table.Recast = Scripting.Navigation()
-- DEBUG PURPOSES
lua_table.Input = Scripting.Inputs()

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
	KNOCKBACK = 4,
	STUNNED = 5,
	DEATH = 6
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
lua_table.speed = 7
lua_table.knock_speed = 50
lua_table.currentState = 0
lua_table.is_stunned = false
lua_table.is_taunt = false
lua_table.is_knockback = false
lua_table.is_dead = false
	
-- Aggro values 
lua_table.AggroRange = 100
lua_table.minDistance = 2.5 -- If entity is inside this distance, then attack
lua_table.jumpDistance = 7
--
lua_table.stun_duration = 0

local knock_force = {0, 0, 0}

-- Combo attack values
local Punch = 10
local Swipe = 50
local Crush = 150

-- Time management
local start_jump = false
local jump_timer = 0

local start_combo = false
local combo_timer = 0

local start_stun = false
local stun_timer = 0

local start_knockback = false
local knockback_timer = 0

local start_death = false
local death_timer = 0

-- Flow control conditionals
local jumping = false
local stunning = false
local punching = false
local swiping = false
local crushing = false

-- Recast navigation
local navID = 0
local corners = {}
local currCorner = 2

-- ______________________SCRIPT FUNCTIONS______________________

local function ResetNavigation()
	currCorner = 2
	-- navigation_timer = 0
	-- start_navigation = false
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

local function ResetStun()
	if start_stun == true then start_stun = false end
	if stun_timer > 0 then stun_timer = 0 end
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
	
	if lua_table.is_taunt then 
		lua_table.currentTarget = lua_table.jaskier
		lua_table.currentTargetDir = lua_table.JaskierDistance
		lua_table.currentTargetPos = lua_table.JaskierPos
	else 
		lua_table.currentTarget = lua_table.geralt
		lua_table.currentTargetDir = lua_table.GeraltDistance
		lua_table.currentTargetPos = lua_table.GeraltPos
	end
					
	if lua_table.JaskierDistance < lua_table.GeraltDistance then
		lua_table.currentTarget = lua_table.jaskier
		lua_table.currentTargetDir = lua_table.JaskierDistance
		lua_table.currentTargetPos = lua_table.JaskierPos
		
	elseif lua_table.JaskierDistance == lua_table.GeraltDistance then 
		lua_table.currentTarget = lua_table.geralt
		lua_table.currentTargetDir = lua_table.GeraltDistance
		lua_table.currentTargetPos = lua_table.GeraltPos
	end 
end
	
local function Idle() 
		
	if lua_table.currentTargetDir <= lua_table.AggroRange then
		lua_table.currentState = State.SEEK
		lua_table.Animations:PlayAnimation("Walk", 40.0, lua_table.MyUID)
		lua_table.System:LOG("Zomboid state: SEEK (1)") 
	end
	
end
	
local function Seek()
	
	-- Now we get the direction vector and then we normalize it and aply a velocity in every component
	
	if lua_table.currentTargetDir < lua_table.AggroRange and lua_table.currentTargetDir > lua_table.minDistance then
			
		-- Wait 4 second to recalculate path

		--navigation_timer = lua_table.System:GameTime() * 1000
		corners = lua_table.Recast:CalculatePath(lua_table.GhoulPos[1], lua_table.GhoulPos[2], lua_table.GhoulPos[3], lua_table.currentTargetPos[1], lua_table.currentTargetPos[2], lua_table.currentTargetPos[3], 1 << navID)
		--start_navigation = true

		local nextCorner = {}
		nextCorner[1] = corners[currCorner][1] - lua_table.GhoulPos[1]
		nextCorner[2] = corners[currCorner][2] - lua_table.GhoulPos[2]
		nextCorner[3] = corners[currCorner][3] - lua_table.GhoulPos[3]

		local dis = math.sqrt(nextCorner[1] ^ 2 + nextCorner[3] ^ 2)
		
		if dis > 0.05 then 

			local vec = { 0, 0, 0 }
			vec[1] = nextCorner[1] / dis
			vec[2] = nextCorner[2]
			vec[3] = nextCorner[3] / dis
				
			-- Apply movement vector to move character
			lua_table.Transform:LookAt(corners[currCorner][1], lua_table.GhoulPos[2], corners[currCorner][3], lua_table.MyUID)
			lua_table.Physics:Move(vec[1] * lua_table.speed, vec[3] * lua_table.speed, lua_table.MyUID)
			
			else
				currCorner = currCorner + 1
		end
		
		else 
			lua_table.currentState = State.IDLE	
			
	end
	
	if lua_table.currentTargetDir <= lua_table.minDistance then
		lua_table.currentState = State.JUMP
		lua_table.System:LOG("Zomboid state: JUMP (2)")
	end
end

	
local function JumpStun() -- Smash the ground with a jump, then stun
	
	if not start_jump then 
		jump_timer = lua_table.System:GameTime() * 1000
		start_jump = true
	end

	if jump_timer <= lua_table.System:GameTime() * 1000 and not jumping then
		lua_table.System:LOG("Jump")
		lua_table.Animations:PlayAnimation("Jump_Stun_1", 10.0, lua_table.MyUID)
		jumping = true
	end
	if jump_timer + 1500 <= lua_table.System:GameTime() * 1000 and not stunning then
		lua_table.System:LOG("Land and stun")
		lua_table.Animations:PlayAnimation("Jump_Stun_2", 40.0, lua_table.MyUID)
		stunning = true
	end
	if jump_timer + 2000 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.COMBO
		lua_table.System:LOG("Zomboid state: COMBO (3)")  
	end
end
	
local function Combo()

	if lua_table.currentTargetDir >= lua_table.jumpDistance then
		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Zomboid state: SEEK (1), target out of range")    
		lua_table.Animations:PlayAnimation("Walk", 60.0, lua_table.MyUID)
		return
	end

	--lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.GhoulPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if not start_combo then 
		combo_timer = lua_table.System:GameTime() * 1000
		start_combo = true
	end

	lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.GhoulPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if combo_timer + 250 <= lua_table.System:GameTime() * 1000 and not punching then
		lua_table.System:LOG("Punch to target")
		lua_table.Animations:PlayAnimation("Punch", 30.0, lua_table.MyUID)
		punching = true
	end
	if combo_timer + 1750 <= lua_table.System:GameTime() * 1000 and not swiping then
		lua_table.System:LOG("Swipe to target")
		lua_table.Animations:PlayAnimation("Swipe", 30.0, lua_table.MyUID)
		swiping = true
	end
	if combo_timer + 3500 <= lua_table.System:GameTime() * 1000 and not crushing then
		lua_table.System:LOG("Crush to target")
		lua_table.Animations:PlayAnimation("Smash", 45.0, lua_table.MyUID)
		crushing = true
	end
	
	-- After he finished, switch state and reset jump values
	if combo_timer + 5000 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.SEEK	
		lua_table.Animations:PlayAnimation("Walk", 40.0, lua_table.MyUID)
		lua_table.System:LOG("Zomboid state: SEEK (1), cycle to jump")
	end
	
end

local function Stun()
	if start_stun then 
		stun_timer = lua_table.System:GameTime() * 1000
		
		if lua_table.is_knockback == true then 
			lua_table.stun_duration = 2000
		else
			lua_table.stun_duration = 4000
		end

		start_stun = false
	end

	if stun_timer + lua_table.stun_duration <= lua_table.System:GameTime() * 1000 then
		lua_table.Animations:PlayAnimation("Walk", 40.0, lua_table.MyUID)
		lua_table.stun_duration = 0
		lua_table.is_knockback = false

		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Zomboid state: SEEK (1), from stun")
	end
	
end

local function KnockBack()
	if start_knockback then 
		knockback_timer = lua_table.System:GameTime() * 1000
		start_knockback = false
	end

	if knockback_timer + 500 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.STUNNED	
		lua_table.System:LOG("Zomboid state: STUNNED (4), from KD")
		
	else 
		lua_table.Physics:Move(knock_force[1] * lua_table.knock_speed, knock_force[3] * lua_table.knock_speed, lua_table.MyUID)

	end
	
end

local function Die()
	if not start_death then 
		death_timer = lua_table.System:GameTime() * 1000
		lua_table.System:LOG("Im dying")  
		lua_table.Animations:PlayAnimation("Death", 30.0, lua_table.MyUID)
		start_death = true
	end

	if death_timer + 7000 <= lua_table.System:GameTime() * 1000 then
		lua_table.System:LOG("Im dead!!!!!!!!!")  
		lua_table.GameObject:DestroyGameObject(lua_table.MyUID) -- Delete GO from scene
	end
	
end

-- ______________________COLLISIONS______________________
function lua_table:OnTriggerEnter()	
	local collider = lua_table.Physics:OnTriggerEnter(lua_table.MyUID)
    local layer = lua_table.GameObject:GetLayerByID(collider)

    if layer == layers.player_attack then 
		local parent = lua_table.GameObject:GetGameObjectParent(collider)
		local script = lua_table.GameObject:GetScript(parent)
		
		if lua_table.currentState ~= State.DEATH then

			lua_table.health = lua_table.health - script.collider_damage
	
			if script.collider_effect ~= attack_effects.none then
				
				if script.collider_effect == attack_effects.stun then ----------------------------------------------------- React to stun effect
					start_stun = true
					lua_table.currentState = State.STUNNED
					lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
					lua_table.System:LOG("Zomboid state: STUNNED (5)")  
				end
		
				if script.collider_effect == attack_effects.knockback then ------------------------------------------------ React to kb effect

					local knock_vector = {0, 0, 0}
					knock_vector[1] = lua_table.GhoulPos[1] - lua_table.currentTargetPos[1]
					knock_vector[2] = lua_table.GhoulPos[2] - lua_table.currentTargetPos[2]
					knock_vector[3] = lua_table.GhoulPos[3] - lua_table.currentTargetPos[3]
									
 					local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

					
					knock_force[1] = knock_vector[1] / module
					knock_force[2] = knock_vector[2]
					knock_force[3] = knock_vector[3] / module

					if not start_knockback then 
						knockback_timer = lua_table.System:GameTime() * 1000
						lua_table.System:LOG("Im KB")  
						lua_table.Animations:PlayAnimation("Hit", 20.0, lua_table.MyUID)
						lua_table.is_knockback = true
						start_knockback = true
					end
				
					if knockback_timer + 1000 <= lua_table.System:GameTime() * 1000 then
						lua_table.System:LOG("KB FINISH")
						lua_table.GameObject:DestroyGameObject(lua_table.MyUID) -- Delete GO from scene
					end
					
				end
		
				if script.collider_effect == attack_effects.taunt then ---------------------------------------------------- React to taunt effect
					
				end
	
			else
				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
				lua_table.System:LOG("Hit registered")
			end
		end
    end
end

function lua_table:OnCollisionEnter()
	local collider = lua_table.Physics:OnCollisionEnter(lua_table.MyUID)
	
end

function lua_table:RequestedTrigger(collider_GO)
	lua_table.System:LOG("RequestedTrigger activated")

	local script = lua_table.GameObject:GetScript(collider_GO)
	
	if lua_table.currentState ~= State.DEATH then

		lua_table.health = lua_table.health - script.collider_damage

		if script.collider_effect ~= attack_effects.none then
			
			if script.collider_effect == attack_effects.stun then ----------------------------------------------------- React to stun effect
				start_stun = true
				lua_table.currentState = State.STUNNED
				lua_table.System:LOG("Zomboid state: STUNNED (5)")  
			end
	
			if script.collider_effect == attack_effects.knockback then ------------------------------------------------ React to kb effect
				
			end
	
			if script.collider_effect == attack_effects.taunt then ---------------------------------------------------- React to taunt effect
				
			end

		else
			lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
			lua_table.System:LOG("Hit registered")
		end
	end
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
	lua_table.Animations:PlayAnimation("Idle", 30.0, lua_table.MyUID)
	lua_table.System:LOG("Zomboid state: IDLE (0)") 
	lua_table.health = lua_table.max_hp

	-- Initialize Nav
	navID = lua_table.Recast:GetAreaFromName("Walkable")
	
end

function lua_table:Update()

	SearchPlayers() -- Constantly calculate distances between entity and players

	-- Check if our entity is dead
	if lua_table.health <= 0 then 
		lua_table.currentState = State.DEATH
		lua_table.System:LOG("Zomboid state: Death (5)")
	end

	-- ResetX values when currentState ~= State.X
	if lua_table.currentState ~= State.SEEK then
		ResetNavigation()
	end
	if lua_table.currentState ~= State.JUMP then 
		ResetJumpStun()
	end
	if lua_table.currentState ~= State.COMBO then
		ResetCombo()
	end
	if lua_table.currentState ~= State.STUNNED then
		ResetStun()
	end

	-- Check which state the entity is in and then handle them accordingly
	if lua_table.currentState == State.IDLE then -- Initial state is always idle --and lua_table.is_stunned == false
		Idle()
	elseif lua_table.currentState == State.SEEK then -- and lua_table.is_stunned == false 
		Seek()
	elseif lua_table.currentState == State.JUMP then    	
		JumpStun()
	elseif lua_table.currentState == State.COMBO then    	-- and not lua_table.is_stunned == false
		Combo()
	elseif lua_table.currentState == State.KNOCKBACK then    	-- and not lua_table.is_stunned == false
		KnockBack()
	elseif lua_table.currentState == State.STUNNED then    	-- and not lua_table.is_stunned == false
		Stun()
	elseif lua_table.currentState == State.DEATH then	
		Die()
	end

	-- Apply knockback to target, stun it for a second, then return to SEEK


	------------------------------------------ TEST STUN
	if lua_table.Input:KeyUp("s") then
		
		lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
		start_stun = true
		lua_table.currentState = State.STUNNED
		
		lua_table.System:LOG("Zomboid state: STUNNED (5)")  
	end

	------------------------------------------------ TEST KD
	if lua_table.Input:KeyUp("d") then
		local knock_vector = {0, 0, 0}
		knock_vector[1] = lua_table.GhoulPos[1] - lua_table.currentTargetPos[1]
		knock_vector[2] = lua_table.GhoulPos[2] - lua_table.currentTargetPos[2]
		knock_vector[3] = lua_table.GhoulPos[3] - lua_table.currentTargetPos[3]
						
 		local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

		knock_force[1] = knock_vector[1] / module
		knock_force[2] = knock_vector[2]
		knock_force[3] = knock_vector[3] / module

		lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

		lua_table.currentState = State.KNOCKBACK
		start_knockback = true
		lua_table.is_knockback = true
		lua_table.System:LOG("Zomboid state: KNOCKBACK (4)") 
	
	end
	
end

return lua_table
end