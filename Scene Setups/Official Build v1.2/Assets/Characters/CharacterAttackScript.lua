function	GetTableCharacterAttackScript()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
lua_table.PhysicsFunctions = Scripting.Physics()

local layers = {
	enemy = 3,
	prop = 5
}

local attack_collider_GO_UID
local my_owner_script

function lua_table:OnTriggerEnter()
	lua_table.SystemFunctions:LOG("On Trigger Enter")
	
	local collider_GO = lua_table.PhysicsFunctions:OnTriggerEnter(attack_collider_GO_UID)
	local collider_layer = lua_table.GameObjectFunctions:GetLayerByID(collider_GO)
	if collider_layer == layers.enemy or collider_layer == layers.prop then my_owner_script:EnemyHit() end	--IF collider is tagged as an enemy
end

--Main Code
function lua_table:Awake()
	--lua_table.SystemFunctions:LOG("CharacterAttackScript AWAKE")

	attack_collider_GO_UID = lua_table.GameObjectFunctions:GetMyUID()
	local collider_parent = lua_table.GameObjectFunctions:GetGameObjectParent(attack_collider_GO_UID)

	if collider_parent ~= 0 then	--IF collider has parent, relevant data is saved on the highest parent in the hierarchy ("the manager")
		local tmp_parent = lua_table.GameObjectFunctions:GetGameObjectParent(collider_parent)

		while tmp_parent ~= 0 do	-- tmp_parent checks if <root> is the current parent of collider_parent, if it is then collider_parent is the highest parent in the hierarchy ("the manager")
			collider_parent = tmp_parent
			tmp_parent = lua_table.GameObjectFunctions:GetGameObjectParent(tmp_parent)
		end

		my_owner_script = lua_table.GameObjectFunctions:GetScript(collider_parent)
	end

end

function lua_table:Start()
	--lua_table.SystemFunctions:LOG("CharacterAttackScript START")
	
end

return lua_table
end