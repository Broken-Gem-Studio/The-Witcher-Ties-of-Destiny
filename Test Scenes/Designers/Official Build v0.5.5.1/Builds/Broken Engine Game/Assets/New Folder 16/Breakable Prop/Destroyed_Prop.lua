function GetTableDestroyed_Prop()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Particles = Scripting.Particles()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.AudioFunctions = Scripting.Audio()

lua_table.type = 0
lua_table.Random = 1
lua_table.Player = 0
lua_table.myUID = 0


local Emmiter_UID = 0

function lua_table:Awake()
	lua_table.myUID = lua_table.GameObjectFunctions:GetMyUID()
  Emmiter_UID = lua_table.GameObjectFunctions:FindChildGameObject("Particles")

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
	
	local script = lua_table.GameObjectFunctions:GetScript(lua_table.Player)

	if lua_table.type == 0
	then
    local potion = script.item_library.health_potion
    if potion < 5
    then
		lua_table.AudioFunctions:PlayAudioEvent("Play_Potion_health")
		potion = potion + 1
		lua_table.Particles:SetParticleColor(255,255,0,255,Emmiter_UID)
    end
	elseif lua_table.type == 1
	then
    local potion = script.item_library.stamina_potion
    if potion < 5
    then
		lua_table.AudioFunctions:PlayAudioEvent("Play_Potion_stamina")
		potion = potion + 1
		lua_table.Particles:SetParticleColor(255,0,0,255,Emmiter_UID)
    end
	elseif lua_table.type == 2
	then
    local potion = script.item_library.power_potion
    if potion < 5
    then
		lua_table.AudioFunctions:PlayAudioEvent("Play_Potion_power")
		potion = potion + 1
		lua_table.Particles:SetParticleColor(255,0,200,255,Emmiter_UID)
    end
	end
end

function lua_table:Update()

  
end

return lua_table
end