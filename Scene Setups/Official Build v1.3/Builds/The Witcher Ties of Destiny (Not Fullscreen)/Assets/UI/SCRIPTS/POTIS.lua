function GetTablePOTIS()
    local lua_table = {}
    lua_table["GameObject"] = Scripting.GameObject()
    lua_table["Inputs"] = Scripting.Inputs()
    lua_table["System"] = Scripting.System()
    lua_table["UI"] = Scripting.Interface()
    lua_table["Transform"] = Scripting.Transform()  
    lua_table["Audio"] = Scripting.Audio()  

    --GERALT
    local POTID = 0--IMAGE ON HP ALL FULL
    local POTID2 = 0--IMAGE ON ENG ALL FULL
    local POTID3 = 0--IMG EMPTY HP ON HP REST FULL
    local POTID4 = 0--IMG EMPTY ENG ON ENG REST FULL
    local POTID5 = 0--ALL EMPTY ON HP
    local POTID6 = 0--ALL EMPTY ON ENG
    local POTID7 = 0--LIFE FULL ON LIFE REST EMPTY
    local POTID8 = 0--ENG FULL ON ENG REST EMPTY
    --
    local POTID9 = 0--ALL EMPTY ON DMG
    local POTID10 = 0--ALL FULL ON DMG
    local POTID11 = 0--NO DMG ALL FULL ON DMG
    local POTID12 = 0--NO DMG ALL FULL ON ENG
    local POTID13 = 0--NO DMG ALL FULL ON HP
    local POTID14 = 0--NO DMG NO HP ON DMG
    local POTID15 = 0--NO DMG NO HP ON HP
    local POTID16 = 0-- NO ENG ALL FULL ON DMG
    local POTID17 = 0--NO ENG ALL FULL ON HP
    local POTID18 = 0--NO ENG NO DMG ON DMG
    local POTID19 = 0--NO ENG NO DMG ON ENG
    local POTID20 = 0--NO HP ALL FULL ON DMG
    local POTID21 = 0--NO HP ALL FULL ON ENG
    local POTID22 = 0--NO HP NO ENG ON DMG
    local POTID23 = 0--NO HP NO ENG ON ENG
    local POTID24 = 0--NO HP NO ENG ON HP

    local HPPOTID = 0--NUMBER HP POTI
    local ENGPOTID = 0--NUMBER ENG POTI
    local DMGPOTID = 0--NUMBER DMG POTI

    local hp_potis = 0
    local eng_potis = 0
    local dmg_potis = 0

    local on_hp = false
    local on_energy = false
    local on_dmg = false

    local p1ID = 0
    lua_table.p1 = {}

    --JASKIER
    local POTID_J = 0--IMAGE HP
    local POTID2_J = 0--IMAGE ENG
    local POTID3_J = 0--IMG EMPTY HP
    local POTID4_J = 0--IMG EMPTY ENG
    local POTID5_J = 0--BOTH EMPTY from HP PERSPECTIVE(LEFT)
    local POTID6_J = 0--BOTH EMPTY from ENG PERSPECTIVE(RIGHT)
    local POTID7_J = 0--LIFE OK ENERGY EMPTY
    local POTID8_J = 0--ENRGY OK LIFE EMPTY
    --
    local POTID9_J = 0--ALL EMPTY ON DMG
    local POTID10_J = 0--ALL FULL ON DMG
    local POTID11_J = 0--NO DMG ALL FULL ON DMG
    local POTID12_J = 0--NO DMG ALL FULL ON ENG
    local POTID13_J = 0--NO DMG ALL FULL ON HP
    local POTID14_J = 0--NO DMG NO HP ON DMG
    local POTID15_J = 0--NO DMG NO HP ON HP
    local POTID16_J = 0-- NO ENG ALL FULL ON DMG
    local POTID17_J = 0--NO ENG ALL FULL ON HP
    local POTID18_J = 0--NO ENG NO DMG ON DMG
    local POTID19_J = 0--NO ENG NO DMG ON ENG
    local POTID20_J = 0--NO HP ALL FULL ON DMG
    local POTID21_J = 0--NO HP ALL FULL ON ENG
    local POTID22_J = 0--NO HP NO ENG ON DMG
    local POTID23_J = 0--NO HP NO ENG ON ENG
    local POTID24_J = 0--NO HP NO ENG ON HP

    local HPPOTID_J = 0--NUMBER HP POTI
    local ENGPOTID_J = 0--NUMBER ENG POTI
    local DMGPOTID_J = 0--NUMBER DMG POTI

    local hp_potis2 = 0
    local eng_potis2 = 0
    local dmg_potis2 = 0

    local on_hp2 = false
    local on_energy2 = false
    local on_dmg2 = false

    local p2ID = 0
    lua_table.p2 = {}

    --prefab pause 
    local pause_prefab = 0
    lua_table.pause = {}

    local function HidePotis(player)

        if player == 1
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID)
            lua_table["UI"]:MakeElementInvisible("Image", POTID2)
            lua_table["UI"]:MakeElementInvisible("Image", POTID3)
            lua_table["UI"]:MakeElementInvisible("Image", POTID4)
            lua_table["UI"]:MakeElementInvisible("Image", POTID5)
            lua_table["UI"]:MakeElementInvisible("Image", POTID6)
            lua_table["UI"]:MakeElementInvisible("Image", POTID7)
            lua_table["UI"]:MakeElementInvisible("Image", POTID8)
            lua_table["UI"]:MakeElementInvisible("Image", POTID9)
            lua_table["UI"]:MakeElementInvisible("Image", POTID10)
            lua_table["UI"]:MakeElementInvisible("Image", POTID11)
            lua_table["UI"]:MakeElementInvisible("Image", POTID12)
            lua_table["UI"]:MakeElementInvisible("Image", POTID13)
            lua_table["UI"]:MakeElementInvisible("Image", POTID14)
            lua_table["UI"]:MakeElementInvisible("Image", POTID15)
            lua_table["UI"]:MakeElementInvisible("Image", POTID16)
            lua_table["UI"]:MakeElementInvisible("Image", POTID17)
            lua_table["UI"]:MakeElementInvisible("Image", POTID18)
            lua_table["UI"]:MakeElementInvisible("Image", POTID19)
            lua_table["UI"]:MakeElementInvisible("Image", POTID20)
            lua_table["UI"]:MakeElementInvisible("Image", POTID21)
            lua_table["UI"]:MakeElementInvisible("Image", POTID22)
            lua_table["UI"]:MakeElementInvisible("Image", POTID23)
            lua_table["UI"]:MakeElementInvisible("Image", POTID24)
        end

        if player == 2
        then
            lua_table["UI"]:MakeElementInvisible("Image", POTID_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID2_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID3_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID4_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID5_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID6_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID7_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID8_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID9_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID10_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID11_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID12_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID13_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID14_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID15_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID16_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID17_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID18_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID19_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID20_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID21_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID22_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID23_J)
            lua_table["UI"]:MakeElementInvisible("Image", POTID24_J)
        end
        
    
    end

    function lua_table:Awake()

       POTID = lua_table["GameObject"]:FindGameObject("POTI1")--vida
       POTID2 = lua_table["GameObject"]:FindGameObject("POTI2")--energia
       POTID3 = lua_table["GameObject"]:FindGameObject("POTI3")--usada HP
       POTID4 = lua_table["GameObject"]:FindGameObject("POTI4")--usada ENG
       POTID5 = lua_table["GameObject"]:FindGameObject("POTI5")--usada both from hp perspective
       POTID6 = lua_table["GameObject"]:FindGameObject("POTI6")--usada both from energy perspective
       POTID7 = lua_table["GameObject"]:FindGameObject("POTI7")--hp ok energy not ok
       POTID8 = lua_table["GameObject"]:FindGameObject("POTI8")--energy ok hp not ok
       --
       POTID9 = lua_table["GameObject"]:FindGameObject("POTI9")--vida
       POTID10 = lua_table["GameObject"]:FindGameObject("POTI10")--energia
       POTID11 = lua_table["GameObject"]:FindGameObject("POTI11")--usada HP
       POTID12 = lua_table["GameObject"]:FindGameObject("POTI12")--usada ENG
       POTID13 = lua_table["GameObject"]:FindGameObject("POTI13")--usada both from hp perspective
       POTID14 = lua_table["GameObject"]:FindGameObject("POTI14")--usada both from energy perspective
       POTID15 = lua_table["GameObject"]:FindGameObject("POTI15")--hp ok energy not ok
       POTID16 = lua_table["GameObject"]:FindGameObject("POTI16")--energy ok hp not ok
       POTID17 = lua_table["GameObject"]:FindGameObject("POTI17")--vida
       POTID18 = lua_table["GameObject"]:FindGameObject("POTI18")--energia
       POTID19 = lua_table["GameObject"]:FindGameObject("POTI19")--usada HP
       POTID20 = lua_table["GameObject"]:FindGameObject("POTI20")--usada ENG
       POTID21 = lua_table["GameObject"]:FindGameObject("POTI21")--usada both from hp perspective
       POTID22 = lua_table["GameObject"]:FindGameObject("POTI22")--usada both from energy perspective
       POTID23 = lua_table["GameObject"]:FindGameObject("POTI23")--hp ok energy not ok
       POTID24 = lua_table["GameObject"]:FindGameObject("POTI24")--energy ok hp not ok

       ENGPOTID = lua_table["GameObject"]:FindGameObject("ENGPOTINUMBER")
       HPPOTID = lua_table["GameObject"]:FindGameObject("HPPOTINUMBER")
       DMGPOTID = lua_table["GameObject"]:FindGameObject("DMGPOTINUMBER")

       p1ID = lua_table["GameObject"]:FindGameObject("Geralt")
       lua_table.p1 = lua_table["GameObject"]:GetScript(p1ID)

       POTID_J = lua_table["GameObject"]:FindGameObject("POTIJ")--vida
       POTID2_J = lua_table["GameObject"]:FindGameObject("POTI2J")--energia
       POTID3_J = lua_table["GameObject"]:FindGameObject("POTI3J")--usada HP
       POTID4_J = lua_table["GameObject"]:FindGameObject("POTI4J")--usada ENG
       POTID5_J = lua_table["GameObject"]:FindGameObject("POTI5J")--usada both from hp perspective
       POTID6_J = lua_table["GameObject"]:FindGameObject("POTI6J")--usada both from energy perspective
       POTID7_J = lua_table["GameObject"]:FindGameObject("POTI7J")--hp ok energy not ok
       POTID8_J = lua_table["GameObject"]:FindGameObject("POTI8J")--energy ok hp not ok
       --
       POTID9_J = lua_table["GameObject"]:FindGameObject("POTI9J")--vida
       POTID10_J = lua_table["GameObject"]:FindGameObject("POTI10J")--energia
       POTID11_J = lua_table["GameObject"]:FindGameObject("POTI11J")--usada HP
       POTID12_J = lua_table["GameObject"]:FindGameObject("POTI12J")--usada ENG
       POTID13_J = lua_table["GameObject"]:FindGameObject("POTI13J")--usada both from hp perspective
       POTID14_J = lua_table["GameObject"]:FindGameObject("POTI14J")--usada both from energy perspective
       POTID15_J = lua_table["GameObject"]:FindGameObject("POTI15J")--hp ok energy not ok
       POTID16_J = lua_table["GameObject"]:FindGameObject("POTI16J")--energy ok hp not ok
       POTID17_J = lua_table["GameObject"]:FindGameObject("POTI17J")--vida
       POTID18_J = lua_table["GameObject"]:FindGameObject("POTI18J")--energia
       POTID19_J = lua_table["GameObject"]:FindGameObject("POTI19J")--usada HP
       POTID20_J = lua_table["GameObject"]:FindGameObject("POTI20J")--usada ENG
       POTID21_J = lua_table["GameObject"]:FindGameObject("POTI21J")--usada both from hp perspective
       POTID22_J = lua_table["GameObject"]:FindGameObject("POTI22J")--usada both from energy perspective
       POTID23_J = lua_table["GameObject"]:FindGameObject("POTI23J")--hp ok energy not ok
       POTID24_J = lua_table["GameObject"]:FindGameObject("POTI24J")--energy ok hp not ok


       ENGPOTID_J = lua_table["GameObject"]:FindGameObject("ENGPOTINUMBER2")
       HPPOTID_J = lua_table["GameObject"]:FindGameObject("HPPOTINUMBER2")
       DMGPOTID_J = lua_table["GameObject"]:FindGameObject("DMGPOTINUMBER2")

       p2ID = lua_table["GameObject"]:FindGameObject("Jaskier")
       lua_table.p2 = lua_table["GameObject"]:GetScript(p2ID)

       --pause prefab
       pause_prefab = lua_table["GameObject"]:FindGameObject("ButtonManager")
       lua_table.pause = lua_table["GameObject"]:GetScript(pause_prefab)

    end
    
    function lua_table:Start()

        lua_table["UI"]:MakeElementInvisible("Image", POTID2)--ESCONDEMOS LA ENERGY POTI AL PRINCIPIO
        lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID)--ESCONDEMOS NUMERO ENG POTIS
        lua_table["UI"]:MakeElementInvisible("Text", DMGPOTID)
        lua_table["UI"]:MakeElementInvisible("Image", POTID3)--LO MISMO CON LAS VACIAS
        lua_table["UI"]:MakeElementInvisible("Image", POTID4)
        lua_table["UI"]:MakeElementInvisible("Image", POTID5)
        lua_table["UI"]:MakeElementInvisible("Image", POTID6)
        lua_table["UI"]:MakeElementInvisible("Image", POTID7)
        lua_table["UI"]:MakeElementInvisible("Image", POTID8)
        lua_table["UI"]:MakeElementInvisible("Image", POTID9)
        lua_table["UI"]:MakeElementInvisible("Image", POTID10)
        lua_table["UI"]:MakeElementInvisible("Image", POTID11)
        lua_table["UI"]:MakeElementInvisible("Image", POTID12)
        lua_table["UI"]:MakeElementInvisible("Image", POTID13)
        lua_table["UI"]:MakeElementInvisible("Image", POTID14)
        lua_table["UI"]:MakeElementInvisible("Image", POTID15)
        lua_table["UI"]:MakeElementInvisible("Image", POTID16)
        lua_table["UI"]:MakeElementInvisible("Image", POTID17)
        lua_table["UI"]:MakeElementInvisible("Image", POTID18)
        lua_table["UI"]:MakeElementInvisible("Image", POTID19)
        lua_table["UI"]:MakeElementInvisible("Image", POTID20)
        lua_table["UI"]:MakeElementInvisible("Image", POTID21)
        lua_table["UI"]:MakeElementInvisible("Image", POTID22)
        lua_table["UI"]:MakeElementInvisible("Image", POTID23)
        lua_table["UI"]:MakeElementInvisible("Image", POTID24)


        hp_potis = lua_table.p1.inventory[1] 
        eng_potis = lua_table.p1.inventory[2]
        dmg_potis = lua_table.p1.inventory[3]
        if lua_table.p1.item_selected == lua_table.p1.item_library.health_potion
        then
            on_hp = true--PLAYER EMPIEZA CON HOP POTIS SELECIONADA
            on_energy = false
            on_dmg = false
        end

        lua_table["UI"]:MakeElementInvisible("Image", POTID2_J)--ESCONDEMOS LA ENERGY POTI AL PRINCIPIO
        lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID_J)--ESCONDEMOS NUMERO ENG POTIS
        lua_table["UI"]:MakeElementInvisible("Text", DMGPOTID_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID3_J)--LO MISMO CON LAS VACIAS
        lua_table["UI"]:MakeElementInvisible("Image", POTID4_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID5_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID6_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID7_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID8_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID9_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID10_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID11_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID12_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID13_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID14_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID15_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID16_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID17_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID18_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID19_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID20_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID21_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID22_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID23_J)
        lua_table["UI"]:MakeElementInvisible("Image", POTID24_J)

        hp_potis2 = lua_table.p2.inventory[1] 
        eng_potis2 = lua_table.p2.inventory[2]
        dmg_potis2 = lua_table.p2.inventory[3]
        if lua_table.p2.item_selected == lua_table.p2.item_library.health_potion
        then
            on_hp2 = true--PLAYER EMPIEZA CON HOP POTIS SELECIONADA
            on_energy2 = false
            on_dmg2 = false
        end
        

    end
    
    function lua_table:Update()

        hp_potis = lua_table.p1.inventory[1] 
        eng_potis = lua_table.p1.inventory[2]
        dmg_potis = lua_table.p1.inventory[3]
        --lua_table["System"]:LOG("HP POTIS: " .. hp_potis)
        --lua_table["System"]:LOG("ENG POTIS: " .. eng_potis)
        --lua_table["System"]:LOG("DMG POTIS: " .. dmg_potis)
        --lua_table["System"]:LOG("SELECTED: " .. lua_table.p1.item_selected)
        hp_potis2 = lua_table.p2.inventory[1] 
        eng_potis2 = lua_table.p2.inventory[2]
        dmg_potis2 = lua_table.p2.inventory[3]
        --lua_table["System"]:LOG("HP2 POTIS: " .. hp_potis2)
        --lua_table["System"]:LOG("ENG2 POTIS: " .. eng_potis2)
        --lua_table["System"]:LOG("DMG2 POTIS: " .. dmg_potis2)
        --lua_table["System"]:LOG("SELECTED2: " .. lua_table.p2.item_selected)

        lua_table["UI"]:SetTextNumber(hp_potis, HPPOTID)
        lua_table["UI"]:SetTextNumber(eng_potis, ENGPOTID)
        lua_table["UI"]:SetTextNumber(dmg_potis, DMGPOTID)
        lua_table["UI"]:SetTextNumber(hp_potis2, HPPOTID_J)
        lua_table["UI"]:SetTextNumber(eng_potis2, ENGPOTID_J)
        lua_table["UI"]:SetTextNumber(dmg_potis2, DMGPOTID_J)


        if lua_table.p1.item_selected == lua_table.p1.item_library.health_potion
        then
           
            on_hp = true
            on_energy = false
            on_dmg = false
            lua_table["UI"]:MakeElementVisible("Text", HPPOTID)
            lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID)
            lua_table["UI"]:MakeElementInvisible("Text", DMGPOTID)

            
        end

        if lua_table.p1.item_selected == lua_table.p1.item_library.stamina_potion 
        then
            
            on_energy = true
            on_hp = false
            on_dmg = false
            lua_table["UI"]:MakeElementVisible("Text", ENGPOTID)
            lua_table["UI"]:MakeElementInvisible("Text", HPPOTID)
            lua_table["UI"]:MakeElementInvisible("Text", DMGPOTID)
            
        end

        if lua_table.p1.item_selected == lua_table.p1.item_library.power_potion 
        then
           
            on_dmg = true
            on_hp = false
            on_energy = false
            lua_table["UI"]:MakeElementVisible("Text", DMGPOTID)
            lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID)
            lua_table["UI"]:MakeElementInvisible("Text", HPPOTID)
            
        end

        -------------------------JASKIER 

        if lua_table.p2.item_selected == lua_table.p2.item_library.health_potion
        then
           
            on_hp2 = true
            on_energy2 = false
            on_dmg2 = false
            lua_table["UI"]:MakeElementVisible("Text", HPPOTID_J)
            lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID_J)
            lua_table["UI"]:MakeElementInvisible("Text", DMGPOTID_J)

            
        end

        if lua_table.p2.item_selected == lua_table.p2.item_library.stamina_potion 
        then
            
            on_energy2 = true
            on_hp2 = false
            on_dmg2 = false
            lua_table["UI"]:MakeElementVisible("Text", ENGPOTID_J)
            lua_table["UI"]:MakeElementInvisible("Text", HPPOTID_J)
            lua_table["UI"]:MakeElementInvisible("Text", DMGPOTID_J)
            
        end

        if lua_table.p2.item_selected == lua_table.p2.item_library.power_potion 
        then
           
            on_dmg2 = true
            on_hp2 = false
            on_energy2 = false
            lua_table["UI"]:MakeElementVisible("Text", DMGPOTID_J)
            lua_table["UI"]:MakeElementInvisible("Text", ENGPOTID_J)
            lua_table["UI"]:MakeElementInvisible("Text", HPPOTID_J)
            
        end
        

        -------------------
        --GERALT
        ------------------
    -----------HP

        if eng_potis ~= 0 and hp_potis ~= 0 and dmg_potis ~= 0 and on_hp == true--ALL full WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end

        if eng_potis == 0 and hp_potis == 0 and dmg_potis == 0 and on_hp == true--ALL EMPTY WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID5)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end 

        if eng_potis == 0 and on_hp == true and hp_potis ~= 0 and dmg_potis ~= 0--SI NO HAY POTIS DE ENG pero si hay de demas desde perspectiva HP
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID17)
        end   

        if hp_potis == 0 and on_hp == true and eng_potis ~= 0 and dmg_potis ~= 0--SI NO HAY POTIS DE VIDA pero si hay de demas desde perspectiva HP
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID3)
            
        end

        if dmg_potis == 0 and on_hp == true and eng_potis ~= 0 and hp_potis ~= 0--SI NO HAY POTIS DE daño pero si hay de demas desde perspectiva HP
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID13)
            
        end

        if dmg_potis == 0 and eng_potis == 0 and on_hp == true and hp_potis ~= 0--SI NO HAY POTIS DE daño NI ENG  PERO SI DE HP Desde perspectiva HP
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID7)
            
        end

        if dmg_potis == 0 and hp_potis == 0 and on_hp == true and eng_potis ~= 0--si nop hay ni hp ni dmg potis Desde perspectiva HP
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID15)
            
        end

        if hp_potis == 0 and eng_potis == 0 and on_hp == true and dmg_potis ~= 0--si nop hay ni hp ni eng potis Desde perspectiva HP
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID24)
            
        end
