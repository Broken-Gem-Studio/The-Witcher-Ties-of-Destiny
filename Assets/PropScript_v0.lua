function GetTablePropScript ()
local lua_table = {}
lua_table["Functions_System"] = Scripting.System ()
lua_table["Functions_Transform"] = Scripting.Transform ()
lua_table["Functions_GameObject"] = Scripting.GameObject ()
lua_table["Functions_Particles"] = Scripting.Particles ()
lua_table["Functions_Particles"] = Scripting.Audio()

-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

-- Health Value
lua_table.health

-----------------------------------------------------------------------------------------
-- Prop Variables
-----------------------------------------------------------------------------------------

-- Prop position
local prop_position_x = 0
local prop_position_y = 0 
local prop_position_z = 0

local state = -- not in use rn
{
	DESTROYED = 0,
	FULL = 1,
	HURT = 2
}
local current_state = state.DYNAMIC -- Should initialize at awake(?)

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------


-- Main Code
function lua_table:Awake ()
	lua_table["Functions_System"]:LOG ("This Log was called from Camera Script on AWAKE")
	-- Get players id maybe?

end

function lua_table:Start ()
	lua_table["Functions_System"]:LOG ("This Log was called from Camera Script on START")
	is_start = true

	-- set particles parameters

	is_start = false
end

function lua_table:Update ()
	dt = lua_table["Functions_System"]:DT ()
	is_update = true
	
	-- do something over time?
	-- check players proximity to start doing something when close
	-- check collision
	-- update helth + state if hit
	-- hit reaction
	-- item generator?
	
	is_update = false
end
	return lua_table
end

