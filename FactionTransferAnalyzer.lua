--[[

************************************************************************

FactionTransferAnalyzer.lua

File date: @file-date-iso@
File revision: @file-revision@
Project revision: @project-revision@
Project version: @project-version@

Author: Ackis

************************************************************************

Please see http://www.wowace.com/projects/faction-transfer-analyzer/for more information.

License:
	Please see LICENSE.txt

This source code is released under All Rights Reserved.

************************************************************************

--]]

--- **Faction Transfer Analyzer** provides you with information on what will occur should you
-- transfer factions with the current character.  Essentially it automates the comparison from
-- the site http://www.worldofwarcraft.com/info/faction-change/index.xml for you.
-- @class file
-- @name FactionTransferAnalyzer.lua
-- @release 1.0

local LibStub = LibStub

local MODNAME	= "Faction Transfer Analzyer"

FactionTransferAnalyzer = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceConsole-3.0", "AceEvent-3.0")

--@alpha@
FTA = FactionTransferAnalyzer
--@end-alpha@

local addon = LibStub("AceAddon-3.0"):GetAddon(MODNAME)
--local L	= LibStub("AceLocale-3.0"):GetLocale(MODNAME)
local BFAC = LibStub("LibBabble-Faction-3.0"):GetLookupTable()
local BRACE = LibStub("LibBabble-Race-3.0"):GetLookupTable()

-- Frame we use for viewing the output
addon.DisplayFrame = nil

local tinsert = table.insert
local tconcat = table.concat
local twipe = table.wipe

function addon:OnInitialize()

	-- Create slash commands
	self:RegisterChatCommand("fta", "SlashHandler")

end

-- Rep Scanning Stuff
do

	local GetNumFactions = GetNumFactions
	local GetFactionInfo = GetFactionInfo
	local CollapseFactionHeader = CollapseFactionHeader
	local ExpandFactionHeader = ExpandFactionHeader
	local rep_list = {}

	function addon:ScanFactions(RepTable)

		twipe(rep_list)

		-- Number of factions before we expand
		local numfactions = GetNumFactions()

		-- Lets expand all the headers
		for i = numfactions, 1, -1 do
			local name, _, _, _, _, _, _, _, _, isCollapsed = GetFactionInfo(i)

			if (isCollapsed) then
				ExpandFactionHeader(i)
				rep_list[name] = true
			end
		end

		-- Number of factions with everything expanded
		numfactions = GetNumFactions()

		-- Get the rep levels
		for i = 1, numfactions, 1 do
			local name, _, replevel = GetFactionInfo(i)
			RepTable[name] = replevel
		end

		-- Collapse the headers again
		for i = numfactions, 1, -1 do
			local name = GetFactionInfo(i)
			if (rep_list[name]) then
				CollapseFactionHeader(i)
			end
		end

	end

end -- end-do

local orc = string.lower(BRACE["Orc"])
local troll = string.lower(BRACE["Troll"])

local RaceListHorde = {
	[orc] = BFAC["Orgrimmar"],
	[troll] = BFAC["Darkspear Trolls"],
	[string.lower(BRACE["Undead"])] = BFAC["Undercity"],
	[string.lower(BRACE["Tauren"])] = BFAC["Thunder Bluff"],
	[string.gsub(string.lower(BRACE["Blood Elf"]), " ", "")] = BFAC["Silvermoon City"],
	["be"] = BFAC["Silvermoon City"], -- People are lazy and BloodElf is too long to type
}

local human = string.lower(BRACE["Human"])
local gnome = string.lower(BRACE["Gnome"])

local RaceListAlliance = {
	[human] = BFAC["Stormwind"],
	[gnome] = BFAC["Gnomeregan Exiles"],
	[string.lower(BRACE["Dwarf"])] = BFAC["Ironforge"],
	[string.lower(BRACE["Draenei"])] = BFAC["Exodar"],
	[string.gsub(string.lower(BRACE["Night Elf"]), " ", "")] = BFAC["Darnassus"],
	["ne"] = BFAC["Darnassus"], -- People are lazy and NightElf is too long to type
}

