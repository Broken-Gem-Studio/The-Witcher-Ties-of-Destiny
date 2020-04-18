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
lua_table.movementSpeed = 65
lua_table.evadeSpeed = 100
lua_table.maxHealth = 100
lua_table.health = 0
lua_table.maxEvades = 2
lua_table.seekDistance = 170
lua_table.attackDistance = 70
lua_table.evadeDistance = 35
lua_table.pathThreshold = 0.5
lua_table.dead = false
lua_table.stunned = false

local State = {
    IDLE = 1,
    SUMMONING = 2, 
    SCREAMING = 3,
    SEEK = 4,
    EVADE = 5,
    DEATH = 6
}

local Layers = {
    DEFAULT = 0,
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    ENEMY = 3,
    ENEMY_ATTACK = 4
}

local MyUUID = 0
local dt = 0
local evades = 0
local currentState = State.IDLE
local currentTarget_UUID = 0
local cornerCounter = 1
local is_idle = false

-- Timers and cooldowns
local lastTimeEvaded = 0
local evadingTime = 0.5
local evadeCooldown = 3
local evadeResetTimer = 10

local lastTimeSummoned = 0
local summoningTime = 1
local summonCooldown = 15

local lastTimeScreamed = 0
local screamingTime = 2
local screamingCooldown = 7

local lastTimeStunned = 0
local stunTime = 0.5

local lastTimeDead = 0
local deathTime = 2

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

local function CalculateDistances() 
    lua_table.GeraltPosition = lua_table.TransformFunctions:GetPosition(lua_table.Geralt_UUID)
    lua_table.JaskierPosition = lua_table.TransformFunctions:GetPosition(lua_table.Jaskier_UUID)
    lua_table.MyPosition = lua_table.TransformFunctions:GetPosition(MyUUID)
    
    -- Calculate the distance from the ghoul to the players
    lua_table.GeraltDistance = math.sqrt((lua_table.GeraltPosition[1] - lua_table.MyPosition[1]) ^ 2 + (lua_table.GeraltPosition[3] - lua_table.MyPosition[3]) ^ 2)
    lua_table.JaskierDistance = math.sqrt((lua_table.JaskierPosition[1] - lua_table.MyPosition[1]) ^ 2 + (lua_table.JaskierPosition[3] - lua_table.MyPosition[3]) ^ 2)

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
    end

    -- Handle evade budget reset
    if lua_table.SystemFunctions:GameTime() > lastTimeEvaded + evadeResetTimer
    then
        evades = lua_table.maxEvades
    end
end

local function Idle()    
    if lua_table.stunned == false
    then
        -- Looks for proximity to the players
        if lua_table.ClosestDistance <= lua_table.evadeDistance and lua_table.SystemFunctions:GameTime() > lastTimeEvaded + evadeCooldown and evades > 0
        then 
            is_idle = false
            currentState = State.EVADE
            lastTimeEvaded = lua_table.SystemFunctions:GameTime()
            evades = evades - 1
            --lua_table.AnimationSystem:PlayAnimation("Evade", 30)  
            --lua_table.AnimationSystem:PlayAudioEvent()
            lua_table.SystemFunctions:LOG("Ghoul state is EVADE")

        elseif lua_table.ClosestDistance <= lua_table.attackDistance
        then
            if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summonCooldown
            then            
                is_idle = false
                currentState = State.SUMMONING
                lastTimeSummoned = lua_table.SystemFunctions:GameTime()
                --lua_table.AnimationSystem:PlayAnimation("Summon", 30)
                --lua_table.AnimationSystem:PlayAudioEvent()
                lua_table.SystemFunctions:LOG("Ghoul state is SUMMONING")
            elseif lua_table.SystemFunctions:GameTime() > lastTimeScreamed + screamingCooldown
            then
                is_idle = false
                currentState = State.SCREAMING
                lastTimeScreamed = lua_table.SystemFunctions:GameTime()  
                lua_table.ScreamColliderPosition = lua_table.TransformFunctions:GetPosition(lua_table.ScreamCollider_UUID)           
                --lua_table.AnimationSystem:PlayAnimation("Scream", 30) 
                --lua_table.AnimationSystem:PlayAudioEvent()
                lua_table.SystemFunctions:LOG("Ghoul state is SCREAMING")
            end

        elseif lua_table.ClosestDistance <= lua_table.seekDistance
        then
            is_idle = false
            currentState = State.SEEK                 
            lua_table.PathCorners = lua_table.NavigationFunctions:CalculatePath(lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3], lua_table.ClosestPosition[1], lua_table.ClosestPosition[2], lua_table.ClosestPosition[3], 1 << lua_table.WalkableID)
            --lua_table.AnimationSystem:PlayAnimation("Seek", 30)                             
            lua_table.SystemFunctions:LOG("Ghoul state is SEEK") 

        elseif is_idle == false
        then
            is_idle = true
            --lua_table.AnimationSystem:PlayAnimation("Idle", 30)
        end
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
            lua_table.PhysicsFunctions:Move(velocity[1] * lua_table.movementSpeed, velocity[3] * lua_table.movementSpeed, MyUUID)
        else           
            lua_table.PhysicsFunctions:Move(0, 0, MyUUID)
            cornerCounter = cornerCounter + 1
        end
    else     
        lua_table.PhysicsFunctions:Move(0, 0, MyUUID)
        currentState = State.IDLE
        cornerCounter = 1
    end
