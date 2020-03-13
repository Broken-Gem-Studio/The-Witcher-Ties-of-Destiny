local Functions = Debug.Scripting()

function	GetTableEquipmentGenerator()
local lua_table = {}
lua_table.Functions = Debug.Scripting()

--Item parameters
local special_effects = {
	none = 0,

	--Chance for a special effect ocurring
	resurge = 1,
	free_item = 2,

	--Critical
	critical_chance = 3,
	crtical_power = 4,

	--Evade
	evade_extension = 5,
	evade_cost_reduction = 6,

	health_reg_boost = 7,

	--Energy (Chaos)
	energy_cap_boost = 8,
	energy_reg_boost = 9,

	ability_cd_reduction 10,

	--On hit
	health_steal = 11,
	energy_steal = 12,
	ability_steal = 13,
	ultimate_steal = 14
}

--Generated Item
local generated_item = {
	health = 1.0,
	damage = 1.0,
	speed = 1.0,

	effect_val = 1.0,
	effect_type = 0
}

--Tier parameter setup
lua_table.num_tiers = 5
local tier_parameters = {
	[1] = {
		item_value_score = 0
		item_value_cap = 0

		upgrade_type_cap = 0
		upgrade_value_cap = 0
	},

	[2] = {
		item_value_score = 0
		item_value_cap = 0

		upgrade_type_cap = 0
		upgrade_value_cap = 0
	},

	[3] = {
		item_value_score = 0
		item_value_cap = 0

		upgrade_type_cap = 0
		upgrade_value_cap = 0
	},

	[4] = {
		item_value_score = 0
		item_value_cap = 0

		upgrade_type_cap = 0
		upgrade_value_cap = 0
	},

	[5] = {
		item_value_score = 0
		item_value_cap = 0

		upgrade_type_cap = 0
		upgrade_value_cap = 0
	}
}

--Generator Parameters
local item_value_score = 0		--Equipment score
local item_value_cap = 0		--Equipment max score

local upgrade_type_cap = 0		--Upgrade type cap
local upgrade_value_cap = 0		--Upgrade size cap

--Request item tier to be selected based on a difficulty number
local function SelectTier(difficulty)	--Use a difficulty NUMBER as parameter

	local selected_tier = 0
	local rng = lua_table.Functions:RNG(1, 101)

	local drop_chance = {}
	local chance_to_tier = {}

	for i = 1, lua_table.num_tiers, 1 do
		drop_chance[i] = tier_parameters[i][difficulty]	--TODO: The system to decide the chance for each tier will change, so this is temporary
		chance_to_tier[drop_chance[i]] = i
	end

	table.sort(drop_chance)

	local tier_at_pos = {}

	for k,v in pairs(drop_chance) do
		tier_at_pos[k] = chance_to_tier[v]
	end

	local accumulation = 0
	for k,v in pairs(drop_chance) do
		drop_chance[k] = v + accumulation
		accumulation = drop_chance[k]
	end

	for k,v in pairs(drop_chance) do
		if rng <= v
		then
			selected_tier = tier_at_pos[k]
			break
		 end
	 end

	return selected_tier
end

local function SetupGenerator(tier)	--Use the tier's number as parameter
	item_value_score = tier_parameters[tier].item_value_score
	item_value_cap = tier_parameters[tier].item_value_cap

	upgrade_type_cap = tier_parameters[tier].upgrade_type_cap
	upgrade_value_cap = tier_parameters[tier].upgrade_value_cap
end

local function GenerateEquipment()
	--TODO: Rest of equipment generation
end

function RequestRandomEquipment(curr_difficulty)
	SetupGenerator(SelectTier(curr_difficulty))
	return GenerateEquipment()
end

function RequestSpecificEquipment(tier)
	SetupGenerator(tier)
	return GenerateEquipment()
end

function lua_table:Awake()
	lua_table.Functions:LOG("This Log was called from LUA testing a table on AWAKE")
end

function lua_table:Start()
    lua_table.Functions:LOG("This Log was called from LUA testing a table on START")
end

function lua_table:Update()

end

return lua_table
end

--For the curious, how SelectTier() works:
local function Explanation_SelectTier_Explanation(difficulty)	--Use a difficulty number as parameter

	--0. A random number from 1 to 100 is chosen
	local selected_tier = 0
	local rng = lua_table.Functions:RNG(1, 101)

	--1.1. The keys (1-5) represent the tiers, and the value their drop chance (% from 0 to 100)
	local drop_chance = {}
	
	--1.2. The keys are the drop chance of each tier, and the value the tier itself
	local chance_to_tier = {}

	--2. On each position of drop chance, which equivalents the tier, we assign its chance as value
	--On the chance_to_tier table, we use the chances as keys and assign each their tier as value
	for i = 1, lua_table.num_tiers, 1 do
		drop_chance[i] = tier_parameters[i].difficulty	--TODO: The system to decide the chance for each tier will change, so this is temporary
		chance_to_tier[drop_chance[i]] = i
	end

	--3. Sort chances from smaller to bigger for later use
	--(this fucks up the key-value relationship between tier and its drop chance from step 1!)
	table.sort(drop_chance)

	--4. Because of step 3 and future changes, we create a new table that saves
	--the position of each tier inside "drop_chance".
	--For example: "key 1 of drop_chance corresponds to tier 2"
	local tier_at_pos = {}

	for k,v in pairs(drop_chance) do
		tier_at_pos[k] = chance_to_tier[v]
	end

	----------------------------------------------------------------------------------------------
	--Carles' Rubber Duck or "I need to write this stuff to myself to understand wtf is going on":
	
	-- We assume that the tier 3 has a %0 drop rate for this explanation

	--We have 1 to 5 positions on drop_chance, which are now unrelated to tier because of the table.sort
	--Wherever chance 0 is, it corresponds to tier 3, we know that by the "chance_to_tier" table
	--Because of the low to high sort, in the 1st position of drop chance, we find 0
	--We must save that in drop_chance's position 1, the drop chance of a tier 3 item is saved

	--In the first iteration, we have k = 1, and v = 0
	--We can access "chance_to_tier" through 0, the chance, and we get 3, the tier
	--So we can save that in pos 1 of drop_chance, we have tier 3
	----------------------------------------------------------------------------------------------

	--5. To respect the rules of probability we now change the values of the chances
	--so that they fit all numbers between 1 and 100 by adding the accumulated numbers
	--to each new one from lowest to highest. Example of the system with 4 total chances:
	--{ 0, 15, 35, 50 } will change to { 0 + 0, 15 + 0, 35 + 15, 50 + 50 }
	local accumulation = 0
	for k,v in pairs(drop_chance) do
		drop_chance[k] = v + accumulation
		accumulation = drop_chance[k]
	end

	--6. Now, we go from the 1st to the last value of drop_chance, and look if the random
	--number is lower or equal to the chance. When we get a true, we will look at the
	--tier_at_pos table to save which tier corresponds to the position of drop_chance
	--we stopped at, and return it
	for k,v in pairs(drop_chance) do
		if rng <= v
		then
			selected_tier = tier_at_pos[k]
			break
		 end
	 end

	return selected_tier
end