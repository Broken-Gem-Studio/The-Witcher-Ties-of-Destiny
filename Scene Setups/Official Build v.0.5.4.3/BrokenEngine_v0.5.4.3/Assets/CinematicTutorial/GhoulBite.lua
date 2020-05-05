function GetTableGhoulBite()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Animations = Scripting.Animations()

lua_table.time = 0

local MyUID = 0

function lua_table:Awake()
end

function lua_table:Start()
    MyUID = lua_table.GameObject:GetMyUID()
  
    lua_table.Animations:PlayAnimation("Bite_Anticipation", 30.0, MyUID)
end

function lua_table:Update()

end

return lua_table
end