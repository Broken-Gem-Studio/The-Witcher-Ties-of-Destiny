function GetTableDestroyed_Prop()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Particles = Scripting.Particles()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.Scenes = Scripting.Scenes()
lua_table.Transform = Scripting.Transform()

lua_table.type = 0
lua_table.Random = 1
lua_table.myUID = 0
lua_table.player_owner = 0

lua_table.power_potion = 0
lua_table.stamina_potion = 0
lua_table.health_potion = 0

local barrel_particles

function lua_table:Awake()
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
	local parent = lua_table.GameObjectFunctions:GetGameObjectParent(lua_table.myUID)
end

function lua_table:Start()
	if lua_table.Random  == 1
	then
		local random = lua_table.System:RandomNumberInRange(1, 4)
		if random < 2
		then
			lua_table.type = 0
		elseif random < 3
		then
			lua_table.type = 1
		elseif random < 4
		then
			lua_table.type = 2
		end
	end
	local position = {}
	local rotation = {}
	local potion = 0
	position = lua_table.Transform:GetPosition(lua_table.myUID)
	rotation = lua_table.Transform:GetRotation(lua_table.myUID)
	if lua_table.type == 0
	then
		potion = lua_table.Scenes:Instantiate(lua_table.health_potion, position[1], position[2], position[3], rotation[1], rotation[2], rotation[3])
	elseif lua_table.type == 1
	then
		potion = lua_table.Scenes:Instantiate(lua_table.stamina_potion, position[1], position[2], position[3], rotation[1], rotation[2], rotation[3])
	elseif lua_table.type == 2
	then
		potion = lua_table.Scenes:Instantiate(lua_table.power_potion, position[1], position[2], position[3], rotation[1], rotation[2], rotation[3])
	end
	if potion ~= 0 then
		local script = lua_table.GameObjectFunctions:GetScript(potion)
		script.player_owner = lua_table.player_owner
	end
end


function lua_table:Update()

  
end

return lua_table
end