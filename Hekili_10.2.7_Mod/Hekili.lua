
local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )
Hekili.Version = GetAddOnMetadata( "Hekili", "Version" )
Hekili.Flavor = GetAddOnMetadata( "Hekili", "X-Flavor" ) or "Retail"

local format = string.format
local insert, concat = table.insert, table.concat

local buildStr, _, _, buildNum = GetBuildInfo()

Hekili.CurrentBuild = buildNum

if Hekili.Version == ( "@" .. "project-version" .. "@" ) then
    Hekili.Version = format( "Dev-%s (%s)", buildStr, date( "%Y%m%d" ) )
    Hekili.IsDev = true
end

Hekili.AllowSimCImports = true

Hekili.IsRetail = function()
    return Hekili.Flavor == "Retail"
end

Hekili.IsWrath = function()
    return Hekili.Flavor == "Wrath"
end

Hekili.IsClassic = function()
    return Hekili.IsWrath()
end

Hekili.IsDragonflight = function()
    return buildNum >= 100000
end

Hekili.BuiltFor = 100205
Hekili.GameBuild = buildStr

ns.PTR = buildNum > 100205


ns.Patrons = "|cFFFFD100Current Status|r\n\n"
    .. "All existing specializations are currently supported, though healer priorities are experimental and focused on rotational DPS only.\n\n"
    .. "If you find odd recommendations or other issues, please follow the |cFFFFD100Issue Reporting|r link below and submit all the necessary information to have your issue investigated.\n\n"
    .. "Please do not submit tickets for routine priority updates (i.e., from SimulationCraft).  I will routinely update those when they are published.  Thanks!"

do
    local cpuProfileDB = {}

    function Hekili:ProfileCPU( name, func )
        cpuProfileDB[ name ] = func
    end

	ns.cpuProfile = cpuProfileDB


	local frameProfileDB = {}

	function Hekili:ProfileFrame( name, f )
		frameProfileDB[ name ] = f
	end

	ns.frameProfile = frameProfileDB
end


ns.lib = {
    Format = {}
}


-- 04072017:  Let's go ahead and cache aura information to reduce overhead.
ns.auras = {
    target = {
        buff = {},
        debuff = {}
    },
    player = {
        buff = {},
        debuff = {}
    }
}

Hekili.Class = {
    specs = {},
    num = 0,

    file = "NONE",
    initialized = false,

	resources = {},
	resourceAuras = {},
    talents = {},
    pvptalents = {},
	auras = {},
	auraList = {},
    powers = {},
	gear = {},
    setBonuses = {},

	knownAuraAttributes = {},

    stateExprs = {},
    stateFuncs = {},
    stateTables = {},

	abilities = {},
	abilityByName = {},
    abilityList = {},
    itemList = {},
    itemMap = {},
    itemPack = {
        lists = {
            items = {}
        }
    },

    packs = {},

    pets = {},
    totems = {},

    potions = {},
    potionList = {},

	hooks = {},
    range = 8,
	settings = {},
    stances = {},
	toggles = {},
	variables = {},
}

Hekili.Scripts = {
    DB = {},
    Channels = {},
    PackInfo = {},
}

Hekili.State = {}

ns.hotkeys = {}
ns.keys = {}
ns.queue = {}
ns.targets = {}
ns.TTD = {}

ns.UI = {
    Displays = {},
    Buttons = {}
}

ns.debug = {}
ns.snapshots = {}


function Hekili:Query( ... )
	local output = ns

	for i = 1, select( '#', ... ) do
		output = output[ select( i, ... ) ]
    end

    return output
end


function Hekili:Run( ... )
	local n = select( "#", ... )
	local fn = select( n, ... )

	local func = ns

	for i = 1, fn - 1 do
		func = func[ select( i, ... ) ]
    end

    return func( select( fn, ... ) )
end


local debug = ns.debug
local active_debug
local current_display

local lastIndent = 0

function Hekili:SetupDebug( display )
    if not self.ActiveDebug then return end
    if not display then return end

    current_display = display

    debug[ current_display ] = debug[ current_display ] or {
        log = {},
        index = 1
    }
    active_debug = debug[ current_display ]
	active_debug.index = 1

	lastIndent = 0

	local pack = self.State.system.packName

    if not pack then return end

	self:Debug( "New Recommendations for [ %s ] requested at %s ( %.2f ); using %s( %s ) priority.", display, date( "%H:%M:%S"), GetTime(), self.DB.profile.packs[ pack ].builtIn and "built-in " or "", pack )
