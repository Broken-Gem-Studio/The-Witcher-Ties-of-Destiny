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

local Buttons = {
	RESUME = 1,
	COMBOS = 2,
	MENU = 3
}

local currentButton = Buttons.RESUME
local showingCombos = false
local goMenu = false
local activatePause = false
local ControllerID = 1

-- Core
local function Reset()	
	lua_table.gamePaused = false
	lua_table.SystemFunctions:ResumeGame()
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.parchmentImage_UUID)	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.background_UUID)	

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.menuButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.resumeButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.combosButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.combosButton_UUID, false)

end

function lua_table:Awake()
	lua_table.parchmentImage_UUID = lua_table.ObjectFunctions:FindGameObject("PauseImage")
	lua_table.combosPanels_UUID = lua_table.ObjectFunctions:FindGameObject("CombosPanels")
	lua_table.background_UUID = lua_table.ObjectFunctions:FindGameObject("Background")
	lua_table.menuButton_UUID = lua_table.ObjectFunctions:FindGameObject("MenuButton")
	lua_table.resumeButton_UUID = lua_table.ObjectFunctions:FindGameObject("ResumeButton")
	lua_table.combosButton_UUID = lua_table.ObjectFunctions:FindGameObject("CombosButton")
end

function lua_table:Start()
end

function lua_table:Update()

	-- Pause menu activation
	if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_START", "DOWN") 
	then
		ControllerID = 1
		activatePause = true
		
	elseif lua_table.InputFunctions:IsGamepadButton(2, "BUTTON_START", "DOWN")
	then
		ControllerID = 2
		activatePause = true
	end

	if lua_table.InputFunctions:KeyDown("P") or activatePause == true
	then 
		lua_table.AudioFunctions:PlayAudioEvent("Play_Pause")
		if lua_table.gamePaused == false
		then
			currentButton = Buttons.RESUME
			activatePause = false
			lua_table.gamePaused = true
			lua_table.SystemFunctions:PauseGame()
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.parchmentImage_UUID)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.background_UUID)

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

	-- Controller management
	if lua_table.gamePaused == true 
	then
		if showingCombos == false
		then
			if lua_table.InputFunctions:IsGamepadButton(ControllerID, "BUTTON_A", "DOWN")
			then
				if currentButton == Buttons.RESUME
				then
					lua_table:ResumeGame()			
				elseif currentButton == Buttons.COMBOS
				then
					lua_table:ShowCombos()			
				elseif currentButton == Buttons.MENU
				then
					lua_table:GoToMainMenu()
				end
			end

			if lua_table.InputFunctions:IsGamepadButton(ControllerID, "BUTTON_DPAD_DOWN", "DOWN")
			then 
				lua_table.AudioFunctions:PlayAudioEvent("Play_Mouse_over")
				currentButton = currentButton + 1
				if currentButton > Buttons.MENU
				then
					currentButton = Buttons.MENU
				end
			end

			if lua_table.InputFunctions:IsGamepadButton(ControllerID, "BUTTON_DPAD_UP", "DOWN")
			then 
				lua_table.AudioFunctions:PlayAudioEvent("Play_Mouse_over")
				currentButton = currentButton - 1
				if currentButton < Buttons.RESUME
				then
					currentButton = Buttons.RESUME
				end
			end
		end

		if lua_table.InputFunctions:IsGamepadButton(ControllerID, "BUTTON_B", "DOWN")
		then
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.combosPanels_UUID)
			showingCombos = false
		end
	end

	if goMenu == true
	then
		lua_table.SceneFunctions:LoadScene(lua_table.mainMenu_UUID)
	end
end

-- Button functions
function lua_table:GoToMainMenu()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Button_main_menu")
	goMenu = true
	Reset()
end

function lua_table:ResumeGame()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Button_resume")
	Reset()
end

function lua_table:ShowCombos()
	lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.combosPanels_UUID)
	showingCombos = true
end

return lua_table
end