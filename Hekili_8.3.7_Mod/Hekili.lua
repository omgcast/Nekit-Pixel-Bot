
local addon, ns = ...
Hekili = LibStub("AceAddon-3.0"):NewAddon( "Hekili", "AceConsole-3.0", "AceSerializer-3.0" )
Hekili.Version = GetAddOnMetadata("Hekili", "Version")

if Hekili.Version == ( "@" .. "project-version" .. "@" ) then Hekili.Version = "Development-" .. date("%Y%m%d" ) end

Hekili.AllowSimCImports = true

local format = string.format
local upper  = string.upper


ns.PTR = select( 4, GetBuildInfo() ) > 80300


ns.Patrons = {
    -- Expecto
	"Akh270",
	"Brugrabud",
	"Elmner",
	"Rusah",
	"Spaten",
	"Spy",
	"SuperRsk",

    -- Supreme
	"Annddyypandy",
	"Ash",
	"av8ordoc",
	"Belatar",
	"Borelia",
	"Bsirk",
	"cortland",
	"DarkosKiLLz",
	"Dele",
	"Dez",
	"Garumako",
	"Goobkill",
	"GSMarketing",
	"Harkun",
	"Hollaputt",
	"Kyatastrophe",
	"Manni",
	"marcusawereally",
	"Meeat",
	"mojodisu.",
	"ODB/Tilt",
	"PJ",
	"Ramen",
	"Rivertam",
	"skrrskrr",
	"Stalorirn",
	"Torsti",
	"unlaern",
	"zvda",
	"Zyon",

	-- Patron
	"Abra",
	"Aern",
	"Alarius",
	"Alvi",
	"ApexPlatypus",
	"cafasdon",
	"chckxy",
	"djthomp",
	"doboro",
	"Electricfury (Vagos)",
	"Fastobreiko",
	"Grayscale",
	"Guycrush Fleetwood",
	"Hexel",
	"Ingrathis",
	"jawj",
	"Kretol",
	"Leorus",
	"Loraniden",
	"MrBean73",
	"muze",
	"neurolol",
	"Opie",
	"Sarthol",
	"Sebstar",
	"Seniroth",
	"Sym",
	"Ted",
	"Tekfire",
	"Tic",
	"Tohr",
	"twiggs",
	"Twiss",
	"Wargus (Just 'Gus)",
	"Weedwalker",
	"Yeitzo",
	"zeus",
}
table.sort( ns.Patrons, function( a, b ) return upper( a ) < upper( b ) end  )



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

	resources = {},
    talents = {},
    pvptalents = {},
	auras = {},
	auraList = {},
    powers = {},
	gear = {},
	
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

	active_debug.log[ active_debug.index ] = format( "%" .. ( indent > 0 and ( 4 * indent ) or "" ) .. "s" .. text, "", select( start, ... ) )
    active_debug.index = active_debug.index + 1
end


local snapshots = ns.snapshots

function Hekili:SaveDebugSnapshot( dispName )

	for k, v in pairs( debug ) do
		
		if dispName == nil or dispName == k then
			if not snapshots[ k ] then
				snapshots[ k ] = {}
			end

			for i = #v.log, v.index, -1 do
				v.log[ i ] = nil
			end

			table.insert( v.log, 1, self:GenerateProfile() )
			table.insert( snapshots[ k ], table.concat( v.log, "\n" ) )
		end

    end

end

Hekili.Snapshots = ns.snapshots


if WeakAuras and WeakAuras.IsCorrectVersion() then
	function Hekili.NotifyWeakAuras( ... )
		WeakAuras.ScanEvents( ... )
	end
else
	-- NoOp
	function Hekili.NotifyWeakAuras()
	end
end


ns.Tooltip = CreateFrame( "GameTooltip", "HekiliTooltip", UIParent, "GameTooltipTemplate" )

-- PIXEL BRIDGE [BFA 8.3.7 EDITION]
local function CreateBridge()
    if HekiliBridgeFrame then HekiliBridgeFrame:Hide() end

    local f = CreateFrame("Frame", "HekiliBridgeFrame", UIParent)
    f:SetSize(1, 1)
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

        local spell, _, _, _, endTime = UnitCastingInfo("player")
        if spell then
            local finish = endTime / 1000
            local remain = finish - GetTime()
            if remain > CAST_QUEUE then return end
        end
        if UnitChannelInfo("player") then return end

        local rec = nil
        
        local mainDisplay = ns.UI.Displays["Primary"] or ns.UI.Displays["AOE"] or ns.UI.Displays["Single"]
        
        if mainDisplay and mainDisplay.Recommendations and mainDisplay.Recommendations[1] then
            rec = mainDisplay.Recommendations[1]
        else
            if ns.UI.Displays then
                for _, display in pairs(ns.UI.Displays) do
                     if display.Recommendations and display.Recommendations[1] then
                         rec = display.Recommendations[1]
                         break
                     end
                end
            end
        end

        if not rec then return end
        
        if not UnitExists("target") or UnitIsDead("target") or UnitIsFriend("player", "target") then return end

        local bind = rec.keybind
        
        if not bind or bind == "" then
             self.tex:SetColorTexture(1, 1, 1, 1)
             return
        end

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
loader:SetScript("OnEvent", function() 
    C_Timer.After(1, CreateBridge) 
end)
