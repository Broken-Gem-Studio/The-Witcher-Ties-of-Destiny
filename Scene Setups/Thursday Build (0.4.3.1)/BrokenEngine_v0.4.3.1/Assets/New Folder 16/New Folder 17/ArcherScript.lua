function GetTableArcherScript()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.Scene = Scripting.Scenes()
lua_table.AnimationSystem = Scripting.Animations()
lua_table.Navigation = Scripting.Navigation()
-- Test
lua_table.Input = Scripting.Inputs()

-- Targets
lua_table.geralt = "Geralt"
lua_table.jaskier = "Jaskier"
lua_table.arrow = 0

-- Archer Values -------------------------
lua_table.health = 500
lua_table.speed = 5

-- 
lua_table.DistanceToTarget = 0
lua_table.ClosestPlayer_ID = 0

local MyUID = 0

-- Archer main states ---------------------
local State = {
    IDL = 1,
    PATROL = 2,
    SEEK = 3,
    RANGE_ATTACK = 4,
    MELEE_ATTACK = 5,
    STUNNED = 6,
	DEATH = 7
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
    KNONKBACK = 2,
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

lua_table.start_stun = false
local stun_time = 0

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

    if layer == Layers.PLAYER_ATTACK and lua_table.health > 0
    then
        local parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_GO)
        local script = lua_table.GameObjectFunctions:GetScript(parent)

        lua_table.health = lua_table.health - script.collider_damage
        
        if script.collider_effect ~= Effects.NONE
		then
            -- TODO: React depending on type of effect 
            if script.collider_effect == Effects.STUN then
                lua_table.start_stun = true
                lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
                stun_time = PerfGameTime()
            elseif script.collider_effect == Effects.KNONKBACK then

            elseif script.collider_effect == Effects.TAUNT then
            end
        else -- animatio hit
            lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
            hit_time = PerfGameTime()
            lua_table.start_hit = true
		end
    end
end

-- Collider Calls 2.0 
function lua_table:RequestedTrigger(collider_GO)
	--lua_table.System:LOG("On RequestedTrigger")

	if lua_table.health > 0		
	then
        local player_script = lua_table.GameObjectFunctions:GetScript(collider_GO)
        
        -- Recieve damage
        lua_table.health = lua_table.health - player_script.collider_damage

        if player_script.collider_effect ~= Effects.NONE
		then
            -- TODO: React depending on type of effect 
            if player_script.collider_effect == Effects.STUN then
                lua_table.start_stun = true
                lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
                stun_time = PerfGameTime()

            elseif player_script.collider_effect == Effects.KNONKBACK then

            elseif player_script.collider_effect == Effects.TAUNT then
            end
        else -- animatio hit
            lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
            hit_time = PerfGameTime()
            lua_table.start_hit = true
		end
	end
end

function lua_table:OnCollisionEnter()
    local collider = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
end

local function GetClosestPlayer()

    position = lua_table.Transform:GetPosition(MyUID)

    Gpos = lua_table.Transform:GetPosition(Geralt_ID)   
    Jpos = lua_table.Transform:GetPosition(Jaskier_ID)

    GX = Gpos[1] - position[1]
    GZ = Gpos[3] - position[3]
    GeraltDistance =  math.sqrt(GX^2 + GZ^2)

    JX = Jpos[1] - position[1]
	JZ = Jpos[3] - position[3]
    JaskierDistance =  math.sqrt(JX^2 + JZ^2)

    if GeraltDistance < JaskierDistance then 
        lua_table.ClosestPlayer_ID = Geralt_ID
    elseif GeraltDistance > JaskierDistance then
        lua_table.ClosestPlayer_ID = Jaskier_ID
    else
        lua_table.ClosestPlayer_ID = 0;
    end

end

