function GetTableKikimoraScript_v3 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.TransformFunctions = Scripting.Transform ()
lua_table.GameObjectFunctions = Scripting.GameObject ()
lua_table.PhysicsFunctions = Scripting.Physics()
lua_table.ParticlesFunctions = Scripting.Particles ()
lua_table.AudioFunctions = Scripting.Audio ()
lua_table.AnimationFunctions = Scripting.Animations ()

-----------------------------------------------------------------------------------------
-- Health Variables
-----------------------------------------------------------------------------------------

-- Health Value
local current_health = 0
lua_table.health = 3000

-- Health Percentages for each phase
local current_health_percentage = 0
lua_table.health_percentage_phase_1 = 100
lua_table.health_percentage_phase_2 = 75
lua_table.health_percentage_phase_3 = 50
lua_table.health_percentage_phase_4 = 25


local damage_received_real = -1
lua_table.damage_received_mod = 1.0
lua_table.damage_received_orig = -1

-----------------------------------------------------------------------------------------
-- Movement Variables
-----------------------------------------------------------------------------------------

-- Distance of player/s to activate the boss
lua_table.awakening_distance = 10
local player_in_awakening_distance = false

lua_table.position_x = 0
lua_table.position_y = 0
lua_table.position_z = 0

-----------------------------------------------------------------------------------------
-- Phases & States Variables
-----------------------------------------------------------------------------------------

local phase = -- not in use rn
{
	CHILL = 0,      -- phase 1
	HURT = 1, 		-- phase 2
	MAD = 2,      	-- phase 3
	ENRAGED = 3     -- phase 4
}
local current_phase = phase.CHILL -- Should initialize at awake(?)

local state =  
{
    UNACTIVE = 0,

    AWAKENING = 1,
    
	IDLE = 2,
    MOVING = 3,
    
    ATTACKING = 4,
    
	JUMPING = 8,
    TAUNTING = 9,

	STUNNED = 10,
    SWAPPING_PHASE = 11,
    
	SPAWNING_MINIONS = 12
}
local current_state = state.UNACTIVE -- Should initialize at awake(?)

local start_swapping = false
local finish_swapping = false

-----------------------------------------------------------------------------------------
-- Attacks Variables
-----------------------------------------------------------------------------------------
local attack_type = 
{
    TO_BE_DETERMINED = 0,

    ATTACKING_LEASH = 1,
    ATTACKING_STOMP = 2,
    ATTACKING_SWEEP = 3,
    ATTACKING_ROAR = 4
}
local current_attack_type = attack_type.TO_BE_DETERMINED

local attack_effect = --Not definitive, but as showcase
{	
	none = 0,
	stun = 1,
	knockback = 2,
	taunt = 3,
	venom = 4
}

local attack = 
{
	leash = { att_damage = 120, att_duration = 0, att_cooldown_time = 5, att_cooldown_bool = false, att_timer = 0},
	sweep = { att_damage = 100, att_duration = 0, att_cooldown_time = 9, att_cooldown_bool = false, att_timer = 0},
	stomp = { att_damage = 150, att_duration = 0, att_cooldown_time = 16, att_cooldown_bool = false, att_timer = 0},
	roar = { att_damage = 0, att_duration = 0, att_cooldown_time = 30, att_cooldown_bool = false, att_timer = 0}
}

local attack_finished = false


-----------------------------------------------------------------------------------------
-- Animation Variables
-----------------------------------------------------------------------------------------
local animation = 
{
    idle = { anim_name = "idle", anim_frames = 42, anim_speed = 30, anim_blendtime = 0 },
    walk = { anim_name = "walk", anim_frames = 25, anim_speed = 30, anim_blendtime = 0 },
	leash = { anim_name = "leash", anim_frames = 68, anim_speed = 30, anim_blendtime = 0 },
	sweep = { anim_name = "sweep", anim_frames = 112, anim_speed = 30, anim_blendtime = 0 },
	stomp = { anim_name = "stomp", anim_frames = 109, anim_speed = 30, anim_blendtime = 0 },
	roar = { anim_name = "roar", anim_frames = 42, anim_speed = 30, anim_blendtime = 0 }
}

-- -----------------------------------------------------------------------------------------
-- -- Collider Variables
-- -----------------------------------------------------------------------------------------

