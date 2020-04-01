function GetTableMoveCube()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Transform = Scripting.Transform()
lua_table.GameObjectFunctions = Scripting.GameObject()

-- Inspector variables
lua_table.value_ = 0

-- Time management
local time = 0
local started_time = 0
local start_motion_time = 0

local start_movement = false
local cube_moved = false

function Lerp(start, end_, value)
    if value > 1.0
    then
        value = 1.0
    end
    return (1 - value) * start + value * end_
end

function lua_table:Awake()
    lua_table.System:LOG ("This Log was called from MoveCube on AWAKE")
end

function lua_table:Start()
    started_time = lua_table.System:GameTime()
    lua_table.Transform:SetPosition(-998, 1.85, -4237)
end
 
function lua_table:Update()
    time = lua_table.System:GameTime() - started_time

    if time > 16 and not start_movement
    then
        start_motion_time = time
        start_movement = true 
    end

    if start_movement and not cube_moved -- Move Cube
    then
        local motion_time = time - start_motion_time
        lua_table.value_ = motion_time / 3
        
        local x = lua_table.Transform:GetPositionX()
        local y = lua_table.Transform:GetPositionY()
        local z = Lerp(-4237, -4142, lua_table.value_)
        
        lua_table.Transform:SetPosition(x, y, z)
        if lua_table.value_ >= 1
        then
            cube_moved = true
        end
    end
end

return lua_table
end