---------------ENERGY

        if eng_potis ~= 0 and hp_potis ~= 0 and dmg_potis ~= 0 and on_energy == true--ALL full WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID2)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end

        if eng_potis == 0 and hp_potis == 0 and dmg_potis == 0 and on_energy == true--ALL EMPTY WHEN WE HAVE SELECTED THE ENG POTIS
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID6)
            
            --lua_table["System"]:LOG("ON ENG EMPTY")
        end 

        if eng_potis == 0 and on_energy == true and hp_potis ~= 0 and dmg_potis ~= 0--SI NO HAY POTIS DE ENG pero si hay de demas desde perspectiva eng
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID4)
        end   

        if hp_potis == 0 and on_energy == true and eng_potis ~= 0 and dmg_potis ~= 0--SI NO HAY POTIS DE VIDA pero si hay de demas desde perspectiva eng
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID21)
            
        end

        if dmg_potis == 0 and on_energy == true and eng_potis ~= 0 and hp_potis ~= 0--SI NO HAY POTIS DE daño pero si hay de demas desde perspectiva eng
        then
            
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID12)
            
        end

        if dmg_potis == 0 and eng_potis == 0 and on_energy == true and hp_potis ~= 0--SI NO HAY POTIS DE daño NI ENG  PERO SI DE HP Desde perspectiva eng
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID19)
            
        end

        if dmg_potis == 0 and hp_potis == 0 and on_energy == true and eng_potis ~= 0--si nop hay ni hp ni dmg potis Desde perspectiva eng
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID8)
            
        end

        if hp_potis == 0 and eng_potis == 0 and on_energy == true and dmg_potis ~= 0--si nop hay ni hp ni eng potis Desde perspectiva eng
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID23)
            
        end