local attack_colliders = 
{
	leash = { GO_name = "Leash_Attack", GO_UID = 0, active = false },
	sweep = { GO_name = "Sweep_Attack", GO_UID = 0, active = false },
	stomp = { GO_name = "Stomp_Attack", GO_UID = 0, active = false },
	roar = { GO_name = "Roar_Attack", GO_UID = 0, active = false }
}

-- Collider Layers
local layers = 
{
	default = 0,
	player = 1,
	player_attack = 2,
	enemy = 3,
	enemy_attack = 4
}	
lua_table.collider_damage = 0
lua_table.collider_effect = attack_effect.none

-----------------------------------------------------------------------------------------
-- Game Objects Variables
-----------------------------------------------------------------------------------------

-- Kikimora GO UID
lua_table.myUID = 0

-- Kikimora target GO names
lua_table.geralt_GO = "Geralt"
lua_table.jaskier_GO = "Jaskier"
lua_table.yennefer_GO = "Yennefer"
lua_table.ciri_GO = "Ciri"

-- P1
local P1_id = 0
lua_table.P1_pos = {}
lua_table.P1_script = {}
local P1_abs_distance = nil 

-- P2
local P2_id = 0
lua_table.P2_pos = {}
lua_table.P2_script = {}
local P2_abs_distance = nil

lua_table.collider_parent_script = {}

-- I use this for visual pleasure (so I can write lua_table.P1_pos[x] instead of lua_table.P1_pos[1])  )
local x = 1
local y = 2
local z = 3

local game_time = 0
local attack_timer = 0
local state_timer = 0
local animation_timer = 0

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

function PerfGameTime()
	return lua_table.SystemFunctions:GameTime()-- * 1000
end

function HandlePhases()

    -- Calculate health percentage
    current_health_percentage = (lua_table.health / current_health) * 100

    -- Checking if inside phase 2 threshold
    if  current_health_percentage <= lua_table.health_percentage_phase_2 and current_health_percentage >= lua_table.health_percentage_phase_3
    then
        if current_phase ~= phase.HURT 
        then
            current_state = state.SWAPPING_PHASE
            current_phase = phase.HURT
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 2")
        end
    -- Checking if inside phase 3 threshold
    elseif current_health_percentage <= lua_table.health_percentage_phase_3 and current_health_percentage >= lua_table.health_percentage_phase_4
    then
        if current_phase ~= phase.MAD
        then
            current_state = state.SWAPPING_PHASE
            current_phase = phase.MAD
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 3")
        end
    -- Checking if inside phase 4 threshold
    elseif current_health_percentage <= lua_table.health_percentage_phase_4
    then
        if current_phase ~= phase.MAD
        then
            current_state = state.SWAPPING_PHASE
            current_phase = phase.ENRAGED
            start_swapping = true
            lua_table.SystemFunctions:LOG ("Kikimora: Swapping to phase 4")
        end
    end
end

function HandleRoarAttack()
    -- Handles Roar Attack
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_ROAR
        lua_table.AnimationFunctions:PlayAnimation(animation.roar.anim_name, animation.roar.anim_speed, lua_table.myUID)
        attack_timer = game_time + attack.roar.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Roar Start")
    end

    if current_attack_type == attack_type.ATTACKING_ROAR --Checks if is started
    then
        if game_time <= attack_timer --Checks if ongoing
        then
            -- Activates collider                               TODO: TIME WELL COLLIDERS
            lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.roar.GO_UID)
            -- Sets damage
            lua_table.collider_damage = attack.roar.att_damage
            -- Sets effect
            lua_table.collider_effect = attack_effect.none -- attack_effect.knockback TODO: Figure out how to send knockback to players.

        elseif game_time >= attack_timer --Checks if attack finished
        then
            attack.roar.att_cooldown_bool = true
            attack.roar.att_timer = game_time + attack.roar.att_cooldown_time
            attack_finished = true

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.roar.GO_UID)
            current_attack_type = attack_type.TO_BE_DETERMINED
            lua_table.SystemFunctions:LOG ("Kikimora: Roar Finish")
        end
    end
end

