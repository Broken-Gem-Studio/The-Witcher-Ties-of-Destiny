function GetTableGhoulBite()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.GameObject = Scripting.GameObject()
lua_table.Animations = Scripting.Animations()

lua_table.name = "Bite_Anticipation"

local MyUID = 0

function lua_table:Awake()
end

function lua_table:Start()
    MyUID = lua_table.GameObject:GetMyUID()
  
    lua_table.Animations:PlayAnimation(lua_table.name, 30.0, MyUID)
end

function lua_table:Update()

end

return lua_table
end