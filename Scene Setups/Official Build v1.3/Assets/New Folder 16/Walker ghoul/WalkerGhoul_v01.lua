function GetTableWalkerGhoul_v01()

local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsFunctions =  Scripting.Physics()
lua_table.AnimationFunctions = Scripting.Animations()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.ParticleFunctions = Scripting.Particles()
lua_table.NavigationFunctions = Scripting.Navigation()
lua_table.MaterialFunctions = Scripting.Materials()
lua_table.InputFunctions = Scripting.Inputs()

-----------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------

-- Lua table variabes
lua_table.ghoul_UUID = 0
lua_table.movementSpeed = 10
lua_table.collider_damage = 10
lua_table.collider_effect = 0
lua_table.evadeSpeed = 20
lua_table.knockbackSpeed = 200
lua_table.maxHealth = 400
lua_table.health = 0
lua_table.maxEvades = 2
lua_table.seekDistance = 40
lua_table.screamDistance = 8
lua_table.evadeDistance = 5
lua_table.pathThreshold = 0.25
lua_table.dead = false
lua_table.hit = false
lua_table.stunned = false
lua_table.taunted = false

local State = {
    IDLE = 1,
    SUMMONING = 2, 
    SCREAMING = 3,
    SEEK = 4,
    EVADE = 5,
    DEATH = 6,    
    ALERT = 7,     
    KNOCKBACK = 8,
    PUNCHING = 9
}

local Layer = {
    DEFAULT = 0,
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    ENEMY = 3,
    ENEMY_ATTACK = 4
}

local Effect = {
    NONE = 0,
    STUN = 1,
    KNOCKBACK = 2,
    TAUNT = 3,
    VENOM = 4
}

local currentState = State.IDLE
local MyUUID = 0
local meshUUID = 0
local dt = 0
local evades = 0
local maxDistanceToCamera = 80
local currentTarget_UUID = 0
local cornerCounter = 1
local first_time = true
local canStartScreaming = true
local canStartPunch = true
local canStandUp = true
local canStartEvanding = true
local white = false

-- Timers and cooldowns
local lastTimeEvaded = 0
local evadingTime = 0.7
local preparingEvadeTime = 0.3
local evadeCooldown = 3
local evadeResetTimer = 10

local lastTimeArrived = 0
local waitingForNextPursue = 0.3

local lastTimeSummoned = 0
local summoningTime = 2
local summonCooldown = 15

local lastTimeScreamed = 0
local preparingScreamTime = 1
local screamingTime = 1
local screamingCooldown = 10

local lastTimePunch = 0
local anticipationTime = 0.75
local punchTime = 0.4
local punchCooldown = 2

local lastTimeStunned = 0
local stunTime = 2.5

local lastTimeHit = 0
local hitTime = 0.5

local lastTimeWhite = 0
local whiteTime = 0.1

local lastTimeTaunted = 0
local tauntTime = 5

local lastTimeKnockback = 0
local knockbackTime = 1
local standingTime = 1.5

local lastTimeDead = 0
local deathTime = 5

local lastTimeAlert = 0
local alertTime = 2

-----------------------------------------------------------------------------
-- WALKER GHOUL FUNCTIONS
-----------------------------------------------------------------------------

local function NormalizeVector(vector)
	module = math.sqrt(vector[1] ^ 2 + vector[3] ^ 2)

    local newVector = {0, 0, 0}
    newVector[1] = vector[1] / module
    newVector[2] = vector[2] / module
    newVector[3] = vector[3] / module
    return newVector
end

local function PlayParticles(emitter_UUID)
    local emitters = lua_table.ObjectFunctions:GetGOChilds(emitter_UUID)

    for i = 1, #emitters do
        lua_table.ParticleFunctions:PlayParticleEmitter(emitters[i])
    end
end

local function StopParticles(emitter_UUID)
    local emitters = lua_table.ObjectFunctions:GetGOChilds(emitter_UUID)

    for i = 1, #emitters do
        lua_table.ParticleFunctions:StopParticleEmitter(emitters[i])
    end
end

