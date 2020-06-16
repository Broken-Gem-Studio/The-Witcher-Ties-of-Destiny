function GetTableIdleAnimation()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.AnimationSystem = Scripting.Animations()
lua_table.GameObjectFunctions = Scripting.GameObject()

local MyUID = 0
local play = true

lua_table.anim_name = "Idle" 

function lua_table:Awake()
end

function lua_table:Start()
    MyUID = lua_table.GameObjectFunctions:GetMyUID()
end

function lua_table:Update()

    if play == true then 
        lua_table.AnimationSystem:PlayAnimation(lua_table.anim_name,30.0, MyUID) 
        play = false
    end

end

return lua_table
end