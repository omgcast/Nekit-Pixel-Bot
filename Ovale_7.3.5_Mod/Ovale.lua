local __exports = LibStub:NewLibrary("ovale/Ovale", 10000)
if not __exports then return end
local __class = LibStub:GetLibrary("tslib").newClass
local __Localization = LibStub:GetLibrary("ovale/Localization")
local L = __Localization.L
local __tsaddon = LibStub:GetLibrary("tsaddon", true)
local NewAddon = __tsaddon.NewAddon
local aceEvent = LibStub:GetLibrary("AceEvent-3.0", true)
local ipairs = ipairs
local pairs = pairs
local select = select
local strjoin = strjoin
local tostring = tostring
local tostringall = tostringall
local wipe = wipe
local _G = _G
local format = string.format
local find = string.find
local len = string.len
local UnitClass = UnitClass
local UnitGUID = UnitGUID
local UnitChannelInfo = UnitChannelInfo
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local huge = math.huge
local self_oneTimeMessage = {}
local MAX_REFRESH_INTERVALS = 500
local self_refreshIntervals = {}
local self_refreshIndex = 1
__exports.MakeString = function(s, ...)
    if s and len(s) > 0 then
        if ... then
            if find(s, "%%%.%d") or find(s, "%%[%w]") then
                s = format(s, tostringall(...))
            else
                s = strjoin(" ", s, tostringall(...))
            end
        end
    else
        s = tostring(nil)
    end
    return s
end
local OvaleBase = NewAddon("Ovale", aceEvent)
local OvaleClass = __class(OvaleBase, {
    constructor = function(self)
        self.playerClass = select(2, UnitClass("player"))
        self.playerGUID = nil
        self.db = nil
        self.refreshNeeded = {}
        self.MSG_PREFIX = "Ovale"
        OvaleBase.constructor(self)
        _G["BINDING_HEADER_OVALE"] = "Ovale"
        local toggleCheckBox = L["Inverser la boîte à cocher "]
        _G["BINDING_NAME_OVALE_CHECKBOX0"] = toggleCheckBox .. "(1)"
        _G["BINDING_NAME_OVALE_CHECKBOX1"] = toggleCheckBox .. "(2)"
        _G["BINDING_NAME_OVALE_CHECKBOX2"] = toggleCheckBox .. "(3)"
        _G["BINDING_NAME_OVALE_CHECKBOX3"] = toggleCheckBox .. "(4)"
        _G["BINDING_NAME_OVALE_CHECKBOX4"] = toggleCheckBox .. "(5)"
    end,
    OnInitialize = function(self)
        self.playerGUID = UnitGUID("player")
        wipe(self_refreshIntervals)
        self_refreshIndex = 1
        self:ClearOneTimeMessages()
    end,
    needRefresh = function(self)
        if self.playerGUID then
            self.refreshNeeded[self.playerGUID] = true
        end
    end,
    AddRefreshInterval = function(self, milliseconds)
        if milliseconds < huge then
            self_refreshIntervals[self_refreshIndex] = milliseconds
            self_refreshIndex = (self_refreshIndex < MAX_REFRESH_INTERVALS) and (self_refreshIndex + 1) or 1
        end
    end,
    GetRefreshIntervalStatistics = function(self)
        local sumRefresh, minRefresh, maxRefresh, count = 0, huge, 0, 0
        for _, v in ipairs(self_refreshIntervals) do
            if v > 0 then
                if minRefresh > v then
                    minRefresh = v
                end
                if maxRefresh < v then
                    maxRefresh = v
                end
                sumRefresh = sumRefresh + v
                count = count + 1
            end
        end
        local avgRefresh = (count > 0) and (sumRefresh / count) or 0
        return avgRefresh, minRefresh, maxRefresh, count
    end,
    OneTimeMessage = function(self, ...)
        local s = __exports.MakeString(...)
        if  not self_oneTimeMessage[s] then
            self_oneTimeMessage[s] = true
        end
    end,
    ClearOneTimeMessages = function(self)
        wipe(self_oneTimeMessage)
    end,
    PrintOneTimeMessages = function(self)
        for s in pairs(self_oneTimeMessage) do
            if self_oneTimeMessage[s] ~= "printed" then
                self:Print(s)
                self_oneTimeMessage[s] = "printed"
            end
        end
    end,
    Print = function(self, ...)
        local s = __exports.MakeString(...)
        DEFAULT_CHAT_FRAME:AddMessage(format("|cff33ff99%s|r: %s", self:GetName(), s))
    end,
})
__exports.Ovale = OvaleClass()

