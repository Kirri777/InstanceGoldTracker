local addonName, InstanceGoldTracker = ...

local MyAddon = LibStub("AceAddon-3.0"):NewAddon("Instance Gold Tracker", "AceConsole-3.0")
local MyConsole = LibStub("AceConsole-3.0")

--- VARIABLES ---
    local tinsert, smatch, getn, floor = tinsert, string.match, getn, math.floor
    local table_single_dungeon_name = {}
    local stMain, stItems, igtMainFrame, igtDungeonFrame, igtSettingsFrame, igtCustomFrame, igtSaveFrame, igtGoldFrame, igtPriceSourceFrame, cbtnMinimap
    local data = {}
    local GameTooltip = GameTooltip
    local tt_start, tt_pause, tt_end, t_start = 0, 0, 0, 0
    local currentZone = GetZoneText()
    local currentSubZone = GetSubZoneText()
    local timer_Status = 0
    local PATTERN_LOOT_ITEM_SELF = LOOT_ITEM_SELF:gsub("%%s", "(.+)")
    local PATTERN_LOOT_ITEM_SELF_MULTIPLE = LOOT_ITEM_SELF_MULTIPLE:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
    local player_name, player_realm = UnitName("player")
    local sell_value_total = 0
    local sell_value_per_minute = 0
    local looted_money_total = 0
    local looted_money_per_minute = 0
    local total_money = 0
    local total_money_per_minute = 0
    local LootedItems = {}
    local LootedItemsQuantity = {}
    local CustomLootedItems = {}
    local CustomLootedItemsQuantity = {}
    local tracking = false
    local killcount = 0
    local rebuildstate = "IDLE"
    local table_failed_items = {}
    local table_failed_items2 = {}
    local framerate = GetFramerate();
    local framecounter = 0
    local buildcount = 1
    local build_done = false
    local build_percent = 0
    local fail_count = 0
--- SAVED VARIABLES ---
    table_Dungeon_Name = table_Dungeon_Name or  {}
    table_Dungeon_Difficulty = table_Dungeon_Difficulty or {}
    table_Time = table_Time or {}
    table_Looted_Item_Value_Total = table_Looted_Item_Value_Total or {}
    table_Looted_Money_Total = table_Looted_Money_Total or {}
    table_Money_Total = table_Money_Total or {}
    table_Character_Name = table_Character_Name or {}
    table_Date = table_Date or {}
    table_Character_Class = table_Character_Class or {}
    table_kill_count = table_kill_count or {}
    table_coordinates = table_coordinates or {}
    table_map = table_map or {}
    table_LootedItems = table_LootedItems or {}
    table_LootedItemsQuantity = table_LootedItemsQuantity or {}
    DB = DB or {}
    goldframex = goldframex or 0
    goldframey = goldframey or 0
    goldframealign1 = goldframealign1 or "CENTER"
    goldframealign2 = goldframealign2 or "CENTER"
    customframex = customframex or 0
    customframey = customframey or 0
    customframealign1 = customframealign1 or "CENTER"
    customframealign2 = customframealign2 or "CENTER"
    MinGold = MinGold or 0
    MinTime = MinTime or 0
    LiveGold = LiveGold or "ON"
    CustomPrice = CustomPrice or "vendorsell"
    CustomPriceStorage = CustomPriceStorage or {"dbmarket", "dbmarket", "dbmarket", "dbmarket", "dbmarket"}
    Rmain = Rmain or 0.5
    Gmain = Gmain or 0.5
    Bmain = Bmain or 0.5
    Amain = Amain or 0.5
    maintable = maintable or 1

local function reset_instance(timer)
    tracking = true
    timer_Status = timer
    sell_value_total = 0
    sell_value_per_minute = 0
    looted_money_total = 0
    looted_money_per_minute = 0
    total_money = 0
    total_money_per_minute = 0
    LootedItems = {}
    LootedItemsQuantity = {}
    killcount = 0
end

local function setButtonTextures(btn)
    btn:DisableDrawLayer("BACKGROUND")
    btn:SetNormalTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
end
local function toggleFrame(frame)
    frame:SetShown(not frame:IsShown())
end





--   local function recalculatetable()
--       rebuildstate = "BUILDING"
--       for i = 1, table.getn(table_Dungeon_Name) do
--           local temp = 0
--           for x = 1, table.getn(table_LootedItems[i])do
--               local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(table_LootedItems[i][x])
--               if itemName then
--                   if (IsAddOnLoaded("TradeSkillMaster")) then
--                       if TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")) and CustomPrice ~= "vendorsell" and (itemRarity > 1 or itemType == "Tradeskill") then
--                           itemSellPrice = TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)"))
--                       end
--                   end
--                   temp = temp + (itemSellPrice * table_LootedItemsQuantity[i][x])
--                   if rebuildstate ~= "FAILED" then
--                       rebuildstate = "SUCCESS"
--                   end
--               elseif itemName == nil then
--                   tinsert(table_failed_items, {i,x})
--                   rebuildstate = "FAILED"
--                   --MyAddon:Print(table_LootedItems[i][x])
--               end
--           end
--           table_Looted_Item_Value_Total[i] = temp
--           table_Money_Total[i] = temp + table_Looted_Money_Total[i] 
--       end
--       MyAddon:Print(rebuildstate)
--       MyAddon:Print(table.getn(table_failed_items))
--       return rebuildstate
--   end


local function setframecolors(rval, gval, bval, aval)
        Rmain, Gmain, Bmain, Amain = rval, gval, bval, aval
        igtMainFrame:SetBackdropColor(rval, gval, bval, aval)
        igtMainFrame:SetBackdropBorderColor(rval, gval, bval, aval)
        igtSettingsFrame:SetBackdropColor(rval, gval, bval, aval)
        igtSettingsFrame:SetBackdropBorderColor(rval, gval, bval, aval)
        igtDungeonFrame:SetBackdropColor(rval, gval, bval, aval)
        igtDungeonFrame:SetBackdropBorderColor(rval, gval, bval, aval)
        igtCustomFrame:SetBackdropColor(rval, gval, bval, aval)
        igtCustomFrame:SetBackdropBorderColor(rval, gval, bval, aval)
        igtPriceSourceFrame:SetBackdropColor(rval, gval, bval, aval)
        igtPriceSourceFrame:SetBackdropBorderColor(rval, gval, bval, aval)
        igtExportFrame:SetBackdropColor(rval, gval, bval, aval)
        igtExportFrame:SetBackdropBorderColor(rval, gval, bval, aval)
        igtGoldFrame:SetBackdropColor(rval, gval, bval, aval)
        igtGoldFrame:SetBackdropBorderColor(rval, gval, bval, aval)     
end
local function write_string(string)
    MyAddon:Print(string)
end

local function OpenColorPicker(rval, gval, bval, aval) 
    local r, g, b, a = rval, gval, bval, aval
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame.hasOpacity, ColorPickerFrame.opacity = (a ~= nil), a;
    ColorPickerFrame.previousValues = {r=rval,g=gval,b=bval,a=aval};
    ColorPickerFrame.hasOpacity = true

    r, g, b = ColorPickerFrame:GetColorRGB()
    a = OpacitySliderFrame:GetValue()
    
    ColorPickerFrame.func = 
        function () 
            r, g, b = ColorPickerFrame:GetColorRGB()
            setframecolors(r,g,b,a)
        end
    ColorPickerFrame.opacityFunc =
        function ()
            a = OpacitySliderFrame:GetValue()
            setframecolors(r,g,b,a)
        end
    ColorPickerFrame.cancelFunc = 
        function (prevVals)
            local r, g, b, a= prevVals.r, prevVals.g, prevVals.b, prevVals.a
            setframecolors(r,g,b,a)
        end

    ColorPickerFrame:Show()
end
local function CopperToGold(copper)
    local gold = floor(copper / 10000)
    copper = copper%10000
    local silver = floor(copper/100)
    copper = floor(copper%100)
    return  "|cFFC9B037" .. gold .. " " .. "|cFF808080" .. silver .. " " .. "|cFF976D5C" .. copper
end
local function SecondsToClock(seconds)
    local seconds = tonumber(seconds)
    if seconds <= 0 then
        return "00:00:00";
    else
        local hours = string.format("%02.f", floor(seconds/3600));
        local mins = string.format("%02.f", floor(seconds/60 - (hours*60)));
        local secs = string.format("%02.f", floor(seconds - hours*3600 - mins *60));
        return hours..":"..mins..":"..secs
    end
end
local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
local function sumArray(table)
    local value = 0
    for i = 1, getn(table) do
        value = value + table[i]  
    end
    return value
end
local function minArray(table)
    local value = table[1] 
    for i = 1, getn(table) do
        if value > table[i] then
            value = table[i] 
        end 
    end
    return value
end
local function maxArray(table)
    local value = table[1] 
    for i = 1, getn(table) do
        if value < table[i] then
            value = table[i] 
        end 
    end
    return value
end
local function getpart(name)
    local runcount = 0
    local temp_table_time = {}
    local temp_table_money = {}
    local temp_table_gold = {}
    local temp_table_looted_item = {}
    local temp_table_kill_count = {}
    for i = 1, getn(table_Dungeon_Name) do
        if table_Dungeon_Name[i] == name then
            tinsert(temp_table_time, table_Time[i])
            tinsert(temp_table_money, table_Money_Total[i])
            tinsert(temp_table_gold, table_Looted_Money_Total[i])
            tinsert(temp_table_looted_item, table_Looted_Item_Value_Total[i])
            tinsert(temp_table_kill_count, table_kill_count[1])
            runcount = runcount + 1
        end
    end
    return sumArray(temp_table_time), sumArray(temp_table_money), sumArray(temp_table_gold), sumArray(temp_table_looted_item), sumArray(temp_table_kill_count), runcount, temp_table_time, temp_table_money
