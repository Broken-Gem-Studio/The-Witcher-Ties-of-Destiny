function GetTableTitan_v01()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Transform = Scripting.Transform()
lua_table.Physics =  Scripting.Physics()
lua_table.Animations = Scripting.Animations()
lua_table.Recast = Scripting.Navigation()
lua_table.Particles = Scripting.Particles()
lua_table.Audio = Scripting.Audio()
lua_table.Material = Scripting.Materials()
-- DEBUG PURPOSES. COMMENT BELOW WHEN NOT USING
--lua_table.Input = Scripting.Inputs()

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
	PUNCH = 3,
	SWIPE = 4,
	SMASH = 5,
	KNOCKBACK = 6,
	STUNNED = 7,
	DEATH = 8
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
-- Titan values 
lua_table.MyUID = 0 --Entity UID
lua_table.max_hp = 800
lua_table.health = 0
lua_table.speed = 5
lua_table.knock_speed = 17
lua_table.currentState = 0
lua_table.is_stunned = false
lua_table.is_taunt = false
lua_table.is_knockback = false
lua_table.is_dead = false
	
--------------------------------- Aggro values 
lua_table.AggroRange = 35
lua_table.minDistance = 4 -- If entity is inside this distance, then attack
lua_table.jumpDistance = 8
--
lua_table.stun_duration = 3000

--------------------------------- Damage values || TOTAL DMG = 100
local Stun_DMG = 10
local Punch_DMG = 15
local Swipe_DMG = 25
local Smash_DMG = 50

--------------------------------- Time management
local start_idle = false

local start_jump = false
local jump_timer = 0

-- 3 attack timers
local start_punch = false
local punch_timer = 0

local start_swipe = false
local swipe_timer = 0

local start_smash = false
local smash_timer = 0

--Special status timers
local start_hit = false
local hit_timer = 0

local start_stun = false
local stun_timer = 0

local start_knockback = false
local knockback_timer = 0

local start_taunt = false
local taunt_timer = 0

local start_death = false
local death_timer = 0

local start_hit = false
local hit_timer = 0

local start_material = false
local material_timer = 0

-- Jump Cooldown
lua_table.can_jump = true
local jump_cd = 0

-- Navigation timer
local start_navigation = true
local navigation_timer = 0

-- Recast navigation
local navID = 0
local corners = {}
local vec = { 0, 0, 0 }
local currCorner = 2
local path_distance = -1

-- To calculate Player positions
local GC1 = 0
local GC2 = 0

local JC1 = 0
local JC2 = 0

local knock_force = {0, 0, 0}

--------------------------------- Flow control conditionals
local jumping = false
local stunning = false
local speed_up = false
local punching = false
local swiping = false
local smashing = false
local play_particles = true
local has_died = false

local rand_death_time = 0

--------------------------------- Entity colliders
local is_front_active = false
local is_area_active = false

local Front_Att_Coll = 0
local Stun_Coll = 0
lua_table.collider_damage = 0
lua_table.collider_effect = 0

--------------------------------- Entity particles
local General_Emitter_UID = 0
local MyMesh_UID = 0
local curr_dmg_dealer = 0

local dt = 0

-- ______________________SCRIPT FUNCTIONS______________________

local function ResetNavigation()
	currCorner = 2
	start_navigation = true
end

local function ResetJumpStun()
	-- Timer
	if start_jump == true then start_jump = false end
	if jump_timer > 0 then jump_timer = 0 end
	-- Control bools
	if jumping == true then jumping = false end
	if speed_up == true then speed_up = false end 
	if stunning == true then stunning = false end
	if play_particles == false then play_particles = true end
end

local function ResetPunch()
	if start_punch == true then start_punch = false end
	if punch_timer > 0 then punch_timer = 0 end
	if punching == true then punching = false end
end

local function ResetSwipe()
	if start_swipe == true then start_swipe = false end
	if swipe_timer > 0 then swipe_timer = 0 end
	if swiping == true then swiping = false end
end

local function ResetSmash()
	if start_smash == true then start_smash = false end
	if smash_timer > 0 then smash_timer = 0 end
	if smashing == true then smashing = false end
end