-- =========================================================
local Bridge = CreateFrame("Frame", "OvaleBridgeFrame", UIParent)
Bridge:SetSize(3, 3)
Bridge:SetPoint("TOPLEFT", 0, 0)
Bridge:SetFrameStrata("TOOLTIP")
Bridge:SetFrameLevel(9999)
Bridge.tex = Bridge:CreateTexture()
Bridge.tex:SetAllPoints()
Bridge.tex:SetColorTexture(1, 0, 1, 1)

local KEY_MAP = {
    ["1"]=1, ["2"]=2, ["3"]=3, ["4"]=4, ["5"]=5, ["6"]=6, ["7"]=7, ["8"]=8, ["9"]=9, ["0"]=10,
    ["Q"]=11, ["W"]=12, ["E"]=13, ["R"]=14, ["T"]=15, ["Y"]=16, ["U"]=17, ["I"]=18, ["O"]=19, ["P"]=20,
    ["A"]=21, ["S"]=22, ["D"]=23, ["F"]=24, ["G"]=25, ["H"]=26, ["J"]=27, ["K"]=28, ["L"]=29,
    ["Z"]=30, ["X"]=31, ["C"]=32, ["V"]=33, ["B"]=34, ["N"]=35, ["M"]=36,
    ["F1"]=37, ["F2"]=38, ["F3"]=39, ["F4"]=40, ["F5"]=41, ["F6"]=42, ["F7"]=43, ["F8"]=44, ["F9"]=45,
    ["-"]=46, ["="]=47, ["`"]=48,
    ["["]=49, ["]"]=50, [";"]=51, ["'"]=52, [","]=53, ["."]=54, ["/"]=55, ["\\"]=56,
    ["F10"]=57, ["F11"]=58, ["F12"]=59
}

local MOD_MAP = { ["S"]=1, ["C"]=2, ["A"]=3, ["SC"]=4, ["SA"]=5, ["CA"]=6 }

local KeyToSlot = {}
local SlotToKey = {}
local TextureToKey = {}

local function UpdateKeyToSlot()
    wipe(KeyToSlot)
    wipe(SlotToKey)
    wipe(TextureToKey)
    for i = 1, 120 do
        local bind = nil
        if i <= 12 then bind = GetBindingKey("ACTIONBUTTON"..i)
        elseif i <= 24 then bind = GetBindingKey("MULTIACTIONBAR1BUTTON"..(i-12))
        elseif i <= 36 then bind = GetBindingKey("MULTIACTIONBAR2BUTTON"..(i-24))
        elseif i <= 48 then bind = GetBindingKey("MULTIACTIONBAR3BUTTON"..(i-36))
        elseif i <= 60 then bind = GetBindingKey("MULTIACTIONBAR4BUTTON"..(i-48))
        elseif i <= 72 then bind = GetBindingKey("MULTIACTIONBAR5BUTTON"..(i-60))
        elseif i <= 84 then bind = GetBindingKey("MULTIACTIONBAR6BUTTON"..(i-72))
        end
        
        if bind then
            local clean = bind:upper():gsub("%s+", ""):gsub("SHIFT", "S"):gsub("CTRL", "C"):gsub("ALT", "A"):gsub("NUMPAD", "NUMPAD")
            local keyOnly = clean:match("%-(.+)") or clean
            if KEY_MAP[keyOnly] then
                KeyToSlot[clean] = i
                SlotToKey[i] = clean
                
                local actionTex = GetActionTexture(i)
                if actionTex then
                    local sTex = tostring(actionTex):lower()
                    if not TextureToKey[sTex] then
                        TextureToKey[sTex] = clean
                    end
                end
            end
        end
    end