end
local function getindexofentry(realrow)
    local counter = 0
    local returnvalue = 0
    for i = 1, getn(table_Dungeon_Name) do
        if table_Dungeon_Name[i] == table_single_dungeon_name[currententry] then
            counter = counter + 1
        end
        if counter == realrow then
            returnvalue = i
            break
        end
    end
    return returnvalue
end
local function setTableData(realrow)
    stMain:EnableSelection(true)
    stMain:ClearSelection()
    data = {}
    if maintable == 1 or realrow == 0 then
        table_single_dungeon_name = {table_Dungeon_Name[1]}
    
        for x = 1, getn(table_Dungeon_Name) do
            for i = 1, getn(table_single_dungeon_name) do
                if has_value(table_single_dungeon_name, table_Dungeon_Name[x]) then
                else
                    tinsert(table_single_dungeon_name, table_Dungeon_Name[x])
                end
            end
        end

        local table_single_character_name = {table_Character_Name[1]}

        for x = 1, getn(table_Character_Name) do
            for i = 1, getn(table_single_character_name) do
                if has_value(table_single_character_name, table_Character_Name[x]) then
                else
                    tinsert(table_single_character_name, table_Character_Name[x])
                end
            end
        end

        for row = 1, getn(table_single_dungeon_name) do
            if not data[row] then
                data[row] = {};
            end
            if not data[row].cols then
                data[row].cols = {};
            end
            local dngtime, dngmoney, dnggold, dngitemvalue, dngkill, dngcount, timearray, moneyarray = getpart(table_single_dungeon_name[row])
            data[row].cols[1] = { ["value"] = table_single_dungeon_name[row] .. "" } -- name
            data[row].cols[2] = { ["value"] = "Runs: " .. dngcount} -- difficulty
            data[row].cols[3] = { ["value"] = SecondsToClock(dngtime) } -- time
            data[row].cols[4] = { ["value"] = CopperToGold(dngitemvalue) } -- item value
            data[row].cols[5] = { ["value"] = CopperToGold(dnggold) } -- gold
            data[row].cols[6] = { ["value"] = CopperToGold(dngmoney) } -- total
            data[row].cols[7] = { ["value"] = CopperToGold(floor(3600/sumArray(timearray)*sumArray(moneyarray))) } -- per hour
            data[row].cols[8] = { ["value"] = dngkill } 
            data[row].cols[9] = { ["value"] = string.format("%.2f", dngkill/sumArray(timearray)*60) }
        end
        
        maintable = 0
    elseif maintable == 0 then
        local row = 1
        Dungeon_Name = table_single_dungeon_name[realrow]
        for i = 1, getn(table_Dungeon_Name) do
            if table_Dungeon_Name[i] == table_single_dungeon_name[realrow] then
                if not data[row] then
                    data[row] = {};
                end
                if not data[row].cols then
                    data[row].cols = {};
                end
                data[row].cols[1] = { ["value"] = table_Dungeon_Name[i] }
                data[row].cols[2] = { ["value"] = table_Dungeon_Difficulty[i] }
                data[row].cols[3] = { ["value"] = SecondsToClock(table_Time[i]) }
                data[row].cols[4] = { ["value"] = CopperToGold(table_Looted_Item_Value_Total[i]) }
                data[row].cols[5] = { ["value"] = CopperToGold(table_Looted_Money_Total[i]) }
                data[row].cols[6] = { ["value"] = CopperToGold(table_Money_Total[i]) }
                data[row].cols[7] = { ["value"] = CopperToGold(3600/table_Time[i]*table_Money_Total[i]) }
                data[row].cols[8] = { ["value"] = table_kill_count[i] }
                data[row].cols[9] = { ["value"] = string.format("%.2f", table_kill_count[i]/table_Time[i]*60) }
                row = row + 1
            end
        end
        --mainbtn:Show()
        maintable = 1 
    end
    stMain:SetData(data)
    stMain:SortData()	
end
local function recalculatetable(i)
    rebuildstate = "BUILDING"
    local temp = 0
    for x = 1, table.getn(table_LootedItems[i])do
        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(table_LootedItems[i][x])
        temp_item = table_LootedItems[i][x]
        if itemName then
            if (IsAddOnLoaded("TradeSkillMaster")) then
                if TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")) and CustomPrice ~= "vendorsell" and (itemRarity > 1 or itemType == "Tradeskill") then
                    itemSellPrice = TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)"))
                end
            end
            temp = temp + (itemSellPrice * table_LootedItemsQuantity[i][x])
            rebuildstate = "SUCCESS"
        elseif itemName == nil then
            tinsert(table_failed_items, {i,x})
            rebuildstate = "FAILED"
        end
    end
    table_Looted_Item_Value_Total[i] = temp
    table_Money_Total[i] = temp + table_Looted_Money_Total[i] 
    buildcount = buildcount + 1
    return rebuildstate, temp_item
end
local function setItemTableData(realrow)
    local data = {}
        if table_LootedItems[realrow] then
            if getn(table_Dungeon_Name) >= realrow then
                for row = 1, getn(table_LootedItems[realrow]) do
                    if not data[row] then
                        data[row] = {};
                    end
                    if not data[row].cols then
                        data[row].cols = {};
                    end
                    data[row].cols[1] = { ["value"] = table_LootedItems[realrow][row] }
                    data[row].cols[2] = { ["value"] = table_LootedItemsQuantity[realrow][row] }
                end
            end
        end
    stItems:ClearSelection()
    stItems:SetData(data)
    stItems:SortData()
end
local function deleteEntry(index)
    table.remove(table_Dungeon_Name, index)
    table.remove(table_Dungeon_Difficulty, index)
    table.remove(table_Time, index)
    table.remove(table_Looted_Item_Value_Total, index)
    table.remove(table_Looted_Money_Total, index)
    table.remove(table_Money_Total, index)
    table.remove(table_Character_Name, index)
    table.remove(table_Character_Class, index)
    table.remove(table_Date, index)        
    table.remove(table_LootedItems, index)
    table.remove(table_LootedItemsQuantity, index)
    table.remove(table_kill_count, index)
    table.remove(table_coordinates, index)
    table.remove(table_map, index)
end
local function datestuff(entrydate, days)

    local today = date("%m/%d/%y")
    local dates = {}
    local dates1 = {}

    today:gsub("%d+",
    function(i)
        table.insert(dates, i)
    end
    )
    if entrydate then
        entrydate:gsub("%d+",
        function(i)
            table.insert(dates1, i)
        end
        )

        entrydate = time{month = dates1[1], day = dates1[2], year = "20" .. dates1[3]}
        returndate = time{month = dates[1], day = dates[2] - days, year = "20" .. dates[3]}

        return returndate, entrydate
    end
end
local function instance_timer()
    if LiveGold == "ON" then
        igtCustomFrame:Hide()
        local localizedClass, englishClass, classIndex = UnitClass("player")
        local inInstance, instanceType = IsInInstance()
        local overall, equipped = GetAverageItemLevel()
        local name_lastDungen, type, difficultyIndex, difficultyName, maxPlayers,dynamicDifficulty, isDynamic, instanceMapId, lfgID = GetInstanceInfo()
        local difficulty_lastDungen = difficultyName
        t_start = GetTime()

        if inInstance and (instanceType == "party" or instanceType == "raid") then
            if timer_Status == 0 then
                reset_instance(1)
                igtGoldFrame:Show()
                igtGoldFrame.goldlabel1:SetText(CopperToGold(0))     
                t_start = GetTime()
                MyAddon:Print("Your run is being recorded.")
            end
        else
            local goldframealign1, temp, goldframealign2, goldframex, goldframey = igtGoldFrame:GetPoint()
            if timer_Status == 1 then
                timer_Status = 0
                local t_end = GetTime() - t_start
                local sell_value_per_minute = (sell_value_total / (math.floor(t_end*1000)/1000)) * 60
                local total_money = sell_value_total + looted_money_total
                local looted_money_per_minute = (looted_money_total / (math.floor(t_end*1000)/1000)) * 60
                local total_money_per_minute = (total_money / (math.floor(t_end*1000)/1000)) * 60

                igtGoldFrame:Hide()
                tracking = false
                if t_end >= MinTime and total_money >= MinGold * 10000 then
                    local px, py = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
                    local map = C_Map.GetBestMapForUnit("player")
                    local Coordinates = string.format("%.2f",px*100) .. " - ".. string.format("%.2f",py*100)
                    -- print(t_end)
                    tinsert(table_Dungeon_Name,name_lastDungen)
                    tinsert(table_Dungeon_Difficulty,difficultyName)
                    tinsert(table_Time,math.floor(t_end))
                    tinsert(table_Looted_Item_Value_Total,sell_value_total)
                    tinsert(table_Looted_Money_Total,looted_money_total)
                    tinsert(table_Money_Total,total_money)
                    tinsert(table_Character_Name, player_name)
                    tinsert(table_Character_Class, englishClass)
                    tinsert(table_Date,date("%m/%d/%y"))
                    tinsert(table_LootedItems, LootedItems)
                    tinsert(table_LootedItemsQuantity, LootedItemsQuantity)
                    tinsert(table_kill_count, killcount)
                    tinsert(table_coordinates, Coordinates)
                    tinsert(table_map, map)
                    local dngtime, dngmoney, dnggold, dngitemvalue, dngkill, dngcount, timearray, moneyarray = getpart(table_Dungeon_Name[getn(table_Dungeon_Name)])
                    MyAddon:Print("Stored data:", name_lastDungen, difficultyName)
                    MyAddon:Print("Gold earned:", CopperToGold(total_money))
                    MyAddon:Print("Average run:", CopperToGold(math.floor(dngmoney/dngcount)))
                else
                    MyAddon:Print("Time or Gold below your minimum. Data has not been stored.")
                end
            end
        end
    else
        MyAddon:Print("Instance tracking disabled!")
    end
