function GetTablePivotKikimoraScript_v1 ()
local lua_table = {}
lua_table.SystemFunctions = Scripting.System ()
lua_table.GameObjectFunctions = Scripting.GameObject ()

lua_table.my_UID = 0
lua_table.kikimora_id = 0
lua_table.kikimora_GO = "Kikimora"
lua_table.kikimora_script = {}

local dmg = 0
local eff = 0
lua_table.collider_damage = 0
lua_table.collider_effect = 0

-- Main Code
function lua_table:Awake ()
    lua_table.SystemFunctions:LOG ("This Log was called from Pivot Script on AWAKE")
    
    lua_table.my_UID = lua_table.GameObjectFunctions:GetMyUID()
	
    lua_table.kikimora_id = lua_table.GameObjectFunctions:GetGameObjectParent(lua_table.my_UID)

    lua_table.kikimora_script = lua_table.GameObjectFunctions:GetScript(lua_table.kikimora_id)
end

function lua_table:Start ()
	lua_table.SystemFunctions:LOG ("Pivot Script START")

end

function lua_table:Update ()
    dt = lua_table.SystemFunctions:DT ()

    dmg = lua_table.kikimora_script.collider_damage
    eff = lua_table.kikimora_script.collider_effect

    lua_table.collider_damage = dmg
    lua_table.collider_effect = eff

    lua_table.SystemFunctions:LOG ("Pivot Damage: " .. dmg)
    lua_table.SystemFunctions:LOG ("Pivot Effect: " .. eff)
    
end
	return lua_table
end