local function ResetStun()
	if start_stun == true then start_stun = false end
	if stun_timer > 0 then stun_timer = 0 end
end

local function ResetKnockBack()
	if start_knockback == true then start_knockback = false end
	if knockback_timer > 0 then knockback_timer = 0 end
end

local function SearchPlayers() -- Check if targets are within range

	local GeraltState = lua_table.GameObject:GetScript(lua_table.geralt)
	local JaskierState = lua_table.GameObject:GetScript(lua_table.jaskier)

	lua_table.GeraltPos = lua_table.Transform:GetPosition(lua_table.geralt)
	lua_table.JaskierPos = lua_table.Transform:GetPosition(lua_table.jaskier)
	lua_table.TitanPos = lua_table.Transform:GetPosition(lua_table.MyUID)
	
	GC1 = lua_table.GeraltPos[1] - lua_table.TitanPos[1]
	GC2 = lua_table.GeraltPos[3] - lua_table.TitanPos[3]

	if GeraltState.current_state > -3 then
		lua_table.GeraltDistance = math.sqrt(GC1 ^ 2 + GC2 ^ 2)
	else 
		lua_table.GeraltDistance = -1
	end

	JC1 = lua_table.JaskierPos[1] - lua_table.TitanPos[1]
	JC2 = lua_table.JaskierPos[3] - lua_table.TitanPos[3]
	
	if JaskierState.current_state > -3 then
		lua_table.JaskierDistance =  math.sqrt(JC1 ^ 2 + JC2 ^ 2)
	else 
		lua_table.JaskierDistance = -1
	end

	-- Handle Taunt
	if lua_table.is_taunt then 
		lua_table.currentTarget = lua_table.jaskier
		lua_table.currentTargetDir = lua_table.JaskierDistance
		lua_table.currentTargetPos = lua_table.JaskierPos
	end

	if lua_table.GeraltDistance ~= -1 and lua_table.is_taunt == false then -- Geralt alive and Jaskier dead
		if lua_table.JaskierDistance == - 1 or lua_table.GeraltDistance < lua_table.JaskierDistance then
			lua_table.currentTarget = lua_table.geralt
			lua_table.currentTargetDir = lua_table.GeraltDistance
			lua_table.currentTargetPos = lua_table.GeraltPos
		end
	end

	if lua_table.JaskierDistance ~= -1 and lua_table.is_taunt == false then -- Jaskier alive and Geralt dead
		if lua_table.GeraltDistance == - 1 or lua_table.JaskierDistance < lua_table.GeraltDistance then
			lua_table.currentTarget = lua_table.jaskier
			lua_table.currentTargetDir = lua_table.JaskierDistance
			lua_table.currentTargetPos = lua_table.JaskierPos
		end
	end

	if lua_table.GeraltDistance == -1 and lua_table.JaskierDistance == -1 then
		AttackColliderShutdown()
		lua_table.currentTarget = -1
		lua_table.currentTargetDir = -1
		lua_table.currentTargetPos = -1
	end

end

local function ToggleCollider(ID, start, finish, timer, condition, dmg, effect)

	lua_table.collider_effect = effect
	lua_table.collider_damage = dmg
		
	condition = true

	if timer + start < lua_table.System:GameTime() * 1000 and condition then
		lua_table.GameObject:SetActiveGameObject(true, ID)
	end
	if timer + finish < lua_table.System:GameTime() * 1000 then
		lua_table.GameObject:SetActiveGameObject(false, ID)
		condition = false
	end
end

local function AttackColliderShutdown()
	-- if is_front_active then
	-- 		--TODO-Colliders: Check
	-- 	is_front_active = false
	-- end
	-- if is_area_active then
	-- 		--TODO-Colliders: Check
	-- 	is_area_active = false
	-- end

	lua_table.GameObject:SetActiveGameObject(false, Front_Att_Coll)
	lua_table.GameObject:SetActiveGameObject(false, Stun_Coll)
	
end

local function IsTargetInRange()
	if lua_table.currentTargetDir >= lua_table.jumpDistance then
		AttackColliderShutdown()
		lua_table.Animations:PlayAnimation("Walk", 50.0, lua_table.MyUID)
		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Titan state: SEEK (1), target out of range")    
		
		return true
	else 
		return false
	end
