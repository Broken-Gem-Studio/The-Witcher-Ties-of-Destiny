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

-----------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------

-- Lua table variabes
lua_table.ghoul_UUID = 0
lua_table.movementSpeed = 40
lua_table.evadeSpeed = 60
lua_table.maxHealth = 100
lua_table.health = 0
lua_table.maxEvades = 2
lua_table.seekDistance = 120
lua_table.attackDistance = 70
lua_table.evadeDistance = 30
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
    DEFAULT = 1
}

local MyUUID = 0
local dt = 0
local evades = 0
local currentState = State.IDLE
local currentTarget_UUID = 0

-- Timers and cooldowns
local lastTimeEvaded = 0
local evadingTime = 1
local evadeCooldown = 2.5
local evadeResetTimer = 10

local lastTimeSummoned = 0
local summoningTime = 1
local summonCooldown = 15

local lastTimeScreamed = 0
local screamingTime = 2
local screamingCooldown = 5

local lastTimeStunned = 0
local stunTime = 0.5

-----------------------------------------------------------------------------
-- WALKER GHOUL FUNCTIONS
-----------------------------------------------------------------------------

local function NormalizeVector(vector)
	module = math.sqrt(vector[1] ^ 2 + vector[3] ^ 2)

    newVector = {0, 0, 0}
    newVector[1] = vector[1] / module
    newVector[2] = vector[2]
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

    lua_table.VelocityToClosest = {0, 0, 0}
    lua_table.VelocityToClosest[1] = lua_table.ClosestPosition[1] - lua_table.MyPosition[1]
    lua_table.VelocityToClosest[2] = lua_table.ClosestPosition[2] - lua_table.MyPosition[2]
    lua_table.VelocityToClosest[3] = lua_table.ClosestPosition[3] - lua_table.MyPosition[3]
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

    -- Looks for proximity to the players
    if lua_table.stunned == false
    then
        if lua_table.ClosestDistance <= lua_table.evadeDistance and lua_table.SystemFunctions:GameTime() > lastTimeEvaded + evadeCooldown and evades > 0
        then 
            currentState = State.EVADE
            lastTimeEvaded = lua_table.SystemFunctions:GameTime()
            evades = evades - 1
            lua_table.SystemFunctions:LOG("Ghoul state is EVADE")
        elseif lua_table.ClosestDistance <= lua_table.attackDistance
        then
            if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summonCooldown
            then            
                currentState = State.SUMMONING
                lastTimeSummoned = lua_table.SystemFunctions:GameTime()
                lua_table.SystemFunctions:LOG("Ghoul state is SUMMONING")
            elseif lua_table.SystemFunctions:GameTime() > lastTimeScreamed + screamingCooldown
            then
                currentState = State.SCREAMING
                lastTimeScreamed = lua_table.SystemFunctions:GameTime()                
                lua_table.SystemFunctions:LOG("Ghoul state is SCREAMING")
            end
        elseif lua_table.ClosestDistance <= lua_table.seekDistance
        then
            currentState = State.SEEK           
            lua_table.SystemFunctions:LOG("Ghoul state is SEEK") 
        --else        
            --lua_table.AnimationSystem:PlayAnimation("Idle", 30)
        end
    end
end

local function Seek()
    --lua_table.AnimationSystem:PlayAnimation("Seek", 30)      

    if lua_table.ClosestDistance <= lua_table.seekDistance and lua_table.ClosestDistance > lua_table.attackDistance 
    then
         local velocity = NormalizeVector(lua_table.VelocityToClosest)
         lua_table.PhysicsFunctions:Move(velocity[1] * lua_table.movementSpeed, velocity[3] * lua_table.movementSpeed, MyUUID)
    else     
        currentState = State.IDLE
    end
end

local function Evade()
    --lua_table.AnimationSystem:PlayAnimation("Evade", 30)

    if lua_table.SystemFunctions:GameTime() < lastTimeEvaded + evadingTime
    then
        local velocity = NormalizeVector(lua_table.VelocityToClosest)
        lua_table.PhysicsFunctions:Move(-velocity[1] * lua_table.evadeSpeed, -velocity[3] * lua_table.evadeSpeed, MyUUID)    
    else
        currentState = State.IDLE
    end
end

local function Summon()
    --lua_table.AnimationSystem:PlayAnimation("Summon", 30)

    if lua_table.SystemFunctions:GameTime() > lastTimeSummoned + summoningTime
    then
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1], lua_table.MyPosition[2], lua_table.MyPosition[3] + 50, 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] + 50, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        lua_table.SceneFunctions:Instantiate(lua_table.ghoul_UUID, lua_table.MyPosition[1] - 50, lua_table.MyPosition[2], lua_table.MyPosition[3], 0, 0, 0)
        currentState = State.IDLE
    end
end

local function Scream()
    --lua_table.AnimationSystem:PlayAnimation("Scream", 30)
    if lua_table.SystemFunctions:GameTime() < lastTimeScreamed + screamingTime
    then
        local velocity = NormalizeVector(lua_table.VelocityToClosest)
        lua_table.ParticleFunctions:ActivateParticlesEmission(MyUUID)
        lua_table.ParticleFunctions:SetParticlesVelocity(velocity[1] * 40, 0, velocity[3] * 40, MyUUID)
    else
        lua_table.ParticleFunctions:DeactivateParticlesEmission(MyUUID)
        currentState = State.IDLE
    end
end

local function Die()
if lua_table.dead == false
    then
        lua_table.AnimationFunctions:PlayAnimation("Death", 30)
        lua_table.dead = true
    end
end

-----------------------------------------------------------------------------
-- COLISIONS
-----------------------------------------------------------------------------

function lua_table:OnTriggerEnter()	
	local collider = lua_table.PhysicsFunctions:OnTriggerEnter(MyUUID)
	--lua_table.SystemFunctions:LOG("OnTriggerEnter(): entered collider from GameObject with UUID ".. collider)
    local layer  =lua_table.ObjectFunctions:GetLayerByID(collider)

    if layer == Layers.DEFAULT
    then
    	lua_table.health = lua_table.health - 50.0
        lua_table.stunned = true
        currentState = State.IDLE
        lastTimeStunned = lua_table.SystemFunctions:GameTime()
        --lua_table.AnimationSystem:PlayAnimation("Hit", 30)
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
   MyUUID = lua_table.ObjectFunctions:GetMyUID()

   lua_table.ParticleFunctions:DeactivateParticlesEmission(MyUUID)
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
        lua_table.SystemFunctions:LOG("Ghoul state is DEATH")
    end   
end

return lua_table
end