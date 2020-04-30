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

-----------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------

-- Lua table variabes
lua_table.ghoul_UUID = 0
lua_table.screamCollider_UUID = 0
lua_table.movementSpeed = 10
lua_table.evadeSpeed = 15
lua_table.knockbackSpeed = 200
lua_table.maxHealth = 100
lua_table.health = 0
lua_table.maxEvades = 2
lua_table.seekDistance = 20
lua_table.attackDistance = 10
lua_table.evadeDistance = 5
lua_table.pathThreshold = 0.1
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
    KNOCKBACK = 8
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

local MyUUID = 0
local dt = 0
local evades = 0
local currentState = State.IDLE
local currentTarget_UUID = 0
local cornerCounter = 1
local first_time = true
local canStartScreaming = true

-- Timers and cooldowns
local lastTimeEvaded = 0
local evadingTime = 0.75
local evadeCooldown = 3
local evadeResetTimer = 10

local lastTimeSummoned = 0
local summoningTime = 2
local summonCooldown = 25

local lastTimeScreamed = 0
local preparingTime = 1
local screamingTime = 1
local screamingCooldown = 10

local lastTimeStunned = 0
local stunTime = 2.5

local lastTimeHit = 0
local hitTime = 0.5

local lastTimeTaunted = 0
local tauntTime = 5

local lastTimeKnockback = 0
local knockbackTime = 1

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

local function GimbalLockWorkaroundY(param_rot_y)

    if math.abs(lua_table.TransformFunctions:GetRotation(MyUUID)[1]) == 180
    then
        if param_rot_y >= 0 then param_rot_y = 90 + 90 - param_rot_y
        elseif param_rot_y < 0 then param_rot_y = -90 + -90 - param_rot_y
        end
    end

    return param_rot_y
end

