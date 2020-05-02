function GetTableScreamCollider()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.Transform = Scripting.Transform()

lua_table.force = 70
lua_table.collider_effect = 2
lua_table.collider_damage = 0

local start_time = 0

local rotation = {}
local rot_fixed = 0

local MyUID = 0

local Layers = {
    DEFAULT = 0,
    PLAYER = 1,
    PLAYER_ATTACK = 2,
    ENEMY = 3,
    ENEMY_ATTACK = 4
}
function lua_table:OnTriggerEnter()
    local collider_GO = lua_table.PhysicsSystem:OnTriggerEnter(MyUUID)      
end

function lua_table:OnCollisionEnter()
    local collider_GO = lua_table.PhysicsSystem:OnCollisionEnter(MyUUID)
    local layer = lua_table.GameObjectFunctions:GetLayerByID(collider_GO)
end

--------------------------------------------------------------------------------------------------
function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from ArrowScript on AWAKE")
end

function lua_table:Start()
    MyUUID = lua_table.GameObjectFunctions:GetMyUID()
    start_time = lua_table.System:GameTime()
end

function lua_table:Update()    
    if start_time + 3 <= lua_table.System:GameTime() 
    then  
        lua_table.GameObjectFunctions:DestroyGameObject(MyUUID)
    end
end

return lua_table
end