end

local function Idle() 
	
	if lua_table.GeraltDistance ~= -1 or lua_table.JaskierDistance ~= -1 then -- if one player is alive
		if lua_table.currentTargetDir <= lua_table.AggroRange then
			lua_table.Animations:PlayAnimation("Walk", 50.0, lua_table.MyUID)
			lua_table.currentState = State.SEEK
			lua_table.System:LOG("Titan state: SEEK (1)") 
		end
	else 
		AttackColliderShutdown()
		lua_table.Animations:PlayAnimation("Idle", 30.0, lua_table.MyUID)

	end
	
end
	
local function Seek()
	
	AttackColliderShutdown()
	-- Now we get the direction vector and then we normalize it and aply a velocity in every component

		if lua_table.currentTargetDir < lua_table.AggroRange and lua_table.currentTargetDir > lua_table.minDistance then
						
		if navigation_timer + 500 <= lua_table.System:GameTime() * 1000 then
			start_navigation = true
		end
		if start_navigation == true then
			corners = lua_table.Recast:CalculatePath(lua_table.TitanPos[1], lua_table.TitanPos[2], lua_table.TitanPos[3], lua_table.currentTargetPos[1], lua_table.currentTargetPos[2], lua_table.currentTargetPos[3], 1 << navID)
			navigation_timer = lua_table.System:GameTime() * 1000
			start_navigation = false
			currCorner = 2
		end
		
		local nextCorner = {0, 0, 0}
		nextCorner[1] = corners[currCorner][1] - lua_table.TitanPos[1]
		nextCorner[2] = corners[currCorner][2] - lua_table.TitanPos[2]
		nextCorner[3] = corners[currCorner][3] - lua_table.TitanPos[3]

		path_distance = math.sqrt(nextCorner[1] ^ 2 + nextCorner[3] ^ 2)
		
		if path_distance > 0.5 then 

			vec[1] = nextCorner[1] / path_distance
			vec[2] = 0
			vec[3] = nextCorner[3] / path_distance
				
			-- Apply movement vector to move character
			lua_table.Transform:LookAt(corners[currCorner][1], lua_table.TitanPos[2], corners[currCorner][3], lua_table.MyUID)
			lua_table.Physics:Move(vec[1] * lua_table.speed * dt, vec[3] * lua_table.speed * dt, lua_table.MyUID)
			
			else
				currCorner = currCorner + 1
				lua_table.Physics:Move(0, 0, lua_table.MyUID)
		end
			
	end
	
	if lua_table.currentTargetDir <= lua_table.minDistance and lua_table.can_jump == true then
		lua_table.currentState = State.JUMP
		lua_table.System:LOG("Titan state: JUMP (2)")
	elseif lua_table.currentTargetDir <= lua_table.minDistance and lua_table.can_jump == false then
		lua_table.currentState = State.PUNCH
		lua_table.System:LOG("Titan state: Punch (3)")
	end
end

	
local function JumpStun() -- Smash the ground with a jump, then stun

	-- Mark the affected area
	if not start_jump and lua_table.can_jump == true then 

		jump_timer = lua_table.System:GameTime() * 1000

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Circle_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_scream_attack")
		lua_table.can_jump = false
		start_jump = true
		
	end
	-- Play jump anticipation
	if jump_timer <= lua_table.System:GameTime() * 1000 and jumping == false then
		lua_table.System:LOG("Jump")
		lua_table.Animations:PlayAnimation("Jump_Stun_1", 50.0, lua_table.MyUID)
		jumping = true
	end
	-- Play actual jump
	if jump_timer + 500 <= lua_table.System:GameTime() * 1000 and stunning == false then
		lua_table.System:LOG("Land and stun")
		lua_table.Animations:PlayAnimation("Jump_Stun_2", 25.0, lua_table.MyUID)
		stunning = true
	end

	-- Accelerate the fall
	if jump_timer + 800 <= lua_table.System:GameTime() * 1000 and speed_up == false then
		lua_table.Animations:SetCurrentAnimationSpeed(40.0, lua_table.MyUID)
		lua_table.System:LOG("fucking speeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeed")
		speed_up = true
	end

	-- Apply the damage/effect by the jump
	ToggleCollider(Stun_Coll, 1250, 1350, jump_timer, is_area_active, Stun_DMG, attack_effects.stun)

	-- Leave crack in the ground
	if jump_timer + 1250 <= lua_table.System:GameTime() * 1000 and play_particles == true then

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Circle_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:StopParticleEmitter(particles[i])
		end
	
		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Jump_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:PlayParticleEmitter(particles[i])
		end
		
		play_particles = false
	end
		
	if jump_timer + 1850 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.PUNCH
		lua_table.System:LOG("Titan state: PUNCH (3)")  
	end
