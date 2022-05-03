; ActiveEffectKeyHandler finds base addresses for ActiveEffectKeyHandler classes such as BrivUnnaturalHasteHandler and imports the offsets used for them.
#include %A_LineFile%\..\IC_GameObjectStructure_Class.ahk
#include %A_LineFile%\..\IC_IdleGameManager_Class.ahk
class IC_ActiveEffectKeyHandler_Class
{
    ;NerdType := {0:"None", 1:"Fighter_Orange", 2:"Ranger_Red", 3:"Bard_Green", 4:"Cleric_Yellow", 5:"Rogue_Pink", 6:"Wizard_Purple"}
    HeroHandlerIDs := {"HavilarImpHandler":56, "BrivUnnaturalHasteHandler":58,"TimeScaleWhenNotAttackedHandler":47, "OminContraactualObligationsHandler":65, "NerdWagonHandler":87}
    HeroEffectNames := {"NerdWagonHandler":"nerd_wagon", "OminContraactualObligationsHandler": "contractual_obligations", "HavilarImpHandler":"havilar_imps", "BrivUnnaturalHasteHandler":"briv_unnatural_haste", "TimeScaleWhenNotAttackedHandler":"time_scale_when_not_attacked"}
    __new()
    {
        this.Refresh()
    }
 
    GetVersion()
    {
        return "v2.0, 2022-05-01, IC v0.430+"  
    }

    Refresh()
    {
        this.Main := new _ClassMemory("ahk_exe IdleDragons.exe", "", hProcessCopy)
        this.BrivUnnaturalHasteHandler := this.GetEffectHandler("BrivUnnaturalHasteHandler")
        this.HavilarImpHandler := this.GetEffectHandler("HavilarImpHandler")
        this.NerdWagonHandler := this.GetEffectHandler("NerdWagonHandler")
        this.OminContractualObligationsHandler := this.GetEffectHandler("OminContractualObligationsHandler")
        this.TimeScaleWhenNotAttackedHandler := this.GetEffectHandler("TimeScaleWhenNotAttackedHandler")
        if g_SF.Memory.GameManager.Is64Bit()
            this.Refresh64()
        else
            this.Refresh32()
    }

    Refresh32()
    {
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_BrivUnnaturalHasteHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_HavilarImpHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_NerdWagonHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_OminContractualObligationsHandler32_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_TimeScaleWhenNotAttackedHandler32_Import.ahk
    }

    Refresh64()
    {
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_BrivUnnaturalHasteHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_HavilarImpHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_NerdWagonHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_OminContractualObligationsHandler64_Import.ahk
        #include %A_LineFile%\..\Imports\ActiveEffectHandlers\IC_TimeScaleWhenNotAttackedHandler64_Import.ahk
    }

    GetEffectHandler(handlerName)
    {
        baseAddress := this.GetBaseAddress(handlerName)
        gameObject := New GameObjectStructure([])
        gameObject.BaseAddress := baseAddress
        return gameObject
    }

    GetBaseAddress(handlerName)
    {
        champID := this.HeroHandlerIDs[handlerName]
        tempObject := g_SF.Memory.GameManager.game.gameInstances.Controller.userData.HeroHandler.heroes.effects.effectKeysByKeyName.List.parentEffectKeyHandler.activeEffectHandlers.size.GetGameObjectFromListValues( 0, champID - 1, 0 )
        ; add dictionary value from effectkeysbyname
        currOffset := tempobject.CalculateDictOffset(["value", this.GetDictIndex(handlerName)]) + 0 
        tempObject.FullOffsets.InsertAt(15, currOffset)
        ; ; insert list items offset
        ; tempObject.FullOffsets.InsertAt(16, g_SF.Memory.GameManager.Is64Bit() ? 0x20 : 0x8)
        ; ; insert first list item offset (Assuming only 1 item in effectkeyslist of effectkeysbyname (the dictionary value is a List<EffectKey>) list?)
        ; tempObject.FullOffsets.InsertAt(17, g_SF.Memory.GameManager.Is64Bit() ? 0x20 : 0x10)
        ; testHexString := ArrFnc.GetHexFormattedArrayString(tempObject.FullOffsets)
        ; OutputDebug, %testHexString%
        _size := g_SF.Memory.GenericGetValue(tempObject)
        ; Remove the "size" from the offsets list
        tempObject.FullOffsets.Pop()
        ; insert first list item offset (Assuming only 1 item in activeEffectKeys list)
        tempObject.FullOffsets.Push(g_SF.Memory.GameManager.Is64Bit() ? 0x10 : 0x8) ; _items
        ; tempObject.FullOffsets.Push(g_SF.Memory.GameManager.Is64Bit() ? 0x20 : 0x10) ; Item[0]
        testHexString := ArrFnc.GetHexFormattedArrayString(tempObject.FullOffsets)
        OutputDebug, %testHexString%
        address := g_SF.Memory.GenericGetValue(tempObject) + tempObject.CalculateOffset(0)
        return address
    }

    GetDictIndex(handlerName)
    {
        champID := this.HeroHandlerIDs[handlerName]
        effectName := this.HeroEffectNames[handlerName]
        tempObject := g_SF.Memory.GameManager.game.gameInstances.Controller.userData.HeroHandler.heroes.effects.effectKeysByKeyName.size.GetGameObjectFromListValues(0, ChampID - 1)
        dictCount := g_SF.Memory.GenericGetValue(tempObject)
        i := 0
        loop, % dictCount
        {
            tempObject := g_SF.Memory.GameManager.game.gameInstances.Controller.userData.HeroHandler.heroes.effects.effectKeysByKeyName.GetGameObjectFromListValues(0, ChampID - 1)
            currOffset := tempObject.CalculateDictOffset(["key", i])
            tempObject.FullOffsets.Push(currOffset)
            tempObject.ValueType := "UTF-16"
            testString := ArrFnc.GetHexFormattedArrayString(tempObject.FullOffsets)
            keyName := g_SF.Memory.GenericGetValue(tempObject)
            if (keyName == effectName)
                return i
            ++i
        }
        return -1
    }
}

; Omin Contractual Obligations
    ; ChampID := 65
    ; EffectKeyString := "contractual_obligations"
    ; RequiredLevel := 210
    ; EffectKeyID := 4110

; NerdWagon
    ; ChampID := 87
    ; EffectKeyString := "nerd_wagon"
    ; RequiredLevel := 80
    ; EffectKeyID := 921
    ; NerdType := {0:"None", 1:"Fighter_Orange", 2:"Ranger_Red", 3:"Bard_Green", 4:"Cleric_Yellow", 5:"Rogue_Pink", 6:"Wizard_Purple"}

; Havilar Imp Handler (HavilarImpHandler)
    ; ChampID := 56
    ; EffectKeyString := "havilar_imps"
    ; RequiredLevel := 15
    ; EffectKeyID := 3431

; Briv Unnatural haste (BrivUnnaturalHasteHandler)
    ; ChampID := 58
    ; EffectKeyString := "briv_unnatural_haste"
    ; RequiredLevel := 80
    ; EffectKeyID := 3452

; Shandie Dash (TimeScaleWhenNotAttackedHandler)
    ; ChampID := 47
    ; EffectKeyString := "time_scale_when_not_attacked"
    ; RequiredLevel := 120
    ; EffectKeyID := 2774