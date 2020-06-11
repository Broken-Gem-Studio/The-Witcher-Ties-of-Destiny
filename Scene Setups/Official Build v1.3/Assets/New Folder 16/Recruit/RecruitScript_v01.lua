function GetTableRecruitScript_v01()
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
-- DEBUG PURPOSES
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
	IDLE = 1,
	SEEK = 2,
	ATTACK = 3,
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
lua_table.max_hp = 120
lua_table.health = 0
lua_table.speed = 7
lua_table.knock_speed = 35
lua_table.currentState = State.IDLE
lua_table.is_stunned = false
lua_table.is_taunt = false
lua_table.is_knockback = false
lua_table.is_dead = false
	
-- Aggro values 
lua_table.AggroRange = 35
lua_table.minDistance = 2.5 -- If entity is inside this distance, then attack
lua_table.maxDistance = 5
--
lua_table.stun_duration = 3000

local knock_force = {0, 0, 0}

-- Time management
local start_attack = false
local attack_timer = 0

local start_knockback = false
local knockback_timer = 0

local start_taunt = false
local taunt_timer = 0

local start_stun = false
local stun_timer = 0

local start_death = false
local death_timer = 0

local start_navigation = true
local navigation_timer = 0

local start_material = false
local material_timer = 0 

-- Flow control conditionals
local attacked = false
local has_died = false

-- Recast navigation
local navID = 0
local corners = {}
local vec = { 0, 0, 0 }
local currCorner = 2
local path_distance = -1

local GC1 = 0
local GC2 = 0

local JC1 = 0
local JC2 = 0

-- Entity colliders
local is_front_active = false
local is_area_active = false

lua_table.Recruit_Front = "Recruit_Front_Attack"
local Front_Collider = 0
lua_table.collider_damage = 0
lua_table.collider_effect = 0

local Recruit_General_Emitter = 0
local Recruit_Material_UID = 0

local random_attack = 0
local random_death_anim = 0
local random_death_time = 0
local dt = 0

local curr_dmg_dealer = 0

-- ______________________SCRIPT FUNCTIONS______________________

local function ResetNavigation()
	currCorner = 2
	start_navigation = true
end

local function ResetAttack()
	-- Attack Timer
	if start_attack == true then start_attack = false end
	if attack_timer > 0 then attack_timer = 0 end
	-- Attack control bools
	if attacked == true then attacked = false end
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
	lua_table.RecruitPos = lua_table.Transform:GetPosition(lua_table.MyUID)
	
	GC1 = lua_table.GeraltPos[1] - lua_table.RecruitPos[1]
	GC2 = lua_table.GeraltPos[3] - lua_table.RecruitPos[3]

	if GeraltState.current_state > -3 then
		lua_table.GeraltDistance = math.sqrt(GC1 ^ 2 + GC2 ^ 2)
	else 
		lua_table.GeraltDistance = -1
	end

	JC1 = lua_table.JaskierPos[1] - lua_table.RecruitPos[1]
	JC2 = lua_table.JaskierPos[3] - lua_table.RecruitPos[3]
	
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
		lua_table.currentState = State.IDLE
	end
end

local function AttackColliderShutdown()
	if is_front_active then
		lua_table.GameObject:SetActiveGameObject(false, Front_Collider)	--TODO-Colliders: Check
		is_front_active = false
	end
end
	
local function Idle() 
	if lua_table.GeraltDistance ~= -1 or lua_table.JaskierDistance ~= -1 then
		if lua_table.currentTargetDir <= lua_table.AggroRange then
			lua_table.currentState = State.SEEK
			lua_table.Animations:PlayAnimation("Run", 45.0, lua_table.MyUID)
			lua_table.System:LOG("Recruit state: SEEK (1)") 
		end
	end
end

