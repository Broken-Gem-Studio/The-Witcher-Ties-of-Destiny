function GetTableArcherScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.Scene = Scripting.Scenes()
lua_table.AnimationSystem = Scripting.Animations()
lua_table.Navigation = Scripting.Navigation()
lua_table.Audio = Scripting.Audio()
lua_table.Particles = Scripting.Particles()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.Material = Scripting.Materials()

-- Targets
lua_table.geralt = "Geralt"
lua_table.jaskier = "Jaskier"
lua_table.arrow = 0
lua_table.Attack_Collider = "ArcherAttack"
local Attack_Collider_UID = 0

-- Archer Values -------------------------
lua_table.health = 150
lua_table.speed = 0.70
lua_table.Aggro_Range = 30

-- 
lua_table.DistanceToTarget = 0
lua_table.ClosestPlayer_ID = 0

lua_table.collider_damage = 8
lua_table.collider_effect = 0

local mesh_gameobject_UID = 0
local changed_material = false
local material_time = 0
local MyUID = 0

-- Archer main states ---------------------
local State = {
    IDL = 1,
    SEEK = 2,
    RANGE_ATTACK = 3,
    MELEE_ATTACK = 4,
    STUNNED = 5,
	DEATH = 6
}
lua_table.currentState = State.IDL

local Layers = {
    DEFAULT = 0,
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    ENEMY = 3,
    ENEMY_ATTACK = 4
}

local Effects = {
    NONE = 0,
    STUN = 1,
    KNOCKBACK = 2,
    TAUNT = 3,
    VENOM = 4
}

-- Animations --------------------------
lua_table.start_taking_arrow = true
lua_table.start_aiming = true
lua_table.start_shooting = true
local shoot_time = 0

local start_agro = false
local agro_time = 0

local start_running = false
local start_idle = false

local start_death = false
local time_death = 0

local start_melee = true
local melee_time = 0

lua_table.start_hit = false
local hit_time = 0

--- EFFECTS --------------------------------
lua_table.start_stun = false
local stun_time = 0 -- timer
lua_table.stun_duration = 3000 --milisecs

lua_table.start_knockback = false
lua_table.knockback_force = 1

local knockback_time = 0
local knock_direction = {}

local Taunt_GO_UID = 0
local start_taunt = false
local taunt_time = 0
---------------------------------------------
----- PARTICLES------------------------------
local Particles_GO = 0
local BloodParticle = 0
local TauntParticle = 0
local StunParticle = 0

lua_table.random = 0

------------- Pathfinding ---------------------
local corners = {}
local actual_corner = 2
local calculate_path = true
local time_path = 0
local DistToCorner = -1
---------------------------------------------
-- Players UID
local Geralt_ID = 0
local Jaskier_ID = 0

local last_player_hit = 0

-- Archer Position
local position = {}

-- Geralt Position
local Gpos = {}
local GeraltDistance = 0
local GX = 0
local GZ = 0
-- Jaskier Position
local Jpos = {}
local JaskierDistance = 0
local JX = 0
local JZ = 0

-- Target to attack
local Direction = {}
local TargetPos = {}
--------------------------------------------

local navigationID = 0

local function PerfGameTime()
	return lua_table.System:GameTime() * 1000
end

local function GimbalLockWorkaroundY(param_rot_y)

    if math.abs(lua_table.Transform:GetRotation(MyUID)[1]) == 180
    then
        if param_rot_y >= 0 then param_rot_y = 90 + 90 - param_rot_y
        elseif param_rot_y < 0 then param_rot_y = -90 + -90 - param_rot_y
        end
    end

    return param_rot_y
end