end
	
local function Punch()

	if IsTargetInRange() == true then
		return 
	end

	if not start_punch then 
		punch_timer = lua_table.System:GameTime() * 1000
		start_punch = true
	end

	lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.TitanPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if punch_timer <= lua_table.System:GameTime() * 1000 and not punching then
		lua_table.System:LOG("Punch to target")
		lua_table.Animations:PlayAnimation("Punch", 40.0, lua_table.MyUID)
		lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_scream_attack")
		punching = true
	end

	ToggleCollider(Front_Att_Coll, 900, 1000, punch_timer, is_front_active, Punch_DMG, attack_effects.none)
	
	-- After its finished, switch state
	if punch_timer + 1100 <= lua_table.System:GameTime() * 1000 then
		if IsTargetInRange() == true then
			return 
		else 
			lua_table.currentState = State.SWIPE
		end
		
	end
	
end

local function Swipe()

	if not start_swipe then 
		swipe_timer = lua_table.System:GameTime() * 1000
		start_swipe = true
	end

	lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.TitanPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if swipe_timer <= lua_table.System:GameTime() * 1000 and not swiping then
		lua_table.System:LOG("Swipe to target")
		lua_table.Animations:PlayAnimation("Swipe", 45.0, lua_table.MyUID)
		lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_scream_attack")
		swiping = true
	end

	ToggleCollider(Front_Att_Coll, 1250, 1350, swipe_timer, is_front_active, Swipe_DMG, attack_effects.none)
	
	-- After its finished, switch state
	if swipe_timer + 1450 <= lua_table.System:GameTime() * 1000 then

		if IsTargetInRange() == true then
			return 
		else 
			lua_table.currentState = State.SMASH
		end
		
		lua_table.System:LOG("Titan state: SEEK (1), cycle to jump")
	end
end

local function Smash()

	if not start_smash then 
		smash_timer = lua_table.System:GameTime() * 1000
		start_smash = true
	end

	lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.TitanPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if smash_timer <= lua_table.System:GameTime() * 1000 and not smashing then
		lua_table.System:LOG("Crush to target")
		lua_table.Animations:PlayAnimation("Smash", 50.0, lua_table.MyUID)
		lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_scream_attack")
		smashing = true
	end

	ToggleCollider(Front_Att_Coll, 1100, 1200, smash_timer, is_front_active, Smash_DMG, attack_effects.none)

	-- After its finished, switch state
	if smash_timer + 1400 <= lua_table.System:GameTime() * 1000 then
		lua_table.Animations:PlayAnimation("Walk", 50.0, lua_table.MyUID)
		lua_table.currentState = State.SEEK
		lua_table.System:LOG("Titan state: SEEK (1), cycle to jump")
	end

end


local function Stun()
	if start_stun then 
		stun_timer = lua_table.System:GameTime() * 1000

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Stun_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		start_stun = false
	end

	if stun_timer + lua_table.stun_duration <= lua_table.System:GameTime() * 1000 then

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Stun_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:StopParticleEmitter(particles[i])
		end

		
		lua_table.is_knockback = false
		
		lua_table.Animations:PlayAnimation("Walk", 50.0, lua_table.MyUID)
		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Titan state: SEEK (1), from stun")
	end
	
end

local function KnockBack()
	if start_knockback then 
		knockback_timer = lua_table.System:GameTime() * 1000
		start_knockback = false
	end

	if knockback_timer + 1500 <= lua_table.System:GameTime() * 1000 then
		lua_table.Animations:PlayAnimation("Walk", 50.0, lua_table.MyUID)
		lua_table.currentState = State.SEEK
		lua_table.System:LOG("Titan state: STUNNED (5), from KD")
	else 
		lua_table.Physics:Move(knock_force[1] * lua_table.knock_speed * dt, knock_force[3] * lua_table.knock_speed * dt, lua_table.MyUID)

	end
	