local function Seek()
	
	-- Now we get the direction vector and then we normalize it and aply a velocity in every component
	
	if lua_table.currentTargetDir < lua_table.AggroRange and lua_table.currentTargetDir > lua_table.minDistance then
					
		if navigation_timer + 500 <= lua_table.System:GameTime() * 1000 then
			start_navigation = true
		end

		if start_navigation == true then
			corners = lua_table.Recast:CalculatePath(lua_table.RecruitPos[1], lua_table.RecruitPos[2], lua_table.RecruitPos[3], lua_table.currentTargetPos[1], lua_table.currentTargetPos[2], lua_table.currentTargetPos[3], 1 << navID)
			navigation_timer = lua_table.System:GameTime() * 1000
			start_navigation = false
			currCorner = 2
		end

		local nextCorner = {0, 0, 0}
		nextCorner[1] = corners[currCorner][1] - lua_table.RecruitPos[1]
		nextCorner[2] = corners[currCorner][2] - lua_table.RecruitPos[2]
		nextCorner[3] = corners[currCorner][3] - lua_table.RecruitPos[3]

		path_distance = math.sqrt(nextCorner[1] ^ 2 + nextCorner[3] ^ 2)
		
		if path_distance > 0.2 then 

			vec[1] = nextCorner[1] / path_distance
			vec[2] = 0
			vec[3] = nextCorner[3] / path_distance
				
			-- Apply movement vector to move character
			lua_table.Transform:LookAt(corners[currCorner][1], lua_table.RecruitPos[2], corners[currCorner][3], lua_table.MyUID)
			lua_table.Physics:Move(vec[1] * lua_table.speed * dt, vec[3] * lua_table.speed * dt, lua_table.MyUID)
			
			else
				currCorner = currCorner + 1
				lua_table.Physics:Move(0, 0, lua_table.MyUID)
		end
			
	end
	
	if lua_table.currentTargetDir <= lua_table.minDistance then
		lua_table.currentState = State.ATTACK
		lua_table.System:LOG("Recruit state: ATTACK (2)")
	end
end
	
local function Attack()

	if lua_table.currentTargetDir >= lua_table.maxDistance then
		lua_table.currentState = State.SEEK	
		lua_table.System:LOG("Recruit state: SEEK (1), target out of range")    
		lua_table.Animations:PlayAnimation("Run", 45.0, lua_table.MyUID)

		return
	end

	if not start_attack then 
		attack_timer = lua_table.System:GameTime() * 1000
		start_attack = true
	end

	lua_table.Transform:LookAt(lua_table.currentTargetPos[1], lua_table.RecruitPos[2], lua_table.currentTargetPos[3], lua_table.MyUID)

	if attack_timer <= lua_table.System:GameTime() * 1000 and not attacked then

		lua_table.Audio:PlayAudioEvent("Play_Lumberjack_Axe_Swing_Attack")

		random_attack = math.random(1, 2)

		if random_attack == 1 then 
			lua_table.System:LOG("Attack1 chosen")
			lua_table.Animations:PlayAnimation("Attack1", 45.0, lua_table.MyUID)
		elseif random_attack == 2 then 
			lua_table.System:LOG("Attack2 chosen")
			lua_table.Animations:PlayAnimation("Attack2", 45.0, lua_table.MyUID)
		end
		
		attacked = true
	end
	
	if attack_timer + 800 <= lua_table.System:GameTime() * 1000 and attack_timer + 1100 >= lua_table.System:GameTime() * 1000 then
		lua_table.collider_effect = attack_effects.none
		lua_table.collider_damage = 5
		
		is_front_active = true
		lua_table.GameObject:SetActiveGameObject(true, Front_Collider)
	end

	if attack_timer + 900 <= lua_table.System:GameTime() * 1000 then 
		is_front_active = false
		lua_table.GameObject:SetActiveGameObject(false, Front_Collider)
	end
	
	-- After he finished, switch state
	if attack_timer + 1000 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.SEEK	
		lua_table.Animations:PlayAnimation("Run", 45.0, lua_table.MyUID)
		lua_table.System:LOG("Recruit state: SEEK (1), cycle to seek")
	end
	
end

local function Stun()
	if start_stun then

		stun_timer = lua_table.System:GameTime() * 1000
		start_stun = false
	end

	if stun_timer + lua_table.stun_duration <= lua_table.System:GameTime() * 1000 then
		lua_table.Animations:PlayAnimation("Run", 45.0, lua_table.MyUID)

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Stun_Emitter", Recruit_General_Emitter))
		for i = 1, #particles do 
			lua_table.Particles:StopParticleEmitter(particles[i])
		end
	
		lua_table.currentState = State.SEEK	
		lua_table.Animations:PlayAnimation("Run", 45.0, lua_table.MyUID)
		lua_table.System:LOG("Recruit state: SEEK (1), from stun")
	end
	
end

local function KnockBack()
	if start_knockback then 
		knockback_timer = lua_table.System:GameTime() * 1000
		start_knockback = false
	end

	if knockback_timer + 300 <= lua_table.System:GameTime() * 1000 then
		lua_table.currentState = State.SEEK	
		lua_table.Animations:PlayAnimation("Run", 45.0, lua_table.MyUID)
		lua_table.is_knockback = false
		lua_table.System:LOG("Recruit state: STUNNED (5), from KD")
		
	else 
		lua_table.Physics:Move(knock_force[1] * lua_table.knock_speed * dt, knock_force[3] * lua_table.knock_speed * dt, lua_table.MyUID)

	end
	
