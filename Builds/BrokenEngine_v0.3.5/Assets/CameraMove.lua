function GetTableCameraMove()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.UIFunctions = Scripting.Interface()
lua_table.AnimationFunctions = Scripting.Animations()

lua_table.cartel = 0
lua_table.camera = 0
lua_table.buttonplay = 0
lua_table.buttonoptions = 0

local camerapos_y = 0
local camerapos_z = 0

function lua_table:Awake()
    lua_table.camera = lua_table.GameObjectFunctions:FindGameObject("Camara")
    lua_table.cartel = lua_table.GameObjectFunctions:FindGameObject("Cartel")
    lua_table.buttonplay = lua_table.GameObjectFunctions:FindGameObject("Play Button")
    lua_table.buttonoptions = lua_table.GameObjectFunctions:FindGameObject("Options Button")

    camerapos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.camera)
    camerapos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.camera)
end

function lua_table:Start()
end

function lua_table:Update()
    lua_table.cartel = lua_table.AnimationFunctions:PlayAnimation("Fall", 30.0f)
    lua_table.cartel = lua_table.AnimationFunctions:PlayAnimation("Idle", 30.0f)
    
    -- move camera (-1.388f, -18.865f, 38.135) with velocity
    
    lua_table.UIFunctions:MakeElementVisible(lua_table.buttonplay, "ComponentButton")
    lua_table.UIFunctions:MakeElementVisible(lua_table.buttonoptions, "ComponentButton")
end

return lua_table
end