end
local function loot_item(arg1)
    local loottype, itemLink, quantity, source
    if tracking then
        if arg1:match(PATTERN_LOOT_ITEM_SELF_MULTIPLE) then
            itemLink, quantity = smatch(arg1, PATTERN_LOOT_ITEM_SELF_MULTIPLE)
            local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)
                if (IsAddOnLoaded("TradeSkillMaster")) then
                    if TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")) and CustomPrice ~= "vendorsell" and (itemRarity > 1 or itemType == "Tradeskill") then
                        itemSellPrice = TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)"))
                        sell_value_total = sell_value_total + (quantity * TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")))
                    else
                        sell_value_total = sell_value_total + (quantity * itemSellPrice)
                    end
                else
                    sell_value_total = sell_value_total + (quantity * itemSellPrice)
                end
        elseif arg1:match(PATTERN_LOOT_ITEM_SELF) then
            itemLink = smatch(arg1, PATTERN_LOOT_ITEM_SELF)
            local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink)
            quantity = 1
            if (IsAddOnLoaded("TradeSkillMaster")) then
                if TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")) and CustomPrice ~= "vendorsell" and (itemRarity > 1 or itemType == "Tradeskill") then
                    itemSellPrice = TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)"))
                    sell_value_total = sell_value_total + TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)"))
                else
                    sell_value_total = sell_value_total + itemSellPrice
                end
            else
                sell_value_total = sell_value_total + itemSellPrice
            end
        end

        if getn(LootedItems) == 0 then
            tinsert(LootedItems, itemLink)
            tinsert(LootedItemsQuantity, quantity)
        else
            local saved = 0
            for i = 1, getn(LootedItems) do
                if LootedItems[i] == itemLink then
                    LootedItemsQuantity[i] = LootedItemsQuantity[i] + quantity
                    saved = 1
                end
            end
            if saved == 0 then
                tinsert(LootedItems, itemLink)
                tinsert(LootedItemsQuantity, quantity)
            end
        end
        if getn(CustomLootedItems) == 0 then
            tinsert(CustomLootedItems, itemLink)
            tinsert(CustomLootedItemsQuantity, quantity)
        else
            local saved = 0
            for i = 1, getn(CustomLootedItems) do
                if CustomLootedItems[i] == itemLink then
                    CustomLootedItemsQuantity[i] = CustomLootedItemsQuantity[i] + quantity
                    saved = 1
                end
            end
            if saved == 0 then
                tinsert(CustomLootedItems, itemLink)
                tinsert(CustomLootedItemsQuantity, quantity)
            end
        end
    end
end
function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end
local function loot_money(arg1)
    if tracking then
        local string_table = {}
        local gold, silver, copper = 0,0,0
        local is_gold, is_silver, is_copper = 0,0,0
        local digits = {}
        local digitsCounter = 0;

        if string.match(arg1, "+") then arg1 = string.sub(arg1, 1, string.find(arg1, "+")) end

        arg1:gsub("%d+",
            function(i)
                tinsert(digits, i)
                digitsCounter = digitsCounter + 1
            end
        )
        if digitsCounter == 3 then
            copper = (digits[1]*10000)+(digits[2]*100)+(digits[3])
        elseif digitsCounter == 2 then
            copper = (digits[1]*100)+(digits[2])
        else
            copper = digits[1]
        end
        if string.match(arg1, "+") then copper = round(copper * 1.02) end
        looted_money_total = copper + looted_money_total
        end
end
local function checkRequiredAddons(Addon)
    if (IsAddOnLoaded(Addon)) then
        btnPriceSources:Enable()
        btnPriceSources:SetText("Custom Price Source")        
        btnCSVExportLong:Enable()
        btnCSVExportLong:SetText("CSV Export Item List")
    else
        btnPriceSources:Disable()
        btnPriceSources:SetText("TradeSkillMaster not found")
        btnCSVExportLong:Disable()
        btnCSVExportLong:SetText("TradeSkillMaster not found")
    end

end
local function myEventHandler(self, event, ...)
    local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15= ...

    if event == 'ZONE_CHANGED' then
        currentZone = GetZoneText()
        currentSubZone = GetSubZoneText()
    elseif event == 'ZONE_CHANGED_NEW_AREA' then
        currentZone = GetZoneText()
        currentSubZone = GetSubZoneText()
    elseif event == "CHAT_MSG_LOOT" then
        loot_item(arg1)
        igtGoldFrame.goldlabel1:SetText(CopperToGold(looted_money_total + sell_value_total))
        igtCustomFrame.lootvalue1:SetText(CopperToGold(intlootvalue + sell_value_total))
        igtCustomFrame.totalvalue1:SetText(CopperToGold(inttotalvalue + looted_money_total + sell_value_total))
    elseif event == "CHAT_MSG_MONEY" then
        loot_money(arg1)
        igtGoldFrame.goldlabel1:SetText(CopperToGold(looted_money_total + sell_value_total))
        igtCustomFrame.goldvalue1:SetText(CopperToGold(intgoldvalue + looted_money_total))
        igtCustomFrame.totalvalue1:SetText(CopperToGold(inttotalvalue + looted_money_total + sell_value_total))
    elseif event == 'PLAYER_ENTERING_WORLD' then
        instance_timer()
    elseif event == 'PLAYER_LOGIN' then
     end
    
end
local function openigt()
    maintable = 1
    toggleFrame(igtMainFrame)
    igtDungeonFrame:Hide()
    igtSettingsFrame:Hide()
    setTableData()
    checkRequiredAddons("TradeSkillMaster")
end
function MyAddon:OnInitialize()
    --- MINIMAP BUTTON ---
    local LDB = LibStub("LibDataBroker-1.1"):NewDataObject("Instance Gold Tracker", {
        type = "data source",
        text = "Instance Gold Tracker",
        icon = "Interface\\Icons\\inv_misc_thegoldencheep",
        OnTooltipShow = function(tooltip)
            tooltip:SetText("Instance Gold Tracker")
            tooltip:AddLine("/igt to open window.", 1, 1, 1)
            tooltip:AddLine("/igtcustom to open custom farm window.", 1, 1, 1)
            tooltip:Show()
        end,
        OnClick = function() 
            if build_done then
                openigt()
            else
                MyAddon:Print("|cFFFF0000Collecting item and price data, please wait! - " .. build_percent .. "%")
            end
        end,
    })
    local icon = LibStub("LibDBIcon-1.0")
    self.db = LibStub("AceDB-3.0"):New("DB", { profile = { minimap = { hide = false, }, }, }) 
    icon:Register("Instance Gold Tracker", LDB, self.db.profile.minimap)
    function MyAddon:CommandTheBunnies() 
        self.db.profile.minimap.hide = not self.db.profile.minimap.hide 
        if self.db.profile.minimap.hide then 
            icon:Hide("Instance Gold Tracker") 
        else 
            icon:Show("Instance Gold Tracker") 
        end 
    end
    FrameBackDrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeSize = 2,
    }
    STBackDrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    }
    createMainFrame()
    createDungeonFrame()
    createSettingsFrame(self.db)
    createGoldFrame()
    createCustomFrame()
    createSaveFrame()
    createPriceSourceFrame()
    createExportFrame()
    createScrollingTable()
    --recalculatetable()