function HandleStompAttack()
    -- Handles Stomp Attack
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_STOMP
        lua_table.AnimationFunctions:PlayAnimation(animation.stomp.anim_name, animation.stomp.anim_speed, lua_table.myUID)
        attack_timer = game_time + attack.stomp.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Stomp Start")
    end
    if current_attack_type == attack_type.ATTACKING_STOMP --Checks if is started
    then
        if game_time <= attack_timer --Checks if ongoing
        then
            -- Activates collider                               TODO: TIME WELL COLLIDERS
            lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.stomp.GO_UID)
            -- Sets damage
            lua_table.collider_damage = attack.stomp.att_damage
            -- Sets effect
            lua_table.collider_effect = attack_effect.none -- attack_effect.knockback TODO: Figure out how to send knockback to players.

        elseif game_time >= attack_timer --Checks if attack finished
        then
            attack.stomp.att_cooldown_bool = true
            attack.stomp.att_timer = game_time + attack.stomp.att_cooldown_time
            attack_finished = true

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.stomp.GO_UID)
            current_attack_type = attack_type.TO_BE_DETERMINED
            lua_table.SystemFunctions:LOG ("Kikimora: Stomp Finish")
        end
    end
end

function HandleSweepAttack()
    -- Handles Sweep Attack
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_SWEEP
        lua_table.AnimationFunctions:PlayAnimation(animation.sweep.anim_name, animation.sweep.anim_speed, lua_table.myUID)
        attack_timer = game_time + attack.sweep.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Sweep Start")
    end
    if current_attack_type == attack_type.ATTACKING_SWEEP --Checks if is started
    then
        if game_time <= attack_timer --Checks if ongoing
        then
            -- Activates collider                               TODO: TIME WELL COLLIDERS
            lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.sweep.GO_UID)
            -- Sets damage
            lua_table.collider_damage = attack.sweep.att_damage
            -- Sets effect
            lua_table.collider_effect = attack_effect.none -- attack_effect.knockback TODO: Figure out how to send knockback to players.

        elseif game_time >= attack_timer --Checks if attack finished
        then
            attack.sweep.att_cooldown_bool = true
            attack.sweep.att_timer = game_time + attack.sweep.att_cooldown_time
            attack_finished = true

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.sweep.GO_UID)
            current_attack_type = attack_type.TO_BE_DETERMINED
            lua_table.SystemFunctions:LOG ("Kikimora: Sweep Finish")
        end
    end
end

function HandleLeashAttack()
    -- Handles Leash Attack
    if current_attack_type == attack_type.TO_BE_DETERMINED --Checks if is not started
    then
        -- Starts animation and timer
        current_attack_type = attack_type.ATTACKING_LEASH
        lua_table.AnimationFunctions:PlayAnimation(animation.leash.anim_name, animation.leash.anim_speed, lua_table.myUID)
        attack_timer = game_time + attack.leash.att_duration
        lua_table.SystemFunctions:LOG ("Kikimora: Leash Start")
    end
    if current_attack_type == attack_type.ATTACKING_LEASH --Checks if is started
    then
        if game_time <= attack_timer --Checks if ongoing
        then
            -- Activates collider                               TODO: TIME WELL COLLIDERS
            lua_table.GameObjectFunctions:SetActiveGameObject(true, attack_colliders.leash.GO_UID)
            -- Sets damage
            lua_table.collider_damage = attack.leash.att_damage
            -- Sets effect
            lua_table.collider_effect = attack_effect.none -- attack_effect.knockback TODO: Figure out how to send knockback to players.

        elseif game_time >= attack_timer --Checks if attack finished
        then
            attack.leash.att_cooldown_bool = true
            attack.leash.att_timer = game_time + attack.leash.att_cooldown_time
            attack_finished = true

            lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.leash.GO_UID)
            current_attack_type = attack_type.TO_BE_DETERMINED
            lua_table.SystemFunctions:LOG ("Kikimora: Leash Finish")
        end
    end
end