local function CalculateDistances() 

    lua_table.GeraltPosition = {1000, 1000, 1000}
    lua_table.JaskierPosition = {1000, 1000, 1000}

    -- We check the players are stil alive
    if lua_table.Geralt_UUID ~= 0 
    then    
        local geralt_table = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)
        if geralt_table.current_state > -3
        then
            lua_table.GeraltPosition = lua_table.TransformFunctions:GetPosition(lua_table.Geralt_UUID)
        end        
    end

    if lua_table.Jaskier_UUID ~= 0
    then
        local jaskier_table = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)
        if jaskier_table.current_state > -3
        then
            lua_table.JaskierPosition = lua_table.TransformFunctions:GetPosition(lua_table.Jaskier_UUID)               
        end           
    end

    -- Calculate the distance from the ghoul to the camera
    lua_table.MyPosition = lua_table.TransformFunctions:GetPosition(MyUUID)
    lua_table.CameraPosition = lua_table.TransformFunctions:GetPosition(lua_table.Camera_UUID)
    lua_table.DistanceToCamera = math.sqrt((lua_table.CameraPosition[1] - lua_table.MyPosition[1]) ^ 2 + (lua_table.CameraPosition[3] - lua_table.MyPosition[3]) ^ 2)
    
    -- Calculate the distance from the ghoul to the players
    lua_table.JaskierDistance = math.sqrt((lua_table.JaskierPosition[1] - lua_table.MyPosition[1]) ^ 2 + (lua_table.JaskierPosition[3] - lua_table.MyPosition[3]) ^ 2)
    lua_table.GeraltDistance = math.sqrt((lua_table.GeraltPosition[1] - lua_table.MyPosition[1]) ^ 2 + (lua_table.GeraltPosition[3] - lua_table.MyPosition[3]) ^ 2)

    -- We get the position and distance to the closest player
    lua_table.ClosestDistance = lua_table.GeraltDistance
    lua_table.ClosestPosition = lua_table.GeraltPosition

    if lua_table.JaskierDistance < lua_table.GeraltDistance
    then 
        lua_table.ClosestDistance = lua_table.JaskierDistance 
        lua_table.ClosestPosition = lua_table.JaskierPosition 
    end

    lua_table.VectorToClosest = {0, 0, 0}
    lua_table.VectorToClosest[1] = lua_table.ClosestPosition[1] - lua_table.MyPosition[1]
    lua_table.VectorToClosest[2] = lua_table.ClosestPosition[2] - lua_table.MyPosition[2]
    lua_table.VectorToClosest[3] = lua_table.ClosestPosition[3] - lua_table.MyPosition[3]
end

local function HandleGhoulValues()
    -- Handle altered states
    if lua_table.stunned and lua_table.SystemFunctions:GameTime() > lastTimeStunned + stunTime
    then
        lua_table.stunned = false
        StopParticles(lua_table.StunEmitter_UUID)
    end    
    if lua_table.taunted and lua_table.SystemFunctions:GameTime() > lastTimeTaunted + tauntTime
    then
        lua_table.taunted = false
        StopParticles(lua_table.TauntEmitter_UUID)
    end
    if lua_table.hit and lua_table.SystemFunctions:GameTime() > lastTimeHit + hitTime
    then
        lua_table.hit = false
        StopParticles(lua_table.BodyEmitter_UUID)
        StopParticles(lua_table.HitEmitter_UUID)
    end
    if white and lua_table.SystemFunctions:GameTime() > lastTimeWhite + whiteTime
    then
        white = false
        lua_table.MaterialFunctions:SetMaterialByName("ScreamerMat.mat", meshUUID)
    end

    -- Handle evade budget reset
    if lua_table.SystemFunctions:GameTime() > lastTimeEvaded + evadeResetTimer
    then
        evades = lua_table.maxEvades
    end
end

