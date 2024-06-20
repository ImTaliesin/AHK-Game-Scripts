#SingleInstance force
#Requires AutoHotkey v2.0+
#include ..\Libs\OCR.ahk ; https://github.com/Descolada/OCR
#include .\Helper.ahk

; https://github.com/MonzterDev/AHK-Game-Scripts

`::
{
    ocrResult := OCR.FromRect(3000, 310, 1200, 1400, , scale:=1.5).Text ; Scans Stash area in auction window for item

    rarity := GetItemRarity(ocrResult)
    itemName := GetItemName(ocrResult)

    if (itemName = "") {
        ToolTip("Item not found, try again.")
        return
    }

    enchantment := GetItemEnchantments(ocrResult)

    ; TODO
    ; We could use OCR for most of the following steps.

    ; Now we swap to view market tab
    MouseClick("Left", 1576, 156, ,) ; View Market button
    Sleep(500)

    MouseClick("Left", 2823, 271, ,) ; Reset Filters button
    Sleep(400)

    MouseClick("Left", 952, 275, , ) ; Click rarity selection
    Sleep(100)
    if (rarity = "Uncommon") {
        MouseClick("Left", 904, 440, , ) ; Click rarity
    } else if (rarity = "Rare") {
        MouseClick("Left", 909, 475, , ) ; Click rarity
    } else if (rarity = "Epic") { 
        MouseClick("Left", 947, 510, , ) ; Click rarity
    } else if (rarity = "Legend") {
        MouseClick("Left", 948, 539, , ) ; Click rarity
    } else if (rarity = "Unique") {
        MouseClick("Left", 926, 580, , ) ; Click rarity
    }
    Sleep(100)


    MouseClick("Left", 777, 270, , ) ; Click item name reset
    Sleep(100)
    MouseClick("Left", 626, 274, , ) ; Click item name selection
    Sleep(100)
    MouseClick("Left", 560, 324, , ) ; Click item name search box
    Sleep(200)
    Send(itemName) ; Type item name
    Sleep(150)
    MouseClick("Left", 592, 371, , ) ; Click item name
    Sleep(100)


    MouseClick("Left", 2493, 274, , ) ; Click random attributes
    Sleep(100)
    MouseClick("Left", 2503, 325, , ) ; Click enchantment name search box
    Sleep(250)
    Send("^a{BS}") ; Clear textbox
    Sleep(100)
    Send(enchantment) ; Type enchantment name
    Sleep(100)
    MouseClick("Left", 2503, 371, , ) ; Click enchantment name
    Sleep(100)
    MouseClick("Left", 2828, 369, , ) ; Click search
}


GetItemRarity(ocrResult) {
    rarity := ""
    if InStr(ocrResult, "Uncommon") {
        rarity := "Uncommon"
    } else if InStr(ocrResult, "Rare") {
        rarity := "Rare"
    } else if InStr(ocrResult, "Epic") {
        rarity := "Epic"
    } else if InStr(ocrResult, "Legend") {
        rarity := "Legend"
    } else if InStr(ocrResult, "Unique") {
        rarity := "Unique"
    }

    return rarity
}

GetItemName(ocrResult) {
    itemName := ""
    ; TODO
    ; I tried using a while loop here because sometimes the OCR cannot detect the text.
    ; This didn't actually solve the issue. For now, just use hotkey again.
    while (itemName = "" && A_Index <= 3) {
        for i, item in ITEMS {
            if InStr(ocrResult, item) {
                itemName := item
                break
            }
        }

        if (itemName = "") {
            Sleep(100)
        }
    }

    return itemName
}

GetItemEnchantments(ocrResult) {
    ; Enchantments (Random Attributes) can be distinguished from the static attributes by the "+" sign and number on the left side of the enchantment name.
    ; For example, "+5 Magical Damage" is an enchantment, while "Magical Damage 5" is a static attribute.

    ; TODO
    ; This currently only finds the first enchantment. We need to find all enchantments.
    enchantmentsFound := []
    enchantment := ""

    for enchantmentI in ENCHANTMENTS {
        enchantmentRegex := "\+(\d+(?:\.\d+)?%?) " . enchantmentI
        if (matchPos := RegExMatch(ocrResult, enchantmentRegex, &matchObject)) {
            enchantmentValue := matchObject[1]
            enchantmentText := enchantmentValue . " " . enchantmentI
            enchantmentsFound.Push(enchantmentI)
        }
    }

    if (enchantmentsFound.Length > 0) {
        enchantmentsText := ""
        for index, enchantmentL in enchantmentsFound {
            enchantmentsText .= enchantmentL
            enchantment := enchantmentL
            if (index < enchantmentsFound.Length) {
                enchantmentsText .= ", "
            }
        }
        ; ToolTip(itemName . " " . rarity . " (" . enchantmentsText . ")") ; Easy debug
    }

    return enchantment
}