function lua_table:OnTriggerEnter()
    local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUID)
    local layer = lua_table.GameObjectFunctions:GetLayerByID(collider_GO)

    if layer == Layers.PLAYER_ATTACK and lua_table.health > 0 then
        local parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
        local script = lua_table.GameObjectFunctions:GetScript(parent)

        lua_table.health = lua_table.health - script.collider_damage

        lua_table.Material:SetMaterialByName("HitMaterial.mat", mesh_gameobject_UID)
        material_time = PerfGameTime()
        changed_material = true

        if parent == Geralt_ID then
            local particles = {}
            particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("BloodParticles", Particles_GO))
            
            for i=1, #particles do 
                lua_table.Particles:PlayParticleEmitter(particles[i])
            end

            if script.geralt_score ~= nil then
                if script.geralt_score[1] ~= nil then
                    script.geralt_score[1] = script.geralt_score[1] + script.collider_damage
               end
            end
            

            last_player_hit = Geralt_ID

        else 
            local particles = {}
            particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("HitParticles", Particles_GO))
            for i=1, #particles do 
                lua_table.Particles:PlayParticleEmitter(particles[i])
            end

            if script.jaskier_score ~= nil then
                if script.jaskier_score[1] ~= nil then
                    script.jaskier_score[1] = script.jaskier_score[1] + script.collider_damage
                end
            end

            

            last_player_hit = Jaskier_ID
        end
        
        
            
        
        if script.collider_effect ~= Effects.NONE then
            -- TODO: React depending on type of effect 
            if script.collider_effect == Effects.STUN then
                lua_table.start_stun = true
                lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
                stun_time = PerfGameTime()

                if script.collider_stun_duration ~= nil then
                    lua_table.stun_duration = script.collider_stun_duration
                end

                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("StunParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:PlayParticleEmitter(particles[i])
                end

                if parent == Geralt_ID then

                    if script.geralt_score ~= nil then
                        if script.geralt_score[4] ~= nil then
                            script.geralt_score[4] = script.geralt_score[4] + 1
                        end
                    end
                    
                    
        
                else 

                    if script.jaskier_score ~= nil then
                        if script.jaskier_score[4] ~= nil then
                            script.jaskier_score[4] = script.jaskier_score[4] + 1
                        end
                    end
                end

            elseif script.collider_effect == Effects.KNOCKBACK then
                --Calculate direction
                local col_pos = lua_table.Transform:GetPosition(parent)
                knock_direction[1] = position[1] - col_pos[1]
                knock_direction[2] = position[2] - col_pos[2]
                knock_direction[3] = position[3] - col_pos[3]

                local magn_dist =  math.sqrt(knock_direction[1]^2 + knock_direction[3]^2)
                --normalize
                knock_direction[1] = knock_direction[1] / magn_dist
                knock_direction[2] = 0
                knock_direction[3] = knock_direction[3] / magn_dist
                
                lua_table.start_knockback = true
                lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
                knockback_time = PerfGameTime()
                
            elseif script.collider_effect == Effects.TAUNT then
                start_taunt = true
                taunt_time = PerfGameTime()
                Taunt_GO_UID = parent

                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("AggroParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:PlayParticleEmitter(particles[i])
                end
            end
        else -- animatio hit
            lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
            hit_time = PerfGameTime()
            lua_table.start_hit = true
            lua_table.Audio:PlayAudioEvent("Play_Enemy_Humanoid_Hit")

            
        end
    end
end

-- Collider Calls 2.0 
function lua_table:RequestedTrigger(collider_GO)
	--lua_table.System:LOG("On RequestedTrigger")
	if lua_table.health > 0 then
        local player_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
        
        -- Recieve damage
        lua_table.health = lua_table.health - player_script.collider_damage
        lua_table.Material:SetMaterialByName("HitMaterial.mat", mesh_gameobject_UID)
        material_time = PerfGameTime()
        changed_material = true

        if collider_GO == Geralt_ID then

            if script.geralt_score ~= nil then
                if player_script.geralt_score[1] ~= nil then
                    player_script.geralt_score[1] = player_script.geralt_score[1] + player_script.collider_damage
                end
            end
            

            last_player_hit = Geralt_ID

        else 
            if script.jaskier_score ~= nil then
                if player_script.jaskier_score[1] ~= nil then
                    player_script.jaskier_score[1] = player_script.jaskier_score[1] + player_script.collider_damage
                end
            end
            

            last_player_hit = Jaskier_ID
        end

        if player_script.collider_effect ~= Effects.NONE then
            -- TODO: React depending on type of effect 
            if player_script.collider_effect == Effects.STUN then
                lua_table.start_stun = true
                lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
                stun_time = PerfGameTime()

                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("StunParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:PlayParticleEmitter(particles[i])
                end

                if collider_GO == Geralt_ID then

                    if script.geralt_score ~= nil then
                        if player_script.geralt_score[4] ~= nil then
                            player_script.geralt_score[4] = player_script.geralt_score[4] + 1
                        end
                    end
                    
        
                else 
                    if script.jaskier_score ~= nil then
                        if player_script.jaskier_score[4] ~= nil then
                            player_script.jaskier_score[4] = player_script.jaskier_score[4] + 1
                        end
                    end
                   
                end

            elseif player_script.collider_effect == Effects.KNOCKBACK then
                
                --Calculate direction
                local col_pos = lua_table.Transform:GetPosition(collider_GO)
                knock_direction[1] = position[1] - col_pos[1]
                knock_direction[2] = position[2] - col_pos[2]
                knock_direction[3] = position[3] - col_pos[3]

                local magn_dist =  math.sqrt(knock_direction[1]^2 + knock_direction[3]^2)
                --normalize
                knock_direction[1] = knock_direction[1] / magn_dist
                knock_direction[2] = 0
                knock_direction[3] = knock_direction[3] / magn_dist
                
                lua_table.start_knockback = true
                lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
                knockback_time = PerfGameTime()

            elseif player_script.collider_effect == Effects.TAUNT then
                start_taunt = true
                taunt_time = PerfGameTime()
                Taunt_GO_UID = collider_GO
                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("AggroParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:PlayParticleEmitter(particles[i])
                end

            end
        else -- animatio hit
            lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
            hit_time = PerfGameTime()
            lua_table.start_hit = true

            lua_table.Audio:PlayAudioEvent("Play_Enemy_Humanoid_Hit")
        end
  end
end

function lua_table:OnCollisionEnter()
    local collider = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
end

local function GetClosestPlayer()

    local scriptG = lua_table.GameObjectFunctions:GetScript(Geralt_ID)
    local scriptJ = lua_table.GameObjectFunctions:GetScript(Jaskier_ID)

    position = lua_table.Transform:GetPosition(MyUID)

    Gpos = lua_table.Transform:GetPosition(Geralt_ID)   
    Jpos = lua_table.Transform:GetPosition(Jaskier_ID)

    GX = Gpos[1] - position[1]
    GZ = Gpos[3] - position[3]

    if scriptG.current_state > -3 then
        GeraltDistance =  math.sqrt(GX^2 + GZ^2)
    else
      GeraltDistance = -1 
    end

    JX = Jpos[1] - position[1]
    JZ = Jpos[3] - position[3]

    if scriptJ.current_state > -3 then
        JaskierDistance =  math.sqrt(JX^2 + JZ^2)
    else
      JaskierDistance = -1 
    end

    

    if GeraltDistance ~= -1 then
        if JaskierDistance == -1 or GeraltDistance < JaskierDistance  then
            lua_table.ClosestPlayer_ID = Geralt_ID
        end
    end

    if JaskierDistance ~= -1 then
        if GeraltDistance == -1 or JaskierDistance < GeraltDistance then
            lua_table.ClosestPlayer_ID = Jaskier_ID
        end
    end

    if JaskierDistance == -1 and GeraltDistance == -1 then
        lua_table.ClosestPlayer_ID = 0;
    end

end

local function Seek()

    if start_agro == false 
    then 
        --lua_table.Audio:PlayAudioEvent("Play_Enemy_Humanoid_Discover_Players") This should be managed by spawners, audio is working on it
        lua_table.AnimationSystem:PlayAnimation("Hit",45.0, MyUID)
        agro_time = PerfGameTime()
        start_agro = true
    end

    if start_agro and agro_time + 1300 <= PerfGameTime()
    then
        if start_running == false 
        then
            lua_table.AnimationSystem:PlayAnimation("Run",45.0, MyUID)
            start_running = true
        end

        if time_path + 1000 <= PerfGameTime() then
            calculate_path = true
        end

        if calculate_path == true then
            corners = lua_table.Navigation:CalculatePath(position[1], position[2], position[3], TargetPos[1], TargetPos[2], TargetPos[3], 1 << navigation_ID)
            time_path = PerfGameTime()
            calculate_path = false
            actual_corner = 2
        end

        local NextCorner = {0,0,0}
        NextCorner[1] = corners[actual_corner][1] - position[1]
        NextCorner[2] = corners[actual_corner][2] - position[2]
        NextCorner[3] = corners[actual_corner][3] - position[3]
        
        DistToCorner = math.sqrt(NextCorner[1] ^ 2 + NextCorner[3] ^ 2)

        if DistToCorner > 0.2 then
            Direction[1] = NextCorner[1] / DistToCorner
            Direction[2] = 0
            Direction[3] = NextCorner[3] / DistToCorner

            lua_table.Transform:LookAt(corners[actual_corner][1], position[2], corners[actual_corner][3], MyUID)                
            lua_table.PhysicsSystem:Move(Direction[1]*lua_table.speed,Direction[3]*lua_table.speed, MyUID)
        else
            actual_corner = actual_corner + 1
            lua_table.PhysicsSystem:Move(0,0, MyUID)
        end

    end

    

end

local function Idle()

    if start_idle == false 
    then
        lua_table.AnimationSystem:PlayAnimation("Idle",30.0, MyUID)
        start_idle = true
    end


end

local function Shoot()

    if lua_table.start_taking_arrow == true 
    then
        shoot_time = PerfGameTime()
        -- PLAY ANIMATION TAKING ARROW (lasts 1s)
        --lua_table.System:LOG ("TAKING ARROW")
        lua_table.AnimationSystem:PlayAnimation("DrawArrow",45.0, MyUID)
        lua_table.start_taking_arrow = false
        --lua_table.Audio:PlayAudioEvent("Play_Bandit_bow_pulling_rope")
    end

    if shoot_time + 500 <= PerfGameTime() and lua_table.start_aiming == true 
    then
       -- lua_table.System:LOG ("AIMING")
        lua_table.AnimationSystem:PlayAnimation("Aim",45.0, MyUID)
        lua_table.start_aiming = false
    end

    if shoot_time + 1000 <= PerfGameTime() and lua_table.start_shooting == true 
    then
        
        lua_table.Audio:PlayAudioEvent("Play_Archer_Ranged_Attack")

        local rotation = lua_table.Transform:GetRotation(MyUID)
        local pos = lua_table.Transform:GetPosition(MyUID)

        local rot_fixed = GimbalLockWorkaroundY(rotation[2])

        local X = math.sin(math.rad(rot_fixed))
        local Z = math.cos(math.rad(rot_fixed))

        lua_table.Scene:Instantiate(lua_table.arrow, pos[1] + X*3, pos[2] + 3, pos[3]+ Z*3, 0, rot_fixed - 90, 0)

        lua_table.start_shooting = false
    end

    if shoot_time + 1250 <= PerfGameTime() 
    then
        if lua_table.start_taking_arrow == false then lua_table.start_taking_arrow = true
        end
        if lua_table.start_aiming == false then lua_table.start_aiming = true
        end
        if lua_table.start_shooting == false then lua_table.start_shooting = true
        end
    end

end

local function RestartShootValues()
    if lua_table.start_taking_arrow == false then lua_table.start_taking_arrow = true
    end
    if lua_table.start_aiming == false then lua_table.start_aiming = true
    end
    if lua_table.start_shooting == false then lua_table.start_shooting = true
    end
end

local function MeleeHit()

    if start_melee == true then
        melee_time = PerfGameTime()

        lua_table.random = math.random(1,10)

        if lua_table.random % 2 == 0 then 
            lua_table.AnimationSystem:PlayAnimation("MeleeKick",45.0, MyUID)
        else 
            lua_table.AnimationSystem:PlayAnimation("MeleePunch",45.0, MyUID)
        end
        
        lua_table.Audio:PlayAudioEvent("Play_Archer_Melee_Attack")
        --lua_table.System:LOG ("MELEE ATTACK")
        start_melee = false
    end

   

    if melee_time + 225 <= PerfGameTime() then
        lua_table.GameObjectFunctions:SetActiveGameObject(true, Attack_Collider_UID)
        
    end

    if melee_time + 275 <= PerfGameTime() then
        lua_table.GameObjectFunctions:SetActiveGameObject(false, Attack_Collider_UID)
    end

    if melee_time + 750 <= PerfGameTime() then
        start_melee = true
    end

end

local function RestartMeleeValues()
    start_melee = true
    melee_time = 0
end

----------------------------------------------------------------------------

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from ArcherScript on AWAKE")
    Particles_GO = lua_table.GameObjectFunctions:FindChildGameObject("ArcherParticles")

end

function lua_table:Start()
    Geralt_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt)
    Jaskier_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier)
    Attack_Collider_UID = lua_table.GameObjectFunctions:FindChildGameObject(lua_table.Attack_Collider)
    mesh_gameobject_UID = lua_table.GameObjectFunctions:FindChildGameObject("Archer_Mesh")
    
    

    MyUID = lua_table.GameObjectFunctions:GetMyUID()

    navigation_ID = lua_table.Navigation:GetAreaFromName("Walkable")

    lua_table.AnimationSystem:SetBlendTime(0.10, MyUID)

    


end

function lua_table:Update()

    -- if lua_table.InputFunctions:KeyDown("K") then 
    --    start_taunt = true
    --    taunt_time = PerfGameTime()
    --     Taunt_GO_UID = Jaskier_ID
    --     local particles = {}
    --     particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("AggroParticles", Particles_GO))
    --     for i=1, #particles do 
    --         lua_table.Particles:PlayParticleEmitter(particles[i])
    --     end
        
    -- end

    -- if lua_table.InputFunctions:KeyDown("M") then 
    --     lua_table.start_stun = true
    --     lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
    --     stun_time = PerfGameTime()
    --     local particles = {}
    --     particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("StunParticles", Particles_GO))
    --     for i=1, #particles do 
    --         lua_table.Particles:PlayParticleEmitter(particles[i])
    --     end
        
    -- end

   

    GetClosestPlayer()

    if position[2] <= -100 then
        lua_table.Transform:SetPosition(position[1], 100, position[3], MyUID)
    end

    lua_table.speed = 8 * lua_table.System:DT()

    -- ------------------------------------Decide Target----------------------------------
    if not start_taunt
    then

        if lua_table.ClosestPlayer_ID == Geralt_ID then
            lua_table.DistanceToTarget = GeraltDistance
            TargetPos = Gpos
        elseif lua_table.ClosestPlayer_ID == Jaskier_ID then
            lua_table.DistanceToTarget = JaskierDistance
            TargetPos = Jpos
        else
            lua_table.DistanceToTarget = -1;
        end
    else
        if Taunt_GO_UID == Geralt_ID then
            lua_table.DistanceToTarget = GeraltDistance
            TargetPos = Gpos
        elseif Taunt_GO_UID == Jaskier_ID then
            lua_table.DistanceToTarget = JaskierDistance
            TargetPos = Jpos
        end
    end

    if material_time + 100 <= PerfGameTime() and changed_material == true then
        lua_table.Material:SetMaterialByName("ArcherMaterial.mat", mesh_gameobject_UID)
        changed_material = false
    end

    -- ----------------------Manage Archer States | value needs test ------------------------------------------------------

    if lua_table.health > 0.0 and lua_table.start_hit == false and lua_table.start_knockback == false
    then
        if lua_table.start_stun == false
        then
            if lua_table.DistanceToTarget <= lua_table.Aggro_Range and lua_table.DistanceToTarget > 14 then
                lua_table.currentState = State.SEEK
            elseif lua_table.DistanceToTarget <= 14 and lua_table.DistanceToTarget > 4 then
                lua_table.currentState = State.RANGE_ATTACK
            elseif lua_table.DistanceToTarget <= 4 and  lua_table.DistanceToTarget >=0 then
                lua_table.currentState = State.MELEE_ATTACK
            else
                lua_table.currentState = State.IDL
            end
        else   
            if lua_table.start_stun == true then
                lua_table.currentState = State.STUNNED
            end
        end
    
        ---------------------------------------------- Manage Archer Actions depending on STATE ----------------------------------------------------
    
        if lua_table.currentState == State.RANGE_ATTACK or lua_table.currentState == State.MELEE_ATTACK then
            if lua_table.ClosestPlayer_ID ~= 0 then
                lua_table.Transform:LookAt(TargetPos[1], position[2], TargetPos[3], MyUID)
            end
        end
    
        -- RESET ANIMATION VALUES ---------------------------
        if lua_table.currentState ~= State.RANGE_ATTACK then
            RestartShootValues()
        end
        if lua_table.currentState ~= State.MELEE_ATTACK then
            RestartMeleeValues()
        end
        if lua_table.currentState ~= State.SEEK then
            start_running = false
            actual_corner = 2
            calculate_path = true
        end
        if lua_table.currentState ~= State.IDL then
            start_idle = false 
        end
    

        if start_taunt and taunt_time + 5000 <= PerfGameTime() then
            start_taunt = false
            local particles = {}
            particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("AggroParticles", Particles_GO))
            for i=1, #particles do 
                lua_table.Particles:StopParticleEmitter(particles[i])
            end
            
        end


        --- ACTIONS -----------------------------------------
        if lua_table.currentState == State.SEEK then
            Seek()
        elseif lua_table.currentState == State.RANGE_ATTACK then
            --lua_table.System:LOG ("MELEE ATTACK")
            Shoot()
        elseif lua_table.currentState == State.MELEE_ATTACK then
            MeleeHit()
        elseif lua_table.currentState == State.IDL then
            Idle()
        elseif lua_table.currentState == State.STUNNED then
            if lua_table.start_stun == true and stun_time + lua_table.stun_duration <= PerfGameTime() then
                lua_table.start_stun = false
                lua_table.stun_duration = 3000
                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("StunParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:StopParticleEmitter(particles[i])
                end
            end
        end

    else
        if lua_table.health <= 0.0
        then
            lua_table.currentState = State.DEATH

            if start_death == false 
            then
                --lua_table.Audio:PlayAudioEvent("Play_Bandit_death_3")
                local rand = math.random(35,55)
                lua_table.AnimationSystem:PlayAnimation("Death",rand, MyUID) -- 2.33sec
                time_death = PerfGameTime()
                start_death = true

                lua_table.PhysicsSystem:SetActiveController(false, MyUID)

                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("DeathParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:PlayParticleEmitter(particles[i])
                end

                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("AggroParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:StopParticleEmitter(particles[i])
                end

                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("StunParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:StopParticleEmitter(particles[i])
                end
                
                local script = lua_table.GameObjectFunctions:GetScript(last_player_hit)

                -- if script ~= nil then
                --     if last_player_hit == Geralt_ID then
                --         if script.geralt_score[3] ~= nil then 
                --             script.geralt_score[3] = script.geralt_score[3] + 1 
                --         end
                --     else
                --         if script.jaskier_score[3] ~= nil then script.jaskier_score[3] = script.jaskier_score[3] + 1 
                --         end
                --     end
                -- end
               

                local tuto_manager = lua_table.GameObjectFunctions:FindGameObject("TutorialManager")
                if tuto_manager ~= 0
                then 
                    local tuto_table = lua_table.GameObjectFunctions:GetScript(tuto_manager)
                    tuto_table.enemiesToKill = tuto_Table.enemiesToKill - 1
                end
            end

            if time_death + 4000 <= PerfGameTime()
            then
                lua_table.GameObjectFunctions:DestroyGameObject(MyUID)
            end
        elseif lua_table.start_hit == true then

            if hit_time + 1500 <= PerfGameTime() then
                lua_table.start_hit = false
            end

        elseif lua_table.start_knockback == true then
            if knockback_time + 200 <= PerfGameTime() then 
                lua_table.start_knockback = false 
                -- restart values
                RestartShootValues()
                RestartMeleeValues()
                start_running = false
                actual_corner = 2
                calculate_path = true
                start_idle = false 

                lua_table.stun_duration = 1000
                lua_table.start_stun = true
                stun_time = PerfGameTime()
                local particles = {}
                particles = lua_table.GameObjectFunctions:GetGOChilds(lua_table.GameObjectFunctions:FindChildGameObjectFromGO("StunParticles", Particles_GO))
                for i=1, #particles do 
                    lua_table.Particles:PlayParticleEmitter(particles[i])
                end

            else
                lua_table.PhysicsSystem:Move(knock_direction[1]*lua_table.knockback_force, knock_direction[3]*lua_table.knockback_force, MyUID)
            end
        end

        
    end

    

end

return lua_table
end