end

local function Die()

	random_death_time = math.random(45, 60)
	random_death_anim = math.random(1, 2)

	if not start_death then 
		death_timer = lua_table.System:GameTime() * 1000

		lua_table.Physics:SetActiveController(false, lua_table.MyUID)

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Taunt_Emitter", Recruit_General_Emitter))
		for i = 1, #particles do 
			lua_table.Particles:StopParticleEmitter(particles[i])
		end

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Stun_Emitter", Recruit_General_Emitter))
		for i = 1, #particles do 
			lua_table.Particles:StopParticleEmitter(particles[i])
		end
		
		if random_death_anim == 1 then
			lua_table.Animations:PlayAnimation("Death_1", random_death_time, lua_table.MyUID)
		elseif random_death_anim == 2 then
			lua_table.Animations:PlayAnimation("Death_2", random_death_time, lua_table.MyUID)
		end
		
		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Death_Emitter", Recruit_General_Emitter))
		for i = 1, #particles do 
		    lua_table.Particles:PlayParticleEmitter(particles[i])
		end

		start_death = true
	end

	if death_timer + 3000 <= lua_table.System:GameTime() * 1000 then
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

			curr_dmg_dealer = parent

			lua_table.Material:SetMaterialByName("HitMaterial.mat", Recruit_Material_UID)
      		material_timer = lua_table.System:GameTime() * 1000
			start_material  = true

			lua_table.Audio:PlayAudioEvent("Play_Enemy_Humanoid_Hit")
	
			if script.collider_effect ~= attack_effects.none then
				
				if script.collider_effect == attack_effects.stun then ----------------------------------------------------- React to stun effect
					AttackColliderShutdown()
					lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

					if script.collider_stun_duration ~= nil then
						lua_table.stun_duration = script.collider_stun_duration
					end

					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Stun_Emitter", Recruit_General_Emitter))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end

					if parent == lua_table.geralt then
						------- Stun dmg marker
						if script.geralt_score ~= nil then
							if script.geralt_score[1] ~= nil then
								script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
							end
						end
				
						------- Actual stun dmg marker
						if script.geralt_score ~= nil then
							if script.geralt_score[4] ~= nil then
								script.geralt_score[4] = script.geralt_score[4] + 1
							end
						end
				
					else 
						------- Stun dmg marker
						if script.jaskier_score ~= nil then
							if script.jaskier_score[1] ~= nil then
								script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
							end
						end
				
						------- Actual stun dmg marker
						if script.jaskier_score ~= nil then
							if script.jaskier_score[4] ~= nil then
								script.jaskier_score[4] = script.jaskier_score[4] + 1
							end
						end
					end

					start_stun = true
					lua_table.currentState = State.STUNNED
							
					lua_table.System:LOG("Recruit state: STUNNED (5)")  
				
				elseif script.collider_effect == attack_effects.knockback then ------------------------------------------------ React to kb effect
					AttackColliderShutdown()

					if parent == lua_table.geralt then
						local particles = {}
						particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Blood_Emitter", Recruit_General_Emitter))
						for i = 1, #particles do 
							lua_table.Particles:PlayParticleEmitter(particles[i])
						end
				
					else 
						local particles = {}
						particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Hit_Emitter", Recruit_General_Emitter))
						for i = 1, #particles do 
							lua_table.Particles:PlayParticleEmitter(particles[i])
						end
					end

					if parent == lua_table.geralt then
						------- Stun dmg marker
						if script.geralt_score ~= nil then
							if script.geralt_score[1] ~= nil then
								script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
							end
						end
				
						------- Actual stun dmg marker
						if script.geralt_score ~= nil then
							if script.geralt_score[4] ~= nil then
								script.geralt_score[4] = script.geralt_score[4] + 1
							end
						end
				
					else 
						------- Stun dmg marker
						if script.jaskier_score ~= nil then
							if script.jaskier_score[1] ~= nil then
								script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
							end
						end
				
						------- Actual stun dmg marker
						if script.jaskier_score ~= nil then
							if script.jaskier_score[4] ~= nil then
								script.jaskier_score[4] = script.jaskier_score[4] + 1
							end
						end
					end

					local tmp = lua_table.Transform:GetPosition(collider)

					local knock_vector = {0, 0, 0}
					knock_vector[1] = lua_table.RecruitPos[1] - tmp[1]
					knock_vector[2] = lua_table.RecruitPos[2] - tmp[2]
					knock_vector[3] = lua_table.RecruitPos[3] - tmp[3]

					local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

					knock_force[1] = knock_vector[1] / module
					knock_force[2] = knock_vector[2]
					knock_force[3] = knock_vector[3] / module

					lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

					lua_table.currentState = State.KNOCKBACK
					start_knockback = true
					lua_table.is_knockback = true
					lua_table.System:LOG("Recruit state: KNOCKBACK (4)") 
					
				elseif script.collider_effect == attack_effects.taunt then ---------------------------------------------------- React to taunt effect
					AttackColliderShutdown()

					start_taunt = true

					if start_taunt then 

						if script.jaskier_score ~= nil then
							if script.jaskier_score[1] ~= nil then
								script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
							end
						end
				
						------- Actual stun dmg marker
						if script.jaskier_score ~= nil then
							if script.jaskier_score[4] ~= nil then
								script.jaskier_score[4] = script.jaskier_score[4] + 1
							end
						end

						
						local particles = {}
						particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Taunt_Emitter", Recruit_General_Emitter))
						for i = 1, #particles do 
							lua_table.Particles:PlayParticleEmitter(particles[i])
						end

						taunt_timer = lua_table.System:GameTime() * 1000
						lua_table.is_taunt = true
						lua_table.System:LOG("Getting taunted by Jaskier") 
						start_taunt = false
					end
				
				end
	
			else
				AttackColliderShutdown()
				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
				
				if parent == lua_table.geralt then
					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Blood_Emitter", Recruit_General_Emitter))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end
			
				else 
					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Hit_Emitter", Recruit_General_Emitter))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end
				end

				if parent == lua_table.geralt then
					------- Stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[1] ~= nil then
							script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
						end
					end
			
					------- Actual stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[4] ~= nil then
							script.geralt_score[4] = script.geralt_score[4] + 1
						end
					end
			
				else 
					------- Stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[1] ~= nil then
							script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
						end
					end
			
					------- Actual stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[4] ~= nil then
							script.jaskier_score[4] = script.jaskier_score[4] + 1
						end
					end
				end

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

		curr_dmg_dealer = collider_GO

		lua_table.Material:SetMaterialByName("HitMaterial.mat", Recruit_Material_UID)
      	material_timer = lua_table.System:GameTime() * 1000
		start_material  = true

		if script.collider_effect ~= attack_effects.none then
			
			if script.collider_effect == attack_effects.stun then ----------------------------------------------------- React to stun effect
				AttackColliderShutdown()
				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

				if script.collider_stun_duration ~= nil then
					lua_table.stun_duration = script.collider_stun_duration
				end

				local particles = {}
				particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Stun_Emitter", Recruit_General_Emitter))
				for i = 1, #particles do 
					lua_table.Particles:PlayParticleEmitter(particles[i])
				end
				
				if collider_GO == lua_table.geralt then
					------- Stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[1] ~= nil then
							script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
						end
					end
			
					------- Actual stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[4] ~= nil then
							script.geralt_score[4] = script.geralt_score[4] + 1
						end
					end
			
				else 
					------- Stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[1] ~= nil then
							script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
						end
					end
			
					------- Actual stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[4] ~= nil then
							script.jaskier_score[4] = script.jaskier_score[4] + 1
						end
					end
				end

				start_stun = true
				lua_table.currentState = State.STUNNED
				
				lua_table.System:LOG("Recruit state: STUNNED (5)")  
			elseif script.collider_effect == attack_effects.knockback then ------------------------------------------------ React to kb effect
				AttackColliderShutdown()

				if collider_GO == lua_table.geralt then
					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Blood_Emitter", Recruit_General_Emitter))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end
			
				else 
					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Hit_Emitter", Recruit_General_Emitter))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end
				end

				if collider_GO == lua_table.geralt then
					------- Stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[1] ~= nil then
							script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
						end
					end
			
					------- Actual stun dmg marker
					if script.geralt_score ~= nil then
						if script.geralt_score[4] ~= nil then
							script.geralt_score[4] = script.geralt_score[4] + 1
						end
					end
			
				else 
					------- Stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[1] ~= nil then
							script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
						end
					end
			
					------- Actual stun dmg marker
					if script.jaskier_score ~= nil then
						if script.jaskier_score[4] ~= nil then
							script.jaskier_score[4] = script.jaskier_score[4] + 1
						end
					end
				end

				local coll_pos = lua_table.Transform:GetPosition(collider_GO)
				local knock_vector = {0, 0, 0}
				knock_vector[1] = lua_table.RecruitPos[1] - coll_pos[1]
				knock_vector[2] = lua_table.RecruitPos[2] - coll_pos[2]
				knock_vector[3] = lua_table.RecruitPos[3] - coll_pos[3]

				 local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

				knock_force[1] = knock_vector[1] / module
				knock_force[2] = knock_vector[2]
				knock_force[3] = knock_vector[3] / module

				lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

				lua_table.currentState = State.KNOCKBACK
				start_knockback = true
				lua_table.is_knockback = true
				lua_table.System:LOG("Recruit state: KNOCKBACK (4)") 

			elseif script.collider_effect == attack_effects.taunt then ---------------------------------------------------- React to taunt effect
				AttackColliderShutdown()

				if script.jaskier_score ~= nil then
					if script.jaskier_score[1] ~= nil then
						script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
					end
				end
		
				------- Actual stun dmg marker
				if script.jaskier_score ~= nil then
					if script.jaskier_score[4] ~= nil then
						script.jaskier_score[4] = script.jaskier_score[4] + 1
					end
				end

				start_taunt = true

				if start_taunt then 

					taunt_timer = lua_table.System:GameTime() * 1000

					local particles = {}
					particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Taunt_Emitter", Recruit_General_Emitter))
					for i = 1, #particles do 
						lua_table.Particles:PlayParticleEmitter(particles[i])
					end

					lua_table.is_taunt = true
					lua_table.System:LOG("Getting taunted by Jaskier") 
					start_taunt = false
				end
				
			end

		else
			AttackColliderShutdown()
			lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
			
			if collider_GO == lua_table.geralt then
				local particles = {}
				particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Blood_Emitter", Recruit_General_Emitter))
				for i = 1, #particles do 
					lua_table.Particles:PlayParticleEmitter(particles[i])
				end
		
			else 
				local particles = {}
				particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Hit_Emitter", Recruit_General_Emitter))
				for i = 1, #particles do 
					lua_table.Particles:PlayParticleEmitter(particles[i])
				end
			end

			if collider_GO == lua_table.geralt then
				------- Stun dmg marker
				if script.geralt_score ~= nil then
					if script.geralt_score[1] ~= nil then
						script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
					end
				end
		
				------- Actual stun dmg marker
				if script.geralt_score ~= nil then
					if script.geralt_score[4] ~= nil then
						script.geralt_score[4] = script.geralt_score[4] + 1
					end
				end
		
			else 
				------- Stun dmg marker
				if script.jaskier_score ~= nil then
					if script.jaskier_score[1] ~= nil then
						script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
					end
				end
		
				------- Actual stun dmg marker
				if script.jaskier_score ~= nil then
					if script.jaskier_score[4] ~= nil then
						script.jaskier_score[4] = script.jaskier_score[4] + 1
					end
				end
			end

			lua_table.System:LOG("Hit registered")
		end
	end