local function CalculateDistances() 

    lua_table.GeraltPosition = {1000, 1000, 1000}
    lua_table.JaskierPosition = {1000, 1000, 1000}

    -- We check the players are stil alive
    if lua_table.Geralt_UUID ~= 0 
    then    
        --local geralt_table = lua_table.ObjectFunctions:GetScript(lua_table.Geralt_UUID)
        --if geralt_table.current_state > -3
        --then
            lua_table.GeraltPosition = lua_table.TransformFunctions:GetPosition(lua_table.Geralt_UUID)
        --end        
    end

    if lua_table.Jaskier_UUID ~= 0
    then
        --local jaskier_table = lua_table.ObjectFunctions:GetScript(lua_table.Jaskier_UUID)
        --if jaskier_table.current_state > -3
        --then
            lua_table.JaskierPosition = lua_table.TransformFunctions:GetPosition(lua_table.Jaskier_UUID)               
        --end           
    end

    -- Calculate the distance from the ghoul to the players
    lua_table.MyPosition = lua_table.TransformFunctions:GetPosition(MyUUID)
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
    -- Handle health
    if lua_table.health <= 0
	then 
		currentState = State.DEATH
	end

    -- Handle crowd control effects
    if lua_table.stunned and lua_table.SystemFunctions:GameTime() > lastTimeStunned + stunTime
    then
        lua_table.stunned = false
        lua_table.ParticleFunctions:StopParticleEmitter(lua_table.HeadEmitter_UUID)
    end    
    if lua_table.taunted and lua_table.SystemFunctions:GameTime() > lastTimeTaunted + tauntTime
    then
        lua_table.taunted = false
        lua_table.ParticleFunctions:StopParticleEmitter(lua_table.HeadEmitter_UUID)
    end
    if lua_table.hit and lua_table.SystemFunctions:GameTime() > lastTimeHit + hitTime
    then
        lua_table.hit = false
        lua_table.ParticleFunctions:StopParticleEmitter(lua_table.BodyEmitter_UUID)
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
        -- If it is taunted it attacks Jaskier
        if lua_table.taunted == true
        then
            currentState = State.SEEK                 
            lua_table.ObjectivePosition = lua_table.TransformFunctions:GetPosition(lua_table.ObjectivePlayer_UUID)
            lua_table.PathCorners = lua_table.NavigationFunctions:CalculatePath(lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3], lua_table.ObjectivePosition[1], lua_table.ObjectivePosition[2], lua_table.ObjectivePosition[3], 1 << lua_table.WalkableID)
            lua_table.AnimationFunctions:PlayAnimation("Run", 30, MyUUID)                             
            lua_table.SystemFunctions:LOG("Ghoul state is TAUNTED") 

        -- Looks for proximity to the players
        elseif lua_table.ClosestDistance <= lua_table.evadeDistance and lua_table.SystemFunctions:GameTime() > lastTimeEvaded + evadeCooldown and evades > 0
        then 
            currentState = State.EVADE
            lastTimeEvaded = lua_table.SystemFunctions:GameTime()
            evades = evades - 1
            lua_table.AnimationFunctions:PlayAnimation("Evade", 40, MyUUID)  
            --lua_table.AudioFunctions:PlayAudioEvent()
            lua_table.SystemFunctions:LOG("Ghoul state is EVADE")

        elseif lua_table.ClosestDistance <= lua_table.attackDistance
        then
            if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summonCooldown
            then  
                currentState = State.SUMMONING
                lastTimeSummoned = lua_table.SystemFunctions:GameTime()
                lua_table.AnimationFunctions:PlayAnimation("Scream", 30, MyUUID)        
                lua_table.AudioFunctions:PlayAudioEvent("Play_Ghoul_Scream_2")
                lua_table.SystemFunctions:LOG("Ghoul state is SUMMONING")

            elseif lua_table.SystemFunctions:GameTime() > lastTimeScreamed + screamingCooldown
            then
                currentState = State.SCREAMING
                lastTimeScreamed = lua_table.SystemFunctions:GameTime()       
                lua_table.AnimationFunctions:PlayAnimation("Roar", 40, MyUUID)   
                lua_table.AudioFunctions:PlayAudioEvent("Play_Ghoul_Scream_1")       
                lua_table.SystemFunctions:LOG("Ghoul state is SCREAMING")
            end

        elseif lua_table.ClosestDistance <= lua_table.seekDistance
        then
            if first_time == true
            then
                currentState = State.ALERT
                --lua_table.AudioFunctions:PlayAudioEvent()
                lua_table.AnimationFunctions:PlayAnimation("Alert", 30, MyUUID) 
                lastTimeAlert = lua_table.SystemFunctions:GameTime()
                first_time = false

            else
                currentState = State.SEEK                 
                lua_table.PathCorners = lua_table.NavigationFunctions:CalculatePath(lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3], lua_table.ClosestPosition[1], lua_table.ClosestPosition[2], lua_table.ClosestPosition[3], 1 << lua_table.WalkableID)
                lua_table.AnimationFunctions:PlayAnimation("Run", 30, MyUUID)                             
                lua_table.SystemFunctions:LOG("Ghoul state is SEEK") 
            end
        end
    else
        lua_table.SystemFunctions:LOG("Ghoul under an altered state")        
    end
end

local function Seek()
    if lua_table.ClosestDistance >= lua_table.attackDistance and lua_table.ClosestDistance <= lua_table.seekDistance and cornerCounter <= #lua_table.PathCorners
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
        cornerCounter = 1
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end
end

local function Evade()  
    lua_table.TransformFunctions:LookAt(lua_table.ClosestPosition[1], lua_table.MyPosition[2], lua_table.ClosestPosition[3], MyUUID)

    if lua_table.SystemFunctions:GameTime() < lastTimeEvaded + evadingTime
    then
        local velocity = NormalizeVector(lua_table.VectorToClosest)
        lua_table.PhysicsFunctions:Move(-velocity[1] * lua_table.evadeSpeed * dt, -velocity[3] * lua_table.evadeSpeed * dt, MyUUID)    
    else
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end
end

local function Summon()
    if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summoningTime
    then
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3] + 3, 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] + 3, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] - 3, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end
end