end
function createMainFrame()
    igtMainFrame = CreateFrame("Frame", "InstanceGoldTracker", UIParent, "BackdropTemplate")
    igtMainFrame:RegisterEvent("ZONE_CHANGED")
    igtMainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    igtMainFrame:RegisterEvent("CHAT_MSG_LOOT")
    igtMainFrame:RegisterEvent("CHAT_MSG_MONEY")
    igtMainFrame:RegisterEvent("PLAYER_LOGIN")
    igtMainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    local f = CreateFrame("Frame")
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:SetScript("OnEvent", function(self, event)
        self:OnEvent(event, CombatLogGetCurrentEventInfo())
    end)
    f:SetScript("OnUpdate", function(event, elapsed)
        if buildcount <= table.getn(table_Dungeon_Name) then
            local state, temp_item = recalculatetable(buildcount)
            if state == "FAILED" then
                buildcount = buildcount -1
                fail_count = fail_count + 1
                if fail_count > 1000 then
                    buildcount = buildcount + 1
                    fail_count = 0
                    --MyAddon:Print("Failed to build item" .. temp_item)
                end
                build_percent = round(buildcount/table.getn(table_Dungeon_Name)*100)
            end
        elseif buildcount > table.getn(table_Dungeon_Name) and not build_done then
            MyAddon:Print("|cff1eff00Rebuild Done")
            build_done = true
        end
    end)

    function f:OnEvent(event, ...)
        local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
        local spellId, spellName, spellSchool
        local amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
        if subevent == "PARTY_KILL" then
            killcount = killcount + 1 
        end
    end

    igtMainFrame:SetScript("OnEvent", myEventHandler)    
    igtMainFrame:SetBackdrop(FrameBackDrop)
    igtMainFrame:SetPoint("CENTER")
    igtMainFrame:SetSize(932, 641)
    igtMainFrame:SetFrameStrata("HIGH")
    tinsert(UISpecialFrames, "InstanceGoldTracker")
    igtMainFrame:SetMovable(true)
    igtMainFrame:EnableMouse(true)
    igtMainFrame:RegisterForDrag("LeftButton")
    igtMainFrame:SetScript("OnDragStart", igtMainFrame.StartMoving)
    igtMainFrame:SetScript("OnDragStop", igtMainFrame.StopMovingOrSizing)
    igtMainFrame.title = igtMainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    igtMainFrame.title:SetPoint("CENTER", igtMainFrame, "TOP", 0,-17)
    igtMainFrame.title:SetText("Instance Gold Tracker")

    --- Exit Button ---
    local btnExit = CreateFrame("button","ExitButton", igtMainFrame, "UIPanelCloseButtonNoScripts")
    btnExit:SetPoint("TOPRIGHT", igtMainFrame, "TOPRIGHT", 0, -1)
    btnExit:SetScript("OnClick", function(self, button, down) 
        igtSettingsFrame:Hide()
        self:GetParent():Hide() 
    end)

    --- Delete Button ---
    local btnDelete = CreateFrame("button","DeleteButton", igtMainFrame, "UIPanelButtonTemplate")
    btnDelete:SetPoint("BOTTOMLEFT", igtMainFrame, "BOTTOMLEFT", 5, 5)
    btnDelete:SetSize(60, 21)
    btnDelete:SetText("Delete")
    btnDelete.tooltipText = "Delete selected entry"
    setButtonTextures(btnDelete)

    btnDelete:SetScript("OnClick", function(self, button, down) 
        if stMain:GetSelection() and maintable == 1 then
        deleteEntry(getindexofentry(stMain:GetSelection())) 
        igtDungeonFrame:Hide()
        maintable = 0
        setTableData(currententry) 
        else
            MyAddon:Print("Please select row you want to delete!")
        end
       
    end)

    --- Back Button ---
    local btnBack = CreateFrame("button","MainButton", igtMainFrame, "UIPanelButtonTemplate")
    btnBack:SetPoint("BOTTOM", igtMainFrame, "BOTTOM", -6, 5)
    btnBack:SetSize(100, 21)
    btnBack:SetText("Back")
    setButtonTextures(btnBack)
    btnBack:SetScript("OnClick", function(self, button, down) 
        igtDungeonFrame:Hide()
        maintable = 1
        setTableData()
        Dungeon_Name = table_single_dungeon_name[0]
        stMain.SetFilter(stMain, function (stMain, row)
                return true
        end)
    end)
    --- Settings Button ---
    local btnSettings = CreateFrame("button","SettingsButton", igtMainFrame, "UIPanelButtonTemplate")
    btnSettings:SetPoint("BOTTOMRIGHT", igtMainFrame, "BOTTOMRIGHT", -5, 5)
    btnSettings:SetSize(60, 21)
    btnSettings:SetText("More")
    setButtonTextures(btnSettings)
    btnSettings:SetScript("OnClick", function(self, button, down) 
        toggleFrame(igtSettingsFrame)
    end)
end
function createDungeonFrame()
    --- CREATE DUNGEONS FRAME ---
    igtDungeonFrame = CreateFrame("Frame", "Dungeons", igtMainFrame, "BackdropTemplate")
    igtDungeonFrame:SetBackdrop(FrameBackDrop)
    igtDungeonFrame:SetPoint("TOPRIGHT", igtMainFrame, "TOPLEFT", -1,0)
    igtDungeonFrame:SetSize(300, 641)
    --tinsert(UISpecialFrames, "Dungeons")
    igtDungeonFrame.title = igtDungeonFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    igtDungeonFrame.title:SetPoint("CENTER", igtDungeonFrame, "TOP", 0,-17)
    igtDungeonFrame.title:SetText("Looted Items")