-- Faction Stuff
do

	-- Horde factions which change based on the race combination
	local FACTION_CHANGE_HORDE = {
		[BFAC["Undercity"]] = BFAC["Darnassus"],
		[BFAC["Orgrimmar"]] = BFAC["Stormwind"],
		[BFAC["Thunder Bluff"]] = BFAC["Gnomeregan Exiles"],
		[BFAC["Darkspear Trolls"]] = BFAC["Ironforge"],
		[BFAC["Silvermoon City"]] = BFAC["Exodar"],
	}

	-- Default Horde factions which always translate
	local FACTION_DEFAULT_HORDE = {
		[BFAC["The Defilers"]] = BFAC["The League of Arathor"],
		[BFAC["Tranquillien"]] = 0,
		[BFAC["Frostwolf Clan"]] = BFAC["Stormpike Guard"],
		[BFAC["Warsong Outriders"]] = BFAC["Silverwing Sentinels"],
		[BFAC["The Mag'har"]] = BFAC["Kurenai"],
		[BFAC["Thrallmar"]] = BFAC["Honor Hold"],
		[BFAC["Horde Expedition"]] = BFAC["Alliance Vanguard"],
		[BFAC["The Taunka"]] = BFAC["Explorers' League"],
		[BFAC["The Hand of Vengeance"]] = BFAC["The Frostborn"],
		[BFAC["Warsong Offensive"]] = BFAC["Valiance Expedition"],
	}

	-- Alliance factions which change based on the race combination
	local FACTION_CHANGE_ALLIANCE = {
		[BFAC["Darnassus"]] = BFAC["Undercity"],
		[BFAC["Stormwind"]] = BFAC["Orgrimmar"],
		[BFAC["Gnomeregan Exiles"]] = BFAC["Thunder Bluff"],
		[BFAC["Ironforge"]] = BFAC["Darkspear Trolls"],
		[BFAC["Exodar"]] = BFAC["Silvermoon City"],
	}

	-- Default Alliance factions which always translate
	local FACTION_DEFAULT_ALLIANCE = {
		[BFAC["Wintersaber Trainers"]] = 0,
		[BFAC["The League of Arathor"]] = BFAC["The Defilers"],
		[BFAC["Stormpike Guard"]] = BFAC["Frostwolf Clan"],
		[BFAC["Silverwing Sentinels"]] = BFAC["Warsong Outriders"],
		[BFAC["Kurenai"]] = BFAC["The Mag'har"],
		[BFAC["Honor Hold"]] = BFAC["Thrallmar"],
		[BFAC["Alliance Vanguard"]] = BFAC["Horde Expedition"],
		[BFAC["Explorers' League"]] = BFAC["The Taunka"],
		[BFAC["The Frostborn"]] = BFAC["The Hand of Vengeance"],
		[BFAC["Valiance Expedition"]] = BFAC["Warsong Offensive"],
	}

	function addon:ParseReps(RepTable, DefaultFactionTable, ChangeFactionTable, OFaction, TFaction)
		local t = {}

		-- Parse all the reps that we have
		for name, replevel in pairs(RepTable) do
			-- Factions which always have a 1-1 translation
			if (DefaultFactionTable[name]) then
				if (DefaultFactionTable[name] == 0) then
					tinsert(t,"- " .. name .. " -> Removed")
				else
					tinsert(t,"* " .. name .. " -> " .. DefaultFactionTable[name])
				end
			-- Factions that translate based on which race you are transitioning to
			-- Only will deal with default right now
			elseif (ChangeFactionTable[name]) then
				if (name == OFaction) then
					tinsert(t,"* " .. name .. " -> " .. TFaction)
				elseif (ChangeFactionTable[name] == TFaction) then
					tinsert(t,"* " .. name .. " -> " .. ChangeFactionTable[OFaction])
				else
					tinsert(t,"* " .. name .. " -> " .. ChangeFactionTable[name])
				end
			end
		end

		return tconcat(t,"\n")

	end

	function addon:ScanRep(TRace, ORace)

		local playerFaction = UnitFactionGroup("player")
		local RepTable = {}

		self:ScanFactions(RepTable)

		local t = {}

		if (RaceListHorde[ORace]) then
			local OFaction = RaceListHorde[ORace]
			local TFaction = RaceListAlliance[TRace]
			tinsert("Displaying transfer changes from " .. ORace .. " (" .. OFaction .. ") to " .. TRace .. " (" .. TFaction .. ").")
			-- Are we part of the faction we're scanning?
			if (playerFaction == "Horde") then
				tinsert(t,self:ParseReps(RepTable, FACTION_DEFAULT_HORDE, FACTION_CHANGE_HORDE, OFaction, TFaction))
			-- Scanning for opposite faction, just dump the defaults
			else
				for i,j in pairs(FACTION_DEFAULT_HORDE) do
					if (j == 0) then
						tinsert(t,"- " .. i .. " -> Removed")
					else
						tinsert(t,"* " .. i .. " -> " .. j)
					end
				end
				for i,j in pairs(FACTION_CHANGE_HORDE) do
					tinsert(t,"* " .. i .. " -> " .. j)
				end
			end
		elseif (RaceListAlliance[ORace]) then
			local OFaction = RaceListAlliance[ORace]
			local TFaction = RaceListHorde[TRace]
			tinsert(t,"Displaying transfer changes from " .. ORace .. " (" .. OFaction .. ") to " .. TRace .. " (" .. TFaction .. ").")
			-- Are we part of the faction we're scanning?
			if (playerFaction == "Alliance") then
				tinsert(t,self:ParseReps(RepTable, FACTION_DEFAULT_ALLIANCE, FACTION_CHANGE_ALLIANCE, OFaction, TFaction))
			-- Scanning for opposite faction, just dump the defaults
			else
				for i,j in pairs(FACTION_DEFAULT_ALLIANCE) do
					if (j == 0) then
						tinsert(t,"- " .. i .. " -> Removed")
					else
						tinsert(t,"* " .. i .. " -> " .. j)
					end
				end
				for i,j in pairs(FACTION_CHANGE_ALLIANCE) do
					tinsert(t,"* " .. i .. " -> " .. j)
				end
			end
		end

		return tconcat(t,"\n")

	end

