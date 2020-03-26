function	GetTableGhoulScript()

local lua_table = {}
--lua_table.DebugFunctions = Scripting.Debug()
--lua_table.ElementFunctions = Scripting.Elements()
--lua_table.SystemFunctions = Scripting.Systems()
--lua_table.InputFunctions = Scripting.Inputs()
-----------------------------------------------------------------------------------------
-- Inspector Variables
-----------------------------------------------------------------------------------------

--Enemy main state
local State = {
    IDL = 1,
    PATROL = 2,
    SEEK = 3,
    ATTACK = 4
}

lua_table.Life = 80

lua_table.MaxSpeed = 150

lua_table.SwipeAttack = 10

lua_table.Stunned = false

lua_table.StuntTime = 5000 --time that the base stunt is this value should be changed by every character for every different stunt they use //milliseconds
-----------------------------------------------------------------------------------------
-- Enemy Variables
-----------------------------------------------------------------------------------------

--Movement
local Speed_x = 0.0
local Speed_z = 0.0
local Speed_y = 0.0 --up?

local currentState 


---------------------------------FUNCTIONS------------------------------
------------------------------------------------------------------------

function HandleAggro()

ret = true

-- here choose who to attack
return ret
end

function HandleTheNearestPlayer() --function to know if there is a player in the area

    ret = true

    if Geralt == 1 --Geralt comprovation
    then 
        GeraltPos_x = lua_table.ElementFunctions:GetGameObjectPosX(Geralt)
        GeraltPos_y = lua_table.ElementFunctions:GetGameObjectPosY(Geralt)
        GeraltPos_z = lua_table.ElementFunctions:GetGameObjectPosZ(Geralt)
    elseif Geralt == 0
    then
        lua_table.DebugFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Geralt is not found")     
    end

    if Jaskier == 1 --Jaskier comprovation
    then 
        JaskierPos_x = lua_table.ElementFunctions:GetGameObjectPosX(Jaskier)
        JaskierPos_y = lua_table.ElementFunctions:GetGameObjectPosY(Jaskier)
        askierPos_z = lua_table.ElementFunctions:GetGameObjectPosZ(Jaskier)        
    elseif Jaskier == 0 
    then
        lua_table.DebugFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Geralt is not found")
    end

    --calculate distances

    JaskierDistance =  math.sqrt(JaskierPos_x ^ 2 + JaskierPos_z ^ 2)
    GeraltDistance = math.sqrt(GrealtPos_x ^ 2 + GeraltPos_z ^ 2)

    --calculate if necessary to change ghoul state to idl

    if GeraltDistance < 15 or JaskierDistance < 15 -- HC as fuck
    then
        ret = true
    end

    return ret
end



function HandleIdleState() --handle if necessary to change idle state to patrol.

	

    if currentState == State.IDL
    then
		if Stunned == false
		then
			if HandleTheNearestPlayer() == true
			then 
				currentState = State.PATROL
			end 
		else if Stunned == true -- when stunned is true idle state does not change. add a script to add stunned effect in enemy head when stunned
		then
			Time
			--timer for stunt here. dt??? when end Timer controller is false turn stunned to false
				if Time == StuntTime 
				then
					Stunned = false
				end
			end
		end
    end

end
function HandlePatrolState() -- THIS IS NOT A PATROL ITSELF, IS JUST A LITTLE AREA IN WICH THE GHOULS WILL WALK. (little is like 3 meters in a circle)

    if currentState ==State.PATROL
    then
        Patrol()
    end
    

    JaskierPos_x = lua_table.ElementFunctions:GetGameObjectPosX(Jaskier)
    JaskierPos_y = lua_table.ElementFunctions:GetGameObjectPosY(Jaskier)
    JaskierPos_z = lua_table.ElementFunctions:GetGameObjectPosZ(Jaskier)

    GeraltPos_x = lua_table.ElementFunctions:GetGameObjectPosX(Geralt)
    GeraltPos_y = lua_table.ElementFunctions:GetGameObjectPosY(Geralt)
    GeraltPos_z = lua_table.ElementFunctions:GetGameObjectPosZ(Geralt)

    JaskierDistance =  math.sqrt(JaskierPos_x ^ 2 + JaskierPos_z ^ 2)
    GeraltDistance = math.sqrt(GrealtPos_x ^ 2 + GeraltPos_z ^ 2)

    if JaskierDistance < 7 or GeraltDistance < 7
    then 
         if HandleAggro()
         then 
            currentState = State.ATTACK
         end
    end
end

function HandleAttackState()

-- attack!
-- play 1 time the attack anim=?????

end

---------------------------------FUNCTIONS END -------------------------
------------------------------------------------------------------------


--Main Code
function lua_table:Awake()

 --   lua_table.DebugFunctions:LOG("This Log was called from LUA table from a GhoulScript on AWAKE")


    -------------------- GET PLAYERS id START--------------------
    Geralt = lua_table.ElementFunctions:FindGameObject("gerardo1")
    Jaskier = lua_table.ElementFunctions:FindGameObject("jaskier1") 

    if Geralt == 0 then lua_table.DebugFunctions:LOG ("A random GhoulScript: Null Geralt id, check the name of game object the script is looking for or add Geralt to the scene if not there already")
    end
    
    if Jaskier == 0 then lua_table.DebugFunctions:LOG ("A random GhoulScript: Null Jaskier id, check the name of game object the script is looking for or add Jaskier to the scene if not there already")
    end

    currentState = State.IDL
    -------------------- GET PLAYERS id END --------------------
end

function lua_table:Start()
    lua_table.DebugFunctions:LOG("A random GhoulScript: START")  
end

function lua_table:Update()

	dt = lua_table.Functions:dt()
    lua_table.Functions:SetCurrentAnimationSpeed(100)
	
	if stunned == true --stunt bool change handled inn HandleIdleState() function
	then 
		currentState = State.IDL
	end

    if currentState == State.IDL 
    then
        HandleIdleState()
    elseif currentState == State.PATROL
    then
        HandlePatrolState()
    elseif currentState == State.SEEK
    then
        HandleSeekState()
    elseif currentState == State.ATTACK
    then    
        HandleAttackState()
    end

    HandleAnimations()
    HandleMovement()
end

return lua_table
end
