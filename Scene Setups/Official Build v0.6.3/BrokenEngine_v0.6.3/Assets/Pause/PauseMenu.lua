function GetTablePauseMenu()

local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.InterfaceFunctions = Scripting.Interface()

local gamePaused = false
local goMenu = false
lua_table.mainMenu_UUID = 0

function lua_table:Awake()
	lua_table.pauseImage_UUID = lua_table.ObjectFunctions:FindGameObject("PauseText")
	lua_table.parchmentImage_UUID = lua_table.ObjectFunctions:FindGameObject("PauseImage")
	lua_table.menuButton_UUID = lua_table.ObjectFunctions:FindGameObject("MenuButton")
	lua_table.resumeButton_UUID = lua_table.ObjectFunctions:FindGameObject("ResumeButton")
end

function lua_table:Start()
end

function lua_table:Update()
	if lua_table.InputFunctions:KeyDown("P")
	or lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_START", "DOWN") or lua_table.InputFunctions:IsGamepadButton(2, "BUTTON_START", "DOWN")
	then
		if gamePaused == false
		then
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.pauseImage_UUID)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.parchmentImage_UUID)
			lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.menuButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, true)
			lua_table.ObjectFunctions:SetActiveGameObject(true, lua_table.resumeButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, true)
			lua_table.SystemFunctions:PauseGame()
			gamePaused = true
		else
			lua_table.SystemFunctions:ResumeGame()
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.pauseImage_UUID)
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.parchmentImage_UUID)
			lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.menuButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, false)
			lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.resumeButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, false)
			gamePaused = false
		end
	end

	if goMenu
	then
		lua_table.SceneFunctions:LoadScene(lua_table.mainMenu_UUID)
	end
end

function lua_table:GoToMainMenu()
	goMenu = true
	lua_table.SystemFunctions:ResumeGame()
end

function lua_table:ResumeGame()
	lua_table.SystemFunctions:ResumeGame()
	gamePaused = false

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.pauseImage_UUID)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.parchmentImage_UUID)
	lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.menuButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, false)
	lua_table.ObjectFunctions:SetActiveGameObject(false, lua_table.resumeButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, false)
end

return lua_table
end