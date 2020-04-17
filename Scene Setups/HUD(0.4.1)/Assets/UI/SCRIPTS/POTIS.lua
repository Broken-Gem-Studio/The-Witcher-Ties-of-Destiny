function GetTablePOTIS()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()    

    local POTID = 0--IMAGE HP
    local POTID2 = 0--IMAGE ENG
    local POTID3 = 0--IMG EMPTY HP
    local POTID4 = 0--IMG EMPTY ENG
    local POTID5 = 0--BOTH EMPTY from HP PERSPECTIVE(LEFT)
    local POTID6 = 0--BOTH EMPTY from ENG PERSPECTIVE(RIGHT)
    local POTID7 = 0--LIFE OK ENERGY EMPTY
    local POTID8 = 0--ENRGY OK LIFE EMPTY

    local HPPOTID = 0--NUMBER HP POTI
    local ENGPOTID = 0--NUMBER ENG POTI

    local hp_potis = 0
    local eng_potis = 0

    local on_hp = false
    local on_energy = false

    local p1ID = 0
    lua_table.p1 = {}


    function lua_table:Awake()

       POTID = lua_table["GameObject"]:FindGameObject("POTI1")--vida
       POTID2 = lua_table["GameObject"]:FindGameObject("POTI2")--energia
       POTID3 = lua_table["GameObject"]:FindGameObject("POTI3")--usada HP
       POTID4 = lua_table["GameObject"]:FindGameObject("POTI4")--usada ENG
       POTID5 = lua_table["GameObject"]:FindGameObject("POTI5")--usada both from hp perspective
       POTID6 = lua_table["GameObject"]:FindGameObject("POTI6")--usada both from energy perspective
       POTID7 = lua_table["GameObject"]:FindGameObject("POTI7")--hp ok energy not ok
       POTID8 = lua_table["GameObject"]:FindGameObject("POTI8")--energy ok hp not ok

       ENGPOTID = lua_table["GameObject"]:FindGameObject("ENGPOTINUMBER")
       HPPOTID = lua_table["GameObject"]:FindGameObject("HPPOTINUMBER")

       p1ID = lua_table["GameObject"]:FindGameObject("Geralt")
       --lua_table.p1 = lua_table["GameObject"]:GetScript(p1ID)

    end
    
    function lua_table:Start()

        lua_table["UI"]:MakeElementInvisible("Image", POTID2)--ESCONDEMOS LA ENERGY POTI AL PRINCIPIO
        lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID)--ESCONDEMOS NUMERO ENG POTIS
        lua_table["UI"]:MakeElementInvisible("Image", POTID3)--LO MISMO CON LAS VACIAS
        lua_table["UI"]:MakeElementInvisible("Image", POTID4)
        lua_table["UI"]:MakeElementInvisible("Image", POTID5)
        lua_table["UI"]:MakeElementInvisible("Image", POTID6)
        lua_table["UI"]:MakeElementInvisible("Image", POTID7)
        lua_table["UI"]:MakeElementInvisible("Image", POTID8)

        hp_potis = 3 --igualarlas a potis available desde codigo carles
        eng_potis = 3
        on_hp = true--PLAYER EMPIEZA CON HOP POTIS SELECIONADA

    end
    
    function lua_table:Update()

        lua_table["UI"]:SetTextNumber(hp_potis, HPPOTID)
        lua_table["UI"]:SetTextNumber(eng_potis, ENGPOTID)

        --consumo
        if lua_table["Inputs"]:KeyDown("F") and hp_potis > 0 and on_hp == true--condicion para consumir poti de hp
        then
            hp_potis = hp_potis - 1
        end

        if lua_table["Inputs"]:KeyDown("G") and eng_potis > 0 and on_energy == true--condicion para consumir poti de energy
        then
            eng_potis = eng_potis - 1
        end
        -------------------

        if eng_potis == 0 and hp_potis == 0 and on_energy == true--BOTH EMPTY WHEN WE HAVE SELECTED THE ENG POTIS
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID2)
            lua_table["UI"]:MakeElementInvisible("Image", POTID4)
            lua_table["UI"]:MakeElementInvisible("Image", POTID5)
            lua_table["UI"]:MakeElementInvisible("Image", POTID8)
            lua_table["UI"]:MakeElementVisible("Image", POTID6)
        end 

        if eng_potis == 0 and hp_potis == 0 and on_hp == true--BOTH EMPTY WHEN WE HAVE SELECTED THE HP POTIS
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID)
            lua_table["UI"]:MakeElementInvisible("Image", POTID3)
            lua_table["UI"]:MakeElementInvisible("Image", POTID6)
            lua_table["UI"]:MakeElementInvisible("Image", POTID7)
            lua_table["UI"]:MakeElementVisible("Image", POTID5)
        end 

        if eng_potis == 0 and on_hp == true and hp_potis ~= 0--SI NO HAY POTIS DE ENG pero si hay de vida desde perspectiva HP
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID)
            lua_table["UI"]:MakeElementVisible("Image", POTID7)
        end

        if hp_potis == 0 and on_energy == true and eng_potis ~= 0--SI NO HAY POTIS DE VIDA pero si hay de eng desde perspectiva ENG
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID2)
            lua_table["UI"]:MakeElementVisible("Image", POTID8)
        end

        if eng_potis == 0 and on_energy == true and hp_potis ~= 0--SI NO HAY POTIS DE ENG pero si hay de vida desde perspectiva ENG
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID2)
            lua_table["UI"]:MakeElementInvisible("Image", POTID7)
            lua_table["UI"]:MakeElementVisible("Image", POTID4)
        end

        if hp_potis == 0 and on_hp == true and eng_potis ~= 0--SI NO HAY POTIS DE VIDA pero si hay de eng desde perspectiva HP
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID)
            lua_table["UI"]:MakeElementInvisible("Image", POTID8)
            lua_table["UI"]:MakeElementVisible("Image", POTID3)
        end

        --movimiento entre potis
        if lua_table["Inputs"]:KeyDown("D") and on_energy == false--booleana desde codigo Geralt para cuando cambia a ENERGY poti
        then
            on_energy = true
            on_hp = false
            lua_table["UI"]:MakeElementInvisible("Image", POTID)
            lua_table["UI"]:MakeElementVisible("Image", POTID2)
            lua_table["UI"]:MakeElementInvisible("Image", POTID3)
            lua_table["UI"]:MakeElementInvisible("Text", HPPOTID)
            lua_table["UI"]:MakeElementVisible("Text", ENGPOTID)

        end
        if lua_table["Inputs"]:KeyDown("A") and on_hp == false--booleana desde codigo Geralt para cuando cambia a hp poti
        then
            on_hp = true
            on_energy = false
            lua_table["UI"]:MakeElementInvisible("Image", POTID2)
            lua_table["UI"]:MakeElementVisible("Image", POTID)
            lua_table["UI"]:MakeElementInvisible("Image", POTID4)
            lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID)
            lua_table["UI"]:MakeElementVisible("Text", HPPOTID)
        
        end
    
    end
    
    return lua_table
    end