local function Idle()    
    if lua_table.hit == false and lua_table.stunned == false and currentState ~= State.KNOCKBACK and currentState ~= State.DEATH
    then
        -- Looks for proximity to the players
        if lua_table.ClosestDistance <= lua_table.evadeDistance and lua_table.SystemFunctions:GameTime() > lastTimeEvaded + evadeCooldown and evades > 0 and lua_table.taunted == false
        then 
            currentState = State.EVADE
            lua_table.EvadePosition = lua_table.ClosestPosition
            lastTimeEvaded = lua_table.SystemFunctions:GameTime()
            evades = evades - 1
            lua_table.AnimationFunctions:PlayAnimation("Evade", 40, MyUUID)  
            lua_table.AudioFunctions:PlayAudioEvent("Play_Screamer_ghoul_fall_back")
            lua_table.SystemFunctions:LOG("Ghoul state is EVADE")

        elseif lua_table.ClosestDistance <= lua_table.screamDistance
        then
            if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summonCooldown and lua_table.taunted == false
            then  
                currentState = State.SUMMONING
                lastTimeSummoned = lua_table.SystemFunctions:GameTime()
                lua_table.AnimationFunctions:PlayAnimation("Scream", 30, MyUUID)        
                lua_table.AudioFunctions:PlayAudioEvent("Play_Screamer_ghoul_scream_variation")
                lua_table.SystemFunctions:LOG("Ghoul state is SUMMONING")

            elseif lua_table.SystemFunctions:GameTime() > lastTimeScreamed + screamingCooldown and lua_table.taunted == false
            then
                currentState = State.SCREAMING
                lastTimeScreamed = lua_table.SystemFunctions:GameTime()                       
                lua_table.collider_damage = 10
                lua_table.collider_effect = 2
                lua_table.AnimationFunctions:PlayAnimation("Roar", 40, MyUUID)   
                lua_table.AudioFunctions:PlayAudioEvent("Play_Screamer_ghoul_scream_attack")       
                lua_table.SystemFunctions:LOG("Ghoul state is SCREAMING")
            
            elseif lua_table.SystemFunctions:GameTime() > lastTimePunch + punchCooldown and lua_table.ClosestDistance < 4
            then
                currentState = State.PUNCHING
                lastTimePunch = lua_table.SystemFunctions:GameTime()                   
                lua_table.collider_damage = 30
                lua_table.collider_effect = 0
                lua_table.AnimationFunctions:PlayAnimation("Punch", 50, MyUUID)  
                lua_table.SystemFunctions:LOG("Ghoul state is PUNCHING")
            end

        elseif lua_table.ClosestDistance <= lua_table.seekDistance
        then
            if first_time == true
            then
                currentState = State.ALERT
                lua_table.AnimationFunctions:PlayAnimation("Alert", 30, MyUUID) 
                lastTimeAlert = lua_table.SystemFunctions:GameTime()
                first_time = false

            elseif lua_table.SystemFunctions:GameTime() > lastTimeArrived + waitingForNextPursue
            then
                currentState = State.SEEK       
                lua_table.AnimationFunctions:PlayAnimation("Run", 30, MyUUID)
                if lua_table.taunted == true
                then    
                    local objectivePosition = lua_table.TransformFunctions:GetPosition(lua_table.AttackDealer_UUID)
                    lua_table.PathCorners = lua_table.NavigationFunctions:CalculatePath(lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3], objectivePosition[1], objectivePosition[2], objectivePosition[3], 1 << lua_table.WalkableID)    
                    lua_table.SystemFunctions:LOG("Ghoul state is TAUNTED")
                else
                    lua_table.PathCorners = lua_table.NavigationFunctions:CalculatePath(lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3], lua_table.ClosestPosition[1], lua_table.ClosestPosition[2], lua_table.ClosestPosition[3], 1 << lua_table.WalkableID)
                    lua_table.SystemFunctions:LOG("Ghoul state is SEEK") 
                end
            end
        end  
    end
end