end

local function Die()

	rand_death_time = math.random(45, 60)

	if not start_death then 

		lua_table.Physics:SetActiveController(false, lua_table.MyUID)

		death_timer = lua_table.System:GameTime() * 1000

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Death_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		lua_table.Animations:PlayAnimation("Death", rand_death_time, lua_table.MyUID)
		start_death = true
	end

	if death_timer + 7000 <= lua_table.System:GameTime() * 1000 then
		lua_table.GameObject:DestroyGameObject(lua_table.MyUID) -- Delete GO from scene
	end
	
end

local function ReactToStun(passed_player, player_script)
	
	AttackColliderShutdown()
	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

	-- Update stun time according to passed value
	if player_script.collider_stun_duration ~= nil then
		lua_table.stun_duration = player_script.collider_stun_duration
	end

	if passed_player == lua_table.geralt then
		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Blood_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
			lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		------- Stun dmg marker
		if player_script.geralt_score ~= nil then
			if player_script.geralt_score[1] ~= nil then
				player_script.geralt_score[1] = player_script.geralt_score[1] + player_script.collider_damage
		    end
		end

		------- Actual stun dmg marker
		if player_script.geralt_score ~= nil then
			if player_script.geralt_score[4] ~= nil then
				player_script.geralt_score[4] = player_script.geralt_score[4] + 1
		    end
		end

	else 
		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Hit_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
			lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		------- Stun dmg marker
		if player_script.jaskier_score ~= nil then
			if player_script.jaskier_score[1] ~= nil then
				player_script.jaskier_score[1] = player_script.jaskier_score[1] + player_script.collider_damage
		    end
		end

		------- Actual stun dmg marker
		if player_script.jaskier_score ~= nil then
			if player_script.jaskier_score[4] ~= nil then
				player_script.jaskier_score[4] = player_script.jaskier_score[4] + 1
		    end
		end
	end

	lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_take_damage")

	start_stun = true
	lua_table.currentState = State.STUNNED
	
	lua_table.System:LOG("Titan state: STUNNED (5)")  

end

local function ReactToKB(my_script) --col_ID, forward
	AttackColliderShutdown()

	--local tmp = lua_table.Transform:GetPosition(col_ID)

	lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_take_damage")
	-- local knock_vector = {0, 0, 0}

	-- if forward == true then
	-- 	knock_vector[1] = lua_table.TitanPos[1] - tmp[1]
	-- 	knock_vector[2] = lua_table.TitanPos[2] - tmp[2]
	-- 	knock_vector[3] = lua_table.TitanPos[3] - tmp[3]
	-- else
	-- 	knock_vector[1] = tmp[1] - lua_table.TitanPos[1]
	-- 	knock_vector[2] = tmp[2] - lua_table.TitanPos[2]
	-- 	knock_vector[3] = tmp[3] - lua_table.TitanPos[3]
	-- end

	-- local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

	-- knock_force[1] = knock_vector[1] / module
	-- knock_force[2] = knock_vector[2]
	-- knock_force[3] = knock_vector[3] / module

	if curr_dmg_dealer == lua_table.geralt then
		------- Stun dmg marker
		if my_script.geralt_score ~= nil then
			if my_script.geralt_score[1] ~= nil then
				my_script.geralt_score[1] = my_script.geralt_score[1] + my_script.collider_damage
		    end
		end

		------- Actual stun dmg marker
		if my_script.geralt_score ~= nil then
			if my_script.geralt_score[4] ~= nil then
				my_script.geralt_score[4] = my_script.geralt_score[4] + 1
		    end
		end

	else 
		------- Stun dmg marker
		if my_script.jaskier_score ~= nil then
			if my_script.jaskier_score[1] ~= nil then
				my_script.jaskier_score[1] = my_script.jaskier_score[1] + my_script.collider_damage
		    end
		end

		------- Actual stun dmg marker
		if my_script.jaskier_score ~= nil then
			if my_script.jaskier_score[4] ~= nil then
				my_script.jaskier_score[4] = my_script.jaskier_score[4] + 1
		    end
		end
	end


	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

	lua_table.currentState = State.KNOCKBACK
	start_knockback = true
	lua_table.is_knockback = true
	lua_table.System:LOG("Titan state: KNOCKBACK (4)") 

