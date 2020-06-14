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
local step = 1
local ControllerID = 1
local increment = 1
local positionSum = 665

local resumeMarker = 0
local combosMarker = 0
local menuMarker = 0

local tutorialGO = 0
local tutoScript = 0
local loading_screen = 0
local loading_timer = 0

-- Core
local function Reset()	
	ControllerID = 0
	positionSum = 665
	increment = 1
	step = 1
	activatePause = false
	showingCombos = false
	lua_table.SystemFunctions:ResumeGame()
	lua_table.gamePaused = false
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.parchmentImage_UUID)	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.background_UUID)	

	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.menuButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.resumeButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, false)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.combosButton_UUID)
	lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.combosButton_UUID, false)
			
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.combosPanels_UUID)
	lua_table.InterfaceFunctions:SetUIElementPosition("Image", 4, 665, lua_table.combosPanels_UUID)
	
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", resumeMarker)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", combosMarker)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", menuMarker)
end

function lua_table:Awake()
	lua_table.parchmentImage_UUID = lua_table.ObjectFunctions:FindGameObject("PauseImage")
	lua_table.combosPanels_UUID = lua_table.ObjectFunctions:FindGameObject("CombosPanels")
	lua_table.background_UUID = lua_table.ObjectFunctions:FindGameObject("PauseBackground")
	lua_table.menuButton_UUID = lua_table.ObjectFunctions:FindGameObject("MenuButton")
	lua_table.resumeButton_UUID = lua_table.ObjectFunctions:FindGameObject("ResumeButton")
	lua_table.combosButton_UUID = lua_table.ObjectFunctions:FindGameObject("CombosButton")
	tutorialGO = lua_table.ObjectFunctions:FindGameObject("TutorialManager")
	
	if tutorialGO ~= 0
	then
		tutoScript = lua_table.ObjectFunctions:GetScript(tutorialGO)
	end
end

function lua_table:Start()
	resumeMarker = lua_table.ObjectFunctions:FindGameObject("ResumeMarker")
	combosMarker = lua_table.ObjectFunctions:FindGameObject("CombosMarker")
	menuMarker = lua_table.ObjectFunctions:FindGameObject("MenuMarker")

	loading_screen = lua_table.ObjectFunctions:FindGameObject("LoadingScreenCanvas")
	
end

function lua_table:Update()

	-- Pause menu activation
	if lua_table.InputFunctions:IsGamepadButton(1, "BUTTON_START", "DOWN") or lua_table.InputFunctions:KeyDown("P")
	then
		ControllerID = 1
		activatePause = true
		
	elseif lua_table.InputFunctions:IsGamepadButton(2, "BUTTON_START", "DOWN")
	then
		ControllerID = 2
		activatePause = true
	end

	if activatePause == true and (tutorialGO == 0 or (tutorialGO ~= 0 and tutoScript.tutorialPause == false))
	then 
		lua_table.AudioFunctions:PlayAudioEvent("Play_Pause")
		if lua_table.gamePaused == false
		then
			currentButton = Buttons.RESUME
			activatePause = false
			lua_table.gamePaused = true
			lua_table.SystemFunctions:PauseGame()
			lua_table.InterfaceFunctions:MakeElementVisible("Image", resumeMarker)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.parchmentImage_UUID)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.background_UUID)

			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.menuButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.menuButton_UUID, true)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.resumeButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.resumeButton_UUID, true)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.combosButton_UUID)
			lua_table.InterfaceFunctions:SetUIElementInteractable("Button", lua_table.combosButton_UUID, true)

			if tutorialGO ~= 0
			then
				if tutoScript.currentStep == 10 and tutoScript.moveStep10 == true
				then
					currentButton = Buttons.COMBOS
					lua_table.InterfaceFunctions:MakeElementInvisible("Image", resumeMarker)
					lua_table.InterfaceFunctions:MakeElementInvisible("Image", menuMarker)
					lua_table:ShowCombos()	
				end
			end
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
				if currentButton >= Buttons.MENU
				then
					lua_table.InterfaceFunctions:MakeElementVisible("Image", menuMarker)
					lua_table.InterfaceFunctions:MakeElementInvisible("Image", combosMarker)
					currentButton = Buttons.MENU
				else
					lua_table.InterfaceFunctions:MakeElementVisible("Image", combosMarker)
					lua_table.InterfaceFunctions:MakeElementInvisible("Image", resumeMarker)
				end
			end

			if lua_table.InputFunctions:IsGamepadButton(ControllerID, "BUTTON_DPAD_UP", "DOWN")
			then 
				lua_table.AudioFunctions:PlayAudioEvent("Play_Mouse_over")
				currentButton = currentButton - 1
				if currentButton <= Buttons.RESUME
				then
					lua_table.InterfaceFunctions:MakeElementVisible("Image", resumeMarker)
					lua_table.InterfaceFunctions:MakeElementInvisible("Image", combosMarker)
					currentButton = Buttons.RESUME
				else
					lua_table.InterfaceFunctions:MakeElementVisible("Image", combosMarker)
					lua_table.InterfaceFunctions:MakeElementInvisible("Image", menuMarker)
				end
			end
		end

		if lua_table.InputFunctions:IsGamepadButton(ControllerID, "BUTTON_B", "DOWN") and showingCombos == true
		then
			lua_table.InterfaceFunctions:MakeElementInvisible("Image", lua_table.combosPanels_UUID)
			lua_table.InterfaceFunctions:MakeElementVisible("Image", combosMarker)
			lua_table.InterfaceFunctions:SetUIElementPosition("Image", 4, 665, lua_table.combosPanels_UUID)
			positionSum = 665
			increment = 1
			step = 1
			showingCombos = false
		end
	end
	
	-- Scene loading management
	if goMenu == true
	then
		loading_timer = loading_timer + lua_table.SystemFunctions:DT()
        if loading_timer >= 1 
		then
			lua_table.SceneFunctions:LoadScene(lua_table.mainMenu_UUID)
			goMenu = false
        else 
			lua_table.ObjectFunctions:SetActiveGameObject(true, loading_screen)
        end 
	end

	-- Combos deployment
	if showingCombos == true
	then
		if step == 1
		then
			if positionSum > 450
			then
				increment = increment + 1
				positionSum = positionSum - increment
				lua_table.InterfaceFunctions:SetUIElementPosition("Image", 4, positionSum, lua_table.combosPanels_UUID)
			else
				step = 2
			end
			
		elseif step == 2
		then
			if positionSum > 110 
			then
				increment = increment + 3
				positionSum = positionSum - increment
				lua_table.InterfaceFunctions:SetUIElementPosition("Image", 4, positionSum, lua_table.combosPanels_UUID)
			else
				step = 3
			end

		elseif step == 3
		then
			if positionSum > -246 
			then
				increment = increment + 0.75
				positionSum = positionSum - increment
				lua_table.InterfaceFunctions:SetUIElementPosition("Image", 4, positionSum, lua_table.combosPanels_UUID)
			end
		end
	end
end

-- Button functions
function lua_table:GoToMainMenu()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Button_main_menu")
	goMenu = true
	last_checkpoint = 0
	Reset()
end

function lua_table:ResumeGame()
	lua_table.AudioFunctions:PlayAudioEvent("Play_Button_resume")
	Reset()
end

function lua_table:ShowCombos()
	lua_table.InterfaceFunctions:MakeElementVisible("Image", lua_table.combosPanels_UUID)
	lua_table.InterfaceFunctions:MakeElementInvisible("Image", combosMarker)
	showingCombos = true
end

return lua_table
end