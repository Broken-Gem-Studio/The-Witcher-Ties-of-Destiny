function GetTablecoca()
local lua_table = {}
lua_table.System = Scripting.System()

lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.TransformFunctions = Scripting.Transform()
lua_table.PhysicsSystem =  Scripting.Physics()
lua_table.OBJ = 0

function lua_table:Awake()
end

function lua_table:Start()

lua_table.OBJ = lua_table.TransformFunctions:GetMyUID()
lua_table.SystemFunctions:LOG("MI UID ES" .. lua_table.OBJ)

end

function lua_table:Update()



end

return lua_table
end