end

local function ReactToTaunt(my_script)
	AttackColliderShutdown()

	start_taunt = true

	if start_taunt then 
		taunt_timer = lua_table.System:GameTime() * 1000

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Taunt_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
			lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		------- Stun dmg marker
		if my_script.jaskier_score ~= nil then
			if my_script.jaskier_score[1] ~= nil then
				my_script.jaskier_score[1] = my_script.jaskier_score[1] + my_script.collider_damage
		    end
		end

		------- Actual stun dmg marker
		if my_script.jaskier_score ~= nil then
			if my_script.jaskier_score[4] ~= nil then
				my_script.jaskier_score[4] = my_script.jaskier_score[4] + 1
		    end
		end

		lua_table.is_taunt = true
		lua_table.System:LOG("Getting taunted by Jaskier") 
		start_taunt = false
	end
end

local function ReactToHeavyHit(passed_player, my_script)
	AttackColliderShutdown()
				
	start_hit = true
	hit_timer = lua_table.System:GameTime() * 1000
	
	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
	lua_table.Audio:PlayAudioEvent("Play_Titan_ghoul_take_damage")
	
	if passed_player == lua_table.geralt then
		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Blood_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
			lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		------- Actual stun dmg marker
		if my_script.geralt_score ~= nil then
			if my_script.geralt_score[1] ~= nil then
				my_script.geralt_score[1] = my_script.geralt_score[1] + my_script.collider_damage
		    end
		end

	else 
		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Hit_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
			lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		------- Actual stun dmg marker
		if my_script.jaskier_score ~= nil then
			if my_script.jaskier_score[1] ~= nil then
				my_script.jaskier_score[1] = my_script.jaskier_score[1] + my_script.collider_damage
		    end
		end

	end

	lua_table.System:LOG("Heavy hit registered")
end

-- ______________________COLLISIONS______________________
function lua_table:OnTriggerEnter()	
	local collider = lua_table.Physics:OnTriggerEnter(lua_table.MyUID)
	local layer = lua_table.GameObject:GetLayerByID(collider)

	if layer == layers.player_attack then 
		local parent = lua_table.GameObject:GetGameObjectParent(collider)
		local script = lua_table.GameObject:GetScript(parent)
		local player_state = script.current_state

		lua_table.health = lua_table.health - script.collider_damage

		curr_dmg_dealer = parent
		
		lua_table.Material:SetMaterialByName("HitMaterial.mat", MyMesh_UID)
        material_timer = lua_table.System:GameTime() * 1000
		start_material  = true

		if lua_table.currentState ~= State.DEATH then

			if script.collider_effect ~= attack_effects.none then
				
				if script.collider_effect == attack_effects.stun then ---------------- React to stun effect
					ReactToStun(parent, script)

				elseif script.collider_effect == attack_effects.knockback then  ------ React to kb effect
					ReactToKB(script)

				elseif script.collider_effect == attack_effects.taunt then ----------- React to taunt effect
					ReactToTaunt(script)

				end
	
			else
				if player_state >= 14 and lua_table.currentState ~= State.JUMP then -- State == heavy_1/heavy_2/heavy_3 and combos cancel animation
					ReactToHeavyHit(parent, script)
					
				else --if player_state <= 13 then // Light/Medium attacks
					

					if parent == lua_table.geralt then
						local particles = {}
						particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Blood_Emitter", General_Emitter_UID))
						for i = 1, #particles do 
						    lua_table.Particles:PlayParticleEmitter(particles[i])
						end

						------- Actual stun dmg marker
						if script.geralt_score ~= nil then
							if script.geralt_score[1] ~= nil then
								script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
						    end
						end

					else 
						local particles = {}
						particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Hit_Emitter", General_Emitter_UID))
						for i = 1, #particles do 
						    lua_table.Particles:PlayParticleEmitter(particles[i])
						end

						------- Actual stun dmg marker
						if script.jaskier_score ~= nil then
							if script.jaskier_score[1] ~= nil then
								script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
						    end
						end

					end

					lua_table.System:LOG("Light/Medium registered")
				end
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

	curr_dmg_dealer = collider_GO

	lua_table.health = lua_table.health - script.collider_damage
	
	if lua_table.currentState ~= State.DEATH and lua_table.currentState ~= State.JUMP then

		
		if script.collider_effect ~= attack_effects.none then
			
			if script.collider_effect == attack_effects.stun then ---------------- React to stun effect
				ReactToStun(collider_GO, script)

			elseif script.collider_effect == attack_effects.knockback then ------- React to kb effect
				ReactToKB(script)

			elseif script.collider_effect == attack_effects.taunt then ----------- React to taunt effect
				ReactToTaunt(script)

			end

		else
			if player_state >= 14 and lua_table.currentState ~= State.JUMP then -- State == heavy_1/heavy_2/heavy_3 and combos cancel animation
				ReactToHeavyHit(collider_GO, script)

			else --if player_state <= 13 then // Light/Medium attacks

				if collider_GO == lua_table.geralt then
					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Blood_Emitter", General_Emitter_UID))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end

					------- Actual stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[1] ~= nil then
							script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
					    end
					end

				else 
					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Hit_Emitter", General_Emitter_UID))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end

					------- Actual stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[1] ~= nil then
							script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
					    end
					end

				end

				lua_table.System:LOG("Hit registered")
			end
		end
	end