local function Seek()
    if ((lua_table.ClosestDistance >= lua_table.screamDistance and lua_table.ClosestDistance <= lua_table.seekDistance) or lua_table.taunted == true) and cornerCounter <= #lua_table.PathCorners
    then               
        -- Calculate distance to the next corner
        local vectorToCorner = {0, 0, 0}
        vectorToCorner[1] = lua_table.PathCorners[cornerCounter][1] - lua_table.MyPosition[1]
        vectorToCorner[2] = lua_table.PathCorners[cornerCounter][2] - lua_table.MyPosition[2]
        vectorToCorner[3] = lua_table.PathCorners[cornerCounter][3] - lua_table.MyPosition[3]
        local distanceToCorner = math.sqrt(vectorToCorner[1] ^ 2 + vectorToCorner[3] ^ 2)

        -- Check if it has arrived
        if distanceToCorner > lua_table.pathThreshold
        then
            local velocity = NormalizeVector(vectorToCorner)
            lua_table.TransformFunctions:LookAt(lua_table.PathCorners[cornerCounter][1], lua_table.MyPosition[2], lua_table.PathCorners[cornerCounter][3], MyUUID)
            lua_table.PhysicsFunctions:Move(velocity[1] * lua_table.movementSpeed * dt, velocity[3] * lua_table.movementSpeed * dt, MyUUID)
        else           
            lua_table.PhysicsFunctions:Move(0, 0, MyUUID)
            cornerCounter = cornerCounter + 1
        end
    else     
        lua_table.PhysicsFunctions:Move(0, 0, MyUUID)
        lastTimeArrived = lua_table.SystemFunctions:GameTime()
        cornerCounter = 1
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end
end

local function Evade()  
    if lua_table.SystemFunctions:GameTime() < lastTimeEvaded + preparingEvadeTime
    then    
        lua_table.TransformFunctions:LookAt(lua_table.EvadePosition[1], lua_table.MyPosition[2], lua_table.EvadePosition[3], MyUUID)

    elseif lua_table.SystemFunctions:GameTime() < lastTimeEvaded + evadingTime + preparingEvadeTime
    then
        local vector = {0, 0, 0}
        vector[1] = lua_table.EvadePosition[1] - lua_table.MyPosition[1]
        vector[2] = lua_table.EvadePosition[2] - lua_table.MyPosition[2]
        vector[3] = lua_table.EvadePosition[3] - lua_table.MyPosition[3]
        local velocity = NormalizeVector(vector)
        lua_table.PhysicsFunctions:Move(-velocity[1] * lua_table.evadeSpeed * dt, -velocity[3] * lua_table.evadeSpeed * dt, MyUUID)    
        
    else
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end
end

local function Summon()
    if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summoningTime
    then
        lua_table.AudioFunctions:PlayAudioEvent("Play_Screamer_ghoul_minion_spawn")    
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3] + 3, 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] + 3, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] - 3, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end
end

local function Scream() 
    -- Aims for the closest player
    if lua_table.SystemFunctions:GameTime() < lastTimeScreamed + preparingScreamTime
    then    
        local vector = {0, 0, 0}
        vector[1] = lua_table.ClosestPosition[1] - lua_table.MyPosition[1]
        vector[2] = lua_table.ClosestPosition[2] - lua_table.MyPosition[2]
        vector[3] = lua_table.ClosestPosition[3] - lua_table.MyPosition[3]

        lua_table.ScreamingVelocity = NormalizeVector(vector)
        lua_table.TransformFunctions:LookAt(lua_table.ClosestPosition[1], lua_table.MyPosition[2], lua_table.ClosestPosition[3], MyUUID)
    
    -- Locks position and screams
    elseif canStartScreaming == true
    then    
        PlayParticles(lua_table.ScreamEmitter_UUID)  
        
        local emitters = lua_table.ObjectFunctions:GetGOChilds(lua_table.ScreamEmitter_UUID)
        for i = 1, #emitters do
            lua_table.ParticleFunctions:SetParticlesVelocity(lua_table.ScreamingVelocity[1] * 25, 0, lua_table.ScreamingVelocity[3] * 25, emitters[i])
        end          

        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.ScreamCollider_UUID)  
        canStartScreaming = false

    elseif lua_table.SystemFunctions:GameTime() > lastTimeScreamed + preparingScreamTime + screamingTime
    then
        lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.ScreamCollider_UUID)  
        StopParticles(lua_table.ScreamEmitter_UUID) 
        currentState = State.IDLE
        canStartScreaming = true
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID) 
    end
