function GetTableMusic_Manager_v1()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.GameObjectFunctions = Scripting.GameObject()

-- GOs
local camera_GO_UID	--If we decide to make it so battle music sounds when inside the frustum, currently does nothing

local geralt_GO_UID
local geralt_script

local jaskier_GO_UID
local jaskier_script

-- Variables
local music_types = {
	no_request = -1,
	
	none = 0,
	default = 1,
	combat = 2,
	rest = 3,
	menu = 4
}
lua_table.requested_music = music_types.no_request
lua_table.current_music = 0

function lua_table:Awake()
	camera_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Camera")
	geralt_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt")
	jaskier_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier")

	if geralt_GO_UID ~= 0 then geralt_script = lua_table.GameObjectFunctions:GetScript(geralt_GO_UID) end
	if jaskier_GO_UID ~= 0 then jaskier_script = lua_table.GameObjectFunctions:GetScript(jaskier_GO_UID) end
end

function lua_table:Start()
	
end

function lua_table:Update()
	
	-- Request Music
	if geralt_script.enemies_nearby or jaskier_script.enemies_nearby
	then
		if lua_table.current_music ~= music_types.combat then lua_table.requested_music = music_types.combat end
	else
		if lua_table.current_music ~= music_types.default then lua_table.requested_music = music_types.default end
	end

	-- Apply Requested Music (if any)
	if lua_table.requested_music > music_types.no_request
	then
		if lua_table.requested_music == music_types.none
		then
			--lua_table.SystemFunctions:LOG("None")
			
			lua_table.AudioFunctions:StopAudioEvent("Play_Main_menu")
			lua_table.AudioFunctions:StopAudioEvent("Play_Silver_for_Monsters_loop")
			lua_table.AudioFunctions:StopAudioEvent("Rest")
			lua_table.AudioFunctions:StopAudioEvent("Play_Trial_of_the_Grasses_loop")

			lua_table.current_music = music_types.none

		elseif lua_table.requested_music == music_types.default
		then
			--lua_table.SystemFunctions:LOG("Default")

			lua_table.AudioFunctions:StopAudioEvent("Play_Main_menu")
			lua_table.AudioFunctions:StopAudioEvent("Play_Silver_for_Monsters_loop")
			lua_table.AudioFunctions:StopAudioEvent("Rest")
			lua_table.AudioFunctions:PlayAudioEvent("Play_Trial_of_the_Grasses_loop")

			lua_table.current_music = music_types.default

		elseif lua_table.requested_music == music_types.combat
		then
			--lua_table.SystemFunctions:LOG("Combat")

			lua_table.AudioFunctions:StopAudioEvent("Play_Main_menu")
			lua_table.AudioFunctions:PlayAudioEvent("Play_Silver_for_Monsters_loop")
			lua_table.AudioFunctions:StopAudioEvent("Rest")
			lua_table.AudioFunctions:StopAudioEvent("Play_Trial_of_the_Grasses_loop")

			lua_table.current_music = music_types.combat
		end

		lua_table.requested_music = music_types.no_request
	end
	
	--LOGS
	if lua_table.current_music == music_types.none then
		lua_table.SystemFunctions:LOG("Playing NO Music!")
	elseif lua_table.current_music == music_types.default then
		lua_table.SystemFunctions:LOG("Playing Default Music!")
	elseif lua_table.current_music == music_types.combat then
		lua_table.SystemFunctions:LOG("Playing Combat Music!")
	end
end

return lua_table
end