end
function createSettingsFrame(db)

    --- CREATE SETTINGS FRAME ---
    igtSettingsFrame = CreateFrame("Frame", "Settings", igtMainFrame, "BackdropTemplate")
    igtSettingsFrame:SetBackdrop(FrameBackDrop)
    igtSettingsFrame:SetPoint("TOPLEFT", igtMainFrame, "TOPRIGHT", 1,0)
    igtSettingsFrame:SetSize(300, 641)
    igtSettingsFrame:Hide()
    igtSettingsFrame.title = igtSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    igtSettingsFrame.title:SetPoint("CENTER", igtSettingsFrame, "TOP", 0,-17)
    igtSettingsFrame.title:SetText("Settings")

    local cbtnMinimap = CreateFrame("checkbutton","MinimapButton", igtSettingsFrame, "UICheckButtonTemplate")
    cbtnMinimap:SetPoint("TOPLEFT", igtSettingsFrame, "TOPLEFT", 6, -30)
    if db.profile.minimap.hide then
        cbtnMinimap:SetChecked(false)
    else
        cbtnMinimap:SetChecked(true)
    end
    cbtnMinimap:SetText("Minimap Button")
    cbtnMinimap:SetScript("OnClick", function(self, button, down)
        if cbtnMinimap:GetChecked() then
            cbtnMinimap:SetChecked(true)
            MyAddon:CommandTheBunnies()
        else
            cbtnMinimap:SetChecked(false)
            MyAddon:CommandTheBunnies()
        end
    end)

    igtSettingsFrame.helpLabel = igtSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtSettingsFrame.helpLabel:SetPoint("TOPLEFT", cbtnMinimap, "TOPRIGHT", 0, -9)
    igtSettingsFrame.helpLabel:SetText("Minimap Button")

    local cbtnLiveGold = CreateFrame("checkbutton","LiveGoldButton", igtSettingsFrame, "UICheckButtonTemplate")
    cbtnLiveGold:SetPoint("TOPLEFT", cbtnMinimap, "TOPLEFT", 0 , -25)
    if LiveGold == "ON" then
        cbtnLiveGold:SetChecked(true)
    else
        cbtnLiveGold:SetChecked(false)
    end
    cbtnLiveGold:SetScript("OnClick", function(self, button, down)
        if cbtnLiveGold:GetChecked() then
            cbtnLiveGold:SetChecked(true)
            LiveGold = "ON"
        else
            cbtnLiveGold:SetChecked(false)
            LiveGold = "OFF"
        end 
    end)

    igtSettingsFrame.helpLabel = igtSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtSettingsFrame.helpLabel:SetPoint("TOPLEFT", cbtnLiveGold, "TOPRIGHT", 0, -9)
    igtSettingsFrame.helpLabel:SetText("Live Gold")

    local ebMinTime = CreateFrame("EditBox", "myboxtime", igtSettingsFrame, "InputBoxTemplate")
    ebMinTime:SetPoint("TOPLEFT", cbtnLiveGold, "TOPLEFT", 10 , -25)
    ebMinTime:SetSize(32,32)
    ebMinTime:SetMaxLetters(4)
    ebMinTime:SetNumeric(true)
    ebMinTime:SetAutoFocus(false)
    ebMinTime:SetText(MinTime)
    ebMinTime:SetScript("OnCursorChanged", function()
        MinTime = ebMinTime:GetNumber() 
    end)

    igtSettingsFrame.helpLabel = igtSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtSettingsFrame.helpLabel:SetPoint("TOPLEFT", ebMinTime, "TOPRIGHT", 3, -9)
    igtSettingsFrame.helpLabel:SetText("Time: Below this, data wont be stored")

    local ebMinGold = CreateFrame("EditBox", "myboxgold", igtSettingsFrame, "InputBoxTemplate")
    ebMinGold:SetPoint("TOPLEFT", ebMinTime, "TOPLEFT", 0 , -25)
    ebMinGold:SetSize(32,32)
    ebMinGold:SetMaxLetters(4)
    ebMinGold:SetNumeric(true)
    ebMinGold:SetAutoFocus(false)
    ebMinGold:SetText(MinGold)
    ebMinGold.tooltipText = "Delete selected entry"
    ebMinGold:SetScript("OnCursorChanged", function()
        MinGold = ebMinGold:GetNumber() 
    end)

    igtSettingsFrame.helpLabel = igtSettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtSettingsFrame.helpLabel:SetPoint("TOPLEFT", ebMinGold, "TOPRIGHT", 3, -9)
    igtSettingsFrame.helpLabel:SetText("Gold: Below this, data wont be stored")

    local ebDeleteDays = CreateFrame("EditBox", "mydeletebox", igtSettingsFrame, "InputBoxTemplate")
    ebDeleteDays:SetPoint("TOPLEFT", ebMinGold, "TOPLEFT", 0 , -25)
    ebDeleteDays:SetSize(32,32)
    ebDeleteDays:SetMaxLetters(4)
    ebDeleteDays:SetNumeric(true)
    ebDeleteDays:SetAutoFocus(false)
    ebDeleteDays:SetText("")
    ebDeleteDays.tooltipText = "Delete selected entry"

    local btnDeleteAll = CreateFrame("button","DeleteButton", igtSettingsFrame, "UIPanelButtonTemplate")
    btnDeleteAll:SetPoint("TOPLEFT", ebDeleteDays, "TOPRIGHT", 3, -5)
    setButtonTextures(btnDeleteAll)
    btnDeleteAll:SetSize(239, 21)
    btnDeleteAll:SetText("Delete Data older than x day(s)")
    btnDeleteAll.tooltipText = "|cffff0000Data cant be restored...\n\n|cffffffff0 .. Delete All\n"
    btnDeleteAll:SetScript("OnClick", function(self, button, down) 
        if ebDeleteDays:GetText() ~= "" then
            for index = table.getn(table_Date), 1, -1 do
                local returndate, entrydate = datestuff(table_Date[index], ebDeleteDays:GetNumber()-1)
                if returndate > entrydate then
                    table.remove(table_Dungeon_Name, index)
                    table.remove(table_Dungeon_Difficulty, index)
                    table.remove(table_Time, index)
                    table.remove(table_Looted_Item_Value_Total, index)
                    table.remove(table_Looted_Money_Total, index)
                    table.remove(table_Money_Total, index)
                    table.remove(table_Character_Name, index)
                    table.remove(table_Character_Class, index)
                    table.remove(table_Date, index)        
                    table.remove(table_LootedItems, index)
                    table.remove(table_LootedItemsQuantity, index)
                    table.remove(table_kill_count, index)
                    table.remove(table_coordinates, index)
                    table.remove(table_map, index)
                end
            end
        end
        igtDungeonFrame:Hide()
        setTableData(0)
        stMain:ClearSelection()end)
    
    local btnPriceSources = CreateFrame("button","btnPriceSources", igtSettingsFrame, "UIPanelButtonTemplate")
    btnPriceSources:SetPoint("TOPLEFT", ebDeleteDays, "TOPLEFT", -7 , -30)
    setButtonTextures(btnPriceSources)
    btnPriceSources:SetSize(281, 21)
    btnPriceSources.tooltipText = "Current Price Source"
    btnPriceSources:SetScript("OnClick", function(self, button, down)
        toggleFrame(igtPriceSourceFrame)
    end)

    local btnCSVExportLong = CreateFrame("button","btnCSVExportLong", igtSettingsFrame, "UIPanelButtonTemplate")
    btnCSVExportLong:SetPoint("TOPLEFT", btnPriceSources, "BOTTOMLEFT", 0 , -4)
    setButtonTextures(btnCSVExportLong)
    btnCSVExportLong.tooltipText = "Select farm to create itemlist.\n\n|cFFFF0000This might take a few seconds!\n"
    btnCSVExportLong:SetSize(281, 21)
    btnCSVExportLong:SetScript("OnClick", function(self, button, down)
        PleaseTryAgain = 0
        local table_start = {}
        local table_mid = {}
        local table_end = {}
        local temp = {}
        if Dungeon_Name then
            local exportstring = "Instance".. "\t" .. "Runs" .. "\t" .. "Item" .. "\t" .. "Item Count" .. "\t" .. "Item Value[Gold]" .. "\t" .. "Avg. drops per Run".. "\t" .. "Price Source" .."\t" .. "wowhead.com" .. "\n" 
            for i = 1, table.getn(table_LootedItems) do
                local dngtime, dngmoney, dnggold, dngitemvalue, dngkill, dngcount, timearray, moneyarray = getpart(table_Dungeon_Name[i])
                if table_Dungeon_Name[i] == Dungeon_Name then
                    for x = 1, table.getn(table_LootedItems[i]) do
                        local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(table_LootedItems[i][x])
                        if itemLink then
                            if TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")) and CustomPrice ~= "vendorsell" and (itemRarity > 1 or itemType == "Tradeskill" or itemType == "Quest") then
                                --  temp = table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x] .. "\t" .. table_LootedItemsQuantity[i][x] .. "\t" .. itemSellPrice/10000 .. "\t".. table_LootedItemsQuantity[i][x]/dngcount .. "\t" .. "Vendorsell" .. "\t" .. "https://www#wowhead#com/item=" .. string.match(itemLink, "item:(%d*)") .. "\n"
                                if has_value(table_start, table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x]) then
                                    for y = 1, table.getn(table_start) do
                                        if table_start[y] == table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x] then
                                            table_mid[y] = table_mid[y] +  table_LootedItemsQuantity[i][x]
                                            table_end[y] = TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(table_LootedItems[i][x], "item:(%d*)"))/10000 .. "\t".. table_mid[y]/dngcount .. "\t" .. CustomPrice .. "\t" .. "https://www#wowhead#com/item=" .. string.match(itemLink, "item:(%d*)") .. "\n"
                                        end
                                    end
                                else
                                    table.insert(table_start, table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x])
                                    table.insert(table_mid, table_LootedItemsQuantity[i][x])
                                    table.insert(table_end, TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(table_LootedItems[i][x], "item:(%d*)"))/10000 .. "\t".. table_LootedItemsQuantity[i][x]/dngcount .. "\t" .. CustomPrice .. "\t" .. "https://www#wowhead#com/item=" .. string.match(itemLink, "item:(%d*)") .. "\n")
                                end
                            else
                                --  temp = table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x] .. "\t" .. table_LootedItemsQuantity[i][x] .. "\t" .. itemSellPrice/10000 .. "\t".. table_LootedItemsQuantity[i][x]/dngcount .. "\t" .. "Vendorsell" .. "\t" .. "https://www#wowhead#com/item=" .. string.match(itemLink, "item:(%d*)") .. "\n"
                                if has_value(table_start, table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x]) then
                                    for y = 1, table.getn(table_start) do
                                        if table_start[y] == table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x] then
                                            table_mid[y] = table_mid[y] +  table_LootedItemsQuantity[i][x]
                                            table_end[y] = itemSellPrice/10000 .. "\t".. table_mid[y]/dngcount .. "\t" .. "Vendorsell" .. "\t" .. "https://www#wowhead#com/item=" .. string.match(itemLink, "item:(%d*)") .. "\n"
                                        end
                                    end
                                else
                                    table.insert(table_start, table_Dungeon_Name[i] .. "\t" .. dngcount .. "\t" .. table_LootedItems[i][x])
                                    table.insert(table_mid, table_LootedItemsQuantity[i][x])
                                    table.insert(table_end, itemSellPrice/10000 .. "\t".. table_LootedItemsQuantity[i][x]/dngcount .. "\t" .. "Vendorsell" .. "\t" .. "https://www#wowhead#com/item=" .. string.match(itemLink, "item:(%d*)") .. "\n")
                                end
                            end
                        else
                            itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(table_LootedItems[i][x])
                            PleaseTryAgain = 1
                        end
                    end
                end
            end
            for x = 1, table.getn(table_start) do
                table.insert(temp, table_start[x] .. "\t" .. table_mid[x] .. "\t" .. table_end[x])
            end
            for i = 1, table.getn(temp) do
                temp[i] = string.gsub(temp[i], '%.', ',')
                temp[i] = string.gsub(temp[i], '%#', '%.')
                exportstring = exportstring .. temp[i]
            end
            editBox:SetText(exportstring)
            if PleaseTryAgain == 1 then
                MyAddon:Print("|cFFFF0000Failed to create itemlist, please try again")
            else
                igtExportFrame:Show()
            end
        else
            MyAddon:Print("Please select Instance or Farm first to create itemlist.")
        end
        
    end)
    local btnCSVExportShort = CreateFrame("button","btnCSVExportShort", igtSettingsFrame, "UIPanelButtonTemplate")
    btnCSVExportShort:SetPoint("TOPLEFT", btnCSVExportLong, "BOTTOMLEFT", 0 , -4)
    setButtonTextures(btnCSVExportShort)
    btnCSVExportShort:SetText("Excel String: Runs")
    btnCSVExportShort:SetSize(281, 21)
    btnCSVExportShort:SetScript("OnClick", function(self, button, down)
        local exportstring = "Instance".. "\t" .. "Difficulty" .. "\t" .. "Time" .. "\t" .. "Item Value" .. "\t" .. "Looted Money" .. "\t" .. "Total Money" .. "\t" .. "Kills" .. "\t" .. "Character" .. "\n" 
        for i = 1, table.getn(table_Dungeon_Name) do
            local temp = table_Dungeon_Name[i] .. "\t" .. table_Dungeon_Difficulty[i] .. "\t" .. table_Time[i]/86400 .. "\t" .. table_Looted_Item_Value_Total[i]/10000 .. "\t" .. table_Looted_Money_Total[i]/10000 .. "\t" .. table_Money_Total[i]/10000 .. "\t" .. table_kill_count[i] .. "\t" .. table_Character_Name[i] .. "\n"
            temp = string.gsub(temp, '%.', ',')
            exportstring = exportstring .. temp
        end
        editBox:SetText(exportstring)
        igtExportFrame:Show()
    end)

    local btnCustomFarm = CreateFrame("button","customfarm", igtSettingsFrame, "UIPanelButtonTemplate")
    btnCustomFarm:SetPoint("TOPLEFT", btnCSVExportShort, "BOTTOMLEFT", 0 , -4)
    setButtonTextures(btnCustomFarm)
    btnCustomFarm:SetText("Custom Farm")
    btnCustomFarm:SetSize(281, 21)
    btnCustomFarm:SetScript("OnClick", function(self, button, down)
        local inInstance, instanceType = IsInInstance()
        if inInstance then
            MyAddon:Print("|cFFFF0000Cannot start Custom Farm in instance")
        else
            tt_start = GetTime()
            tt_pause = 0
            intgoldvalue = 0
            intlootvalue = 0
            inttotalvalue = 0
            looted_money_total = 0
            sell_value_total = 0
            igtCustomFrame.goldvalue1:SetText(CopperToGold(0))
            igtCustomFrame.lootvalue1:SetText(CopperToGold(0))
            igtCustomFrame.totalvalue1:SetText(CopperToGold(0))
            CustomLootedItems = {}
            CustomLootedItemsQuantity = {}
            reset_instance(0)
            toggleFrame(igtCustomFrame)
            killcount = 0
        end
    end)

    local btnColorPickerMain = CreateFrame("button","colorpickermain", igtSettingsFrame, "UIPanelButtonTemplate")
    btnColorPickerMain:SetPoint("TOPLEFT", btnCustomFarm, "BOTTOMLEFT", 0 , -4)
    setButtonTextures(btnColorPickerMain)
    btnColorPickerMain:SetText("Frame Color")
    btnColorPickerMain:SetSize(281, 21)
    btnColorPickerMain:SetScript("OnClick", function(self, button, down)
        OpenColorPicker(Rmain, Gmain, Bmain, Amain, "main")
    end)
