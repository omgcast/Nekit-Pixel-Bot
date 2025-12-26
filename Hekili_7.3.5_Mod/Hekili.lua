local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )
Hekili.Version = GetAddOnMetadata("Hekili", "Version");

local format = string.format
local upper  = string.upper

ns.PTR = GetBuildInfo() ~= "7.3.2"

ns.Patrons = {
    "Alarius", "Alvi", "ApexPlatypus", "belashar", "Belatar", "Borelia", "Bsirk/Kris", "Dane", "Dez", "djthomp", "Drift", "FatIrishMidget", "Grayscale", "Harkun", "Ingrathis", "Issamonk", "jamie_cortez", "Jingy - Rekya", "kaernunnos", "Kingreboot", "Leorus", "Manni", "Mojolari中国", "Nikö", "Opie", "Ovaldo", "ralask", "Rusah", "Saijtas", "Shakeydev", "Spaten", "Theda99", "Tianzhun", "Tic[à]sentence", "Tilt", "Vagelis (Bougatsas)", "Wargus (Shagus)", "zenpox", "Z[EU]S", "Корнишон",
}
table.sort( ns.Patrons, function( a, b ) return upper( a ) < upper( b ) end )

ns.cpuProfile = {}
ns.lib = { Format = {} }

ns.auras = {
    target = { buff = {}, debuff = {} },
    player = { buff = {}, debuff = {} }
}

ns.class = {
    file = "NONE", abilities = {}, auras = {}, castExclusions = {}, resetCastExclusions = {},
    defaults = {}, exclusions = {}, gearsets = {}, glyphs = {}, hooks = {},
    incapacitates = {}, items = {}, perks = {}, range = 8, resources = {},
    resourceModels = {}, searchAbilities = {}, settings = {}, stances = {},
    talentLegendary = {}, talents = {}, toggles = {}
}

ns.hotkeys = {}
ns.keys = {}
ns.queue = {}
ns.scripts = { D = {}, P = {}, A = {} }
ns.state = {}
ns.targets = {}
ns.TTD = {}
ns.UI = { Displays = {}, Buttons = {} }
ns.debug = {}
ns.snapshots = {}

BINDING_HEADER_HEKILI_HEADER = "Hekili"
BINDING_NAME_HEKILI_TOGGLE_PAUSE = "Pause"
BINDING_NAME_HEKILI_SNAPSHOT = "Snapshot"
BINDING_NAME_HEKILI_TOGGLE_COOLDOWNS = "Toggle Cooldowns"
BINDING_NAME_HEKILI_TOGGLE_POTIONS = "Toggle Potions"
BINDING_NAME_HEKILI_TOGGLE_INTERRUPTS = "Toggle Interrupts"
BINDING_NAME_HEKILI_TOGGLE_MODE = "Toggle Mode"

function ns.refreshBindings()
    local profile = Hekili.DB.profile
    profile[ 'HEKILI_TOGGLE_MODE' ] = GetBindingKey( "HEKILI_TOGGLE_MODE" )
    profile[ 'HEKILI_TOGGLE_PAUSE' ] = GetBindingKey( "HEKILI_TOGGLE_PAUSE" )
    profile[ 'HEKILI_TOGGLE_COOLDOWNS' ] = GetBindingKey( "HEKILI_TOGGLE_COOLDOWNS" )
    profile[ 'HEKILI_TOGGLE_POTIONS' ] = GetBindingKey( "HEKILI_TOGGLE_POTIONS" )
end

function Hekili:Query( ... )
	local output = ns
	for i = 1, select( '#', ... ) do output = output[ select( i, ... ) ] end
    return output
end

function Hekili:Run( ... )
	local n = select( "#", ... )
	local fn = select( n, ... )
	local func = ns
	for i = 1, fn - 1 do func = func[ select( i, ... ) ] end
    return func( select( fn, ... ) )
end

ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )

-- PIXEL BRIDGE [Legion 7.3.5 EDITION]
local function CreateBridge()
    if HekiliBridgeFrame then HekiliBridgeFrame:Hide() end
    
    local f = CreateFrame("Frame", "HekiliBridgeFrame", UIParent)
    f:SetSize(3, 3) 
    f:SetPoint("TOPLEFT", 0, 0) 
    f:SetFrameStrata("TOOLTIP")
    f:SetFrameLevel(9999)
    f.tex = f:CreateTexture()
    f.tex:SetAllPoints()

    local KEY_MAP = {
        ["1"]=1, ["2"]=2, ["3"]=3, ["4"]=4, ["5"]=5, ["6"]=6, ["7"]=7, ["8"]=8, ["9"]=9, ["0"]=10,
        ["Q"]=11, ["W"]=12, ["E"]=13, ["R"]=14, ["T"]=15, ["Y"]=16, ["U"]=17, ["I"]=18, ["O"]=19, ["P"]=20,
        ["A"]=21, ["S"]=22, ["D"]=23, ["F"]=24, ["G"]=25, ["H"]=26, ["J"]=27, ["K"]=28, ["L"]=29,
        ["Z"]=30, ["X"]=31, ["C"]=32, ["V"]=33, ["B"]=34, ["N"]=35, ["M"]=36,
        ["F1"]=37, ["F2"]=38, ["F3"]=39, ["F4"]=40, ["F5"]=41, ["F6"]=42, ["F7"]=43, ["F8"]=44, ["F9"]=45,
        ["-"]=46, ["="]=47, ["`"]=48
    }
    local MOD_MAP = { ["S"]=1, ["C"]=2, ["A"]=3, ["SC"]=4, ["SA"]=5, ["CA"]=6 }

    f:SetScript("OnUpdate", function(self)
        local data = nil
        
        if ns.UI and ns.UI.Displays then
            for i = 1, #ns.UI.Displays do
                local display = ns.UI.Displays[i]
                if display and display:IsShown() and display.Recommendations and display.Recommendations[1] then
                    local rec = display.Recommendations[1]
                    if rec.actionName and rec.actionName ~= "" then
                        data = rec
                        break 
                    end
                end
            end
        end

        if not UnitExists("target") or UnitIsDead("target") or UnitIsFriend("player", "target") or UnitIsUnit("player", "target") then
            self.tex:SetColorTexture(1, 0, 1, 1) 
            return
        end

        if not data then
            self.tex:SetColorTexture(1, 0, 1, 1) 
            return
        end

        if UnitChannelInfo("player") or UnitCastingInfo("player") then
            self.tex:SetColorTexture(1, 0, 1, 1)
            return
        end

        local bind = (data.keybind or ""):upper()
        local mod, key = bind:match("([^%-]+)%-(.+)")
        if not key then key = bind end
        
        local kId = KEY_MAP[key] or 0
        local mId = MOD_MAP[mod] or 0

        if kId > 0 then
            self.tex:SetColorTexture(kId/255, mId/255, 1, 1) 
        else
            self.tex:SetColorTexture(1, 1, 1, 1) 
        end
    end)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_ENTERING_WORLD")
loader:SetScript("OnEvent", function() CreateBridge() end)