end

-- ______________________MAIN CODE______________________
function lua_table:Awake()
	lua_table.System:LOG("Titan AWAKE")

	General_Emitter_UID = lua_table.GameObject:FindChildGameObject("Titan_General_Emitter")

end

function lua_table:Start()
	lua_table.System:LOG("Titan START")

	-- Getting Entity and Player UIDs
	lua_table.MyUID = lua_table.GameObject:GetMyUID()
	lua_table.geralt = lua_table.GameObject:FindGameObject("Geralt")
	lua_table.jaskier = lua_table.GameObject:FindGameObject("Jaskier")

	--Getting Mesh UID
	MyMesh_UID = lua_table.GameObject:FindChildGameObject("Titan_LowPo")

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
	lua_table.System:LOG("Titan state: IDLE (0)") 
	lua_table.health = lua_table.max_hp

	-- Get colliders
	Front_Att_Coll = lua_table.GameObject:FindChildGameObject("Titan_Front_Att")
	Stun_Coll = lua_table.GameObject:FindChildGameObject("Titan_Area")
	

	-- Initialize Nav
	navID = lua_table.Recast:GetAreaFromName("Walkable")
	
end

function lua_table:Update()

	dt = lua_table.System:DT()

	if lua_table.health <= 0 and has_died == false then 

		local score = lua_table.GameObject:GetScript(curr_dmg_dealer)

		if curr_dmg_dealer == lua_table.geralt then
			if score.geralt_score ~= nil then
				if score.geralt_score[3] ~= nil then
					score.geralt_score[3] = score.geralt_score[3] + 1
				end
			end
		else 
			if score.jaskier_score ~= nil then
				if score.jaskier_score[3] ~= nil then
					score.jaskier_score[3] = score.jaskier_score[3] + 1
				end
			end
		end 

		lua_table.currentState = State.DEATH
		lua_table.System:LOG("Titan state: Death (6)")
		has_died = true
	end

	SearchPlayers() -- Constantly calculate distances between entity and players

	if lua_table.currentTarget == -1  and lua_table.currentTargetDir == -1 and lua_table.currentTargetPos == -1 then 
		lua_table.currentState = State.IDLE
		lua_table.currentTarget = 0
		lua_table.currentTargetDir = 0
		lua_table.currentTargetPos = 0
	end

	-- Falling enemy fail save, kill it
	if lua_table.TitanPos[2] <= -100 then lua_table.GameObject:DestroyGameObject(lua_table.MyUID) end

	-- Check which state the entity is in and then handle them accordingly
	if lua_table.currentState == State.IDLE then 
		Idle()
	elseif lua_table.currentState == State.SEEK then 
		Seek()
	elseif lua_table.currentState == State.JUMP then    	
		JumpStun()
	elseif lua_table.currentState == State.PUNCH then    	
		Punch()
	elseif lua_table.currentState == State.SWIPE then    	
		Swipe()
	elseif lua_table.currentState == State.SMASH then    	
		Smash()
	elseif lua_table.currentState == State.KNOCKBACK then   
		KnockBack()
	elseif lua_table.currentState == State.STUNNED then   
		Stun()
	elseif lua_table.currentState == State.DEATH then	
		Die()
	end

	-- ResetX values when currentState ~= State.X
	if lua_table.currentState ~= State.SEEK then
		ResetNavigation()
	end
	if lua_table.currentState ~= State.JUMP then 
		ResetJumpStun()
	end
	if lua_table.currentState ~= State.PUNCH then
		ResetPunch()
	end
	if lua_table.currentState ~= State.SWIPE then
		ResetSwipe()
	end
	if lua_table.currentState ~= State.SMASH then
		ResetSmash()
	end
	if lua_table.currentState ~= State.KNOCKBACK then
		ResetKnockBack()
	end
	if lua_table.currentState ~= State.STUNNED then
		ResetStun()
	end

	-- Manual reset for taunt state
	if taunt_timer + 5000 <= lua_table.System:GameTime() * 1000 then

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Titan_Taunt_Emitter", General_Emitter_UID))
		for i = 1, #particles do 
		    lua_table.Particles:StopParticleEmitter(particles[i])
		end

		lua_table.is_taunt = false
		start_taunt = false	
		taunt_timer = 0
	
	end

	-- Manual reset for hit state
	if hit_timer + 1500 <= lua_table.System:GameTime() * 1000 and start_hit == true then
		start_hit = false
	end

	-- Manual reset for hit state
	if material_timer + 50 <= lua_table.System:GameTime() * 1000 and start_material == true then
		lua_table.Material:SetMaterialByName("TitanBase_Material.mat", MyMesh_UID)
		start_material = false
	end

	-- Begin jump cooldown
	if lua_table.can_jump == false then -- 10 sec CD
		jump_cd = jump_cd + dt

		if jump_cd >= 10 then
			lua_table.can_jump = true
			jump_cd = 0
		end
	end

	