-------------DAMAGE

        if eng_potis ~= 0 and hp_potis ~= 0 and dmg_potis ~= 0 and on_dmg == true--ALL full WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID10)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end

        if eng_potis == 0 and hp_potis == 0 and dmg_potis == 0 and on_dmg == true--ALL EMPTY WHEN WE HAVE SELECTED THE DMG POTIS
        then

            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID9)

            --lua_table["System"]:LOG("ON HP EMPTY")
        end 

        if eng_potis == 0 and on_dmg == true and hp_potis ~= 0 and dmg_potis ~= 0--SI NO HAY POTIS DE ENG pero si hay de demas desde perspectiva dmg
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID16)
        end   

        if hp_potis == 0 and on_dmg == true and eng_potis ~= 0 and dmg_potis ~= 0--SI NO HAY POTIS DE VIDA pero si hay de demas desde perspectiva dmg
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID20)
            
        end

        if dmg_potis == 0 and on_dmg == true and eng_potis ~= 0 and hp_potis ~= 0--SI NO HAY POTIS DE daño pero si hay de demas desde perspectiva dmg
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID11)
            
        end

        if dmg_potis == 0 and eng_potis == 0 and on_dmg == true and hp_potis ~= 0--SI NO HAY POTIS DE daño NI ENG  PERO SI DE HP Desde perspectiva dmg
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID18)
            
        end

        if dmg_potis == 0 and hp_potis == 0 and on_dmg == true and eng_potis ~= 0--si nop hay ni hp ni dmg potis Desde perspectiva dmg
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID14)
            
        end

        if hp_potis == 0 and eng_potis == 0 and on_dmg == true and dmg_potis ~= 0--si nop hay ni hp ni eng potis Desde perspectiva dmg
        then
            HidePotis(1)
            lua_table["UI"]:MakeElementVisible("Image", POTID22)
            
        end

        ------------
        --JASKIER
        ------------

        if eng_potis2 ~= 0 and hp_potis2 ~= 0 and dmg_potis2 ~= 0 and on_hp2 == true--ALL full WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID_J)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end

        if eng_potis2 == 0 and hp_potis2 == 0 and dmg_potis2 == 0 and on_hp2 == true--ALL EMPTY WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID5_J)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end 

        if eng_potis2 == 0 and on_hp2 == true and hp_potis2 ~= 0 and dmg_potis2 ~= 0--SI NO HAY POTIS DE ENG pero si hay de demas desde perspectiva HP
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID17_J)
        end   

        if hp_potis2 == 0 and on_hp2 == true and eng_potis2 ~= 0 and dmg_potis2 ~= 0--SI NO HAY POTIS DE VIDA pero si hay de demas desde perspectiva HP
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID3_J)
            
        end

        if dmg_potis2 == 0 and on_hp2 == true and eng_potis2 ~= 0 and hp_potis2 ~= 0--SI NO HAY POTIS DE daño pero si hay de demas desde perspectiva HP
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID13_J)
            
        end

        if dmg_potis2 == 0 and eng_potis2 == 0 and on_hp2 == true and hp_potis2 ~= 0--SI NO HAY POTIS DE daño NI ENG  PERO SI DE HP Desde perspectiva HP
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID7_J)
            
        end

        if dmg_potis2 == 0 and hp_potis2 == 0 and on_hp2 == true and eng_potis2 ~= 0--si nop hay ni hp ni dmg potis Desde perspectiva HP
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID15_J)
            
        end

        if hp_potis2 == 0 and eng_potis2 == 0 and on_hp2 == true and dmg_potis2 ~= 0--si nop hay ni hp ni eng potis Desde perspectiva HP
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID24_J)
            
        end
