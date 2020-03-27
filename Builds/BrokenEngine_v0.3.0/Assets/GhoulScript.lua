function	GetTableGhoulScript()

local lua_table = {}
--lua_table.DebugFunctions = Scripting.Debug() ------------> lua_table.SystemFunctions = Scripting.System()
--lua_table.ElementFunctions = Scripting.Elements() ------------> lua_table.GameObjectFunctions = Scripting.GameObject()
--lua_table.SystemFunctions = Scripting.Systems()
--lua_table.InputFunctions = Scripting.Inputs()
lua_table.SystemFunctions = Scripting.System()
lua_table.GameObjectFunctions = Scripting.GameObject()
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

lua_table.currentTarget = 0

local GeraltPos_x = 0
local GeraltPos_y = 0
local GeraltPos_z = 0

local JaskierPos_x = 0
local JaskierPos_y = 0
local JaskierPos_z = 0

lua_table.JaskierDistance = 0
lua_table.GeraltDistance = 0

lua_table.Geralt = 0
lua_table.Jaskier = 0

-----------------------------------------------------------------------------------------
-- Enemy Variables
-----------------------------------------------------------------------------------------

--Movement
local Speed_x = 0.0
local Speed_z = 0.0
local Speed_y = 0.0 --up?

lua_table.currentState = State.IDL

---------------------------------FUNCTIONS------------------------------
------------------------------------------------------------------------

function HandleAggro()
	ret = true 

	if currentTarget == 0 and Players() --sin objetivo inicial y existen players
	then 
			if GeraltDistance < JaskierDistance
			then
				currentTarget = Geralt
			else
				currentTarget = Jaskier
			end
	elseif currentTarget ~= 0 and Players()
	then	
		currentTarget = currentTarget
	elseif not players()
	then 
		lua_table.SystemFunctions:LOG("GhoulScript: Log called from HandleAggro Function, no players found")
		ret = false
	end

	return ret
end

function patrol()
	-- body
end

local function Players() --function to know if there is a player in the area and where it is

    ret = true
	lua_table.SystemFunctions:LOG("YEAHHHH  players()")

 --   if Geralt == 1 --Geralt comprovation
 --   then 
   --     GeraltPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(Geralt)
   --     GeraltPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(Geralt)
   --     GeraltPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(Geralt)
		
 --   elseif Geralt == 0
--    then
  --      lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Geralt is not found")     
  --  end

 --   if Jaskier == 1 --Jaskier comprovation
 --   then 
  --      JaskierPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(Jaskier)
 --       JaskierPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(Jaskier)
  --      askierPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(Jaskier)        
  --  elseif Jaskier == 0 
  --  then
   --     lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Geralt is not found")
  --  end

    --calculate distances

   -- JaskierDistance =  math.sqrt(JaskierPos_x ^ 2 + JaskierPos_z ^ 2)
  --  GeraltDistance = math.sqrt(GrealtPos_x ^ 2 + GeraltPos_z ^ 2)

    --calculate if necessary to change ghoul state to idl

  --  if JaskierDistance ~= 0 and GeraltDistance ~= 0 -- HC as fuck
  --  then
  --      ret = true
--	else
	--	lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Gerardo1 or jaskier1 are not in the area or where not detected")
  --  end

    return ret
end

function HandleIdleState() --handle if necessary to change idle state to patrol.
	
    if lua_table.currentState == State.IDL
    then
		--lua_table.SystemFunctions:LOG("YEAHHHH  0")
		if lua_table.Stunned == false
		then
			lua_table.SystemFunctions:LOG("YEAHHHH  1")
			if Players() == true
			then
				lua_table.SystemFunctions:LOG("YEAHHHH  2")
				lua_table.currentState = State.PATROL --PETA ESTA LINEA
				--lua_table.SystemFunctions:LOG("GhoulScript: New State: PATROL")
			end 
		--else if lua_table.Stunned == true -- when stunned is true idle state does not change. add a script to add stunned effect in enemy head when stunned
		--then
		--	Time = 0 --TODO timer
			--timer for stunt here. dt??? when end Timer controller is false turn stunned to false
		--		if Time == StuntTime 
		--		then
			--		lua_table.Stunned = false
		--		end
			--end
		end
    end
end

function HandlePatrolState() -- THIS IS NOT A PATROL ITSELF, IS JUST A LITTLE AREA IN WICH THE GHOULS WILL WALK. (little is like 3 meters in a circle)

    if lua_table.currentState ==State.PATROL
    then
        Patrol()
    end
    
    JaskierPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(Jaskier)
    JaskierPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(Jaskier)
    JaskierPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(Jaskier)

    GeraltPos_x = lua_table.GameObjectFunctions:GetGameObjectPosX(Geralt)
    GeraltPos_y = lua_table.GameObjectFunctions:GetGameObjectPosY(Geralt)
    GeraltPos_z = lua_table.GameObjectFunctions:GetGameObjectPosZ(Geralt)

    JaskierDistance =  math.sqrt(JaskierPos_x ^ 2 + JaskierPos_z ^ 2)
    GeraltDistance = math.sqrt(GeraltPos_x ^ 2 + GeraltPos_z ^ 2)


	if JaskierDistance ~= 0 and GeraltDistance ~= 0 -- HC as fuck
    then
        if HandleAggro()
        then 
			lua_table.currentState = State.SEEK
			lua_table.SystemFunctions:LOG("GhoulScript: New State: SEEK")
        end
	else
		lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on HandleTheNearestPlayer function because Gerardo1 or jaskier1 are not in the area or where not detected")
    end

    if JaskierDistance < 7 or GeraltDistance < 7
    then 
         
    end
end

function HandleAttackState()

 --attack!
 --play 1 time the attack anim=?????

end

function HandleSeekState()



end
---------------------------------FUNCTIONS END -------------------------
------------------------------------------------------------------------


--Main Code
function lua_table:Awake()
   lua_table.SystemFunctions:LOG("This Log was called from LUA table from a GhoulScript on AWAKE")

    -------------------- GET PLAYERS id START--------------------
    Geralt = lua_table.GameObjectFunctions:FindGameObject("gerardo1")
    Jaskier = lua_table.GameObjectFunctions:FindGameObject("jaskier1") 

    if Geralt == 0 then lua_table.SystemFunctions:LOG ("A random GhoulScript: Null Geralt id, check the name of game object the script is looking for or add Geralt to the scene if not there already")
    end
    
    if Jaskier == 0 then lua_table.SystemFunctions:LOG ("A random GhoulScript: Null Jaskier id, check the name of game object the script is looking for or add Jaskier to the scene if not there already")
    end

    lua_table.currentState = State.IDL
    -------------------- GET PLAYERS id END --------------------
end

function lua_table:Start()
    lua_table.SystemFunctions:LOG("A random GhoulScript: START")  
end

function lua_table:Update()
 --lua_table.SystemFunctions:LOG("A random GhoulScript: UPDATE")  
--	dt = lua_table.Functions:dt()
--  lua_table.Functions:SetCurrentAnimationSpeed(100)
	
	if stunned == true --stunt bool change handled inn HandleIdleState() function
	then 
		lua_table.currentState = State.IDL
	end

    if lua_table.currentState == State.IDL 
    then
        HandleIdleState()
    elseif lua_table.currentState == State.PATROL
    then
        HandlePatrolState()
    elseif lua_table.currentState == State.SEEK
    then
        HandleSeekState()
    elseif lua_table.currentState == State.ATTACK
    then    
        HandleAttackState()
    end

--    HandleAnimations()
--    HandleMovement()

end

return lua_table
end
