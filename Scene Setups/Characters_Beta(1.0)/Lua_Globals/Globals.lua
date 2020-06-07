function NewVector3()
local vector = {}

vector.type = "Vec3"

vector.x = 0
vector.y = 0
vector.z = 0

geralt_score = {
	0,  --damage_dealt  --Exception, this numbers value_per_instance ratio is 1:1, since this will collect the real value already
	0,  --minion_kills
	0,  --special_kills
	0,  --incapacitations
	0,  --objects_destroyed
	0,  --potions_shared
	0   --ally_revived
}

jaskier_score = {
	0,  --damage_dealt  --Exception, this numbers value_per_instance ratio is 1:1, since this will collect the real value already
	0,  --minion_kills
	0,  --special_kills
	0,  --incapacitations
	0,  --objects_destroyed
	0,  --potions_shared
	0   --ally_revived
}

return vector
end