end

local function Punch()
    -- Aims for the player near to him
    if lua_table.SystemFunctions:GameTime() < lastTimePunch + anticipationTime
    then
        lua_table.TransformFunctions:LookAt(lua_table.ClosestPosition[1], lua_table.MyPosition[2], lua_table.ClosestPosition[3], MyUUID)
    
    -- Locks position and punches
    elseif canStartPunch == true
    then
        lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.PunchCollider_UUID)
        canStartPunch = false

    elseif lua_table.SystemFunctions:GameTime() > lastTimePunch + anticipationTime + punchTime
    then
        lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.PunchCollider_UUID)  
        currentState = State.IDLE
        canStartPunch = true
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID) 
    end
end

local function Knockback()
    -- Falls and slides away from the player
    if lua_table.SystemFunctions:GameTime() < lastTimeKnockback + knockbackTime
    then
        local objectivePosition = lua_table.TransformFunctions:GetPosition(lua_table.AttackDealer_UUID)
        lua_table.VectorToObjective = {0, 0, 0}
        lua_table.VectorToObjective[1] = objectivePosition[1] - lua_table.MyPosition[1]
        lua_table.VectorToObjective[2] = objectivePosition[2] - lua_table.MyPosition[2]
        lua_table.VectorToObjective[3] = objectivePosition[3] - lua_table.MyPosition[3]
        lua_table.ObjectiveDistance = math.sqrt(lua_table.VectorToObjective[1] ^ 2 + lua_table.VectorToObjective[3] ^ 2)        
        
        local velocity = NormalizeVector(lua_table.VectorToObjective)
        lua_table.PhysicsFunctions:Move((-velocity[1] * lua_table.knockbackSpeed/2 * dt) / (lua_table.ObjectiveDistance * 1.25), (-velocity[3] * lua_table.knockbackSpeed/2 * dt) / (lua_table.ObjectiveDistance * 1.25), MyUUID)     
        lua_table.TransformFunctions:LookAt(objectivePosition[1], lua_table.MyPosition[2], objectivePosition[3], MyUUID)

    -- Stands up
    elseif canStandUp == true
    then                
        lua_table.AnimationFunctions:PlayAnimation("Stand", 40, MyUUID) 
        canStandUp = false

    elseif lua_table.SystemFunctions:GameTime() > lastTimeKnockback + knockbackTime + standingTime
    then
        currentState = State.IDLE
        canStandUp = true
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end 
end

local function Die()
    if lua_table.dead == false
    then
        local aux = lua_table.SystemFunctions:RandomNumberInRange(15, 45)
        lua_table.AnimationFunctions:PlayAnimation("Death", aux, MyUUID)
        lua_table.AudioFunctions:PlayAudioEvent("Play_Screamer_ghoul_death")        
        lua_table.PhysicsFunctions:SetActiveController(false, MyUUID)

        StopParticles(lua_table.StunEmitter_UUID)
        StopParticles(lua_table.TauntEmitter_UUID)
        StopParticles(lua_table.ScreamEmitter_UUID)
        PlayParticles(lua_table.DeathEmitter_UUID)

        lua_table.dead = true
        lastTimeDead = lua_table.SystemFunctions:GameTime()
        lua_table.SystemFunctions:LOG("Ghoul state is DEATH")
    elseif lua_table.SystemFunctions:GameTime() > lastTimeDead + deathTime 
    then
        StopParticles(lua_table.DeathEmitter_UUID)
        lua_table.ObjectFunctions:DestroyGameObject(MyUUID)
    end
end		

-----------------------------------------------------------------------------
-- COLISIONS
-----------------------------------------------------------------------------