end

Bridge:RegisterEvent("UPDATE_BINDINGS")
Bridge:RegisterEvent("PLAYER_ENTERING_WORLD")
Bridge:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
Bridge:RegisterEvent("SPELLS_CHANGED")
Bridge:SetScript("OnEvent", UpdateKeyToSlot)

local function FindBestKey(frame)
    if not frame then return nil end
    
    if frame.shortcut and frame.shortcut.GetText then
        local t = frame.shortcut:GetText()
        if t and t ~= "" then
            local clean = t:upper():gsub("%s+", ""):gsub("SHIFT", "S"):gsub("CTRL", "C"):gsub("ALT", "A"):gsub("NUMPAD", "NUMPAD")
            local keyOnly = clean:match("%-(.+)") or clean
            if KEY_MAP[keyOnly] then return clean end
        end
    end
    
    if frame.GetRegions then
        for _, region in ipairs({frame:GetRegions()}) do
            if region:GetObjectType() == "FontString" then
                local point = region:GetPoint()
                if point == "TOPRIGHT" or point == "TOPLEFT" or point == "TOP" or point == "BOTTOMRIGHT" then
                    local t = region:GetText()
                    if t and t ~= "" and string.len(t) < 6 and not t:find(":") and not t:find("%.") then
                        local clean = t:upper():gsub("%s+", ""):gsub("SHIFT", "S"):gsub("CTRL", "C"):gsub("ALT", "A"):gsub("NUMPAD", "NUMPAD")
                        local keyOnly = clean:match("%-(.+)") or clean
                        if KEY_MAP[keyOnly] then return clean end
                    end
                end
            end
        end
    end
    
    local sIcon = nil
    if frame.icon and frame.icon.GetTexture then sIcon = tostring(frame.icon:GetTexture()):lower() end
    if not sIcon and frame.Icon and frame.Icon.GetTexture then sIcon = tostring(frame.Icon:GetTexture()):lower() end
    if not sIcon and _G[frame:GetName() .. "Icon"] then
        local texG = _G[frame:GetName() .. "Icon"]
        if texG.GetTexture then sIcon = tostring(texG:GetTexture()):lower() end
    end
    
    if sIcon and TextureToKey[sIcon] then return TextureToKey[sIcon] end
    
    local children = { frame:GetChildren() }
    for _, child in ipairs(children) do
        local res = FindBestKey(child)
        if res then return res end
    end
    
    return nil
end

Bridge:SetScript("OnUpdate", function(self)
    self.tex:SetColorTexture(1, 0, 1, 1)

    if UnitChannelInfo and UnitChannelInfo("player") then return end
    if not UnitCanAttack("player", "target") or UnitIsDead("target") then return end

    local text = nil
    
    local frame = _G["Icon2n1"]
    if frame and frame:IsVisible() then
        text = FindBestKey(frame)
    end

    if not text then return end

    local keyStr = text
    local modStr = nil
    local dashInd = keyStr:find("-")
    
    if dashInd and dashInd > 1 and MOD_MAP[keyStr:sub(1, dashInd - 1)] then
        modStr = keyStr:sub(1, dashInd - 1)
        keyStr = keyStr:sub(dashInd + 1)
    end

    local kId = KEY_MAP[keyStr]
    local mId = 0
    if modStr then mId = MOD_MAP[modStr] or 0 end

    if kId and kId > 0 then
        self.tex:SetColorTexture(kId/255, mId/255, 1, 1)
    end
end)

print("|cff00ff00Ovale Pixel Bridge Loaded (Strict Icon2n1 + Channeling)|r")