end --end-do

-- Mount Stuff
do

	-- Alliance mounts which change based on the race combination
	-- 0 = random discontinued
	-- 1 = random
	local MOUNT_CHANGE_HORDE = {
		[35018] = 1,
		[6654] = 458,
		[578] = 470,
		[580] = 472,
		[10799] = 6648,
		[8395] = 6777,
		[16084] = 6896,
		[10796] = 6898,
		[64977] = 8394,
		[17464] = 10789,
		[17463] = 10793,
		[64657] = 10873,
		[18990] = 10969,
		[18992] = 15779,
		[16080] = 16082,
		[16081] = 16083,
		[18989] = 17453,
		[18991] = 17459,
		[63642] = 17460,
		[22724] = 22717,
		[22718] = 22719,
		[22721] = 22720,
		[22722] = 22723,
		[23246] = 23219,
		[66846] = 23221,
		[23247] = 23222,
		[23248] = 23223,
		[23249] = 23225,
		[23251] = 23227,
		[23252] = 23228,
		[23250] = 23229,
		[23243] = 23238,
		[23241] = 23239,
		[23242] = 23240,
		[17465] = 23338,
		[35022] = 34406,
		[35020] = 35710,
		[10873] = 35711,
		[35027] = 35712,
		[35025] = 35713,
		[33660] = 35714,
		[35028] = 48027,
		[63640] = 63232,
		[63635] = 63636,
		[6653] = 63637,
		[10795] = 63638,
		[63643] = 63639,
		[65639] = 65637,
		[65645] = 65638,
		[65646] = 65640,
		[65641] = 65642,
		[65644] = 65643,
		[17462] = 66847,
	}

	-- Default Horde mounts which always translate
	local MOUNT_DEFAULT_HORDE = {
		[61230] = 61229,
		[23509] = 23510,
		[68188] = 68187,
		[66088] = 66087,
		[64659] = 17229,
		[32245] = 32235,
		[61997] = 61996,
		[66091] = 66090,
		[55531] = 60424,
		[32243] = 32239,
		[32244] = 32240,
		[32296] = 32242,
		[32295] = 32290,
		[32246] = 32289,
		[32297] = 32292,
		[68056] = 68057,
	}   

	-- Alliance mounts which change based on the race combination
	-- 0 = random discontinued
	-- 1 = random
	local MOUNT_CHANGE_ALLIANCE = {
		[16056] = 0,
		[22719] = 22718,
		[16055] = 0,
		[6896] = 16084,
		[470] = 578,
		[48027] = 35028,
		[22720] = 22721,
		[22717] = 22724,
		[22723] = 22722,
		[10969] = 18990,
		[34406] = 35022,
		[458] = 6654,
		[6648] = 10799,
		[63637] = 6653,
		[63639] = 63643,
		[17460] = 63642,
		[63638] = 10795,
		[35710] = 35020,
		[6777] = 8395,
		[35713] = 35025,
		[35712] = 35027,
		[35714] = 33660,
		[65637] = 65639,
		[17453] = 18989,
		[17459] = 18991,
		[63636] = 63635,
		[16082] = 16080,
		[472] = 580,
		[35711] = 10873,
		[10873] = 64657,
		[10789] = 17464,
		[63232] = 63640,
		[66847] = 17462,
		[8394] = 64977,
		[10793] = 17463,
		[23238] = 23243,
		[23229] = 23250,
		[23221] = 66846,
		[23239] = 23241,
		[65640] = 65646,
		[23225] = 23249,
		[23219] = 23246,
		[65638] = 65645,
		[23227] = 23251,
		[23338] = 17465,
		[65643] = 65644,
		[23223] = 23248,
		[23240] = 23242,
		[23228] = 23252,
		[23222] = 23247,
		[65642] = 65641,
		[17454] = 1,
		[15779] = 18992,
		[6898] = 10796,
		[16083] = 16081,
	}            

	-- Default Alliance mounts which always translate
	local MOUNT_DEFAULT_ALLIANCE = {
		[61229] = 61230,
		[23510] = 23509,
		[68187] = 68188,
		[66087] = 66088,
		[17229] = 64659,
		[32235] = 32245,
		[61996] = 61997,
		[66090] = 66091,
		[60424] = 55531,
		[32239] = 32243,
		[32240] = 32244,
		[32242] = 32296,
		[32290] = 32295,
		[32289] = 32246,
		[32292] = 32297,
		[68057] = 68056,
	}

	local MOUNT_RACE = {
		[troll] = {
			[human] = {
				[8395] = 472,
				[10796] = 6648,
				[10799] = 458,
				[1] = 470,
				[23241] = 23229,
				[23242] = 23228,
				[23243] = 23227,
				[16084] = 16082,
				[580] = 6777,
				[6653] = 6898,
				[6653] = 6899,
				[16080] = 6896,
				[64658] = 1,
				[10795] = 16083,
				[63635] = 63232,
				[65644] = 65640,
				[22721] = 22717,
				[23250] = 23239,
				[23252] = 23240,
				[23251] = 23238,
				[16081] = 17460,
				[63640] = 63636,
				[65646] = 65643,
				[22724] = 22720,
			},           
			[gnome] = {
			},
		},
		[human] = {
			[troll] = {
				[472] = 8395,
				[6648] = 10796,
				[458] = 10799,
				[470] = 1,
				[23229] = 23241,
				[23228] = 23242,
				[23227] = 23243,
				[16082] = 16084,
				[16083] = 10795,
				[63232] = 63635,
				[65640] = 65644,
				[22717] = 22721,
				[6777] = 580,
				[6898] = 6653,
				[6899] = 6654,
				[1] = 64658,
				[23239] = 23250,
				[23240] = 23252,
				[23238] = 23251,
				[6896] = 16080,
				[17460] = 16081,
				[63636] = 63640,
				[65643] = 65646,
				[22720] = 22724,
			},
		},
	}

	local mounts = {}

	local function PopulateMounts()
		local nummounts = GetNumCompanions("MOUNT")

		for i=1,nummounts,1 do
			-- Get the pet's name and spell ID
			local _,_,mountspell = GetCompanionInfo("MOUNT",i)
			mounts[mountspell] = true
		end
	end

	function addon:ScanMounts(TRace, ORace)

		-- Lets get the mount list
		PopulateMounts()

		local t = {}

		-- Handle Default Transfers
		local defaultlist = nil
		local changelist = nil
		if (RaceListHorde[ORace]) then
			defaultlist = MOUNT_DEFAULT_HORDE
			changelist = MOUNT_CHANGE_HORDE
		elseif (RaceListAlliance[ORace]) then
			defaultlist = MOUNT_DEFAULT_ALLIANCE
			changelist = MOUNT_CHANGE_ALLIANCE
		end

		-- Parse through all the mounts in the transfer list and convert them over
		for k,l in pairs(defaultlist) do
			local omount = GetSpellInfo(k)
			local tmount = GetSpellInfo(l)
			if (mounts[k]) then
				tinsert(t,"* " .. omount .. " -> " .. tmount)
			else
				tinsert(t,"* " .. omount .. " -> " .. tmount .. " (You do not have this mount)")
			end
		end

		-- Now lets parse through all the changing ones
		for k,l in pairs(changelist) do
			local omount = GetSpellInfo(k)
			local tmount = GetSpellInfo(l)
			if (mounts[k]) then
				if (MOUNT_RACE[ORace][TRace][k]) then
					tmount = GetSpellInfo(MOUNT_RACE[ORace][TRace][k])
					tinsert(t,"* " .. omount .. " -> " .. tmount)
				else
					tinsert(t,"* " .. omount .. " -> " .. tmount)
				end
			else
				if (MOUNT_RACE[ORace][TRace][k]) then
					tmount = GetSpellInfo(MOUNT_RACE[ORace][TRace][k])
					tinsert(t,"* " .. omount .. " -> " .. tmount .. " (You do not have this mount)")
				else
					tinsert(t,"* " .. omount .. " -> " .. tmount .. " (You do not have this mount)")
				end
			end
		end

		return t

	end

