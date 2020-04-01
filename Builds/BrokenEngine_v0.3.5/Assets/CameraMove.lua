function GetTableCameraMove()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.UIFunctions = Scripting.Interface()
lua_table.AnimationFunctions = Scripting.Animations()

lua_table.camera = 0
lua_table.buttonplay = 0
lua_table.buttonoptions = 0

local camerapos_y = 0
local camerapos_z = 0
local start_time = 0
local time = 0
local flag = false
local steps = 0
local pos_y = 0
local pos_z = 0

function lua_table:Awake()
    lua_table.camera = lua_table.GameObjectFunctions:FindGameObject("Camara")
    lua_table.buttonplay = lua_table.GameObjectFunctions:FindGameObject("Play Button")
    lua_table.buttonoptions = lua_table.GameObjectFunctions:FindGameObject("Options Button")

end

function lua_table:Start()
    start_time = lua_table.SystemFunctions:GameTime()
    camerapos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(lua_table.camera)
    camerapos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(lua_table.camera)
    lua_table.AnimationFunctions:PlayAnimation("Fall", 30.0)
end

function lua_table:Update()
    time = lua_table.SystemFunctions:GameTime() - start_time

    if time > 6.0 and flag == false
    then
        lua_table.AnimationFunctions:PlayAnimation("Idle", 30.0)
        flag = true
    end
    
    if steps < 5 and time > 7.0
    then
        steps = steps + 1
        pos_y = camerapos_y - (1.45 * steps)
        pos_z = camerapos_z - (2.9 * steps)
        lua_table.GameObjectFunctions.TranslateGameObject(lua_table.camera, -1.388, pos_y, pos_z)
    elseif steps >= 5
    then
        lua_table.UIFunctions:MakeElementVisible(lua_table.buttonplay, "Button")
        lua_table.UIFunctions:MakeElementVisible(lua_table.buttonoptions, "Button")
    end
end

return lua_table
end