end
function createGoldFrame()
    --- CREATE GOLD FRAME ---
    igtGoldFrame = CreateFrame("Frame", "igtGoldFrame", UIParent, "BackdropTemplate")
    igtGoldFrame:SetBackdrop(FrameBackDrop)
    igtGoldFrame:SetPoint(goldframealign1, UIParent, goldframealign2, goldframex, goldframey)
    igtGoldFrame:SetSize(150, 40)
    igtGoldFrame:SetFrameStrata("LOW")
    --tinsert(UISpecialFrames, "igtGoldFrame")

    igtGoldFrame:SetMovable(true)
    igtGoldFrame:EnableMouse(true)
    igtGoldFrame:RegisterForDrag("LeftButton")
    igtGoldFrame:SetScript("OnDragStart", igtGoldFrame.StartMoving)
    igtGoldFrame:SetScript("OnDragStop", igtGoldFrame.StopMovingOrSizing)

    igtGoldFrame.goldlabel = igtGoldFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtGoldFrame.goldlabel:SetPoint("TOPLEFT", igtGoldFrame, "TOPLEFT", 8, -7)
    igtGoldFrame.goldlabel:SetText("Gold:")

    igtGoldFrame.goldlabel1 = igtGoldFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtGoldFrame.goldlabel1:SetPoint("TOPRIGHT", igtGoldFrame, "TOPRIGHT", -8, -7)
    igtGoldFrame.goldlabel1:SetText(CopperToGold(0))

    igtGoldFrame.timerlbl1 = igtGoldFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtGoldFrame.timerlbl1:SetPoint("TOPLEFT", igtGoldFrame.goldlabel, "TOPLEFT", 0, -15)
    igtGoldFrame.timerlbl1:SetText("Timer:")

    igtGoldFrame.timerlbl = igtGoldFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtGoldFrame.timerlbl:SetPoint("LEFT", igtGoldFrame.goldlabel1, "RIGHT", -58, -15)

    igtGoldFrame:SetScript("OnUpdate", function(event, elapsed)
        igtGoldFrame.timerlbl:SetText(SecondsToClock(floor(GetTime() - t_start)))
    end)

    igtGoldFrame:Hide()
end
function createCustomFrame()
    --- Create Custom Frame
    igtCustomFrame = CreateFrame("Frame", "CustomFarmFrame", UIParent, "BackdropTemplate")
    igtCustomFrame:SetBackdrop(FrameBackDrop)
    igtCustomFrame:SetPoint(customframealign1, UIParent, customframealign2, customframex, customframey)
    igtCustomFrame:SetSize(150, 95)
    igtCustomFrame:SetFrameStrata("LOW")
    igtCustomFrame:EnableMouse(true)
    intgoldvalue = 0
    intlootvalue = 0
    inttotalvalue = 0
    looted_money_total = 0
    sell_value_total = 0
    igtCustomFrame.title = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    igtCustomFrame.title:SetPoint("CENTER", igtCustomFrame, "TOP", 0,-15)
    igtCustomFrame:Hide()

    local btnReset = CreateFrame("button","resetbutton", igtCustomFrame, "UIPanelButtonTemplate")
    btnReset:SetPoint("BOTTOMLEFT", igtCustomFrame, "BOTTOMLEFT", 5, 5)

    setButtonTextures(btnReset)

    btnReset:SetSize(67, 21)
    btnReset:SetText("Reset")
    btnReset:SetScript("OnClick", function(self, button, down)
        tt_start = GetTime()
        tt_pause = 0
        intgoldvalue = 0
        intlootvalue = 0
        inttotalvalue = 0
        looted_money_total = 0
        sell_value_total = 0
        igtCustomFrame.goldvalue1:SetText(CopperToGold(0))
        igtCustomFrame.lootvalue1:SetText(CopperToGold(0))
        igtCustomFrame.totalvalue1:SetText(CopperToGold(0))
        CustomLootedItems = {}
        CustomLootedItemsQuantity = {}
    end)

    local btnSave = CreateFrame("button","savebutton", igtCustomFrame, "UIPanelButtonTemplate")
    btnSave:SetPoint("BOTTOMRIGHT", igtCustomFrame, "BOTTOMRIGHT", -5, 5)

    setButtonTextures(btnSave)

    btnSave:SetSize(67, 21)
    btnSave:SetText("Save")
    btnSave:SetScript("OnClick", function(self, button, down)
        toggleFrame(igtSaveFrame)
        if currentSubZone ~= ""then
            bSave:SetText(currentZone .. " - " .. currentSubZone)
        else
            bSave:SetText(currentZone)
        end
    end)

    igtCustomFrame:SetMovable(true)
    igtCustomFrame:EnableMouse(true)
    igtCustomFrame:RegisterForDrag("LeftButton")
    igtCustomFrame:SetScript("OnDragStart", igtCustomFrame.StartMoving)
    igtCustomFrame:SetScript("OnDragStop", igtCustomFrame.StopMovingOrSizing)

    igtCustomFrame.goldvalue = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.goldvalue:SetPoint("TOPLEFT", igtCustomFrame, "TOPLEFT", 8, -7)
    igtCustomFrame.goldvalue:SetText("Gold:")

    igtCustomFrame.goldvalue1 = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.goldvalue1:SetPoint("TOPRIGHT", igtCustomFrame, "TOPRIGHT", -8, -7)
    igtCustomFrame.goldvalue1:SetText(CopperToGold(0))

    igtCustomFrame.lootvalue = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.lootvalue:SetPoint("TOPLEFT", igtCustomFrame.goldvalue, "TOPLEFT", 0, -15)
    igtCustomFrame.lootvalue:SetText("Loot:")

    igtCustomFrame.lootvalue1 = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.lootvalue1:SetPoint("RIGHT", igtCustomFrame.goldvalue1, "RIGHT", 0, -15)
    igtCustomFrame.lootvalue1:SetText(CopperToGold(0))

    igtCustomFrame.totalvalue = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.totalvalue:SetPoint("TOPLEFT", igtCustomFrame.lootvalue, "TOPLEFT", 0, -15)
    igtCustomFrame.totalvalue:SetText("Total:")

    igtCustomFrame.totalvalue1 = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.totalvalue1:SetPoint("RIGHT", igtCustomFrame.lootvalue1, "RIGHT", 0, -15)
    igtCustomFrame.totalvalue1:SetText(CopperToGold(0))

    igtCustomFrame.timerlbl1 = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.timerlbl1:SetPoint("TOPLEFT", igtCustomFrame.totalvalue, "TOPLEFT", 0, -15)
    igtCustomFrame.timerlbl1:SetText("Timer:")

    igtCustomFrame.timerlbl = igtCustomFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    igtCustomFrame.timerlbl:SetPoint("LEFT", igtCustomFrame.totalvalue1, "RIGHT", -58, -15)

    igtCustomFrame:SetScript("OnUpdate", function(event, elapsed)
        igtCustomFrame.timerlbl:SetText(SecondsToClock(math.floor(GetTime() - tt_start)))
        customframealign1, temp, customframealign2, customframex, customframey = igtCustomFrame:GetPoint()
    end)