local function Seek()

    if start_agro == false 
    then 
        lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
        agro_time = PerfGameTime()
        start_agro = true
    end

    if start_agro and agro_time + 1300 <= PerfGameTime()
    then
        if start_running == false 
        then
            lua_table.AnimationSystem:PlayAnimation("Run",30.0, MyUID)
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
        lua_table.AnimationSystem:PlayAnimation("DrawArrow",30.0, MyUID)
        lua_table.start_taking_arrow = false
    end

    if shoot_time + 1000 <= PerfGameTime() and lua_table.start_aiming == true 
    then
       -- lua_table.System:LOG ("AIMING")
        lua_table.AnimationSystem:PlayAnimation("Aim",30.0, MyUID)
        lua_table.start_aiming = false
    end

    if shoot_time + 2000 <= PerfGameTime() and lua_table.start_shooting == true 
    then
        --lua_table.System:LOG ("SHOOT")
        
        local rotation = lua_table.Transform:GetRotation(MyUID)
        local pos = lua_table.Transform:GetPosition(MyUID)

        local rot_fixed = GimbalLockWorkaroundY(rotation[2])

        local X = math.sin(math.rad(rot_fixed))
        local Z = math.cos(math.rad(rot_fixed))

        lua_table.Scene:Instantiate(lua_table.arrow, pos[1] + X*2, pos[2] + 3, pos[3]+ Z*2, rotation[1], rotation[2], rotation[3])

        --Test
       -- lua_table.health = lua_table.health - 100

        lua_table.start_shooting = false
    end

    if shoot_time + 2500 <= PerfGameTime() 
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
            lua_table.AnimationSystem:PlayAnimation("MeleeKick",30.0, MyUID)
        else 
            lua_table.AnimationSystem:PlayAnimation("MeleePunch",30.0, MyUID)
        end
        
        --lua_table.System:LOG ("MELEE ATTACK")
        start_melee = false
    end

    if melee_time + 1500 <= PerfGameTime() then
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
end

function lua_table:Start()
    Geralt_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.geralt)
    Jaskier_ID = lua_table.GameObjectFunctions:FindGameObject(lua_table.jaskier)

    MyUID = lua_table.GameObjectFunctions:GetMyUID()

    navigation_ID = lua_table.Navigation:GetAreaFromName("Walkable")

    lua_table.AnimationSystem:SetBlendTime(0.10, MyUID)
end

function lua_table:Update()

    GetClosestPlayer()

    if lua_table.Input:KeyUp("w") then
        lua_table.start_stun = true
        lua_table.AnimationSystem:PlayAnimation("Hit",30.0, MyUID)
        stun_time = PerfGameTime()
    end

    -- ------------------------------------Decide Target----------------------------------
    if lua_table.ClosestPlayer_ID == Geralt_ID then
        lua_table.DistanceToTarget = GeraltDistance
        TargetPos = Gpos
    elseif lua_table.ClosestPlayer_ID == Jaskier_ID then
        lua_table.DistanceToTarget = JaskierDistance
        TargetPos = Jpos
    else
        lua_table.DistanceToTarget = -1;
    end

    -- ----------------------Manage Archer States | value needs test ------------------------------------------------------

    if lua_table.health > 0.0 and lua_table.start_hit == false
    then
        if lua_table.start_stun == false
        then
            if lua_table.DistanceToTarget <= 42 and lua_table.DistanceToTarget > 14 then
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
            if lua_table.start_stun == true and stun_time + 3000 <= PerfGameTime() then
                lua_table.start_stun = false
            end
        end

    else

        if lua_table.health <= 0.0
        then
            lua_table.currentState = State.DEATH

            if start_death == false 
            then
                lua_table.AnimationSystem:PlayAnimation("Death",30.0, MyUID) -- 2.33sec
                time_death = PerfGameTime()
                start_death = true
            end

            if time_death + 4000 <= PerfGameTime()
            then
                lua_table.GameObjectFunctions:DestroyGameObject(MyUID)
            end
        elseif lua_table.start_hit == true and hit_time + 1500 <= PerfGameTime() then
            lua_table.start_hit = false
        end

        
    end

    

end

return lua_table
end