------------------------------------------------
---------------------TESTS----------------------
------------------------------------------------
	-- ------------------------------------------------ TEST STUN
	-- if lua_table.Input:KeyUp("s") then
		
	-- 	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
	-- 	start_stun = true
	-- 	lua_table.currentState = State.STUNNED
		
	-- 	lua_table.System:LOG("Titan state: STUNNED (5)")  
	-- end

	-- ------------------------------------------------ TEST KD
	-- -- Apply knockback to target, stun it for a second, then return to SEEK
	-- if lua_table.Input:KeyUp("d") then
	-- 	local knock_vector = {0, 0, 0}
	-- 	knock_vector[1] = lua_table.TitanPos[1] - lua_table.currentTargetPos[1]
	-- 	knock_vector[2] = lua_table.TitanPos[2] - lua_table.currentTargetPos[2]
	-- 	knock_vector[3] = lua_table.TitanPos[3] - lua_table.currentTargetPos[3]
						
	 -- 	local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

	-- 	knock_force[1] = knock_vector[1] / module
	-- 	knock_force[2] = knock_vector[2]
	-- 	knock_force[3] = knock_vector[3] / module

	-- 	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

	-- 	lua_table.currentState = State.KNOCKBACK
	-- 	start_knockback = true
	-- 	lua_table.is_knockback = true
	-- 	lua_table.System:LOG("Titan state: KNOCKBACK (4)") 
	
	-- end
	-- ------------------------------------------------ TEST TAUNT
	-- if lua_table.Input:KeyUp("t") then
	-- 	start_taunt = true

	-- 	if start_taunt then 
	-- 		taunt_timer = lua_table.System:GameTime() * 1000
	-- 		lua_table.PlayParticleEmitter(TauntedEmitter_UID)
	-- 		lua_table.is_taunt = true
	-- 		lua_table.System:LOG("Getting taunted by Jaskier") 
	-- 		start_taunt = false
	-- 	end

	-- end
	
end

return lua_table
end