end
function createSaveFrame()
    igtSaveFrame = CreateFrame("Frame", "igtSaveFrame", UIParent, "BackdropTemplate")
    igtSaveFrame:SetBackdrop(FrameBackDrop)
    igtSaveFrame:SetPoint("CENTER")
    igtSaveFrame:SetSize(350, 20)
    igtSaveFrame:SetFrameStrata("HIGH")
    igtSaveFrame:EnableMouse(true)
    --tinsert(UISpecialFrames, "igtSaveFrame")

    igtSaveFrame:SetMovable(true)
    igtSaveFrame:EnableMouse(true)
    igtSaveFrame:RegisterForDrag("LeftButton")
    igtSaveFrame:SetScript("OnDragStart", igtCustomFrame.StartMoving)
    igtSaveFrame:SetScript("OnDragStop", igtCustomFrame.StopMovingOrSizing)
    igtSaveFrame:Hide()
    local btnSave = CreateFrame("button","savebutton", igtSaveFrame, "UIPanelButtonTemplate")
    btnSave:SetPoint("BOTTOMRIGHT", igtSaveFrame, "BOTTOMRIGHT", 0, 0)
    btnSave:SetSize(70, 21)
    btnSave:SetText("Save")

    btnSave:SetScript("OnClick", function(self, button, down)
        tracking = false
        local localizedClass, englishClass, classIndex = UnitClass("player")
        local px, py = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player"):GetXY()
        local Coordinates = string.format("%.2f",px*100) .. " - ".. string.format("%.2f",py*100)
        local map = C_Map.GetBestMapForUnit("player")
        
        tt_end = GetTime() - tt_start
        tinsert(table_Dungeon_Name,bSave:GetText())
        tinsert(table_Dungeon_Difficulty,"Custom")
        tinsert(table_Time,math.floor(tt_end) or 1)
        tinsert(table_Looted_Item_Value_Total,sell_value_total or "none")
        tinsert(table_Looted_Money_Total,looted_money_total or 1)
        tinsert(table_Money_Total,(looted_money_total + sell_value_total) or 1)
        tinsert(table_Character_Name, player_name or 1)
        tinsert(table_Character_Class, englishClass or "class")
        tinsert(table_Date,date("%m/%d/%y") or "01/01/0001")
        tinsert(table_LootedItems, CustomLootedItems or "none")
        tinsert(table_LootedItemsQuantity, CustomLootedItemsQuantity or 1)
        tinsert(table_kill_count, killcount or 1)
        tinsert(table_coordinates, Coordinates or "none")
        tinsert(table_map, map or "none")
        toggleFrame(igtSaveFrame)

        intgoldvalue = 0
        intlootvalue = 0
        inttotalvalue = 0
        looted_money_total = 0
        sell_value_total = 0
        templooted = 0
        killcount = 0
        igtCustomFrame.goldvalue1:SetText(CopperToGold(0))
        igtCustomFrame.lootvalue1:SetText(CopperToGold(0))
        igtCustomFrame.totalvalue1:SetText(CopperToGold(0))
        CustomLootedItems = {}
        CustomLootedItemsQuantity = {}
        tt_start = GetTime()
        tt_pause = 0
    end)

    local bSave = CreateFrame("EditBox", "bSave", igtSaveFrame, "InputBoxTemplate")
    bSave:SetPoint("BOTTOMLEFT", igtSaveFrame, "BOTTOMLEFT", 6 , 0)
    bSave:SetSize(273,21)
    bSave:SetAutoFocus(false)
    bSave:SetText(MinTime)
end
function createPriceSourceFrame()
    igtPriceSourceFrame = CreateFrame("Frame", "PriceSourceFrame", UIParent, "BackdropTemplate")
    igtPriceSourceFrame:SetBackdrop(FrameBackDrop)
    igtPriceSourceFrame:SetPoint("CENTER")
    igtPriceSourceFrame:SetSize(550, 67)
    igtPriceSourceFrame:SetFrameStrata("FULLSCREEN")
    igtPriceSourceFrame:SetMovable(true)
    igtPriceSourceFrame:EnableMouse(true)
    igtPriceSourceFrame:RegisterForDrag("LeftButton")
    tinsert(UISpecialFrames, "PriceSourceFrame")

    igtPriceSourceFrame.title = igtPriceSourceFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    igtPriceSourceFrame.title:SetPoint("CENTER", igtPriceSourceFrame, "TOP", 0,-17)
    igtPriceSourceFrame.title:SetText("Custom Price Source")

    local close = CreateFrame("button","ExitButton", igtPriceSourceFrame, "UIPanelCloseButtonNoScripts")
    close:SetPoint("TOPRIGHT", igtPriceSourceFrame, "TOPRIGHT", 0, -1)

    close:SetScript("OnClick", function(self, button, down) 
        self:GetParent():Hide() 
    end)

    local storage1 = CreateFrame("EditBox", "myboxgold", igtPriceSourceFrame, "InputBoxTemplate")
    storage1:SetPoint("TOPLEFT", igtPriceSourceFrame, "TOPLEFT", 13 , -24)
    storage1:SetSize(450,32)
    storage1:SetAutoFocus(false)
    storage1:SetText(CustomPriceStorage[1])
    local savebtn = CreateFrame("button","SettingsButton", igtPriceSourceFrame, "UIPanelButtonTemplate")
    setButtonTextures(savebtn)
    savebtn:SetPoint("TOPLEFT", storage1, "TOPRIGHT", -1, -6)
    savebtn:SetSize(40, 21)
    savebtn:SetText("Save")
    savebtn:SetScript("OnClick", function(self, button, down)
        if TSM_API.GetCustomPriceValue(storage1:GetText(), "i:2589") then
            CustomPriceStorage[1] = storage1:GetText()
        else
            MyAddon:Print("|cFFFF0000Custom Price Source Invalid")
        end
    end)

    local usebtn = CreateFrame("button","SettingsButton", igtPriceSourceFrame, "UIPanelButtonTemplate")
    setButtonTextures(usebtn)
    usebtn:SetPoint("TOPLEFT", savebtn, "TOPRIGHT", -1, 0)
    usebtn:SetSize(40, 21)
    usebtn:SetText("Use")
    usebtn:SetScript("OnClick", function(self, button, down)
        if TSM_API.GetCustomPriceValue(storage1:GetText(), "i:2589") then
            CustomPrice = storage1:GetText()
            btnPriceSources.tooltipText = "Current Price Source\n"..CustomPrice
            MyAddon:Print("Using TSM Price Source:", CustomPrice)
            rebuildstate = "BUILDING"
            --recalculatetable()
            setTableData(0)
            CustomPriceStorage[1] = storage1:GetText()
            buildcount = 1
            build_done = false
        else
            MyAddon:Print("|cFFFF0000Custom Price Source Invalid")
        end
    end)
