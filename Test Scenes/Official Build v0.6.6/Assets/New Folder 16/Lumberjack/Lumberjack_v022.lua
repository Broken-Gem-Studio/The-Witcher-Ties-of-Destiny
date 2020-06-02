function GetTableLumberjack_v022()

	local lua_table = {}
	
	lua_table.SystemFunctions = Scripting.System()
	lua_table.GameObjectFunctions = Scripting.GameObject()
	lua_table.TransformFunctions = Scripting.Transform()
	lua_table.PhysicsSystem =  Scripting.Physics()
	lua_table.AnimationSystem = Scripting.Animations()
	lua_table.SoundSystem = Scripting.Audio()
	lua_table.ParticleSystem = Scripting.Particles()
	lua_table.NavSystem = Scripting.Navigation()
	
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
	
	local SpecialEffect = {
		NONE = 0,
		STUNNED = 1,
		KNOCKBACK = 2,
		HIT = 3
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
	
	--lua_table.FrontCo_name = "Lumberjack_Front"
	--lua_table.JumpCo_name = "Lumberjack_Jump_Attack"
	
	local attack_colliders = {
		jump_attack = { GO_name = "Lumberjack_Jump_Attack", GO_UID = 0 , active = false},
		front = { GO_name = "Lumberjack_Front", GO_UID = 0 , active = false}	
	}
	local particles = {
		ambient = { GO_name = "ambient_particles", GO_UID = 0 , active = false},
		alert1 = { GO_name = "alert_scream_particles_1", GO_UID = 0 , active = false},
		alert2 = { GO_name = "alert_scream_particles_2", GO_UID = 0 , active = false}
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
	
	--Used everywhere
	local MinDistance = 4
	local MyUID = 0
	
	local Geralt = 0
	local Jaskier = 0
	
	
	
	local Nvec3x = 0
	local Nvec3z = 0  -->Movement
	local Nvec3y = 0
	
	local TargetAlive_TimeController = 0
	
	
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
	local PatrolSpeed = 0.035 --perfect velocity to anim velocity 0.3
	
	
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
	local DelayIlde_AnimController = false
	local TimeSinceLastAttack = 0
	
	local Attack1_FirstController = false
	--JumpAttack()
	local AfterJumpAttackTimer = 0
	local JumpAttack_TimeController = 0
	local JumpAttack_AnimController = false
	local Aux_TargetPos = {}
	local Aux_TargetExist = false
	local DistanceMagnitudeAux_Target = 0
	local UseAuxVariables = false
	
	local JumpAttack_CautionTime = 0
	
	--Die()
	
	lua_table.Dead = false
	local DeadTime = 0
	
	--SpecialEffects
	local StunnedTimeController = 0
	local KnockedTimeController = 0
	local Stun_AnimController = false
	local StunnedTime = 1000
	local knockback_AnimController = false
	local Hit_AnimController = false
	local Hit_TimeController = false
	
	
	--Player scripts
	
	local target_script = {}
	-----------------------------------------------------------------------------------------
	-- Inspector Variables
	-----------------------------------------------------------------------------------------
	
	lua_table.deathTimer = 10000
	
	lua_table.player_1 = "Geralt"
	lua_table.player_2 = "Jaskier"
	
	lua_table.player_1_Dead = false
	lua_table.player_2_Dead = false
	
	lua_table.collider_damage = 0
	lua_table.collider_effect = 0
	
	lua_table.MaxHealth = 100
	lua_table.CurrentHealth = 0
	lua_table.MaxSpeed = 0.085
	lua_table.JumpAttackSpeed = 0.035
	lua_table.JumpAttackDone = false
	
	lua_table.CurrentTarget = 0
	lua_table.LastCurrentTarget = 0
	lua_table.CurrentPatrolTarget = {}
	
	lua_table.AggroDistance = 20
	
	lua_table.CurrentState = State.NONE
	lua_table.CurrentSubState = SubState.NONE
	lua_table.CurrentAnim = Anim.NONE
	
	lua_table.Pos = 0
	
	lua_table.MinDistanceFromPlayer = 3
	
	lua_table.CurrentSpecialEffect = SpecialEffect.NONE
	
	local navigation_ID = 0
	local corners = {}
	local actual_corner = 2
	local calculatepath = true
	local distance_to_corner = -1
	
	local CalculatePath_Timer = 0
	
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
		
		Nvec3x = vec3x / distance_to_corner--DistanceMagnitude--
		Nvec3z = vec3z / distance_to_corner--DistanceMagnitude-- -- Normalized values
	
		--lua_table.SystemFunctions:LOG("Nvec3x NormalizeDirVector():"..Nvec3x)
		--lua_table.SystemFunctions:LOG("Nvec3z NormalizeDirVector():"..Nvec3z)
	
	end
	local function NormalizeDirVector_AuxTarget()
		
		
		Nvec3x = vec3x / DistanceMagnitudeAux_Target
		Nvec3z = vec3z / DistanceMagnitudeAux_Target -- Normalized values for jumpattack
		--lua_table.SystemFunctions:LOG("Nvec3x after NormalizedirVector_AuxTarget:------------"..Nvec3x)
		--lua_table.SystemFunctions:LOG("Nvec3z after NormalizedirVector_AuxTarget:------------"..Nvec3z)
	end
	-----------------------------------------------------------------------------------------
	-- SUB FUNCTIONS
	-----------------------------------------------------------------------------------------
	
	local function ApplyVelocity()
	
		if lua_table.CurrentState == State.PRE_DETECTION and lua_table.CurrentSubState == SubState.PATROL
		then 
			if FirstSeekCalled == true and DistanceMagnitude > 0.3 --do this because if not then lumberjack shakes --error lumberjack
			then
				Nvec3x = Nvec3x*PatrolSpeed
				Nvec3z = Nvec3z*PatrolSpeed
				--lua_table.SystemFunctions:LOG("ARRIVED , LookLeftRight_AnimController, FirstSeekCalled"..Arrived2PatrolTarget..LookLeftRight_AnimController,FirstSeekCalled)
			elseif Arrived2PatrolTarget == false and LookLeftRight_AnimController == false and FirstSeekCalled == true and DistanceMagnitude <= lua_table.MinDistanceFromPlayer 
			then
				Nvec3x = Nvec3x * 0.0000000001 --this is to don't convert the lookAt vector to 0 but do not move the dir vector
				Nvec3z = Nvec3z * 0.0000000001
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
				Nvec3x = Nvec3x * 0.0000000001
				Nvec3z = Nvec3z * 0.0000000001
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
		--calculos mios 
		FirstSeekCalled = true
		DistanceMagnitude = CalculateDistanceToPosition(lua_table.CurrentPatrolTarget) --y not used
	
		-- nav mesh stuff
		local NextCorner = {}
		NextCorner[1] = corners[actual_corner][1] - lua_table.Pos[1]
		NextCorner[2] = corners[actual_corner][2] - lua_table.Pos[2]
		NextCorner[3] = corners[actual_corner][3] - lua_table.Pos[3]
	
		distance_to_corner = CalculateDistanceToPosition(corners[actual_corner])
	
		if distance_to_corner > 0.2 
		then
			Nvec3x = NextCorner[1] / distance_to_corner
			Nvec3Z = NextCorner[3] / distance_to_corner
		else
			actual_corner = actual_corner + 1
		end
		
		NormalizeDirVector()
		
	end
	
	local function seekTarget()	 	
		DistanceMagnitude = CalculateDistanceToTarget( lua_table.CurrentTarget) --y not used
	
		-- nav mesh stuff
		local NextCorner = {}
		NextCorner[1] = corners[actual_corner][1] - lua_table.Pos[1]
		NextCorner[2] = corners[actual_corner][2] - lua_table.Pos[2]
		NextCorner[3] = corners[actual_corner][3] - lua_table.Pos[3]
	
		distance_to_corner = CalculateDistanceToPosition(corners[actual_corner])
	
		if distance_to_corner > 0.2 
		then
			Nvec3x = NextCorner[1] / distance_to_corner
			Nvec3Z = NextCorner[3] / distance_to_corner
		else
			actual_corner = actual_corner + 1
		end
		
	
		NormalizeDirVector()
	end
	
	local function Players() --RET TRUE IF 1 PLAYER FOUND
		ret = false
	
		if Geralt ~= 0
		then
			GeraltPos = lua_table.TransformFunctions:GetPosition(Geralt)
			ret = true
		else 
			lua_table.SystemFunctions:LOG("This Log was called from a Lumberjack on Players() function because Geralt is not found")
		end
	
		if Jaskier ~= 0
		then
			JaskierPos = lua_table.TransformFunctions:GetPosition(Jaskier)	
			ret = true
		else 
			lua_table.SystemFunctions:LOG("This Log was called from a Lumberjack on Players() function because Jaskier is not found")
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
		elseif lua_table.CurrentTarget ~= 0 and Players() == true 
		then
			if lua_table.CurrentTarget == Geralt and lua_table.LastCurrentTarget ~= Jaskier
			then	
				GeraltScript = lua_table.GameObjectFunctions:GetScript(Geralt)
				if GeraltScript.current_state == -3 or GeraltScript.current_state == -4
				then
					lua_table.SystemFunctions:LOG("CHANGING AGGRO TO JASKIER")
					lua_table.CurrentTarget = Jaskier
					lua_table.LastCurrentTarget = Geralt
				end
			elseif lua_table.CurrentTarget == Jaskier and lua_table.LastCurrentTarget ~= Geralt
			then
				JaskierScript = lua_table.GameObjectFunctions:GetScript(Jaskier)
				if JaskierScript.current_state == -3 or JaskierScript.current_state == -4
				then
					lua_table.SystemFunctions:LOG("CHANGING AGGRO TO GERALT ")
					lua_table.CurrentTarget = Geralt
					lua_table.LastCurrentTarget = Jaskier
				end
			end
		elseif Players() == false
		then
			--lua_table.SystemFunctions:LOG("NO PLAYERS, NEW STATE PRE_DETECTION ")
			lua_table.CurrentState = State.PRE_DETECTION
		end 
		return ret
	end
	
	local function jumpAttack()
	
		--DistanceMagnitude = CalculateDistanceToTarget(lua_table.CurrentTarget)
		DistanceMagnitudeAux_Target = CalculateDistanceToPosition(Aux_TargetPos)--tengo q pasar un target
		NormalizeDirVector_AuxTarget()
	
		if JumpAttack_AnimController == false
		then
			--lua_table.SystemFunctions:LOG(" JUMP_ATTACK! ")
			lua_table.AnimationSystem:PlayAnimation("JUMP_ATTACK",35.0,MyUID)
			lua_table.CurrentSubState = SubState.JUMP_ATTACK
			JumpAttack_AnimController = true
			JumpAttack_TimeController = PerfGameTime()
		
			lua_table.attack_effects = attack_effects.stun
			lua_table.collider_damage = 20
			lua_table.collider_effect = 1
		end
		if DistanceMagnitudeAux_Target <= lua_table.MinDistanceFromPlayer and lua_table.CurrentSubState == SubState.JUMP_ATTACK and PerfGameTime() - JumpAttack_TimeController > 1800
		then	
			--cambiar q se ponga aqui el state atack y el sub estate
			lua_table.JumpAttackDone = true
			UseAuxVariables = false
			AfterJumpAttackTimer = PerfGameTime()
			
			if attack_colliders.jump_attack.active == false
			then	
				lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.jump_attack.GO_UID)
				attack_colliders.jump_attack.active = true
				--lua_table.SystemFunctions:LOG("jump_attack collider ON   -"..attack_colliders.jump_attack.GO_UID)
			end	
		end
		
	end
	local function Attack()
		--Time = PerfGameTime()
	
		if DelayIlde_AnimController == false 
		then 
			--goto here --magic starts here
	
	
			--empty space
	
	
			--::here:: --magic ends here
	
			--lua_table.SystemFunctions:LOG("1  ")
			lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
			DelayIlde_AnimController = true
		end
	
		if Attack1_AnimController == false and Time_HandleAttack - AfterJumpAttackTimer > 1000 --delay para q caiga y no insta ataque
		then
			--lua_table.SystemFunctions:LOG("2 ")
			Attack1_TimeController = PerfGameTime()
			Attack1_FirstController = true
			lua_table.AnimationSystem:PlayAnimation("ATTACK_1",30.0,MyUID)
			lua_table.attack_effects = attack_effects.none
			lua_table.collider_damage = 10
			lua_table.collider_effect = 0
			Attack1_AnimController = true
		end
	
		if TimeSinceLastAttack > 900 and TimeSinceLastAttack < 1100
		then
			if attack_colliders.front.active == false
			then
				lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.front.GO_UID)
				attack_colliders.front.active = true
				lua_table.SystemFunctions:LOG("attack collider activate ")
				lua_table.SoundSystem:PlayAudioEvent("Play_Bandit_lumberjack_attack")
			end
		end
	
		if TimeSinceLastAttack > 1100 and TimeSinceLastAttack < 1300
		then
			if attack_colliders.front.active == true
			then
				lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.front.GO_UID)
				lua_table.SystemFunctions:LOG("attack collider deactivate ")
				attack_colliders.front.active = false
			
			end
		end
	
		if TimeSinceLastAttack >= 1800
		then
			if IdleArmed_AnimController == false
			then 
				--lua_table.SystemFunctions:LOG("3  ")
				lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
				IdleArmed_AnimController = true
			end	
		end
		if TimeSinceLastAttack >= 2500
		then
			Attack1_AnimController = false
			IdleArmed_AnimController = false
		end		
	end
	
	local function Die()
		lua_table.Dead = true
		lua_table.AnimationSystem:PlayAnimation("DEATH",35.0,MyUID)
		lua_table.SoundSystem:PlayAudioEvent("Play_Bandit_death_3")
	
		tuto_manager = lua_table.GameObjectFunctions:FindGameObject("TutorialManager")
		if tuto_manager ~= 0 
		then
			tuto_table = lua_table.GameObjectFunctions:GetScript(tuto_manager)
	
			if tuto_table.currentStep == 9
			then
				tuto_table.enemiesToKill_Step9 = tuto_table.enemiesToKill_Step9 - 1
			elseif tuto_table.currentStep == 10
			then
				tuto_table.enemiesToKill_Step10 = tuto_table.enemiesToKill_Step10 - 1
			end
		end
	end
	
	local function knockback( )
	 --
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
						lua_table.AnimationSystem:PlayAnimation("UNARMED_IDLE",30.0,MyUID) -- IDLE 
						--lua_table.SystemFunctions:LOG("SUB STATE IDLE")
						--lua_table.SystemFunctions:LOG("ANIM UNARMED_IDLE")
					else
						lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0,MyUID) -- SUSPICIOUS
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
						lua_table.AnimationSystem:PlayAnimation("LOOKING_ARROUND",30.0,MyUID)
						--lua_table.SystemFunctions:LOG("SUB STATE PATROL")
						LookLeftRight_AnimController = true
						LookLeftRight_TimeController = PerfGameTime()
					end
					Timer = PerfGameTime()
					if Timer - LookLeftRight_TimeController > 6000 --TODO change value for a animation duration
					then
						lua_table.CurrentPatrolTarget[1] = lua_table.SystemFunctions:RandomNumberInRange(SpawnPos[1]-5,SpawnPos[1]+5)
						lua_table.CurrentPatrolTarget[3] = lua_table.SystemFunctions:RandomNumberInRange(SpawnPos[3]-5,SpawnPos[3]+5)
						CalculatePath_Timer = PerfGameTime()
						corners = lua_table.NavSystem:CalculatePath(lua_table.Pos[1],lua_table.Pos[2],lua_table.Pos[3],lua_table.CurrentPatrolTarget[1],lua_table.Pos[2],lua_table.CurrentPatrolTarget[3],1 << navigation_ID)
						actual_corner = 2
						Arrived2PatrolTarget = false
						PatrolWalk_AnimController = false
					end
				elseif Arrived2PatrolTarget == false
				then		
					if PatrolWalk_AnimController == false
					then
						lua_table.AnimationSystem:PlayAnimation("WALK_FRONT",30.0,MyUID)
						--lua_table.SystemFunctions:LOG("PATROLING")
						PatrolWalk_AnimController = true
						LookLeftRight_AnimController = false
					end	
					seekPatrolTarget()
					lua_table.SystemFunctions:LOG("distance mag 3 -"..DistanceMagnitude)
				end	
				--end
			end
			---
			lua_table.SystemFunctions:LOG("distance mag 4 -"..DistanceMagnitude)
			PlayerSeen = HandleAggro()
			lua_table.SystemFunctions:LOG("distance mag 5 -"..DistanceMagnitude)
			---
		elseif PlayerSeen == true
		then
			--lua_table.SystemFunctions:LOG("1")
			DistanceMagnitude = CalculateDistanceToTarget(lua_table.CurrentTarget) 
			lua_table.CurrentState = State.SEEK
			lua_table.CurrentSubState = SubState.ALERT	
			CalculatePath_Timer = PerfGameTime()
		end
	end
	
	local function HandleSEEK()
		
	
		
		Time_HandleSeek = PerfGameTime() 
	
		if Time_HandleSeek - CalculatePath_Timer > 500
		then
			calculatepath = true
		end
	
		if calculatepath == true
		then
			TargetPos = {}
			TargetPos = lua_table.TransformFunctions:GetPosition(lua_table.CurrentTarget)
			corners = lua_table.NavSystem:CalculatePath(lua_table.Pos[1],lua_table.Pos[2],lua_table.Pos[3],TargetPos[1],lua_table.Pos[2],TargetPos[3],1 << navigation_ID)
			actual_corner = 2
			CalculatePath_Timer = PerfGameTime()
			calculatepath = false
		end
	
		--#####################################################################################   PATH DONE
	
	
		if lua_table.CurrentSubState == SubState.ALERT
		then
			if Alert_AnimController == false
			then
				lua_table.AnimationSystem:PlayAnimation("ALERT",30.0,MyUID)
				lua_table.SoundSystem:PlayAudioEvent("Play_Bandit_voice_2")
				Alert_AnimController = true
				Alert_TimeController = PerfGameTime()
				lua_table.ParticleSystem:PlayParticleEmitter(particles.alert1.GO_UID)
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
			lua_table.SystemFunctions:LOG("4  ")
				lua_table.AnimationSystem:PlayAnimation("RUN",30.0,MyUID)
				Run_AnimController = true
			end
			--lua_table.SystemFunctions:LOG("seekTarget()")
			seekTarget()
		end
		
		--#####################################################################################   SEEK DONE
		if DistanceMagnitude < 15 and DistanceMagnitude > 14 and lua_table.JumpAttackDone == false 
		then
			UseAuxVariables = true	
		end
	
		if UseAuxVariables == true
		then
			lua_table.JumpAttackSpeed = 0.045
			--lua_table.SystemFunctions:LOG("jumpAttack()")
			if Aux_TargetExist == false
			then 
				Aux_TargetPos = lua_table.TransformFunctions:GetPosition(lua_table.CurrentTarget)
				Aux_TargetExist = true
			end
			--lua_table.SystemFunctions:LOG("DistanceMagnitudeAuxTarget-->"..DistanceMagnitudeAux_Target)
			--lua_table.SystemFunctions:LOG("jumpAttack()")
			jumpAttack()
		end
	
		if DistanceMagnitudeAux_Target < 13.5 and lua_table.JumpAttackDone == false --and lua_table.CurrentSubState == SubState.JUMP_ATTACK
		then
			lua_table.JumpAttackSpeed = 0.14
		end
	
		--#####################################################################################   JUMP ATTACK DONE
	
		if DistanceMagnitudeAux_Target <= lua_table.MinDistanceFromPlayer and lua_table.JumpAttackDone == true and lua_table.CurrentSubState == SubState.JUMP_ATTACK
		then
			if DistanceMagnitudeAux_Target <= lua_table.MinDistanceFromPlayer
			then
				lua_table.SystemFunctions:LOG("d_mag = "..DistanceMagnitudeAux_Target)
				--lua_table.SystemFunctions:LOG("5  ")
				lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
				lua_table.CurrentState = State.ATTACK
				lua_table.CurrentSubState = SubState.NONE
				Run_AnimController = false
				lua_table.SystemFunctions:LOG("JUMP_ATTACK DONE")
				lua_table.SystemFunctions:LOG("SEEK----->ATTACK")
				lua_table.SystemFunctions:LOG("NONE -")
				UseAuxVariables = false
			end
			if DistanceMagnitude >= lua_table.MinDistanceFromPlayer 
			then
				lua_table.AnimationSystem:PlayAnimation("RUN",30.0,MyUID)
				lua_table.CurrentState = State.SEEK
				lua_table.CurrentSubState = SubState.SEEK_TARGET
				lua_table.SystemFunctions:LOG("SEEK----->SEEK")
				lua_table.SystemFunctions:LOG("SEEKTARGET")
				UseAuxVariables = false
			end
		end
		--#####################################################################################    PREPARED TO ATTACK
		if DistanceMagnitude <= lua_table.MinDistanceFromPlayer
		then
			lua_table.AnimationSystem:PlayAnimation("IDLE",30.0,MyUID)
			lua_table.CurrentState = State.ATTACK
			lua_table.CurrentSubState = SubState.NONE
			Run_AnimController = false
			lua_table.SystemFunctions:LOG("SEEK----->ATTACK")
			UseAuxVariables = false
		end
	
		--#####################################################################################   CASE WHEN GERALT RUN FROM ATTACK
		if Time_HandleSeek - AfterJumpAttackTimer > 300 and attack_colliders.jump_attack.active == true
		then 
			lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.jump_attack.GO_UID)
			attack_colliders.jump_attack.active = false
			lua_table.SoundSystem:PlayAudioEvent("Play_Barrel_crush_1")
			lua_table.SystemFunctions:LOG("jump_attack collider OFF   -"..attack_colliders.jump_attack.GO_UID)
		end
	
		if TimeSinceLastAttack > 1100 and TimeSinceLastAttack < 1300
		then
			if attack_colliders.front.active == true
			then
				lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.front.GO_UID)
				attack_colliders.front.active = false
				lua_table.SystemFunctions:LOG("attack collider OFF   -"..attack_colliders.front.GO_UID)
			end
		end
	end
	
	local function HandleAttack()
		
		DistanceMagnitude = CalculateDistanceToTarget(lua_table.CurrentTarget)
		Time_HandleAttack = PerfGameTime()
		if Attack1_FirstController == true -- if first attack done ERGO Attack1_TimeController has a valid value
		then			
			TimeSinceLastAttack = Time_HandleAttack - Attack1_TimeController
		end
		--############################################################################    DEACTIVATE COLLIDER DAMAGE
		if Time_HandleAttack - AfterJumpAttackTimer > 100 and attack_colliders.jump_attack.active == true
		then 
			lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.jump_attack.GO_UID)
			attack_colliders.jump_attack.active = false
			lua_table.SystemFunctions:LOG("jump attack collider deactivate"..attack_colliders.jump_attack.GO_UID)
		end
		--############################################################################    IF IN RANGE ATTACK
		if DistanceMagnitude <= lua_table.MinDistanceFromPlayer   
		then
			Attack()
			--lua_table.SystemFunctions:LOG("attack()")
		elseif DistanceMagnitude >= lua_table.MinDistanceFromPlayer and TimeSinceLastAttack >= 1800 --this last is to make lumberjack end attack anims always
		then 
			lua_table.CurrentState = State.SEEK
			lua_table.CurrentSubState = SubState.SEEK_TARGET
			lua_table.JumpAttackDone = true
			lua_table.SystemFunctions:LOG("ATTACK----->SEEK")
			lua_table.SystemFunctions:LOG("SEEK_TARGET")
			DelayIlde_AnimController = false 
		end
	end
	
	local function HandleDeath()
		if lua_table.Dead == false
		then	
			Die()
			DeadTime = PerfGameTime()
		end
	
		TiMe = PerfGameTime()
		if TiMe - DeadTime > lua_table.deathTimer
		then
			lua_table.GameObjectFunctions:DestroyGameObject(MyUID)
		end
	end
	-----------------------------------------------------------------------------------------
	-- Main Code
	-----------------------------------------------------------------------------------------
	
	function lua_table:OnTriggerEnter()	
		local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUID)
		
		if lua_table.CurrentState ~= State.DEATH and lua_table.GameObjectFunctions:GetLayerByID(collider_GO) == 2 --player attack
		then
			local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
			 local player_script = {}
		
			lua_table.SystemFunctions:LOG("OnTriggerEnter Lumberjack")
	
			 if collider_parent ~= 0 
			then
				player_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
			else
				 player_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
			end
	
			lua_table.CurrentHealth = lua_table.CurrentHealth - player_script.collider_damage
			lua_table.CurrentSpecialEffect = SpecialEffect.HIT
	
			if player_script.collider_effect ~= 0
			then
					--todo react to effect
			end
		end
	
		lua_table.SystemFunctions:LOG("OnTriggerEnter()".. collider_GO)
	end
	
	function lua_table:OnCollisionEnter()
		local collider = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
		--lua_table.SystemFunctions:LOG("T: ".. collider)
	end
	
	function lua_table:RequestedTrigger(collider_GO)
		lua_table.SystemFunctions:LOG("On RequestedTrigger")
	
		if lua_table.CurrentState ~= State.DEATH	
		then
			local player_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
			lua_table.CurrentHealth = lua_table.CurrentHealth - player_script.collider_damage
	
			if player_script.collider_effect ~= attack_effects.none
			then
				if player_script.collider_effect == attack_effects.stun
				then
					lua_table.CurrentSpecialEffect = SpecialEffect.STUNNED
					StunnedTimeController = PerfGameTime()
				end
				if player_script.collider_effect == attack_effects.knockback 
				then
					lua_table.CurrentSpecialEffect = SpecialEffect.KNOCKBACK
					StunnedTimeController = PerfGameTime()
				end
			end
		end
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
		
	
		---GET MY COLLIDERS UIDS
	
	
	end
	
	function lua_table:Start()
	
		lua_table.SystemFunctions:LOG("A random Lumberjack Script: START") 
		lua_table.CurrentHealth = lua_table.MaxHealth
	
		if lua_table.CurrentState == State.NONE
		then	
			lua_table.CurrentState = State.PRE_DETECTION
		end
		lua_table.CurrentSpecialEffect = SpecialEffect.NONE
	
		--bolumena
		--lua_table.SoundSystem:SetVolume(0.09)
	
	
		attack_colliders.front.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.front.GO_name)
		attack_colliders.jump_attack.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(attack_colliders.jump_attack.GO_name)
		lua_table.SystemFunctions:LOG("FRONT GO---"..attack_colliders.front.GO_name)
		lua_table.SystemFunctions:LOG("FRONT GO UID"..attack_colliders.front.GO_UID)
		lua_table.SystemFunctions:LOG("JUMP GO---"..attack_colliders.jump_attack.GO_name)
		lua_table.SystemFunctions:LOG("JUMP GO UID"..attack_colliders.jump_attack.GO_UID)
	
	
		particles.ambient.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(particles.ambient.GO_name)
		particles.alert1.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(particles.alert1.GO_name)
		particles.alert2.GO_UID = lua_table.GameObjectFunctions:FindChildGameObject(particles.alert1.GO_name)
		lua_table.ParticleSystem:PlayParticleEmitter(particles.ambient.GO_UID)
		
		--lua_table.GameObjectFunctions:SetActiveGameObject(true, particles.ambient.GO_UID)
		--particles.ambient.active = true
	
		lua_table.GameObjectFunctions:SetActiveGameObject(true, particles.alert1.GO_UID)
		particles.alert1.active = true
	
		lua_table.ParticleSystem:StopParticleEmitter(particles.alert1.GO_UID)
	
		TargetAlive_TimeController = PerfGameTime()
	
		--------nav mesh -------------
		navigation_ID = lua_table.NavSystem:GetAreaFromName("Walkable")
	
	end
	
	function lua_table:Update()
		
		CurrTime = PerfGameTime()
		--lua_table.SystemFunctions:LOG("MyUID".. MyUID) 
	
		lua_table.SystemFunctions:LOG("CurrentSpecialEffect = --------->  "..lua_table.CurrentSpecialEffect)

		lua_table.Pos = lua_table.TransformFunctions:GetPosition(MyUID)
		
		if CurrTime - TargetAlive_TimeController > 300
		then
			if lua_table.CurrentTarget ~= 0 -- es decir que ya hay un target
			then
				--lua_table.SystemFunctions:LOG("UID TARGET:"..lua_table.CurrentTarget)
				if lua_table.GameObjectFunctions:IsActiveGameObject(lua_table.CurrentTarget) == true
				then
					--lua_table.SystemFunctions:LOG("CURR TARGET ACTIVE-----> HANDLE AGGRO")
					HandleAggro()
					TargetAlive_TimeController = PerfGameTime()
				end
			end
		end
		--############################################################################# HANDLE AGGRO CALLED EVERY 300mls
		if lua_table.CurrentHealth <= 1 
		then
			lua_table.CurrentState = State.DEATH
		end
		--############################################################################# PLAYER IS ALIVE OR DEAD DONE
		if lua_table.CurrentSpecialEffect == SpecialEffect.NONE
		then
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
				
			elseif lua_table.CurrentState == State.DEATH
			then
				HandleDeath()
				
			end
		elseif lua_table.CurrentSpecialEffect == SpecialEffect.STUNNED and lua_table.CurrentHealth > 1
		then
			if Stun_AnimController == false
			then
				lua_table.AnimationSystem:PlayAnimation("SIT_DOWN",30,MyUID)
				Stun_AnimController = true
			end
			if CurrTime - StunnedTimeController > 2000
			then
				lua_table.CurrentSpecialEffect = SpecialEffect.NONE	
				if lua_table.CurrentState == State.SEEK
				then
					Run_AnimController = false
				end
			end
		elseif lua_table.CurrentSpecialEffect == SpecialEffect.KNOCKBACK and lua_table.CurrentHealth > 1
		then
			lua_table.SystemFunctions:LOG("###################################   SpecialEffect.KNOCKBACK   #####################################")
			if knockback_AnimController == false
			then
				lua_table.AnimationSystem:PlayAnimation("HIT",30,MyUID)
				knockback_AnimController = true
			end
			if CurrTime - StunnedTimeController > 2000
			then
				lua_table.SystemFunctions:LOG("stunned")
				lua_table.CurrentSpecialEffect = SpecialEffect.NONE
				if lua_table.CurrentState == State.SEEK
				then
					Run_AnimController = false
				end
				
			end
			--if knockback_AnimController == false
			--then
			--	lua_table.AnimationSystem:PlayAnimation("SIT_DOWN",30,MyUID)
			--	knockback_AnimController = true
			--	KnockedTimeController = PerfGameTime()
			--end
			--Knockback()
			--if CurrTime - KnockedTimeController > 2000
			--then
			--	lua_table.CurrentSpecialEffect = SpecialEffect.NONE
			--	knockback_AnimController = false
			--end
		elseif lua_table.CurrentSpecialEffect == SpecialEffect.HIT 
		then	
			if Hit_AnimController == false
			then
				Hit_TimeController = PerfGameTime()
				lua_table.AnimationSystem:PlayAnimation("HIT",40,MyUID)
				lua_table.SoundSystem:PlayAudioEvent("Play_Bandit_getting_hit")
				
				Hit_AnimController = true
			end
			if CurrTime - Hit_TimeController > 1000
			then
				
				lua_table.SystemFunctions:LOG("AAAAAAAAAAAAAAA")
				lua_table.SystemFunctions:LOG("AAAAAAAAAAAAAAA")
				lua_table.SystemFunctions:LOG("AAAAAAAAAAAAAAA")
				lua_table.SystemFunctions:LOG("AAAAAAAAAAAAAAA")
				lua_table.CurrentSpecialEffect = SpecialEffect.NONE
				Hit_AnimController = false
				if lua_table.CurrentState == State.SEEK
				then
					Run_AnimController = false
				end
			end
		end
		--lua_table.SystemFunctions:LOG("distance mag 7 -"..DistanceMagnitude)
		if lua_table.Dead == false
		then
			--lua_table.SystemFunctions:LOG("distance mag 8 -"..DistanceMagnitude)
			lua_table.TransformFunctions:LookAt(lua_table.Pos[1] + vec3x,lua_table.Pos[2],lua_table.Pos[3] + vec3z,MyUID) -- PROVISIONAL, QUEDA MUY ARTIFICIAL
			--lua_table.SystemFunctions:LOG("distance mag 9 -"..DistanceMagnitude)
			ApplyVelocity() --decides if move function will move or not in x and z axis		
			lua_table.PhysicsSystem:Move(Nvec3x,Nvec3z,MyUID)
		end
	end
	
	return lua_table
	end