local function Scream() 
    if lua_table.SystemFunctions:GameTime() < lastTimeScreamed + preparingTime
    then    
        local vector = {0, 0, 0}
        vector[1] = lua_table.ClosestPosition[1] - lua_table.MyPosition[1]
        vector[2] = lua_table.ClosestPosition[2] - lua_table.MyPosition[2]
        vector[3] = lua_table.ClosestPosition[3] - lua_table.MyPosition[3]

        lua_table.ScreamingVelocity = NormalizeVector(vector)
        lua_table.TransformFunctions:LookAt(lua_table.ClosestPosition[1], lua_table.MyPosition[2], lua_table.ClosestPosition[3], MyUUID)
    
    elseif canStartScreaming == true
    then    
        lua_table.ParticleFunctions:PlayParticleEmitter(lua_table.HeadEmitter_UUID)    
        lua_table.ParticleFunctions:SetParticlesVelocity(lua_table.ScreamingVelocity[1] * 40, 0, lua_table.ScreamingVelocity[3] * 40, lua_table.HeadEmitter_UUID)   
        local rotation = lua_table.TransformFunctions:GetRotation(MyUUID)
        local rot_fixed = GimbalLockWorkaroundY(rotation[2])

        lua_table.X = math.sin(math.rad(rot_fixed))
        lua_table.Z = math.cos(math.rad(rot_fixed))
        
        lua_table.SceneFunctions:Instantiate(lua_table.screamCollider_UUID, lua_table.MyPosition[1] + lua_table.X * 6, lua_table.MyPosition[2] + 2.5, lua_table.MyPosition[3] + lua_table.Z * 6, rotation[1], rotation[2], rotation[3])    
        canStartScreaming = false

    elseif lua_table.SystemFunctions:GameTime() > lastTimeScreamed + preparingTime + screamingTime
    then
        lua_table.ParticleFunctions:StopParticleEmitter(lua_table.HeadEmitter_UUID)   
        currentState = State.IDLE
        canStartScreaming = true
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID) 
    end
end

local function Knockback()
    if lua_table.SystemFunctions:GameTime() < lastTimeKnockback + knockbackTime
    then
        lua_table.VectorToObjective = {0, 0, 0}
        lua_table.VectorToObjective[1] = lua_table.GeraltPosition[1] - lua_table.MyPosition[1]
        lua_table.VectorToObjective[2] = lua_table.GeraltPosition[2] - lua_table.MyPosition[2]
        lua_table.VectorToObjective[3] = lua_table.GeraltPosition[3] - lua_table.MyPosition[3]
        lua_table.ObjectiveDistance = math.sqrt(lua_table.VectorToObjective[1] ^ 2 + lua_table.VectorToObjective[3] ^ 2)
        
        local velocity = NormalizeVector(lua_table.VectorToObjective)
        lua_table.PhysicsFunctions:Move((-velocity[1] * lua_table.knockbackSpeed * dt) / (lua_table.ObjectiveDistance * 1.5), (-velocity[3] * lua_table.knockbackSpeed * dt) / (lua_table.ObjectiveDistance * 1.5), MyUUID)     
    else
        currentState = State.IDLE
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
    end 
end

local function Die()
    if lua_table.dead == false
    then
        lua_table.AnimationFunctions:PlayAnimation("Death", 30, MyUUID)
        lua_table.AudioFunctions:PlayAudioEvent("Play_Ghoul_death_2")
        lua_table.dead = true
        lastTimeDead = lua_table.SystemFunctions:GameTime()
        lua_table.SystemFunctions:LOG("Ghoul state is DEATH")
    elseif lua_table.SystemFunctions:GameTime() > lastTimeDead + deathTime 
    then
        lua_table.ObjectFunctions:DestroyGameObject(MyUUID)
    end
end		

-----------------------------------------------------------------------------
-- COLISIONS
-----------------------------------------------------------------------------

