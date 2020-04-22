function GetTableMainMenuUI_v01()

local lua_table = {}

lua_table.SystemFunctions = Scripting.System()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.CameraFunctions = Scripting.Camera()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.TransformFuctions = Scripting.Transform()

-----------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------

-- Lua table variabes
lua_table.scene_1 = 0
lua_table.scene_2 = 0
lua_table.cameraSpeed = 20

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

local startingGame = false
local playingGame = false

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
end

function lua_table:Start()
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", quitButton)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", startButton)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", playButton)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", showFirstLevel)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", showSecondLevel)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", firstLevelPlay)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", secondLevelPlay)
end

function lua_table:Update()
	dt = lua_table.SystemFunctions:DT()
	lua_table.currentCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)

	-- Camera movement management
	if startingGame
	then
		if lua_table.currentCameraPos[3] > lua_table.lastCameraPos[3] - 10
		then
			lua_table.TransformFuctions:Translate(-lua_table.cameraSpeed/2 * dt, -lua_table.cameraSpeed/5 * dt, -lua_table.cameraSpeed * dt, camera_UUID)
		else		
			startingGame = false
			lua_table.InterfaceFunctions:MakeElementVisible("Button", playButton)
			lua_table.InterfaceFunctions:MakeElementVisible("Button", quitButton)
		end
	end

	if playingGame
	then
		local a = 0
	end
end

function lua_table:StartGame()
	startingGame = true
	lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", startButton)
end

function lua_table:PlayGame()
	playingGame = true
	lua_table.lastCameraPos = lua_table.TransformFuctions:GetPosition(camera_UUID)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", quitButton)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", playButton)

	lua_table.InterfaceFunctions:MakeElementVisible("Button", showFirstLevel)
	lua_table.InterfaceFunctions:MakeElementVisible("Button", showSecondLevel)

	lua_table.TransformFuctions:SetPosition(-89.849, 25.571, -341.054, camera_UUID)
	lua_table.TransformFuctions:SetObjectRotation(88.499, 18.100, -89.461, camera_UUID)
end

function lua_table:QuitGame()
	lua_table.SceneFunctions:QuitGame()
end

function lua_table:ShowFirstLevel()
	lua_table.InterfaceFunctions:MakeElementVisible("Button", firstLevelPlay)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", secondLevelPlay)

	lua_table.InterfaceFunctions:MakeElementVisible("Image", firstLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", secondLevelImage)
end

function lua_table:ShowSecondLevel()
	lua_table.InterfaceFunctions:MakeElementVisible("Button", secondLevelPlay)
	lua_table.InterfaceFunctions:MakeElementInvisible("Button", firstLevelPlay)
	
	lua_table.InterfaceFunctions:MakeElementVisible("Image", secondLevelImage)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", firstLevelImage)
end

function lua_table:PlayFirstLevel()
	lua_table.SceneFunctions:LoadScene(lua_table.scene_1)
end

function lua_table:PlaySecondLevel()
	lua_table.SceneFunctions:LoadScene(lua_table.scene_2)
end

return lua_table
end