end

-- ______________________MAIN CODE______________________
function lua_table:Awake()
	lua_table.System:LOG("Recruit AWAKE")

	Recruit_General_Emitter = lua_table.GameObject:FindChildGameObject("Recruit_General_Particles")

end

function lua_table:Start()
	lua_table.System:LOG("Recruit START")

	-- Getting Entity and Player UIDs
	lua_table.MyUID = lua_table.GameObject:GetMyUID()
	lua_table.geralt = lua_table.GameObject:FindGameObject("Geralt")
	lua_table.jaskier = lua_table.GameObject:FindGameObject("Jaskier")

	Recruit_Material_UID = lua_table.GameObject:FindChildGameObject("Minion_Base")

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
	lua_table.System:LOG("Recruit state: IDLE (0)") 
	lua_table.health = lua_table.max_hp

	-- Get colliders
	Front_Collider = lua_table.GameObject:FindChildGameObject(lua_table.Recruit_Front)

	-- Initialize Nav
	navID = lua_table.Recast:GetAreaFromName("Walkable")


	
end

function lua_table:Update()

	dt = lua_table.System:DT()

	-- Check if our entity is dead
	if lua_table.health <= 0 and has_died == false then 

		local score = lua_table.GameObject:GetScript(curr_dmg_dealer)

		if curr_dmg_dealer == lua_table.geralt then
			if score.geralt_score ~= nil then
				if score.geralt_score[2] ~= nil then
					score.geralt_score[2] = score.geralt_score[2] + 1
				end
			end
		else 
			if score.jaskier_score ~= nil then
				if score.jaskier_score[2] ~= nil then
					score.jaskier_score[2] = score.jaskier_score[2] + 1
				end
			end
		end 

		lua_table.currentState = State.DEATH
		lua_table.System:LOG("Recruit state: Death (5)")
		has_died = true
	end
	
	SearchPlayers() -- Constantly calculate distances between entity and players

	if lua_table.RecruitPos[2] <= -30 then lua_table.GameObject:DestroyGameObject(lua_table.MyUID) end

	-- Check which state the entity is in and then handle them accordingly
	if lua_table.currentState == State.IDLE then 
		Idle()
	elseif lua_table.currentState == State.SEEK then 
		Seek()
	elseif lua_table.currentState == State.ATTACK then 
		Attack()
	elseif lua_table.currentState == State.KNOCKBACK then  
		KnockBack()
	elseif lua_table.currentState == State.STUNNED then  
		Stun()
	elseif lua_table.currentState == State.DEATH then	
		Die()
	end

	-- ResetState values when currentState ~= State.X
	if lua_table.currentState ~= State.SEEK then
		ResetNavigation()
	end
	if lua_table.currentState ~= State.ATTACK then
		ResetAttack()
	end
	if lua_table.currentState ~= State.KNOCKBACK then
		ResetKnockBack()
	end
	if lua_table.currentState ~= State.STUNNED then
		ResetStun()
	end

	-- Manual reset of taunt
	if taunt_timer + 5000 <= lua_table.System:GameTime() * 1000 then

		local particles = {}
		particles = lua_table.GameObject:GetGOChilds(lua_table.GameObject:FindChildGameObjectFromGO("Recruit_Taunt_Emitter", Recruit_General_Emitter))
		for i = 1, #particles do 
			lua_table.Particles:StopParticleEmitter(particles[i])
		end

		lua_table.is_taunt = false
		taunt_timer = 0
	end

	-- Manual reset for material
	if material_timer + 100 <= lua_table.System:GameTime() * 1000 and start_material == true then
		lua_table.Material:SetMaterialByName("New material 100.mat", Recruit_Material_UID)
		start_material = false
	end

