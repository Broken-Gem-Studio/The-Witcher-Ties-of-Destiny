function GetTableJaskierStateTest()
local lua_table = {}
lua_table.System = Scripting.System()


--State Machine
local state = {	--The order of the states is relevant to the code, CAREFUL CHANGING IT (Ex: if curr_state >= state.idle)
	dead = -4,
	down = -3,

	knocked = -2,
	stunned = -1,

	idle = 0,
	walk = 1,
	run = 2,

	evade = 3,
	ability = 4,
	ultimate = 5,
	item = 6,
	revive = 7,

	light_1 = 8,
	light_2 = 9,
	light_3 = 10,

	medium_1 = 11,
	medium_2 = 12,
	medium_3 = 13,

	heavy_1 = 14,
	heavy_2 = 15,
	heavy_3 = 16,

	combo_1 = 17,
	combo_2 = 18,
	combo_3 = 19,
	combo_4 = 20
}
lua_table.previous_state = state.down	-- Previous State
lua_table.current_state = state.down	-- Current State



function lua_table:Awake()
end

function lua_table:Start()
end

function lua_table:Update()
end

return lua_table
end