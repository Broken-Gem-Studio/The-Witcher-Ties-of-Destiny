function GetTableMusicTrigger()
local lua_table = {}
lua_table.System = Scripting.System()
lua_table.Physic = Scripting.Physics()
lua_table.Audios = Scripting.Audio()
lua_table.GO = Scripting.GameObject()

local UID = 0
lua_table.camera = "MainCamera"
lua_table.type = {DEFAULT = 1, COMBAT = 2, REST = 3, MENU = 4}
lua_table.currenttype = 1
local currentmusic = 0
local UIDCamera = 0

function lua_table:Awake()
end

function lua_table:Start()

	UID = lua_table.GO:GetMyUID()

	UIDCamera = lua_table.GO:FindGameObject(lua_table.camera)

	BGMPlaying = false --some background music is playing
	lua_table.Audios:PlayAudioEvent("Main_Menu")

end

function lua_table:Update()

end

function lua_table:OnTriggerEnter()
	local entity = lua_table.Physic:OnTriggerEnter(UID)
	local layer = lua_table.GO:GetLayerByID(entity)
	lua_table.System:LOG(layer)
	if layer == 1
	then
		if lua_table.currenttype == 1 and currentmusic ~= 1 and lua_table.enemies_nearby == false
		then
			lua_table.System:LOG("Default")
			currentmusic = 1
			lua_table.Audios:StopAudioEvent("Play_Main_menu", UIDCamera)
			lua_table.Audios:StopAudioEvent("Play_Silver_for_Monsters_loop", UIDCamera)
			lua_table.Audios:StopAudioEvent("Rest", UIDCamera)
			lua_table.Audios:PlayAudioEvent("Play_Trial_of_the_Grasses_loop", UIDCamera)
		end
		if lua_table.currenttype == 2 and currentmusic ~= 2 and lua_table.enemies_nearby
		then
			lua_table.System:LOG("Combat")
			currentmusic = 2
			lua_table.Audios:StopAudioEvent("Play_Main_menu", UIDCamera)
			lua_table.Audios:PlayAudioEvent("Play_Silver_for_Monsters_loop", UIDCamera)
			lua_table.Audios:StopAudioEvent("Rest", UIDCamera)
			lua_table.Audios:StopAudioEvent("Play_Trial_of_the_Grasses_loop", UIDCamera)
		end
		if lua_table.currenttype == 3 and currentmusic ~= 3
		then
			lua_table.System:LOG("Rest")
			currentmusic = 3
			lua_table.Audios:StopAudioEvent("Play_Main_menu", UIDCamera)
			lua_table.Audios:StopAudioEvent("Play_Silver_for_Monsters_loop", UIDCamera)
			lua_table.Audios:PlayAudioEvent("Rest", UIDCamera)
			lua_table.Audios:StopAudioEvent("Play_Trial_of_the_Grasses_loop", UIDCamera)
		end
		if lua_table.currenttype == 4 and currentmusic ~= 4
		then
			lua_table.System:LOG("Menu")
			currentmusic = 4
			lua_table.Audios:PlayAudioEvent("Play_Main_menu", UIDCamera)
			lua_table.Audios:StopAudioEvent("Play_Silver_for_Monsters_loop", UIDCamera)
			lua_table.Audios:StopAudioEvent("Rest", UIDCamera)
			lua_table.Audios:StopAudioEvent("Play_Trial_of_the_Grasses_loop", UIDCamera)
		end
	end
end

return lua_table
end