end

local function Evade()  
    lua_table.TransformFunctions:LookAt(lua_table.ClosestPosition[1], lua_table.MyPosition[2], lua_table.ClosestPosition[3], MyUUID)

    if lua_table.SystemFunctions:GameTime() < lastTimeEvaded + evadingTime
    then
        local velocity = NormalizeVector(lua_table.VectorToClosest)
        lua_table.PhysicsFunctions:Move(-velocity[1] * lua_table.evadeSpeed, -velocity[3] * lua_table.evadeSpeed, MyUUID)    
    else
        currentState = State.IDLE
    end
end

local function Summon()
    if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summoningTime
    then
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3] + 50, 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] + 50, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] - 50, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        currentState = State.IDLE
    end
end

local function Scream()
    lua_table.TransformFunctions:LookAt(lua_table.ClosestPosition[1], lua_table.MyPosition[2], lua_table.ClosestPosition[3], MyUUID)

    if lua_table.SystemFunctions:GameTime() < lastTimeScreamed + screamingTime
    then
        lua_table.ParticleFunctions:ActivateParticlesEmission(lua_table.Emitter_UUID)
        local velocity = NormalizeVector(lua_table.VectorToClosest)
        lua_table.ParticleFunctions:SetParticlesVelocity(velocity[1] * 40, 0, velocity[3] * 40, lua_table.Emitter_UUID)
        lua_table.TransformFunctions:Translate(velocity[1] * 10, 0, velocity[3] * 10, lua_table.ScreamCollider_UUID)
    else    
        lua_table.TransformFunctions:SetPosition(lua_table.ScreamColliderPosition[1], lua_table.ScreamColliderPosition[2], lua_table.ScreamColliderPosition[3], lua_table.ScreamCollider_UUID)
        lua_table.ParticleFunctions:DeactivateParticlesEmission(lua_table.Emitter_UUID)
        currentState = State.IDLE
    end
end

local function Die()
    if lua_table.dead == false
    then
        --lua_table.AnimationFunctions:PlayAnimation("Death", 30)
        -- Play audio --
        lua_table.dead = true
        lastTimeDead = lua_table.SystemFunctions:GameTime()

        lua_table.ParticleFunctions:DeactivateParticlesEmission(lua_table.Emitter_UUID)
        lua_table.PhysicsFunctions:Move(0, 0, MyUUID)
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

    if layer == Layers.PLAYER_ATTACK
    then
        -- Play audio --
    	lua_table.health = lua_table.health - 50.0
        lua_table.stunned = true
        currentState = State.IDLE
        lastTimeStunned = lua_table.SystemFunctions:GameTime()
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
   lua_table.Emitter_UUID = lua_table.ObjectFunctions:FindGameObject("ScreamingEmitter")
   lua_table.ScreamCollider_UUID = lua_table.ObjectFunctions:FindGameObject("ScreamCollider")
   MyUUID = lua_table.ObjectFunctions:GetMyUID()

   -- Get navigation areas
   lua_table.WalkableID = lua_table.NavigationFunctions:GetAreaFromName("Walkable")
   lua_table.JumpID = lua_table.NavigationFunctions:GetAreaFromName("Jump")
   lua_table.AllAreas = lua_table.NavigationFunctions:AllAreas()

   lua_table.ParticleFunctions:DeactivateParticlesEmission(lua_table.Emitter_UUID)
end

function lua_table:Start()
    lua_table.health = lua_table.maxHealth
    evades = lua_table.maxEvades
end

function lua_table:Update()
    
    HandleGhoulValues()
    CalculateDistances()
    dt = lua_table.SystemFunctions:DT()

    -- Handle ghoul state
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
	elseif currentState == State.DEATH 
	then	
		Die()
    end   
end

return lua_table
end