function lua_table:OnTriggerEnter()	
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)
    local layer = lua_table.ObjectFunctions:GetLayerByID(collider)

    if layer == Layer.PLAYER_ATTACK
    then
        lua_table.AnimationFunctions:PlayAnimation("Hit", 30, MyUUID)
        lua_table.ParticleFunctions:StopParticleEmitter(lua_table.HeadEmitter_UUID)   
        --lua_table.AudioFunctions:PlayAudioEvent("Play_Ghoul_hurt_1")                          
        lua_table.SystemFunctions:LOG("Ghoul has been HIT") 

        local player_table = {}        
        local parent = lua_table.ObjectFunctions:GetGameObjectParent(collider)

        if parent ~= 0
        then
            player_table = lua_table.ObjectFunctions:GetScript(parent)
        else 
            player_table = lua_table.ObjectFunctions:GetScript(collider)
        end
        
		lua_table.health = lua_table.health - player_table.collider_damage
        lua_table.ObjectivePlayer_UUID = collider

        if player_table.collider_effect == Effect.STUN
        then
            lua_table.stunned = true            
            lastTimeStunned = lua_table.SystemFunctions:GameTime()
            currentState = State.IDLE

		elseif player_table.collider_effect == Effect.KNOCKBACK
        then
            currentState = State.KNOCKBACK
            lastTimeKnockback = lua_table.SystemFunctions:GameTime()            

        elseif player_table.collider_effect == Effect.TAUNT
        then
            lua_table.taunted = true
            lastTimeTaunted = lua_table.SystemFunctions:GameTime()
            currentState = State.IDLE

        else
            lua_table.hit = true
            lastTimeHit = lua_table.SystemFunctions:GameTime()
            currentState = State.IDLE   
            lua_table.ParticleFunctions:PlayParticleEmitter(lua_table.BodyEmitter_UUID)
        end
    end
end

function lua_table:RequestedTrigger(collider_object)
	lua_table.SystemFunctions:LOG("Walker Ghooul's OnRequestedTrigger has been called")
    lua_table.ParticleFunctions:StopParticleEmitter(lua_table.HeadEmitter_UUID)   

	if currentState ~= State.DEATH	
	then
		local player_table = lua_table.ObjectFunctions:GetScript(collider_object)
		lua_table.health = lua_table.health - player_table.collider_damage   
        lua_table.ObjectivePlayer_UUID = collider_object

        if player_table.collider_effect == Effect.STUN
        then
            lua_table.stunned = true            
            lastTimeStunned = lua_table.SystemFunctions:GameTime()
            currentState = State.IDLE

		elseif player_table.collider_effect == Effect.KNOCKBACK
        then
            currentState = State.KNOCKBACK
            lastTimeKnockback = lua_table.SystemFunctions:GameTime()            

        elseif player_table.collider_effect == Effect.TAUNT
        then
            lua_table.taunted = true
            lastTimeTaunted = lua_table.SystemFunctions:GameTime()
            currentState = State.IDLE

        else
            lua_table.hit = true
            lastTimeHit = lua_table.SystemFunctions:GameTime()
            currentState = State.IDLE       
            lua_table.ParticleFunctions:PlayParticleEmitter(lua_table.BodyEmitter_UUID)
        end
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
   lua_table.HeadEmitter_UUID = lua_table.ObjectFunctions:FindGameObject("HeadEmitter")
   lua_table.FeetEmitter_UUID = lua_table.ObjectFunctions:FindGameObject("FeetEmitter")
   lua_table.BodyEmitter_UUID = lua_table.ObjectFunctions:FindGameObject("BodyEmitter")
   MyUUID = lua_table.ObjectFunctions:GetMyUID()

   -- Get navigation areas
   lua_table.WalkableID = lua_table.NavigationFunctions:GetAreaFromName("Walkable")
   lua_table.JumpID = lua_table.NavigationFunctions:GetAreaFromName("Jump")
   lua_table.AllAreas = lua_table.NavigationFunctions:AllAreas()

   lua_table.ParticleFunctions:StopParticleEmitter(lua_table.HeadEmitter_UUID)
   lua_table.ParticleFunctions:StopParticleEmitter(lua_table.FeetEmitter_UUID)
   lua_table.ParticleFunctions:StopParticleEmitter(lua_table.BodyEmitter_UUID)
end

function lua_table:Start()
    lua_table.health = lua_table.maxHealth
    evades = lua_table.maxEvades
    lua_table.AnimationFunctions:PlayAnimation("Idle", 30, MyUUID)
end

function lua_table:Update()
    
    HandleGhoulValues()
    CalculateDistances()
    dt = lua_table.SystemFunctions:DT()

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
	elseif currentState == State.KNOCKBACK
	then	
		Knockback()
	elseif currentState == State.DEATH 
	then	
		Die()
    end   
end

return lua_table
end