end --end-do

-- GUI Stuff
function addon:DisplayTextDump(textdump)

	-- If we haven't created these frames, then lets do so now.
	if (not addon.DisplayFrame) then
		addon.DisplayFrame = CreateFrame("Frame", "DisplayFrame", UIParent)
		tinsert(UISpecialFrames, "DisplayFrame")
		addon.DisplayFrame:SetBackdrop(PaneBackdrop)
		addon.DisplayFrame:SetBackdropColor(0,0,0,1)
		addon.DisplayFrame:SetWidth(750)
		addon.DisplayFrame:SetHeight(400)
		addon.DisplayFrame:SetPoint("CENTER", UIParent, "CENTER")
		addon.DisplayFrame:SetFrameStrata("DIALOG")
		
		local scrollArea = CreateFrame("ScrollFrame", "FTAScroll", addon.DisplayFrame, "UIPanelScrollFrameTemplate")
		scrollArea:SetPoint("TOPLEFT", addon.DisplayFrame, "TOPLEFT", 8, -30)
		scrollArea:SetPoint("BOTTOMRIGHT", addon.DisplayFrame, "BOTTOMRIGHT", -30, 8)
		
		addon.DisplayFrame.editBox = CreateFrame("EditBox", "FTAEdit", addon.DisplayFrame)
		addon.DisplayFrame.editBox:SetMultiLine(true)
		addon.DisplayFrame.editBox:SetMaxLetters(99999)
		addon.DisplayFrame.editBox:EnableMouse(true)
		addon.DisplayFrame.editBox:SetAutoFocus(true)
		addon.DisplayFrame.editBox:SetFontObject(ChatFontNormal)
		addon.DisplayFrame.editBox:SetWidth(650)
		addon.DisplayFrame.editBox:SetHeight(270)
		addon.DisplayFrame.editBox:SetScript("OnEscapePressed", function() addon.DisplayFrame:Hide() end)
		addon.DisplayFrame.editBox:SetText(textdump)
		addon.DisplayFrame.editBox:HighlightText(0)
		
		scrollArea:SetScrollChild(addon.DisplayFrame.editBox)
		
		local close = CreateFrame("Button", nil, addon.DisplayFrame, "UIPanelCloseButton")
		close:SetPoint("TOPRIGHT", addon.DisplayFrame, "TOPRIGHT")
		
		addon.DisplayFrame:Show()
	else
		addon.DisplayFrame.editBox:SetText(textdump)
		addon.DisplayFrame.editBox:HighlightText(0)
		addon.DisplayFrame:Show()
	end

