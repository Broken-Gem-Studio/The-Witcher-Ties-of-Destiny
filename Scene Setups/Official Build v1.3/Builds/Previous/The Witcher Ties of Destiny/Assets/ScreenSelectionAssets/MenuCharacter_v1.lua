function GetTableMenuCharacter_v1()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.InterfaceFunctions = Scripting.Interface()
lua_table.SceneFunctions = Scripting.Scenes()
lua_table.CameraFunctions = Scripting.Camera()
lua_table.ObjectFunctions = Scripting.GameObject()
lua_table.TransformFuctions = Scripting.Transform()
lua_table.AudioFunctions = Scripting.Audio()


-----------------------------------------------------------------------------------------
-- Game Objects Variables
-----------------------------------------------------------------------------------------

-- Kikimora GO UID
lua_table.my_UID = 0

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------
--[[
local function DebugInputs()
	if lua_table.InputFunctions:KeyRepeat("Left Ctrl") then
		if lua_table.InputFunctions:KeyDown("a")	--Instakill Boss
		then
            -- Selected Animation
            lua_table.AnimationFunctions:PlayAnimation("Selected", 30, lua_table.my_UID)

        end
	end
end


-- Main Code
function lua_table:Awake ()
	lua_table.SystemFunctions:LOG ("This Log was called from Kikimora Script on AWAKE")
	
	-- Get my own UID
    lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()
    
end

function lua_table:Start ()
    lua_table.SystemFunctions:LOG ("Kikimora Script START")
    
    -- Idle animation
    lua_table.AnimationFunctions:PlayAnimation("Idle", 30, lua_table.my_UID)

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()

    DebugInputs()
end
--]]
end



