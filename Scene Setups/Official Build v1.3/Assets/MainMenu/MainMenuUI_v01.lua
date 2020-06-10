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
local render = 0
local background = 0
local startButton = 0
local quitButton = 0
local playButton = 0
local firstLevelButton = 0
local secondLevelButton = 0
local firstLevelImage = 0
local secondLevelImage = 0
local firstLevelPlay = 0
local secondLevelPlay = 0

local quitMarker = 0
local playGameMarker = 0
local level1Marker = 0
local level2Marker = 0
local playLevelMarker = 0

local camera_UUID = 0
local dt = 0
local step = 1
local time = 0
local started_time = 0

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

local function HandleInputs()
	-- Start game	
	if currentButton == Buttons.START and lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_A", "DOWN")
	then
		lua_table:StartGame()
	end

	-- Sign menu
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
			lua_table.InterfaceFunctions:MakeElementVisible("Image", quitMarker)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", playGameMarker)
			currentButton = Buttons.QUIT
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_UP", "DOWN") and currentButton == Buttons.QUIT
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			lua_table.InterfaceFunctions:MakeElementVisible("Image", playGameMarker)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", quitMarker)
			currentButton = Buttons.PLAY
		end
	end

	-- Board menu
	if boardMenu == true
	then
		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_A", "DOWN")
		then
			if currentButton == Buttons.PLAY1
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
			lua_table.InterfaceFunctions:MakeElementVisible("Image", level2Marker)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", level1Marker)
			currentButton = Buttons.LEVEL2
			lua_table:ShowSecondLevel()
		end

		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_UP", "DOWN") and currentButton == Buttons.LEVEL2
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			lua_table.InterfaceFunctions:MakeElementVisible("Image", level1Marker)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", level2Marker)
			currentButton = Buttons.LEVEL1
			lua_table:ShowFirstLevel()
		end
		
		if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_DPAD_RIGHT", "DOWN") and (currentButton == Buttons.LEVEL1 or currentButton == Buttons.LEVEL2)
		and (showingLevel1 == true or showingLevel2 == true)
		then
			lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_mouse_over")
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", level1Marker)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", level2Marker)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", playLevelMarker)

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
			lua_table.InterfaceFunctions:MakeElementVisible("Image", level1Marker)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", playLevelMarker)
			currentButton = Buttons.LEVEL1
			lua_table:ShowFirstLevel()
		end
	end	

	-- Go back from character selection scene
	if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_Y", "DOWN") and (lua_table.loadLevel1 == true or lua_table.loadLevel2 == true)
	then
		currentButton = Buttons.LEVEL1
		boardMenu = true
		lua_table.loadLevel1 = false
		lua_table.loadLevel2 = false
		showingLevel1 = true

		lua_table.ObjectFunctions:SetActiveGameObject(true, background)
		lua_table.InterfaceFunctions:MakeElementVisible("Image", showFirstLevel)
		lua_table.InterfaceFunctions:MakeElementVisible("Image", showSecondLevel)
		lua_table.InterfaceFunctions:MakeElementVisible("Image", level1Marker)
		lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelImage)
		lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelPlay)
	end
end

local function PrepareCharacterSelection()	
	boardMenu = false
	showingLevel2 = false
	showingLevel1 = false
	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", showFirstLevel)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", showSecondLevel)
	lua_table.ObjectFunctions:SetActiveGameObject(true, SELECTION)
end

-----------------------------------------------------------------------------
-- CORE
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
	render = lua_table.ObjectFunctions:FindGameObject("Board")
	background = lua_table.ObjectFunctions:FindGameObject("MapBackground")

	lastTimeFallen = lua_table.SystemFunctions:GameTime()
	SELECTION = lua_table.ObjectFunctions:FindGameObject("SELECTION")
end

