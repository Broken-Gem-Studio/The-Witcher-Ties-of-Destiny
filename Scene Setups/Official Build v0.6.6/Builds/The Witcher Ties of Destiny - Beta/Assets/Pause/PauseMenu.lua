function GetTablePauseMenu()

local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.InputFunctions = Scripting.Inputs()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.AudioFunctions = Scripting.Audio()

-- Variables
lua_table.gamePaused = false
lua_table.mainMenu_UUID = 0
local goMenu = false

-- Core
local function Reset()	
	lua_table.SystemFunctions:ResumeGame()
	lua_table.gamePaused = false
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.parchmentImage_UUID)

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.menuButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.resumeButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.combosButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.combosButton_UUID, false)
end

function lua_table:Awake()
	lua_table.parchmentImage_UUID = lua_table.ObjectFunctions:FindGameObject("PauseImage")
	lua_table.leftCombosPanel_UUID = lua_table.ObjectFunctions:FindGameObject("LeftCombosPanel")
	lua_table.rightCombosPanel_UUID = lua_table.ObjectFunctions:FindGameObject("RightCombosPanel")
	lua_table.parchmentImage_UUID = lua_table.ObjectFunctions:FindGameObject("PauseImage")
	lua_table.menuButton_UUID = lua_table.ObjectFunctions:FindGameObject("MenuButton")
	lua_table.resumeButton_UUID = lua_table.ObjectFunctions:FindGameObject("ResumeButton")
	lua_table.combosButton_UUID = lua_table.ObjectFunctions:FindGameObject("CombosButton")
end

function lua_table:Start()
end

function lua_table:Update()
	if lua_table.InputFunctions:KeyDown("P")
	or lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_START", "DOWN") or lua_table.InputFunctions:IsGamepadButton(2, "BUTTON_START", "DOWN")
	then
		lua_table.AudioFunctions:PlayAudioEvent("Play_Pause")
		if lua_table.gamePaused == false
		then
			lua_table.SystemFunctions:PauseGame()
			lua_table.gamePaused = true
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.parchmentImage_UUID)

			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.menuButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, true)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.resumeButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, true)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.combosButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.combosButton_UUID, true)
		else
			Reset()
		end
	end

	if goMenu
	then
		lua_table.SceneFunctions:LoadScene(lua_table.mainMenu_UUID)
	end
end

-- Button functions
function lua_table:GoToMainMenu()
	goMenu = true
	lua_table.AudioFunctions:PlayAudioEvent("Play_Button_main_menu")
	lua_table.SystemFunctions:ResumeGame()
end

function lua_table:ResumeGame()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Button_resume")
	Reset()
end

function lua_table:ShowCombos()
end

return lua_table
end