end


function Hekili:Debug( ... )
    if not self.ActiveDebug then return end
	if not active_debug then return end

	local indent, text = ...
	local start

	if type( indent ) ~= "number" then
		indent = lastIndent
		text = ...
		start = 2
	else
		lastIndent = indent
		start = 3
	end

	local prepend = format( indent > 0 and ( "%" .. ( indent * 4 ) .. "s" ) or "%s", "" )
	text = text:gsub("\n", "\n" .. prepend )
    text = format( "%" .. ( indent > 0 and ( 4 * indent ) or "" ) .. "s", "" ) .. text

    if select( start, ... ) ~= nil then
	    active_debug.log[ active_debug.index ] = format( text, select( start, ... ) )
    else
        active_debug.log[ active_debug.index ] = text
    end
    active_debug.index = active_debug.index + 1
end


local snapshots = ns.snapshots
local hasScreenshotted = false

function Hekili:SaveDebugSnapshot( dispName )
    local snapped = false
    local formatKey = ns.formatKey
    local state = Hekili.State

	for k, v in pairs( debug ) do
		if not dispName or dispName == k then
			for i = #v.log, v.index, -1 do
				v.log[ i ] = nil
			end

            -- Store aura data.
            local auraString = "\nplayer_buffs:"
            local now = GetTime()

            local class = Hekili.Class

            for i = 1, 40 do
                local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitBuff( "player", i )

                if not name then break end

                local aura = class.auras[ spellId ]
                local key = aura and aura.key
                if key and not state.auras.player.buff[ key ] then key = key .. " [MISSING]" end

                auraString = format( "%s\n   %6d - %-40s - %3d - %-6.2f", auraString, spellId, key or ( "*" .. formatKey( name ) ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
            end

            auraString = auraString .. "\n\nplayer_debuffs:"

            for i = 1, 40 do
                local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitDebuff( "player", i )

                if not name then break end

                local aura = class.auras[ spellId ]
                local key = aura and aura.key
                if key and not state.auras.player.debuff[ key ] then key = key .. " [MISSING]" end

                auraString = format( "%s\n   %6d - %-40s - %3d - %-6.2f", auraString, spellId, key or ( "*" .. formatKey( name ) ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
            end


            if not UnitExists( "target" ) then
                auraString = auraString .. "\n\ntarget_auras:  target does not exist"
            else
                auraString = auraString .. "\n\ntarget_buffs:"

                for i = 1, 40 do
                    local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitBuff( "target", i )

                    if not name then break end

                    local aura = class.auras[ spellId ]
                    local key = aura and aura.key
                    if key and not state.auras.target.buff[ key ] then key = key .. " [MISSING]" end

                    auraString = format( "%s\n   %6d - %-40s - %3d - %-6.2f", auraString, spellId, key or ( "*" .. formatKey( name ) ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
                end

                auraString = auraString .. "\n\ntarget_debuffs:"

                for i = 1, 40 do
                    local name, _, count, debuffType, duration, expirationTime, source, _, _, spellId, canApplyAura, isBossDebuff, castByPlayer = UnitDebuff( "target", i, "PLAYER" )

                    if not name then break end

                    local aura = class.auras[ spellId ]
                    local key = aura and aura.key
                    if key and not state.auras.target.debuff[ key ] then key = key .. " [MISSING]" end

                    auraString = format( "%s\n   %6d - %-40s - %3d - %-6.2f", auraString, spellId, key or ( "*" .. formatKey( name ) ), count > 0 and count or 1, expirationTime > 0 and ( expirationTime - now ) or 3600 )
                end
            end

            auraString = auraString .. "\n\n"

            insert( v.log, 1, auraString )
            insert( v.log, 1, "targets:  " .. ( Hekili.TargetDebug or "no data" ) )
            insert( v.log, 1, self:GenerateProfile() )

            local custom = ""

            local pack = self.DB.profile.packs[ state.system.packName ]
            if not pack.builtIn then
                custom = format( " |cFFFFA700(Custom: %s[%d])|r", state.spec.name, state.spec.id )
            end

            local overview = format( "%s%s; %s|r", state.system.packName, custom, dispName or state.display )
            local recs = Hekili.DisplayPool[ dispName or state.display ].Recommendations

            for i, rec in ipairs( recs ) do
                if not rec.actionName then
                    if i == 1 then
                        overview = format( "%s - |cFF666666N/A|r", overview )
                    end
                    break
                end
                overview = format( "%s%s%s|cFFFFD100(%0.2f)|r", overview, ( i == 1 and " - " or ", " ), class.abilities[ rec.actionName ].name, rec.time )
            end

            insert( v.log, 1, overview )

            local snap = {
                header = "|cFFFFD100[" .. date( "%H:%M:%S" ) .. "]|r " .. overview,
                log = concat( v.log, "\n" ),
                data = ns.tableCopy( v.log ),
                recs = {}
            }

            insert( snapshots, snap )
            snapped = true
		end
    end

    -- Limit screenshot to once per login.
    if snapped then
        if Hekili.DB.profile.screenshot and not hasScreenshotted then
            Screenshot()
            hasScreenshotted = true
        end
        return true
    end

    return false
end

Hekili.Snapshots = ns.snapshots



ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )
Hekili:ProfileFrame( "HekiliTooltip", ns.Tooltip )

-- PIXEL BRIDGE [Dragonflight 10.2.7 EDITION]
local function CreateBridge()
    if HekiliBridgeFrame then HekiliBridgeFrame:Hide() end

    local f = CreateFrame("Frame", "HekiliBridgeFrame", UIParent)
    f:SetSize(3, 3)
    f:SetPoint("TOPLEFT", 0, 0)
    f:SetFrameStrata("TOOLTIP")
    f:SetFrameLevel(9999)
    f.tex = f:CreateTexture()
    f.tex:SetAllPoints()

    local CAST_QUEUE = 0.2

	local KEY_MAP = {
        ["1"]=1, ["2"]=2, ["3"]=3, ["4"]=4, ["5"]=5, ["6"]=6, ["7"]=7, ["8"]=8, ["9"]=9, ["0"]=10,
        ["Q"]=11, ["W"]=12, ["E"]=13, ["R"]=14, ["T"]=15, ["Y"]=16, ["U"]=17, ["I"]=18, ["O"]=19, ["P"]=20,
        ["A"]=21, ["S"]=22, ["D"]=23, ["F"]=24, ["G"]=25, ["H"]=26, ["J"]=27, ["K"]=28, ["L"]=29,
        ["Z"]=30, ["X"]=31, ["C"]=32, ["V"]=33, ["B"]=34, ["N"]=35, ["M"]=36,
        ["F1"]=37, ["F2"]=38, ["F3"]=39, ["F4"]=40, ["F5"]=41, ["F6"]=42, ["F7"]=43, ["F8"]=44, ["F9"]=45,
        ["-"]=46, ["="]=47, ["`"]=48,
        ["["]=49, ["]"]=50, [";"]=51, ["'"]=52, [","]=53, ["."]=54, ["/"]=55, ["\\"]=56,
        ["F10"]=57, ["F11"]=58, ["F12"]=59,
    }
    
    local MOD_MAP = { ["S"]=1, ["C"]=2, ["A"]=3, ["SC"]=4, ["SA"]=5, ["CA"]=6 }

    f:SetScript("OnUpdate", function(self)
        self.tex:SetColorTexture(1, 0, 1, 1)

        local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo("player")
        if name then
            local finish = endTime / 1000
            local remain = finish - GetTime()
            if remain > CAST_QUEUE then return end
        end

        if UnitChannelInfo("player") then return end

        local rec = nil
        
        if not ns or not ns.UI or not ns.UI.Displays then return end

        local displayPriority = { "Primary", "AOE", "Single", "Cooldowns", "Defensives", "Interrupts" }
        
        for _, displayName in ipairs(displayPriority) do
            if ns.UI.Displays[displayName] and 
               ns.UI.Displays[displayName].Recommendations and 
               ns.UI.Displays[displayName].Recommendations[1] then
                rec = ns.UI.Displays[displayName].Recommendations[1]
                break
            end
        end

        if not rec then
            for _, display in pairs(ns.UI.Displays) do
                 if display.Recommendations and display.Recommendations[1] then
                     rec = display.Recommendations[1]
                     break
                 end
            end
        end

        if not rec then return end
        
        if not UnitExists("target") or UnitIsDead("target") or UnitIsFriend("player", "target") then return end

        local bind = rec.keybind
        
        if not bind or bind == "" then return end

        bind = bind:upper()
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
loader:SetScript("OnEvent", function(self) 
    self:UnregisterAllEvents()
    C_Timer.After(3, CreateBridge) 
end)
