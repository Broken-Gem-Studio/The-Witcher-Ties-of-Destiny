function GetTableMainMenuUI_v01()

local lua_table = {}

lua_table.SystemFunctions = Scripting.System()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.CameraFunctions = Scripting.Camera()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.TransformFuctions = Scripting.Transform()
lua_table.AudioFunctions = Scripting.Audio()
lua_table.InputFunctions = Scripting.Inputs()

-----------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------

-- Lua table variabes
lua_table.loadLevel1 = false
lua_table.loadLevel2 = false
lua_table.cameraSpeed = 25

-- Local variables
local startButton = 0
local quitButton = 0
local playButton = 0
local firstLevelButton = 0
local secondLevelButton = 0
local firstLevelImage = 0
local secondLevelImage = 0
local camera_UUID = 0
local dt = 0
local step = 1

local startingGame = false
local playingGame = false
local startMenu = false
local boardMenu = false
local showingLevel1 = false
local showingLevel2 = false

local Buttons = {
	START = 1,
	PLAY = 2,
	QUIT = 3,
	LEVEL1 = 4,
	LEVEL2 = 5,
	PLAY1 = 6,
	PLAY2 = 7
}

local currentButton = Buttons.START
local SELECTION = 0

-----------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------

function lua_table:Awake()
	camera_UUID = lua_table.ObjectFunctions:FindGameObject("Camera")
	startButton = lua_table.ObjectFunctions:FindGameObject("StartButton")
	playButton = lua_table.ObjectFunctions:FindGameObject("PlayButton")
	quitButton = lua_table.ObjectFunctions:FindGameObject("QuitButton")
	showFirstLevel = lua_table.ObjectFunctions:FindGameObject("ShowFirstLevelButton")
	showSecondLevel = lua_table.ObjectFunctions:FindGameObject("ShowSecondLevelButton")
	firstLevelPlay = lua_table.ObjectFunctions:FindGameObject("PlayFirstLevelButton")
	secondLevelPlay = lua_table.ObjectFunctions:FindGameObject("PlaySecondLevelButton")
	firstLevelImage = lua_table.ObjectFunctions:FindGameObject("FirstLevelImage")
	secondLevelImage = lua_table.ObjectFunctions:FindGameObject("SecondLevelImage")

	lastTimeFallen = lua_table.SystemFunctions:GameTime()

	SELECTION = lua_table.ObjectFunctions:FindGameObject("SELECTION")
end

function lua_table:Start()
end