---------------ENERGY

        if eng_potis2 ~= 0 and hp_potis2 ~= 0 and dmg_potis2 ~= 0 and on_energy2 == true--ALL full WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID2_J)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end

        if eng_potis2 == 0 and hp_potis2 == 0 and dmg_potis2 == 0 and on_energy2 == true--ALL EMPTY WHEN WE HAVE SELECTED THE ENG POTIS
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID6_J)
            
            --lua_table["System"]:LOG("ON ENG EMPTY")
        end 

        if eng_potis2 == 0 and on_energy2 == true and hp_potis2 ~= 0 and dmg_potis2 ~= 0--SI NO HAY POTIS DE ENG pero si hay de demas desde perspectiva eng
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID4_J)
        end   

        if hp_potis2 == 0 and on_energy2 == true and eng_potis2 ~= 0 and dmg_potis2 ~= 0--SI NO HAY POTIS DE VIDA pero si hay de demas desde perspectiva eng
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID21_J)
            
        end

        if dmg_potis2 == 0 and on_energy2 == true and eng_potis2 ~= 0 and hp_potis2 ~= 0--SI NO HAY POTIS DE daño pero si hay de demas desde perspectiva eng
        then
            
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID12_J)
            
        end

        if dmg_potis2 == 0 and eng_potis2 == 0 and on_energy2 == true and hp_potis2 ~= 0--SI NO HAY POTIS DE daño NI ENG  PERO SI DE HP Desde perspectiva eng
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID19_J)
            
        end

        if dmg_potis2 == 0 and hp_potis2 == 0 and on_energy2 == true and eng_potis2 ~= 0--si nop hay ni hp ni dmg potis Desde perspectiva eng
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID8_J)
            
        end

        if hp_potis2 == 0 and eng_potis2 == 0 and on_energy2 == true and dmg_potis2 ~= 0--si nop hay ni hp ni eng potis Desde perspectiva eng
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID23_J)
            
        end

