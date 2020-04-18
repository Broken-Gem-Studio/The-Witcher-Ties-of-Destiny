function GetTableParticles()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Particles = Scripting.Particles()
lua_table.GameObject = Scripting.GameObject()

function lua_table:Awake()
	lua_table.UID = lua_table.GameObject:GetMyUID()
end

function lua_table:Start()
	lua_table.Particles:SetParticlesLifeTime(5000, lua_table.UID)
end

function lua_table:Update()
end

return lua_table
end