------------------------------------------------
---------------------TESTS----------------------
------------------------------------------------
	-- -- ------------------------------------------------ TEST STUN
	-- if lua_table.Input:KeyUp("s") then
		
	-- 	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)
	-- 	start_stun = true
	-- 	lua_table.currentState = State.STUNNED
		
	-- 	lua_table.System:LOG("Recruit state: STUNNED (5)")  
	-- end

	-- ------------------------------------------------ TEST KD
	-- -- Apply knockback to target, stun it for a second, then return to SEEK
	-- if lua_table.Input:KeyUp("d") then
	-- 	local knock_vector = {0, 0, 0}
	-- 	knock_vector[1] = lua_table.RecruitPos[1] - lua_table.currentTargetPos[1]
	-- 	knock_vector[2] = lua_table.RecruitPos[2] - lua_table.currentTargetPos[2]
	-- 	knock_vector[3] = lua_table.RecruitPos[3] - lua_table.currentTargetPos[3]
						
	 -- 	local module = math.sqrt(knock_vector[1] ^ 2 + knock_vector[3] ^ 2)

	-- 	knock_force[1] = knock_vector[1] / module
	-- 	knock_force[2] = knock_vector[2]
	-- 	knock_force[3] = knock_vector[3] / module

	-- 	lua_table.Animations:PlayAnimation("Hit", 30.0, lua_table.MyUID)

	-- 	lua_table.currentState = State.KNOCKBACK
	-- 	start_knockback = true
	-- 	lua_table.is_knockback = true
	-- 	lua_table.System:LOG("Recruit state: KNOCKBACK (4)") 
	
	-- end
	-- ------------------------------------------------ TEST TAUNT
	-- if lua_table.Input:KeyUp("t") then
	-- 	start_taunt = true

	-- 	if start_taunt then 
	-- 		taunt_timer = lua_table.System:GameTime() * 1000
	-- 		lua_table.is_taunt = true
	-- 		lua_table.System:LOG("Getting taunted by Jaskier") 
	-- 		start_taunt = false
	-- 	end
	-- end

end

return lua_table
end