end

function addon:SlashHandler(input)

	local lower = string.lower(input)

	if (not lower) or (lower and lower:trim() == "") then
		self:Print("Error, correct usage is: /tfa <Transfer Race> <Original Race (Optional)>")
	elseif (lower == "help") then
		local helptext = [[Faction Transfer Analyzer:
Assists with transfering your characters faction by letting you know which reputations, mounts, and spells you will have transfered or lose.
Usage: /tfa <Transfer Race> <Original Race (Optional)>
If Original Race is not specified it will use your characters current race.
Acceptible races are: Orc, Troll, Tauren, BloodElf, Undead, Gnome, Human, NightElf, Draenei, Dwarf
]]
		self:Print(helptext)
	else
		local TFaction, OFaction = string.match(lower, "(%a+)%s*(%a*)")

		if (not TFaction) or (TFaction and TFaction:trim() == "") then
			self:Print("Error, you must specify which race you will be transferring to.")
			return
		elseif (not OFaction) or (OFaction and OFaction:trim() == "") then
			OFaction = string.gsub(string.lower(UnitRace("player")), " ", "")
		end
			self:ScanCharacter(TFaction, OFaction)
	end

end

function addon:ScanCharacter(TFaction, OFaction)

	-- See if we can do this scan
	if ((RaceListHorde[TRace]) and (RaceListHorde[OFaction])) or
	((RaceListAlliance[TFaction]) and (RaceListAlliance[OFaction])) then
		self:Print("Error, this transfer is not currently possible (Transfers must be from one faction to the other only).")
		return
	end

	local rep = self:ScanRep(TFaction, OFaction)
	local mounts = self:ScanMounts(TFaction, OFaction)

	local results = rep .. mounts

	self:DisplayTextDump(results)

end