function lua_table:Start()
	quitMarker = lua_table.ObjectFunctions:FindGameObject("QuitMarker")
	playGameMarker = lua_table.ObjectFunctions:FindGameObject("PlayGameMarker")
	level1Marker = lua_table.ObjectFunctions:FindGameObject("Level1Marker")
	level2Marker = lua_table.ObjectFunctions:FindGameObject("Level2Marker")
	playLevelMarker = lua_table.ObjectFunctions:FindGameObject("PlayLevelMarker")

	started_time = lua_table.SystemFunctions:GameTime()
end

function lua_table:Update()
	time = lua_table.SystemFunctions:GameTime() - started_time
	dt = lua_table.SystemFunctions:DT()
	lua_table.currentCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)

	-- Button management
	HandleInputs()

	-- Camera movement management	
	if startingGame == true
	then
		if lua_table.currentCameraPos[1] < lua_table.lastCameraPos[1] + 30
		then
			lua_table.TransformFuctions:Translate(lua_table.cameraSpeed * dt, -lua_table.cameraSpeed/3 * dt, 0, camera_UUID)
		else		
			startingGame = false
			startMenu = true
			lua_table.InterfaceFunctions:MakeElementVisible("Image", playGameMarker)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", playButton)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", quitButton)
		end
	end

	if playingGame == true
	then
		if step == 1
		then
			if lua_table.currentCameraPos[3] > lua_table.lastCameraPos[3] - 40
			then
				lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed * 2.5 * dt, -lua_table.cameraSpeed/7.5 * dt, -lua_table.cameraSpeed/1.5 * dt, camera_UUID)
				lua_table.TransformFuctions:RotateObject(0, lua_table.cameraSpeed/1.2 * dt, 0, camera_UUID)
			else 
				lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
				step = 2
			end

		elseif step == 2
		then
			if lua_table.currentCameraPos[3] > lua_table.lastCameraPos[3] - 28
			then
				lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed * 3 * dt, -lua_table.cameraSpeed/4.5 * dt, -lua_table.cameraSpeed * 1.25 * dt, camera_UUID)
				lua_table.TransformFuctions:RotateObject(0, lua_table.cameraSpeed * 1.5 * dt, 0, camera_UUID)
			else 
				playingGame = false		
				boardMenu = true		
				showingLevel1 = true
				lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelPlay)
			end	
		end
	end	
end

-----------------------------------------------------------------------------
-- BUTTON FUNCTIONS
-----------------------------------------------------------------------------

function lua_table:StartGame()
	if lua_table.SystemFunctions:GameTime() > lastTimeFallen + 7.4
	then
		startingGame = true
		currentButton = Buttons.PLAY;
		lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
	end
end

function lua_table:PlayGame()
	playingGame = true
	startMenu = false
	currentButton = Buttons.LEVEL1;
	lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)	
	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", playGameMarker)
	lua_table.ObjectFunctions:SetActiveGameObject(false, render)
	lua_table.ObjectFunctions:SetActiveGameObject(true, background)
	lua_table.InterfaceFunctions:MakeElementVisible("Image", level1Marker)
	lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelImage)
	lua_table.InterfaceFunctions:MakeElementVisible("Image", showFirstLevel)
	lua_table.InterfaceFunctions:MakeElementVisible("Image", showSecondLevel)
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
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelPlay)

	lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelImage)
end

function lua_table:ShowSecondLevel()
    lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_select")
	showingLevel2 = true
	showingLevel1 = false

	lua_table.InterfaceFunctions:MakeElementVisible("Image", secondLevelPlay)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelPlay)
	
	lua_table.InterfaceFunctions:MakeElementVisible("Image", secondLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelImage)
end

function lua_table:PlayFirstLevel()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_play_2")	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelPlay)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", playLevelMarker)
	
	lua_table.loadLevel1 = true
	PrepareCharacterSelection()
end

function lua_table:PlaySecondLevel()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Main_Menu_play_2")
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelPlay)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", playLevelMarker)

	lua_table.loadLevel2 = true
	PrepareCharacterSelection()
end

return lua_table
end