end
function createExportFrame()
    igtExportFrame = CreateFrame("Frame", "ExcelFrame", UIParent, "BackdropTemplate")
    igtExportFrame:SetBackdrop(FrameBackDrop)

    igtExportFrame:SetWidth(500)
    igtExportFrame:SetHeight(400)
    igtExportFrame:SetPoint("CENTER", UIParent, "CENTER")
    igtExportFrame:Hide()
    igtExportFrame:SetFrameStrata("FULLSCREEN")
    igtExportFrame.title = igtExportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    igtExportFrame.title:SetPoint("CENTER", igtExportFrame, "TOP", 0,-17)
    igtExportFrame.title:SetText("")
    tinsert(UISpecialFrames, "ExcelFrame")

    scrollArea = CreateFrame("ScrollFrame", "BCMCopyScroll", igtExportFrame, "UIPanelScrollFrameTemplate")
    scrollArea:SetPoint("TOPLEFT", igtExportFrame, "TOPLEFT", 8, -30)
    scrollArea:SetPoint("BOTTOMRIGHT", igtExportFrame, "BOTTOMRIGHT", -30, 8)
    igtExportFrame:SetMovable(true)
    igtExportFrame:EnableMouse(true)
    igtExportFrame:RegisterForDrag("LeftButton")

    editBox = CreateFrame("EditBox", "BCMCopyBox", igtExportFrame)
    editBox:SetMultiLine(true)
    editBox:EnableMouse(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetWidth(470)
    editBox:SetHeight(270)

    scrollArea:SetScrollChild(editBox)

    local close = CreateFrame("Button", "BCMCloseButton", igtExportFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", igtExportFrame, "TOPRIGHT")
end
function createScrollingTable()
    --- SCROLLING TABLE ---
    local ScrollingTable = LibStub("ScrollingTable");
    local color = { 
        ["r"] = 0.5,
        ["g"] = 0.5,
        ["b"] = 1.0,
        ["a"] = 1.0,
    };
    local bgcolor = { 
        ["r"] = 0.0,
        ["g"] = 0.0,
        ["b"] = 0.0,
        ["a"] = 0.0,
    };
    local highlight = { 
        ["r"] = 0.75,
        ["g"] = 0.75,
        ["b"] = 0.75,
        ["a"] = 0.1,
    };

    local cols = {
        {
            ["name"] = "Name",
            ["width"] = 200,
            ["align"] = "LEFT",
            ["color"] = color,
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["sortnext"] = 2,
        },
        {
            ["name"] = "Difficulty",
            ["width"] = 100,
            ["align"] = "LEFT",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["sortnext"] = 3,
            ["comparesort"] = function (stMain, rowa, rowb, col)
                local vala = 0 
                local valb = 0
                if string.sub(stMain.data[rowa].cols[col].value, 1, 1) == "R" then
                    for word in string.gmatch(stMain.data[rowa].cols[col].value, "%S+") do
                        if tonumber(word) then
                            vala = tonumber(word)
                        end
                    end
                    for word in string.gmatch(stMain.data[rowb].cols[col].value, "%S+") do
                        if tonumber(word) then
                            valb = tonumber(word)
                        end                
                    end
                    if sortdirection then
                        return vala < valb
                    else
                        return vala > valb
                    end
                else
                    if sortdirection then
                        return stMain.data[rowa].cols[col].value < stMain.data[rowb].cols[col].value
                    else
                        return stMain.data[rowa].cols[col].value > stMain.data[rowb].cols[col].value
                    end
                end
            end,        
        },
        {
            ["name"] = "Time",
            ["width"] = 60,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            
        },
        {
            ["name"] = "Item Value",
            ["width"] = 90,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["comparesort"] = function (stMain, rowa, rowb, col)
                local vala = 0 
                local valb = 0
                for word in string.gmatch(string.sub(stMain.data[rowa].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        vala = word
                    end
                end
                for word in string.gmatch(string.sub(stMain.data[rowb].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        valb = word
                    end                
                end
                if sortdirection then
                    return tonumber(vala) < tonumber(valb)
                else
                    return tonumber(vala) > tonumber(valb)
                end            
            end,        
        },
        {
            ["name"] = "Gold",
            ["width"] = 90,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["comparesort"] = function (stMain, rowa, rowb, col)
                local vala = 0 
                local valb = 0
                for word in string.gmatch(string.sub(stMain.data[rowa].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        vala = word
                    end
                end
                for word in string.gmatch(string.sub(stMain.data[rowb].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        valb = word
                    end                
                end
                if sortdirection then
                    return tonumber(vala) < tonumber(valb)
                else
                    return tonumber(vala) > tonumber(valb)
                end            
            end,        
        },
        {
            ["name"] = "Total",
            ["width"] = 90,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["comparesort"] = function (stMain, rowa, rowb, col)
                local vala = 0 
                local valb = 0
                for word in string.gmatch(string.sub(stMain.data[rowa].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        vala = word
                    end
                end
                for word in string.gmatch(string.sub(stMain.data[rowb].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        valb = word
                    end                
                end
                if sortdirection then
                    return tonumber(vala) < tonumber(valb)
                else
                    return tonumber(vala) > tonumber(valb)
                end            
            end,        
        },
        {
            ["name"] = "per hour",
            ["width"] = 90,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["comparesort"] = function (stMain, rowa, rowb, col)
                local vala = 0 
                local valb = 0
                for word in string.gmatch(string.sub(stMain.data[rowa].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        vala = word
                    end
                end
                for word in string.gmatch(string.sub(stMain.data[rowb].cols[col].value, 11, 100), "%S+") do
                    if tonumber(word) then
                        valb = word
                    end                
                end
                if sortdirection then
                    return tonumber(vala) < tonumber(valb)
                else
                    return tonumber(vala) > tonumber(valb)
                end            
            end,        
        },
        {
            ["name"] = "Kills",
            ["width"] = 82,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
        },
        {
            ["name"] = "per minute",
            ["width"] = 82,
            ["align"] = "CENTER",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
            ["comparesort"] = function (stMain, rowa, rowb, col)
                if sortdirection then
                    return tonumber(stMain.data[rowa].cols[col].value) < tonumber(stMain.data[rowb].cols[col].value)
                else
                    return tonumber(stMain.data[rowa].cols[col].value) > tonumber(stMain.data[rowb].cols[col].value)
                end           
            end,        
        },
    };
    stMain = ScrollingTable:CreateST(cols, 24, 23, nil, igtMainFrame);
    stMain.frame:SetPoint("CENTER", igtMainFrame, "CENTER", -1,-10)
    stMain:EnableSelection(true)

    --- SCROLLING TABLE ITEMS ---
    local ScrollingTable = LibStub("ScrollingTable");
    local color = { 
        ["r"] = 0.5,
        ["g"] = 0.5,
        ["b"] = 1.0,
        ["a"] = 1.0,
    };
    local bgcolor = { 
        ["r"] = 0.0,
        ["g"] = 0.0,
        ["b"] = 0.0,
        ["a"] = 0.0,
    };
    local highlight = { 
        ["r"] = 0.75,
        ["g"] = 0.75,
        ["b"] = 0.75,
        ["a"] = 0.1,
    };

    local cols = {
        {
            ["name"] = "Item",
            ["width"] = 200,
            ["align"] = "LEFT",
            ["color"] = color,
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
        },
        {
            ["name"] = " ",
            ["width"] = 52,
            ["align"] = "RIGHT",
            ["highlight"] = highlight,
            ["bgcolor"] = bgcolor,
            ["defaultsort"] = "dsc",
        },


    };

    stItems = ScrollingTable:CreateST(cols, 24, 23, nil, igtDungeonFrame);
    stItems.frame:SetPoint("CENTER", igtDungeonFrame, "CENTER", -1,-10)

    --- ON CLICK ---
    stMain:RegisterEvents({
    ["OnClick"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button, ...)
        local shift_key = IsShiftKeyDown()
        if shift_key and maintable == 1 then
            if tonumber(table_map[getindexofentry(realrow)]) then
                local x = tonumber(string.sub(table_coordinates[getindexofentry(realrow)], 0, string.find(table_coordinates[getindexofentry(realrow)], "-")-2))/100
                local y = tonumber(string.sub(table_coordinates[getindexofentry(realrow)], string.find(table_coordinates[getindexofentry(realrow)], "-")+2))/100
                local map=table_map[getindexofentry(realrow)];

                C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(map,x,y));
                local hyperlink = C_Map.GetUserWaypointHyperlink()
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                print("Map pin created", C_Map.GetUserWaypointHyperlink())
            else
                print("No coordinates saved for this run")
            end
        end
        if button == "LeftButton" and row then
            local ihatemylife = 1
            if maintable == 0 then
                local currentrow = realrow
                if currentrow == stMain:GetSelection() then
                    igtDungeonFrame:Hide()
                end
                if currentrow then
                    currententry = currentrow
                    setTableData(currentrow)
                end
            ihatemylife = 0
            else
                if realrow then
                    igtDungeonFrame:Show()
                    setItemTableData(getindexofentry(realrow))
                end
            end
        else
            local sortdirection = not sortdirection
        end
        stMain:ClearSelection()
    end,
    ["OnMouseUp"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button, ...)
        --stMain:ClearSelection()
    end,
    ["OnEnter"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
        if stMain:GetSelection()then
            if realrow then
                GameTooltip:SetOwner(TargetFrame, "ANCHOR_CURSOR")
                if tonumber(table_map[getindexofentry(realrow)]) then
                    GameTooltip:SetText("|cFFFFFF00Character: |cffffffff" .. table_Character_Name[getindexofentry(realrow)] .. "\n" .. 
                    "|cFFFFFF00Class: |cffffffff" .. table_Character_Class[getindexofentry(realrow)] .. "\n" .. 
                    "|cFFFFFF00Date: |cffffffff" .. table_Date[getindexofentry(realrow)] .. "\n" ..
                    "|cFFFFFF00Location: |cffffffff" .. C_Map.GetMapInfo(table_map[getindexofentry(realrow)]).name .. " - ".. table_coordinates[getindexofentry(realrow)] .. "\n\n" .. 
                    "|cff1eff00Shift + Left Click: Set map pin at location")
                else
                    GameTooltip:SetText("|cFFFFFF00Character: |cffffffff" .. table_Character_Name[getindexofentry(realrow)] .. "\n" .. 
                    "|cFFFFFF00Class: |cffffffff" .. table_Character_Class[getindexofentry(realrow)] .. "\n" .. 
                    "|cFFFFFF00Date: |cffffffff" .. table_Date[getindexofentry(realrow)] .. "\n" ..
                    "|cFFFFFF00Location: |cffffffff" .. table_coordinates[getindexofentry(realrow)] .. "\n")
                end
            end
        end
    end,

    ["OnLeave"] = function(realrow)
        GameTooltip:Hide()
    end
    });
    stItems:RegisterEvents({
    ["OnClick"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, button, ...)
        if button == "LeftButton" and row then
            DressUpItemLink(data[realrow].cols[1].value)
        end
    end,
    });

    --- TOOLTIP ---
    stItems:RegisterEvents({
        ["OnEnter"] = function (rowFrame, cellFrame, data, cols, row, realrow, column, scrollingTable, ...)
            if stMain:GetSelection() and table_LootedItems[getindexofentry(stMain:GetSelection())][realrow] ~= "No items recorded." then
                if realrow then
                    GameTooltip:SetOwner(TargetFrame, "ANCHOR_CURSOR")
                    GameTooltip:SetHyperlink(table_LootedItems[getindexofentry(stMain:GetSelection())][realrow])
                    GameTooltip:Show()
                end
            end
        end,

        ["OnLeave"] = function(realrow)
            GameTooltip:Hide()
        end
    });

    setframecolors(Rmain, Gmain, Bmain, Amain)
end
--- SLASH COMMANDS ---
SLASH_OPENFRAME1 = "/igt"
SlashCmdList.OPENFRAME = function(arg)
    if build_done then
        openigt()
    else
        MyAddon:Print("|cFFFF0000Collecting item and price data, please wait! - " .. build_percent .. "%")
    end
end

SLASH_TEST1 = "/igttest"
SlashCmdList.TEST = function(arg)
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo("|cffa335ee|Hitem:190597::::::::60:253::28:3:8142:6652:1488:1:28:2057:::::|h[Symbol of the Lupine]|h|r")
    MyAddon:Print(itemName, itemLink, itemSellPrice)
    if (IsAddOnLoaded("TradeSkillMaster")) then
        if TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)")) and CustomPrice ~= "vendorsell" and (itemRarity > 1 or itemType == "Tradeskill") then
            itemSellPrice = TSM_API.GetCustomPriceValue(CustomPrice, "i:"..string.match(itemLink, "item:(%d*)"))
            MyAddon:Print(itemSellPrice)
        end
    end
end

SLASH_CUSTOMFARM1 = "/igtcustom"
SlashCmdList.CUSTOMFARM = function(arg)
    local inInstance, instanceType = IsInInstance()
    if inInstance then
        MyAddon:Print("|cFFFF0000Cannot start Custom Farm in instance")
    else
        tt_start = GetTime()
        tt_pause = 0
        intgoldvalue = 0
        intlootvalue = 0
        inttotalvalue = 0
        looted_money_total = 0
        sell_value_total = 0
        igtCustomFrame.goldvalue1:SetText(CopperToGold(0))
        igtCustomFrame.lootvalue1:SetText(CopperToGold(0))
        igtCustomFrame.totalvalue1:SetText(CopperToGold(0))
        CustomLootedItems = {}
        CustomLootedItemsQuantity = {}
        reset_instance(0)
        toggleFrame(igtCustomFrame)
        killcount = 0
    end
end