local function ReceiveEffect(player_table, attackState)        
    -- Access to players' score
    local character_score = {}
    local tableFound = false
    if lua_table.AttackDealer_UUID == lua_table.Geralt_UUID
    then
        if geralt_score ~= nil 
        then
            character_score = geralt_score
            tableFound = true
        end
    elseif lua_table.AttackDealer_UUID == lua_table.Jaskier_UUID
    then
        if jaskier_score ~= nil 
        then
            character_score = jaskier_score
            tableFound = true
        end
    end
    
    -- Set mesh material to white for hit feedback
    lua_table.MaterialFunctions:SetMaterialByName("HitMaterial.mat", meshUUID)
    lastTimeWhite = lua_table.SystemFunctions:GameTime()
    white = true        

    -- Checks if the attack has beeen strong enough to interrupt canalizations
    if player_table.collider_effect ~= Effect.NONE or (attackState ~= 8 and attackState ~= 9 and attackState ~= 10) 
    then            
        if (player_table.collider_effect == Effect.KNOCKBACK or player_table.collider_effect == Effect.STUN or player_table.collider_effect == Effect.TAUNT) and tableFound == true
        then
            character_score[4] = character_score[4] + 1
        end 
        StopParticles(lua_table.ScreamEmitter_UUID)           
        lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.ScreamCollider_UUID)  
        lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.PunchCollider_UUID) 
        lua_table.collider_effect = 0
    end

    -- Handle attack effect
    if player_table.collider_effect == Effect.STUN
    then
        lua_table.stunned = true            
        currentState = State.IDLE
        lastTimeStunned = lua_table.SystemFunctions:GameTime()
        if player_table.collider_stun_duration ~= 0
        then
            stunTime = player_table.collider_stun_duration / 1000
        end
        PlayParticles(lua_table.StunEmitter_UUID)
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID) 

	elseif player_table.collider_effect == Effect.KNOCKBACK
    then
        currentState = State.KNOCKBACK
        lastTimeKnockback = lua_table.SystemFunctions:GameTime()  
        lua_table.AnimationFunctions:PlayAnimation("Knockback", 40, MyUUID)     
        if player_table.collider_knockback_speed ~= 0
        then
           lua_table.knockbackSpeed = player_table.collider_knockback_speed
        end
            
    elseif player_table.collider_effect == Effect.TAUNT
    then
        lua_table.taunted = true
        currentState = State.IDLE
        lastTimeTaunted = lua_table.SystemFunctions:GameTime()
        PlayParticles(lua_table.TauntEmitter_UUID)   

    else
        if attackState ~= 8 and attackState ~= 9 and attackState ~= 10
        then
            lua_table.hit = true
            currentState = State.IDLE  
            lastTimeHit = lua_table.SystemFunctions:GameTime()
            lua_table.AnimationFunctions:PlayAnimation("Hit", 50, MyUUID)
            lua_table.AudioFunctions:PlayAudioEvent("Play_Screamer_ghoul_damaged")                          
        end         
        
        lua_table.SystemFunctions:LOG("Ghoul has been HIT") 
        if lua_table.AttackDealer_UUID == lua_table.Geralt_UUID
        then
            PlayParticles(lua_table.BodyEmitter_UUID)
        elseif lua_table.AttackDealer_UUID == lua_table.Jaskier_UUID
        then 
            PlayParticles(lua_table.HitEmitter_UUID)
        end
    end    

    -- Receive attack damage 
    lua_table.health = lua_table.health - player_table.collider_damage   
    if tableFound == true 
    then 
        character_score[1] = character_score[1] + player_table.collider_damage 
    end
    if lua_table.health <= 0
	then 
        currentState = State.DEATH
        if tableFound == true 
        then 
            character_score[3] = character_score[3] + 1
        end
    end
end 

function lua_table:OnTriggerEnter()	
	local trigger_collider = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)
    local layer = lua_table.ObjectFunctions:GetLayerByID(trigger_collider)

    if layer == Layer.PLAYER_ATTACK and currentState ~= State.DEATH	
    then
        local player_table = {}        
        local parent = lua_table.ObjectFunctions:GetGameObjectParent(trigger_collider)

        local attackState = 0
        if parent ~= 0
        then
            player_table = lua_table.ObjectFunctions:GetScript(parent)
            attackState = player_table.current_state 
            lua_table.AttackDealer_UUID = parent
        else 
            player_table = lua_table.ObjectFunctions:GetScript(trigger_collider)
            lua_table.AttackDealer_UUID = trigger_collider
        end      	

        ReceiveEffect(player_table, attackState)	
    end