function HandleAttacks()

    -- For now kikimora will always want to attack (except when all attacks are on cooldown)
    if current_state ~= state.ATTACKING and current_state ~= state.AWAKENING and current_state ~= state.SWAPPING_PHASE and current_state ~= state.UNACTIVE
    then
        -- And will always use this priority (in order to avoid spam of the same attack they have different cooldowns, The higher the priority the higher the cooldown)
        -- Using elseif so only executes one (mental note, had a lapsus)
        if attack.roar.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleRoarAttack()

        elseif attack.stomp.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleStompAttack()

        elseif attack.sweep.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleSweepAttack()

        elseif attack.leash.att_cooldown_bool == false
        then
            current_state = state.ATTACKING
            HandleLeashAttack()
        end

    elseif current_state == state.ATTACKING -- if already attacking
    then
        if current_attack_type == attack_type.ATTACKING_ROAR
        then
            HandleRoarAttack()
        end

        if current_attack_type == attack_type.ATTACKING_STOMP
        then
            HandleStompAttack()
        end

        if current_attack_type == attack_type.ATTACKING_SWEEP
        then
            HandleSweepAttack()
        end

        if current_attack_type == attack_type.ATTACKING_LEASH
        then
            HandleLeashAttack()
        end
    end

    -- Updating state maybe should do it in handle states

    -- Updating cooldowns
    if attack.roar.att_cooldown_bool == true
    then
        if game_time >= attack.roar.att_timer and attack.roar.att_timer ~= 0
        then
            attack.roar.att_cooldown_bool = false
        end
    end

    if attack.stomp.att_cooldown_bool == true
    then
        if game_time >= attack.stomp.att_timer and attack.stomp.att_timer ~= 0
        then
            attack.stomp.att_cooldown_bool = false
        end
    end

    if attack.sweep.att_cooldown_bool == true
    then
        if game_time >= attack.sweep.att_timer and attack.sweep.att_timer ~= 0
        then
            attack.sweep.att_cooldown_bool = false
        end
    end

    if attack.leash.att_cooldown_bool == true
    then
        if game_time >= attack.leash.att_timer and attack.leash.att_timer ~= 0
        then
            attack.leash.att_cooldown_bool = false
        end
    end
end

function HandlePlayerPosition()

	if P1_id ~= 0
	then
		-- Gets position from Player 1 gameobject Id
		lua_table.P1_pos = lua_table.TransformFunctions:GetPosition(P1_id)

		if lua_table.P1_pos[x] == nil or lua_table.P1_pos[y] == nil or lua_table.P1_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 position nil")
		else
			-- Checks player proximity 
			if current_state == state.UNACTIVE
			then
				-- Calculates distance
				P1_abs_distance = math.sqrt((lua_table.P1_pos[x] * lua_table.P1_pos[x]) + (lua_table.P1_pos[z] * lua_table.P1_pos[z]))

				if P1_abs_distance ~= nil and P1_abs_distance <= lua_table.awakening_distance
				then
					player_in_awakening_distance = true
					lua_table.SystemFunctions:LOG ("Kikimora: SHOULD AWAKEN")
				end 
			end
		end
	end

	if P2_id ~= 0
	then
		-- Gets position from Player 2 gameobject Id
		lua_table.P2_pos = lua_table.TransformFunctions:GetPosition(P2_id)

		if lua_table.P2_pos[x] == nil or lua_table.P2_pos[y] == nil or lua_table.P2_pos[z] == nil
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 position nil")
		else
			-- Checks player proximity 
			if current_state == state.UNACTIVE
			then
				--Calculates distance
				P2_abs_distance = math.sqrt((lua_table.P2_pos[x] * lua_table.P2_pos[x]) + (lua_table.P2_pos[z] * lua_table.P2_pos[z]))

				if P2_abs_distance ~= nil and P2_abs_distance <= lua_table.awakening_distance
				then
					player_in_awakening_distance = true
					lua_table.SystemFunctions:LOG ("Kikimora: SHOULD AWAKEN")
				end 
			end
		end
    end
end

function HandleStates()
    -- State Unactive to Awaken
    if current_state == state.UNACTIVE and player_in_awakening_distance == true --Check if player in range and start awakening
    then 
        current_state = state.AWAKENING 
        lua_table.SystemFunctions:LOG ("Kikimora: AWAKENED")
        state_timer = game_time + 5 -- duration of awakening animation
        -- PLAY AWAKENING ANIMATION
    end

    if current_state == state.AWAKENING
    then
        if game_time >= state_timer
        then
            current_state = state.IDLE
            lua_table.SystemFunctions:LOG ("Kikimora: AWAKENING ended now idle")
        end
    end

    if current_state == state.IDLE
    then
        if game_time >= state_timer
        then
            lua_table.AnimationFunctions:PlayAnimation(animation.idle.anim_name, animation.idle.anim_speed, lua_table.myUID)
            state_timer = game_time + (animation.idle.anim_frames / animation.idle.anim_speed)
        end
    end

    if current_state == state.ATTACKING
    then
        if attack_finished == true
        then 
            attack_finished = false
            current_state = state.IDLE
            lua_table.SystemFunctions:LOG ("Kikimora: Attacks on cooldown now idle")
        end
    end

    if current_state == state.MOVING
    then
        -- Not moving for now
    end

    if current_state == state.JUMPING
    then
        -- Not jumping for now
    end

    if current_state == state.TAUNTING
    then
        -- Not taunting for now
    end

    if current_state == state.STUNNED
    then
        -- Not stunned for now
    end

    if current_state == state.SWAPPING_PHASE
    then
        if start_swapping == true
        then
            -- This is while I don't have a Swapping phase animation (maybe with a stun + roar would make the same effect)
            lua_table.AnimationFunctions:PlayAnimation(animation.roar.anim_name, animation.roar.anim_speed / 2, lua_table.myUID) -- It will have a times 2 duration
            animation_timer = game_time + attack.roar.att_duration * 2
            start_swapping = false
        end
    
        if game_time >= animation_timer
        then 
            current_state = state.IDLE
        end
    end

    if current_state == state.SPAWNING_MINIONS
    then
        -- Play spaawning minions animation
    end
        