-------------DAMAGE

        if eng_potis2 ~= 0 and hp_potis2 ~= 0 and dmg_potis2 ~= 0 and on_dmg2 == true--ALL full WHEN WE HAVE SELECTED THE HP POTIS
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID10_J)
            
            --lua_table["System"]:LOG("ON HP EMPTY")
        end

        if eng_potis2 == 0 and hp_potis2 == 0 and dmg_potis2 == 0 and on_dmg2 == true--ALL EMPTY WHEN WE HAVE SELECTED THE DMG POTIS
        then

            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID9_J)

            --lua_table["System"]:LOG("ON HP EMPTY")
        end 

        if eng_potis2 == 0 and on_dmg2 == true and hp_potis2 ~= 0 and dmg_potis2 ~= 0--SI NO HAY POTIS DE ENG pero si hay de demas desde perspectiva dmg
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID16_J)
        end   

        if hp_potis2 == 0 and on_dmg2 == true and eng_potis2 ~= 0 and dmg_potis2 ~= 0--SI NO HAY POTIS DE VIDA pero si hay de demas desde perspectiva dmg
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID20_J)
            
        end

        if dmg_potis2 == 0 and on_dmg2 == true and eng_potis2 ~= 0 and hp_potis2 ~= 0--SI NO HAY POTIS DE daño pero si hay de demas desde perspectiva dmg
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID11_J)
            
        end

        if dmg_potis2 == 0 and eng_potis2 == 0 and on_dmg2 == true and hp_potis2 ~= 0--SI NO HAY POTIS DE daño NI ENG  PERO SI DE HP Desde perspectiva dmg
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID18_J)
            
        end

        if dmg_potis2 == 0 and hp_potis2 == 0 and on_dmg2 == true and eng_potis2 ~= 0--si nop hay ni hp ni dmg potis Desde perspectiva dmg
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID14_J)
            
        end

        if hp_potis2 == 0 and eng_potis2 == 0 and on_dmg2 == true and dmg_potis2 ~= 0--si nop hay ni hp ni eng potis Desde perspectiva dmg
        then
            HidePotis(2)
            lua_table["UI"]:MakeElementVisible("Image", POTID22_J)
            
        end

        
    

        --SOUND FX
        if (lua_table["Inputs"]:IsGamepadButton(1,"BUTTON_DPAD_LEFT","DOWN") or lua_table["Inputs"]:IsGamepadButton(1,"BUTTON_DPAD_RIGHT","DOWN"))
        and lua_table.pause.gamePaused == false
        then
            lua_table["Audio"]:PlayAudioEventGO("Play_HUD_Switch_Potion", POTID)
        end

        if (lua_table["Inputs"]:IsGamepadButton(2,"BUTTON_DPAD_LEFT","DOWN") or lua_table["Inputs"]:IsGamepadButton(2,"BUTTON_DPAD_RIGHT","DOWN"))
        and lua_table.pause.gamePaused == false
        then
            lua_table["Audio"]:PlayAudioEventGO("Play_HUD_Switch_Potion", POTID)
        end

        if (on_hp == true and lua_table["Inputs"]:IsGamepadButton(1,"BUTTON_RIGHTSHOULDER","DOWN") and hp_potis == 0 or
        on_hp2 == true and lua_table["Inputs"]:IsGamepadButton(2,"BUTTON_RIGHTSHOULDER","DOWN") and hp_potis2 == 0 or
        on_energy == true and lua_table["Inputs"]:IsGamepadButton(1,"BUTTON_RIGHTSHOULDER","DOWN") and eng_potis == 0 or
        on_energy2 == true and lua_table["Inputs"]:IsGamepadButton(2,"BUTTON_RIGHTSHOULDER","DOWN") and eng_potis2 == 0 or
        on_dmg == true and lua_table["Inputs"]:IsGamepadButton(1,"BUTTON_RIGHTSHOULDER","DOWN") and dmg_potis == 0 or
        on_dmg2 == true and lua_table["Inputs"]:IsGamepadButton(2,"BUTTON_RIGHTSHOULDER","DOWN") and dmg_potis2 == 0)
        and lua_table.pause.gamePaused == false
        then
            lua_table["Audio"]:PlayAudioEvent("Play_No_potion")
        end

    end
    
    return lua_table
    end