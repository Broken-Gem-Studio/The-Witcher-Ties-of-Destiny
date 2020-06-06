function GetTableMusic_Manager_v2()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.GameObjectFunctions = Scripting.GameObject()

lua_table.Enemies_Nearby = false
lua_table.Level = "1"

-- GOs
local camera_GO_UID	--If we decide to make it so battle music sounds when inside the frustum, currently does nothing
local my_UID = 0
local geralt_GO_UID
local geralt_script

local jaskier_GO_UID
local jaskier_script

local pause_GO
local pause_script

function lua_table:Awake()
	geralt_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Geralt")
	jaskier_GO_UID = lua_table.GameObjectFunctions:FindGameObject("Jaskier")

	pause_GO = lua_table.GameObjectFunctions:FindGameObject("ButtonManager")
	pause_script = lua_table.GameObjectFunctions:GetScript(pause_GO)

	if geralt_GO_UID ~= 0 then geralt_script = lua_table.GameObjectFunctions:GetScript(geralt_GO_UID) end
	if jaskier_GO_UID ~= 0 then jaskier_script = lua_table.GameObjectFunctions:GetScript(jaskier_GO_UID) end
end

function lua_table:Start()
	my_UID = lua_table.GameObjectFunctions:GetMyUID()
	local audio_event = "Play_Level_" .. lua_table.Level .. "_Music"
	lua_table.AudioFunctions:PlayAudioEvent(audio_event)

	lua_table.AudioFunctions:SetAudioSwitch("Lvl_" .. lua_table.Level .. "_Music_Switch","Exploration",my_UID)
	lua_table.AudioFunctions:SetVolume(0.3,my_UID)

end

function lua_table:Update()
	
	if pause_script.gamePaused == false then
		if geralt_script.enemies_nearby == true or jaskier_script.enemies_nearby == true then
			lua_table.Enemies_Nearby = true
			lua_table.AudioFunctions:SetAudioSwitch("Lvl_" .. lua_table.Level .. "_Music_Switch","Combat",my_UID)
		elseif geralt_script.enemies_nearby == false and jaskier_script.enemies_nearby == false then
			lua_table.Enemies_Nearby = false
			lua_table.AudioFunctions:SetAudioSwitch("Lvl_" .. lua_table.Level .. "_Music_Switch","Exploration",my_UID)
		end
	elseif pause_script.gamePaused == true then

		lua_table.AudioFunctions:SetAudioSwitch("Lvl_" .. lua_table.Level .. "_Music_Switch","Pause",my_UID)
	end
	
end

function lua_table:StopMusic()
	local audio_event = "Play_Level_" .. lua_table.Level .. "_Music"
	lua_table.AudioFunctions:StopAudioEventGO(audio_event, my_UID)
end

return lua_table
end