end

function lua_table:RequestedTrigger(trigger_collider)
    lua_table.SystemFunctions:LOG("Walker Ghooul's OnRequestedTrigger has been called")        
    if currentState ~= State.DEATH	
	then
        local player_table = lua_table.ObjectFunctions:GetScript(trigger_collider)  
        local attackState = player_table.current_state  
        lua_table.AttackDealer_UUID = trigger_collider

        ReceiveEffect(player_table, attackState)
	end
end

function lua_table:OnCollisionEnter()
	local collider = lua_table.PhysicsFunctions:OnCollisionEnter(MyUUID)
	--lua_table.SystemFunctions:LOG("OnCollisionEnter(): entered collider from GameObject with UUID " .. collider)
end

-----------------------------------------------------------------------------
-- GAME LOOP
-----------------------------------------------------------------------------

function lua_table:Awake()
   -- Get necessary UUIDs
   lua_table.Geralt_UUID = lua_table.ObjectFunctions:FindGameObject("Geralt")
   lua_table.Jaskier_UUID = lua_table.ObjectFunctions:FindGameObject("Jaskier") 
   lua_table.Camera_UUID = lua_table.ObjectFunctions:FindGameObject("Camera") 
   MyUUID = lua_table.ObjectFunctions:GetMyUID()
   meshUUID = lua_table.ObjectFunctions:FindChildGameObject("Screamer_Mesh")

   lua_table.ScreamCollider_UUID = lua_table.ObjectFunctions:FindChildGameObject("ScreamCollider")
   lua_table.PunchCollider_UUID = lua_table.ObjectFunctions:FindChildGameObject("PunchCollider")

   local particles = lua_table.ObjectFunctions:FindChildGameObject("Particles")
   lua_table.ScreamEmitter_UUID = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Scream", particles)
   lua_table.StunEmitter_UUID = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Stun", particles)
   lua_table.TauntEmitter_UUID = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Taunt", particles)
   lua_table.BodyEmitter_UUID = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Blood", particles)
   lua_table.HitEmitter_UUID = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Hit", particles)
   lua_table.DeathEmitter_UUID = lua_table.ObjectFunctions:FindChildGameObjectFromGO("Death", particles)

   -- Get navigation areas
   lua_table.WalkableID = lua_table.NavigationFunctions:GetAreaFromName("Walkable")
   lua_table.JumpID = lua_table.NavigationFunctions:GetAreaFromName("Jump")
   lua_table.AllAreas = lua_table.NavigationFunctions:AllAreas()
end

function lua_table:Start()
    lua_table.health = lua_table.maxHealth
    evades = lua_table.maxEvades
    lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.ScreamCollider_UUID)     
    lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.PunchCollider_UUID)    
end

function lua_table:Update()    
    
    HandleGhoulValues()
    CalculateDistances()
    dt = lua_table.SystemFunctions:DT()

    -- Check if the ghoul is falling into the void and delete it
    if lua_table.MyPosition[2] < -100
    then
        lua_table.ObjectFunctions:DestroyGameObject(MyUUID)
    end

    -- Deactivate until the camera is close enough
    if lua_table.DistanceToCamera < maxDistanceToCamera
    then
        -- Handle ghoul states
        if currentState == State.ALERT
        then
            if lua_table.SystemFunctions:GameTime() > lastTimeAlert + alertTime
            then
                currentState = State.IDLE
                lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
            end
        end

        if currentState == State.IDLE
        then
            Idle()
        elseif currentState == State.SEEK
        then       
	    	Seek()
        elseif currentState == State.EVADE
        then    	
            Evade()
        elseif currentState == State.SUMMONING
        then    	
            Summon()
        elseif currentState == State.SCREAMING
        then    	
            Scream()
        elseif currentState == State.PUNCHING
        then    	
            Punch()
	    elseif currentState == State.KNOCKBACK
	    then	
	    	Knockback()
	    elseif currentState == State.DEATH 
	    then	
	    	Die()
        end   
    end
end

return lua_table
end