end

-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Kikimora Script on AWAKE")
	
	-- Get my own UID
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()

	---------------------------------------------------------------------------
	-- Player UIDs
	---------------------------------------------------------------------------

	-- Player 1 id
	P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt_GO)	-- first checks if Geralt available

	if P1_id ~= 0
	then 
		lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Geralt)")

		-- Player 1 script (only if successfull id)
		lua_table.P1_script = lua_table.GameObjectFunctions:GetScript(P1_id)

		-- Player 2 id
		P2_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) --If Geralt available checks for Jaskier as player 2

		if P2_id == 0 
		then
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 2 id, check name of game object inside script")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Player 2 id successfully recieved (Jaskier)")

			-- Player 2 script (only if successfull id)
			lua_table.P2_script = lua_table.GameObjectFunctions:GetScript(P2_id)
		end
	else
		P1_id = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier_GO) -- If Geralt not available checks for Jaskier

		if P1_id ~= 0
		then 
			lua_table.SystemFunctions:LOG ("Kikimora: Player 1 id successfully recieved (Jaskier)")
		else
			lua_table.SystemFunctions:LOG ("Kikimora: Null Player 1 id")
		end
    end
    
    ---------------------------------------------------------------------------
	-- Attacks Init
    ---------------------------------------------------------------------------
    
    -- Attack colliders UIDs + setting them unactive
    attack_colliders.leash.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.leash.GO_name)
    attack_colliders.sweep.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.sweep.GO_name)
    attack_colliders.stomp.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.stomp.GO_name)
    attack_colliders.roar.GO_UID = lua_table.GameObjectFunctions:FindGameObject(attack_colliders.roar.GO_name)
    
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.stomp.GO_UID)
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.sweep.GO_UID)
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.leash.GO_UID)
    lua_table.GameObjectFunctions:SetActiveGameObject(false, attack_colliders.roar.GO_UID)

    -- Attacks duartion
    attack.leash.att_duration = animation.leash.anim_frames / animation.leash.anim_speed
    attack.sweep.att_duration = animation.sweep.anim_frames / animation.sweep.anim_speed
    attack.stomp.att_duration = animation.stomp.anim_frames / animation.stomp.anim_speed
    attack.roar.att_duration = animation.roar.anim_frames / animation.roar.anim_speed

    ---------------------------------------------------------------------------
	-- Health Init
    ---------------------------------------------------------------------------
    current_health = lua_table.health
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("Kikimora Script START")
	--lua_table.ParticlesFunctions:ActivateParticlesEmission(lua_table.myUID)

    HandlePlayerPosition()
    HandleStates()

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()
    game_time = PerfGameTime()

    HandlePlayerPosition()
    HandlePhases()
    HandleStates()
    HandleAttacks()
    

end

function lua_table:OnTriggerEnter()
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(lua_table.myUID)

	local collider_parent_GO
	local layer = lua_table.GameObjectFunctions:GetLayerByID(collider)

	if layer == layers.player_attack  --Checks if its player attack collider layer
	then
		collider_parent_GO = lua_table.GameObjectFunctions:GetGameObjectParent(collider)
		lua_table.collider_parent_script = lua_table.GameObjectFunctions:GetScript(collider_parent_GO)

		damage_received = lua_table.collider_parent_script.collider_damage

		lua_table.SystemFunctions:LOG ("Kikimora: damage received: ".. damage_received)

		current_health = current_health - damage_received
    end
end

function lua_table:OnCollisionEnter() -- NOT FINISHED
    local collider = lua_table.PhysicsFunctions:OnCollisionEnter(lua_table.myUID)
	-- lua_table.SystemFunctions:LOG("T:" .. collider)
end
	return lua_table
end

