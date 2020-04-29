function GetTableScreamCollider()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.Transform = Scripting.Transform()

lua_table.force = 70
lua_table.collider_effect = 2
lua_table.collider_damage = 0

local start_time = 0
local MyUID = 0

local Layers = {
    DEFAULT = 0,
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    ENEMY = 3,
    ENEMY_ATTACK = 4
}

-- Collisions
function lua_table:OnTriggerEnter()
    local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUID)      
end

function lua_table:OnCollisionEnter()
    local collider_GO = lua_table.PhysicsSystem:OnCollisionEnter(MyUID)
    local layer = lua_table.ObjectFunctions:GetLayerByID(collider_GO)
end

-- Core
function lua_table:Awake()
    MyUID = lua_table.ObjectFunctions:GetMyUID()
end

function lua_table:Start()
    start_time = lua_table.System:GameTime()
end

function lua_table:Update()    
    if start_time + 3 <= lua_table.System:GameTime() 
    then  
        lua_table.ObjectFunctions:DestroyGameObject(MyUID)
        local a = 0
    end
end

return lua_table
end