function lua_table:Update()
	dt = lua_table.SystemFunctions:DT()
	lua_table.currentCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)

	-- Button management
	if currentButton == Buttons.START and lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_START", "DOWN")
	then
		lua_table:StartGame()
	end

	if startMenu == true
	then
		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_A", "DOWN")
		then
			if currentButton == Buttons.PLAY
			then
				lua_table:PlayGame()
			elseif currentButton == Buttons.QUIT
			then
				lua_table:QuitGame()
			end
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_DOWN", "DOWN") and currentButton == Buttons.PLAY
		then 
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			currentButton = Buttons.QUIT
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_UP", "DOWN") and currentButton == Buttons.QUIT
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			currentButton = Buttons.PLAY
		end
	end

	if boardMenu == true
	then
		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_A", "DOWN")
		then
			if currentButton == Buttons.LEVEL1
			then
				lua_table:ShowFirstLevel()
			elseif currentButton == Buttons.LEVEL2
			then
				lua_table:ShowSecondLevel()
			elseif currentButton == Buttons.PLAY1
			then
				lua_table:PlayFirstLevel()
			elseif currentButton == Buttons.PLAY2
			then
				lua_table:PlaySecondLevel()
			end
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_DOWN", "DOWN") and currentButton == Buttons.LEVEL1
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			currentButton = Buttons.LEVEL2
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_UP", "DOWN") and currentButton == Buttons.LEVEL2
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			currentButton = Buttons.LEVEL1
		end
		
		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN") and (currentButton == Buttons.LEVEL1 or currentButton == Buttons.LEVEL2)
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			if showingLevel1 == true
			then
				currentButton = Buttons.PLAY1
			elseif showingLevel2 == true
			then
				currentButton = Buttons.PLAY2
			end
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_LEFT", "DOWN") and (currentButton == Buttons.PLAY1 or currentButton == Buttons.PLAY2)
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			currentButton = Buttons.LEVEL1
		end
	end

	-- Camera movement management	
	if startingGame == true
	then
		if lua_table.currentCameraPos[1] < lua_table.lastCameraPos[1] + 30
		then
			lua_table.TransformFuctions:Translate(lua_table.cameraSpeed * dt, -lua_table.cameraSpeed/3 * dt, 0, camera_UUID)
		else		
			startingGame = false
			startMenu = true
			lua_table.InterfaceFunctions:MakeElementVisible("Image", playButton)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", playButton, true)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", quitButton)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", quitButton, true)
		end
	end

	if playingGame == true
	then
		if step == 1
		then
			if lua_table.currentCameraPos[3] > lua_table.lastCameraPos[3] - 25
			then
				lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed * 1.5 * dt, 0, -lua_table.cameraSpeed/1.2 * dt, camera_UUID)
				lua_table.TransformFuctions:RotateObject(0, lua_table.cameraSpeed/1.5 * dt, 0, camera_UUID)
			else 
				lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
				step = 2
			end

		elseif step == 2
		then
			if lua_table.currentCameraPos[1] > lua_table.lastCameraPos[1] - 60
			then
				lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed * 1.5 * dt, 0, -lua_table.cameraSpeed/2.7 * dt, camera_UUID)
				lua_table.TransformFuctions:RotateObject(0, lua_table.cameraSpeed/1.2 * dt, 0, camera_UUID)
			else 
				lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
				step = 3
			end
			
		elseif step == 3
		then
			if lua_table.currentCameraPos[1] > lua_table.lastCameraPos[1] - 70
			then
				lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed * 1.5 * dt, -lua_table.cameraSpeed/6.5 * dt, -lua_table.cameraSpeed/5 * dt, camera_UUID)
				lua_table.TransformFuctions:RotateObject(0, lua_table.cameraSpeed/3.5 * dt, 0, camera_UUID)
			else 
				lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
				step = 4
			end
			
		elseif step == 4
		then
			if lua_table.currentCameraPos[3] > lua_table.lastCameraPos[3] - 23
			then
				lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed * 1.95 * dt, -lua_table.cameraSpeed/4.5 * dt, -lua_table.cameraSpeed * dt, camera_UUID)
				lua_table.TransformFuctions:RotateObject(0, lua_table.cameraSpeed/1.2 * dt, 0, camera_UUID)
			else 
				lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
				step = 5
			end

		else		
			playingGame = false		
			boardMenu = true
			lua_table.InterfaceFunctions:MakeElementVisible("Image",  showFirstLevel)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showFirstLevel, true)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", showSecondLevel)		
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showSecondLevel, true)
		end
	end	

	if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_Y", "DOWN") and (lua_table.loadLevel1 == true or lua_table.loadLevel2 == true)
	then
		currentButton = Buttons.LEVEL1
		boardMenu = true
		lua_table.loadLevel1 = false
        lua_table.loadLevel2 = false

		lua_table.InterfaceFunctions:MakeElementVisible("Image", showFirstLevel)
		lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showFirstLevel, true)
		lua_table.InterfaceFunctions:MakeElementVisible("Image", showSecondLevel)
		lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showSecondLevel, true)
	end

end

function lua_table:StartGame()
	if lua_table.SystemFunctions:GameTime() > lastTimeFallen + 7.4
	then
		startingGame = true
		currentButton = Buttons.PLAY;
		lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
		lua_table.InterfaceFunctions:SetUIElementInteractable("Button", startButton, false)
	end
end

function lua_table:PlayGame()
	playingGame = true
	startMenu = false
	currentButton = Buttons.LEVEL1;
	lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
	lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_play_1")
	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", quitButton)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", quitButton, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", playButton)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", playButton, false)
end

function lua_table:QuitGame()
    lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_quit")
	lua_table.SceneFunctions:QuitGame()
end

function lua_table:ShowFirstLevel()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_select")
	showingLevel1 = true
	showingLevel2 = false

	lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelPlay)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", firstLevelPlay, true)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelPlay)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", secondLevelPlay, false)

	lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelImage)
end

function lua_table:ShowSecondLevel()
    lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_select")
	showingLevel2 = true
	showingLevel1 = false

	lua_table.InterfaceFunctions:MakeElementVisible("Image", secondLevelPlay)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", secondLevelPlay, true)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelPlay)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", firstLevelPlay, false)
	
	lua_table.InterfaceFunctions:MakeElementVisible("Image", secondLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelImage)
end

function lua_table:PlayFirstLevel()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_play_2")
	boardMenu = false
	showingLevel2 = false
	showingLevel1 = false
	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", showFirstLevel)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showFirstLevel, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", showSecondLevel)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showSecondLevel, false)

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelPlay)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", firstLevelPlay, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelImage)

	lua_table.ObjectFunctions:SetActiveGameObject(true, SELECTION)
	lua_table.loadLevel1 = true
end

function lua_table:PlaySecondLevel()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_play_2")
	boardMenu = false
	showingLevel2 = false
	showingLevel1 = false

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", showFirstLevel)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showFirstLevel, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", showSecondLevel)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", showSecondLevel, false)

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelPlay)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", secondLevelPlay, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelImage)

	lua_table.ObjectFunctions:SetActiveGameObject(true, SELECTION)
	lua_table.loadLevel2 = true
end

return lua_table
end