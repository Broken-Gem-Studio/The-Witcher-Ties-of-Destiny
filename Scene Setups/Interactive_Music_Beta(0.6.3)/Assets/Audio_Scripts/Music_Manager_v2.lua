function GetTableMusic_Manager_v2()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.GameObjectFunctions = Scripting.GameObject()

lua_table.Enemies_Nearby = false

-- GOs
local camera_GO_UID	--If we decide to make it so battle music sounds when inside the frustum, currently does nothing
local my_UID = 0
local geralt_GO_UID
local geralt_script

local jaskier_GO_UID
local jaskier_script

function lua_table:Awake()
	camera_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Camera")
	geralt_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt")
	jaskier_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier")

	if geralt_GO_UID ~= 0 then geralt_script = lua_table.GameObjectFunctions:GetScript(geralt_GO_UID) end
	if jaskier_GO_UID ~= 0 then jaskier_script = lua_table.GameObjectFunctions:GetScript(jaskier_GO_UID) end
end

function lua_table:Start()
	my_UID = lua_table.GameObjectFunctions:GetMyUID()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Level_1_Music")

	lua_table.AudioFunctions:SetAudioSwitch("Level_1_Switch","Default",my_UID)
	lua_table.AudioFunctions:SetVolume(0.3,my_UID)

end

function lua_table:Update()
	-- Request Music
	-- if geralt_script.enemies_nearby or jaskier_script.enemies_nearby
	-- then
	-- 	if lua_table.current_music ~= music_types.combat then lua_table.requested_music = music_types.combat end
	-- else
	-- 	if lua_table.current_music ~= music_types.default then lua_table.requested_music = music_types.default end
	-- end

	if geralt_script.enemies_nearby == true or jaskier_script.enemies_nearby == true then
		lua_table.Enemies_Nearby = true
	elseif geralt_script.enemies_nearby == false and jaskier_script.enemies_nearby == false then
		lua_table.Enemies_Nearby = false
	end

end

return lua_table
end