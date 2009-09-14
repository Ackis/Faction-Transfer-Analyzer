﻿--[[

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
local undead = string.lower(BRACE["Undead"])
local tauren = string.lower(BRACE["Tauren"])
local bloodelf = string.gsub(string.lower(BRACE["Blood Elf"]), " ", "")
local be = "be"

local RaceListHorde = {
	[orc] = BFAC["Orgrimmar"],
	[troll] = BFAC["Darkspear Trolls"],
	[undead] = BFAC["Undercity"],
	[tauren] = BFAC["Thunder Bluff"],
	[bloodelf] = BFAC["Silvermoon City"],
	[be] = BFAC["Silvermoon City"], -- People are lazy and BloodElf is too long to type
}

local human = string.lower(BRACE["Human"])
local gnome = string.lower(BRACE["Gnome"])
local dwarf = string.lower(BRACE["Dwarf"])
local draenei = string.lower(BRACE["Draenei"])
local nightelf = string.gsub(string.lower(BRACE["Night Elf"]), " ", "")
local ne = "ne"

local RaceListAlliance = {
	[human] = BFAC["Stormwind"],
	[gnome] = BFAC["Gnomeregan Exiles"],
	[dwarf] = BFAC["Ironforge"],
	[draenei] = BFAC["Exodar"],
	[nightelf] = BFAC["Darnassus"],
	[ne] = BFAC["Darnassus"], -- People are lazy and NightElf is too long to type
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
		tinsert(t,"Please note that the information provided in this report must be considered in beta form.  I have taken all steps to ensure that the transfer information is correct, however Blizzard can change this at anytime.")
		tinsert(t,"If you find the data to be incorrect, please submit a ticket on the project page.  All the data is pulled from: http://www.worldofwarcraft.com/info/faction-change/index.xml")

		if (RaceListHorde[ORace]) then
			local OFaction = RaceListHorde[ORace]
			local TFaction = RaceListAlliance[TRace]
			tinsert(t,"Displaying transfer changes from " .. ORace .. " (|cffff0000" .. OFaction .. "|r) to " .. TRace .. " (|cff0000ff" .. TFaction .. "|r).\nLegend:\n* = Changed\n- = Removed\nReputation Changes:\n")
			-- Are we part of the faction we're scanning?
			if (playerFaction == "Horde") then
				tinsert(t,self:ParseReps(RepTable, FACTION_DEFAULT_HORDE, FACTION_CHANGE_HORDE, OFaction, TFaction))
			-- Scanning for opposite faction, just dump the defaults
			else
				for i,j in pairs(FACTION_DEFAULT_HORDE) do
					if (j == 0) then
						tinsert(t,"|cffff0000- " .. i .. " -> Removed|r")
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
			tinsert(t,"Displaying transfer changes from " .. ORace .. " (|cff0000ff" .. OFaction .. "|r) to " .. TRace .. " (|cffff0000" .. TFaction .. "|r).\nLegend:\n* = Changed\n- = Removed\nReputation Changes:\n")
			-- Are we part of the faction we're scanning?
			if (playerFaction == "Alliance") then
				tinsert(t,self:ParseReps(RepTable, FACTION_DEFAULT_ALLIANCE, FACTION_CHANGE_ALLIANCE, OFaction, TFaction))
			-- Scanning for opposite faction, just dump the defaults
			else
				for i,j in pairs(FACTION_DEFAULT_ALLIANCE) do
					if (j == 0) then
						tinsert(t,"|cffff0000- " .. i .. " -> Removed|r")
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
		[human] = {
			[undead] = {
				[472] = 64977,
				[6648] = 17464,
				[470] =   17463,
				[23229] = 17462,
				[23228] = 17465,
				[16082] = 66846,
				[23227] = 0,
				[16083] = 0,
				[63232] = 63643,
				[65640] = 65645,
				[22717] = 22722,
				[8394] = 580,
				[10789] = 6653,
				[10793] = 6654,
				[66847] = 64658,
				[23338] = 23250,
				[23219] = 23252,
				[23221] = 23251,
				[16056] = 16080,
				[16055] = 16081,
				[63637] = 63640,
				[65638] = 65646,
				[22723] = 22724,
			},
			[tauren] = {
				[472] = 18990,
				[6648] = 18989,
				[470] = 1,
				[23229] = 23249,
				[23228] = 23248,
				[16082] = 23247,
				[23227] = 18991,
				[16083] = 18992,
				[63232] = 63641,
				[65640] = 65641,
				[22717] = 22718,
				[33630] = 580,
				[17453] = 6653,
				[10873] = 6654,
				[17454] = 64658,
				[23225] = 23250,
				[23223] = 23252,
				[23222] = 23251,
				[15779] = 16080,
				[17459] = 16081,
				[63638] = 63640,
				[65642] = 65646,
				[22719] = 22724,
			},           
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
			[bloodelf] = {
				[472] = 35022,
				[6648] = 35020,
				[470] = 34795,
				[23229] = 35018,
				[23228] = 35025,
				[16082] = 35027,
				[23227] = 33660,
				[16083] = 0,
				[63232] = 0,
				[65640] = 63642,
				[22717] = 65639,
				[34406] = 580,
				[35710] = 6653,
				[35711] = 6654,
				[35713] = 64658,
				[1] = 23250,
				[35712] = 23252,
				[35714] = 23251,
				[0] =     16080,
				[0] =     16081,
				[63639] = 63640,
				[65637] = 65646,
				[48027] = 22724,
			},  
			[be] = {
				[472] = 35022,
				[6648] = 35020,
				[470] = 34795,
				[23229] = 35018,
				[23228] = 35025,
				[16082] = 35027,
				[23227] = 33660,
				[16083] = 0,
				[63232] = 0,
				[65640] = 63642,
				[22717] = 65639,
				[34406] = 580,
				[35710] = 6653,
				[35711] = 6654,
				[35713] = 64658,
				[1] = 23250,
				[35712] = 23252,
				[35714] = 23251,
				[0] =     16080,
				[0] =     16081,
				[63639] = 63640,
				[65637] = 65646,
				[48027] = 22724,
			},
		},
		[dwarf] = {
			[orc] = {
				[472] = 8395,
				[6648] = 10796,
				[458] = 10799,
				[470] = 1,
				[23229] = 23241,
				[23228] = 23242,
				[23227] = 23243,
				[16082] = 16084,
				[16083] = 17450,
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
				[17461] = 16080,
				[17460] = 16081,
				[63636] = 63640,
				[65643] = 65646,
				[22720] = 22724,
			},
			[undead] = {
				[6777] = 64977,
				[6898] = 17464,
				[6899] = 17463,
				[1] = 17462,
				[23239] = 17465,
				[23240] = 23246,
				[23238] = 66846,
				[17461] = 0,
				[17460] = 0,
				[63636] = 63643,
				[65643] = 65645,
				[22720] = 22722,
				[8394] = 8395,
				[10789] = 10796,
				[10793] = 10799,
				[66847] = 1,
				[23338] = 23241,
				[23219] = 23242,
				[23221] = 23243,
				[16056] = 16084,
				[16055] = 17450,
				[63637] = 63635,
				[65638] = 65644,
				[22723] = 22721,
			},         
			[tauren] = {
				[6777] = 18990,
				[6898] = 18989,
				[6899] = 64657,
				[23239] = 23249,
				[23240] = 23248,
				[23238] = 23247,
				[17461] = 18991,
				[17460] = 18992,
				[63636] = 63641,
				[65643] = 65641,
				[22720] = 22718,
				[33630] = 8395,
				[17453] = 10796,
				[10873] = 10799,
				[17454] = 1,
				[23225] = 23241,
				[23223] = 23242,
				[23222] = 23243,
				[15779] = 16084,
				[17459] = 17450,
				[63638] = 63635,
				[65642] = 65644,
				[22719] = 22721,
			},
			[bloodelf] = {
				[6777] = 35022,
				[6898] = 35020,
				[6899] = 34795,
				[1] = 35018,
				[23239] = 35025,
				[23240] = 35027,
				[23238] = 33660,
				[17461] = 0,
				[17460] = 0,
				[63636] = 63642,
				[65643] = 65639,
				[22720] = 35028,
				[34406] = 8395,
				[35710] = 10796,
				[35711] = 10799,
				[35713] = 23241,
				[35712] = 23242,
				[35714] = 23243,
				[0] = 16084,
				[0] = 17450,
				[63639] = 63635,
				[65637] = 65644,
				[48027] = 22721,
			},  
			[be] = {
				[6777] = 35022,
				[6898] = 35020,
				[6899] = 34795,
				[1] = 35018,
				[23239] = 35025,
				[23240] = 35027,
				[23238] = 33660,
				[17461] = 0,
				[17460] = 0,
				[63636] = 63642,
				[65643] = 65639,
				[22720] = 35028,
				[34406] = 8395,
				[35710] = 10796,
				[35711] = 10799,
				[35713] = 23241,
				[35712] = 23242,
				[35714] = 23243,
				[0] = 16084,
				[0] = 17450,
				[63639] = 63635,
				[65637] = 65644,
				[48027] = 22721,
			},
		},
		[nightelf] = {
			[orc] = {
				[472] = 64977,
				[6648] = 17464,
				[470] = 17463,
				[23229] = 17462,
				[23228] = 17465,
				[16082] = 66846,
				[23227] = 0,
				[16083] = 0,
				[63232] = 63643,
				[65640] = 65645,
				[22717] = 22722,
				[8394] = 580,
				[10789] = 6653,
				[10793] = 6654,
				[66847] = 64658,
				[23338] = 23250,
				[23219] = 23252,
				[23221] = 23251,
				[16056] = 16080,
				[16055] = 16081,
				[63637] = 63640,
				[65638] = 65646,
				[22723] = 22724,
			},
			[undead] = {
				[65638] = 0,
				[22723] = 0,
			},
			[tauren] = {
				[8394] = 18990,
				[10789] = 18989,
				[10793] = 64657,
				[66847] = 1,
				[23338] = 23249,
				[23219] = 23248,
				[23221] = 23247,
				[16056] = 18991,
				[16055] = 18992,
				[63637] = 63641,
				[65638] = 65641,
				[22723] = 22718,
				[33630] = 64977,
				[17453] = 17464,
				[10873] = 17463,
				[17454] = 17462,
				[23225] = 17465,
				[23223] = 23246,
				[23222] = 66846,
				[15779] = 0,
				[17459] = 0,
				[63638] = 63643,
				[65642] = 65645,
				[22719] = 22722,
			},
			[troll] = {
				[64977] = 6777,
				[17464] = 6898,
				[17463] = 6899,
				[17462] = 1,
				[17465] = 23239,
				[23246] = 23240,
				[66846] = 23238,
				[0] = 17461,
				[0] = 17460,
				[63643] = 63636,
				[65645] = 65643,
				[22722] = 22720,
				[8395] = 8394,  
				[10796] = 10789,
				[10799] = 10793,
				[1] = 66847,
				[23241] = 23338,
				[23242] = 23219,
				[23243] = 23221,
				[16084] = 16056,
				[17450] = 16055,
				[63635] = 63637,
				[65644] = 65638,
				[22721] = 22723,
			},
			[bloodelf] = {
				[8394] = 35022,
				[10789] = 35020,
				[10793] = 34795,
				[66847] = 35018,
				[23338] = 35025,
				[23219] = 35027,
				[23221] = 33660,
				[16056] = 0,
				[16055] = 0,
				[63637] = 63642,
				[65638] = 65639,
                [22723] = 35028,
				[34406] = 64977,
				[35710] = 17464,
				[35711] = 17463,
				[1] = 17462,
				[35713] = 17465,
				[35712] = 23246,
				[35714] = 66846,
				[63639] = 63643,
				[65637] = 65645,
				[48027] = 22722,
			},
			[be] = {
				[8394] = 35022,
				[10789] = 35020,
				[10793] = 34795,
				[66847] = 35018,
				[23338] = 35025,
				[23219] = 35027,
				[23221] = 33660,
				[16056] = 0,
				[16055] = 0,
				[63637] = 63642,
				[65638] = 65639,
                [22723] = 35028,
				[34406] = 64977,
				[35710] = 17464,
				[35711] = 17463,
				[1] = 17462,
				[35713] = 17465,
				[35712] = 23246,
				[35714] = 66846,
				[63639] = 63643,
				[65637] = 65645,
				[48027] = 22722,
			},
		},
		[ne] = {
			[orc] = {
				[472] = 64977,
				[6648] = 17464,
				[470] = 17463,
				[23229] = 17462,
				[23228] = 17465,
				[16082] = 66846,
				[23227] = 0,
				[16083] = 0,
				[63232] = 63643,
				[65640] = 65645,
				[22717] = 22722,
				[8394] = 580,
				[10789] = 6653,
				[10793] = 6654,
				[66847] = 64658,
				[23338] = 23250,
				[23219] = 23252,
				[23221] = 23251,
				[16056] = 16080,
				[16055] = 16081,
				[63637] = 63640,
				[65638] = 65646,
				[22723] = 22724,
			},
			[undead] = {
				[65638] = 0,
				[22723] = 0,
			},
			[tauren] = {
				[8394] = 18990,
				[10789] = 18989,
				[10793] = 64657,
				[66847] = 1,
				[23338] = 23249,
				[23219] = 23248,
				[23221] = 23247,
				[16056] = 18991,
				[16055] = 18992,
				[63637] = 63641,
				[65638] = 65641,
				[22723] = 22718,
				[33630] = 64977,
				[17453] = 17464,
				[10873] = 17463,
				[17454] = 17462,
				[23225] = 17465,
				[23223] = 23246,
				[23222] = 66846,
				[15779] = 0,
				[17459] = 0,
				[63638] = 63643,
				[65642] = 65645,
				[22719] = 22722,
			},
			[troll] = {
				[64977] = 6777,
				[17464] = 6898,
				[17463] = 6899,
				[17462] = 1,
				[17465] = 23239,
				[23246] = 23240,
				[66846] = 23238,
				[0] = 17461,
				[0] = 17460,
				[63643] = 63636,
				[65645] = 65643,
				[22722] = 22720,
				[8395] = 8394,  
				[10796] = 10789,
				[10799] = 10793,
				[1] = 66847,
				[23241] = 23338,
				[23242] = 23219,
				[23243] = 23221,
				[16084] = 16056,
				[17450] = 16055,
				[63635] = 63637,
				[65644] = 65638,
				[22721] = 22723,
			},
			[bloodelf] = {
				[8394] = 335022,
				[10789] = 35020,
				[10793] = 34795,
				[66847] = 35018,
				[23338] = 35025,
				[23219] = 35027,
				[23221] = 33660,
				[16056] = 0,
				[16055] = 0,
				[63637] = 63642,
				[65638] = 65639,
                [22723] = 35028,
				[34406] = 64977,
				[35710] = 17464,
				[35711] = 17463,
				[1] = 17462,
				[35713] = 17465,
				[35712] = 23246,
				[35714] = 66846,
				[63639] = 63643,
				[65637] = 65645,
				[48027] = 22722,
			},
			[be] = {
				[8394] = 335022,
				[10789] = 35020,
				[10793] = 34795,
				[66847] = 35018,
				[23338] = 35025,
				[23219] = 35027,
				[23221] = 33660,
				[16056] = 0,
				[16055] = 0,
				[63637] = 63642,
				[65638] = 65639,
                [22723] = 35028,
				[34406] = 64977,
				[35710] = 17464,
				[35711] = 17463,
				[1] = 17462,
				[35713] = 17465,
				[35712] = 23246,
				[35714] = 66846,
				[63639] = 63643,
				[65637] = 65645,
				[48027] = 22722,
			},
		},
		[gnome] = {
			[orc] = {
				[472] = 18990,
				[6648] = 18989,
				[458] = 64657,
				[470] = 1,
				[23229] = 23249,
				[23228] = 23248,
				[16082] = 23247,
				[23227] = 18991,
				[16083] = 18992,
				[63232] = 63641,
				[65640] = 65641,
				[22717] = 22718,
				[33630] = 580,
				[17453] = 6653,
				[10873] = 6654,
				[17454] = 64658,
				[23225] = 23250,
				[23223] = 23252,
				[23222] = 23251,
				[15779] = 16080,
				[17459] = 16081,
				[63638] = 63640,
				[65642] = 65646,
				[22719] = 22724,
			},
			[undead] = {
				[8394] = 18990,
				[10789] = 18989,
				[10793] = 64657,
				[66847] = 1,
				[23338] = 23249,
				[23219] = 23248,
				[23221] = 23247,
				[16056] = 18991,
				[16055] = 18992,
				[63637] = 63641,
				[65638] = 65641,
				[22723] = 22718,
				[33630] = 64977,
				[17453] = 17464,
				[10873] = 64656,
				[17454] = 17462,
				[23225] = 17465,
				[23223] = 23246,
				[23222] = 66846,
				[15779] = 0,
				[17459] = 0,
				[63638] = 63643,
				[65642] = 65645,
				[22719] = 22722,
			},
			[tauren] = {
				[17454] = 1,
			},
			[troll] = {
				[6777] = 18990,
				[6898] = 18989,
				[6899] = 64657,
				[23239] = 23249,
				[23240] = 23248,
				[23238] = 23247,
				[17461] = 18991,
				[17460] = 18992,
				[63636] = 63641,
				[65643] = 65641,
				[22720] = 22718,
				[33630] = 8395,
				[17453] = 10796,
				[10873] = 10799,
				[17454] = 1,
				[23225] = 23241,
				[23223] = 23242,
				[23222] = 23243,
				[15779] = 16084,
				[17459] = 17450,
				[63638] = 63635,
				[65642] = 65644,
				[22719] = 22721,
			},
			[bloodelf] = {
				[33630] = 35022,
				[17453] = 35020,
				[10873] = 34795,
				[17454] = 35018,
				[23225] = 35025,
				[23223] = 35027,
				[23222] = 33660,
				[15779] = 0,
				[17459] = 0,
				[63638] = 63642,
				[65642] = 65639,
				[22719] = 35028,
				[34406] = 18990,
				[35710] =  18989,
				[35711] = 64657,
				[35713] = 23249,
				[35712] = 23248,
				[35714] = 23247,
				[0] = 18991,
				[0] = 18992,
				[63639] = 63641,
				[65637] = 65641,
				[48027] = 22718,
			},
			[be] = {
				[33630] = 35022,
				[17453] = 35020,
				[10873] = 34795,
				[17454] = 35018,
				[23225] = 35025,
				[23223] = 35027,
				[23222] = 33660,
				[15779] = 0,
				[17459] = 0,
				[63638] = 63642,
				[65642] = 65639,
				[22719] = 35028,
				[34406] = 18990,
				[35710] =  18989,
				[35711] = 64657,
				[35713] = 23249,
				[35712] = 23248,
				[35714] = 23247,
				[0] = 18991,
				[0] = 18992,
				[63639] = 63641,
				[65637] = 65641,
				[48027] = 22718,
			},
		},
		[draenei] = {
			[orc] = {
				[472] = 35022,
				[6648] = 35020,
				[458] = 34795,
				[470] = 35018,
				[23229] = 35025,
				[23228] = 35027,
				[16082] = 33660,
				[23227] = 0,
				[16083] = 0,
				[63232] = 63642,
				[65640] = 65639,
				[22717] = 35028,
				[34406] = 580,
				[35710] = 6653,
				[35711] = 6654,
				[35713] = 64658,
				[1] = 23250,
				[35712] = 23252,
				[35714] = 23251,
				[0] = 16080,
				[0] = 16081,
				[63639] = 63640,
				[65637] = 65646,
				[48027] = 22724,
			},
			[undead] = {
				[8394] = 35022,
				[10789] = 35020,
				[10793] = 34795,
				[66847] = 35018,
				[23338] = 35025,
				[23219] = 35027,
				[23221] = 33660,
				[16056] = 0,
				[16055] = 0,
				[63637] = 63642,
				[65638] = 65639,
				[22723] = 35028,
				[34406] = 64977,
				[35710] = 17464,
				[35711] = 17463,
				[1] = 17462,
				[35713] = 17465,
				[35712] = 23246,
				[35714] = 66846,
				[63639] = 63643,
				[65637] = 65645,
				[48027] = 22722,
			},
			[tauren] = {
				[33630] = 35022,
				[17453] = 35020,
				[10873] = 34795,
				[17454] = 35018,
				[23225] = 35025,
				[23223] = 35027,
				[23222] = 33660,
				[15779] = 0,
				[17459] = 0,
				[63638] = 63642,
				[65642] = 65639,
				[22719] = 35028,
				[34406] = 18990,
				[35710] = 18989,
				[35711] = 64657,
				[35713] = 23249,
				[35712] = 23248,
				[35714] = 23247,
				[0] =     18991,
				[0] =     18992,
				[63639] = 63641,
				[65637] = 65641,
				[48027] = 22718,
			},
			[troll] = {
				[18990] = 35022,
				[18989] = 35020,
				[64657] = 34795,
				[1] = 35018,
				[23249] = 35025,
				[23248] = 35027,
				[23247] = 33660,
				[18991] = 0,
				[18992] = 0,
				[63641] = 63642,
				[65641] = 65639,
				[22718] = 35028,
				[34406] = 8395,
				[35710] = 10796,
				[35711] = 10799,
				[35713] = 23241,
				[35712] = 23242,
				[35714] = 23243,
				[0] =     16084,
				[0] =     17450,
				[63639] = 63635,
				[65637] = 65644,
				[48027] = 22721,
			},            
		},
		[orc] = {
			[human] = {
			},
			[dwarf] = {
			},
			[nightelf] = {
			},
			[ne] = {
			},
			[gnome] = {
			},
			[draenei] = {
			},
		},
		[undead] = {
			[human] = {
			},
			[dwarf] = {
			},
			[nightelf] = {
			},
			[ne] = {
			},
			[gnome] = {
			},
			[draenei] = {
			},
		},
		[tauren] = {
			[human] = {
			},
			[dwarf] = {
			},
			[nightelf] = {
			},
			[ne] = {
			},
			[gnome] = {
			},
			[draenei] = {
			},
		},
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
			[ne] = {
				[18990] = 64977,
				[18989] = 17464,
				[64657] = 17463,
				[1] = 17462,
				[23249] = 17465,
				[23248] = 23246,
				[23247] = 66846,
				[18991] = 0,
				[18992] = 0,
				[63641] = 63643,
				[65641] = 65645,
				[22718] = 22722,
				[8394] = 8395,
				[10789] = 10796,
				[10793] = 10799,
				[66847] = 1,
				[23338] = 23241,
				[23219] = 23242,
				[23221] = 23243,
				[16056] = 16084,
				[16055] = 17450,
				[63637] = 63635,
				[65638] = 65644,
				[22723] = 22721,
			},
			[nightelf] = {
				[6777] = 64977,
				[6898] = 17464,
				[6899] = 17463,
				[1] = 17462,
				[23239] = 17465,
				[23240] = 23246,
				[23238] = 66846,
				[17461] = 0,
				[17460] = 0,
				[63636] = 63643,
				[65643] = 65645,
				[22720] = 22722,
				[8394] = 8395,
				[10789] = 10796,
				[10793] = 10799,
				[66847] = 1,
				[23338] = 23241,
				[23219] = 23242,
				[23221] = 23243,
				[16056] = 16084,
				[16055] = 17450,
				[63637] = 63635,
				[65638] = 65644,
				[22723] = 22721,
			},
			[gnome] = {
				[18990] = 6777,
				[18989] = 6898,
				[64657] = 6899,
				[23249] = 23239,
				[23248] = 23240,
				[23247] = 23238,
				[18991] = 17461,
				[18992] = 17460,
				[63641] = 63636,
				[65641] = 65643,
				[22718] = 22720,
				[8395] = 33630,
				[10796] = 17453,
				[10799] = 10873,
				[1] = 	17454,
				[23241] = 23225,
				[23242] = 23223,
				[23243] = 23222,
				[16084] = 15779,
				[17450] = 17459,
				[63635] = 63638,
				[65644] = 65642,
				[22721] = 22719,
			},
			[draenei] = {
				[35022] = 18990,
				[35020] = 18989,
				[34795] = 64657,
				[35018] = 1,
				[35025] = 23249,
				[35027] = 23248,
				[33660] = 23247,
				[0] = 18991,
				[0] = 18992,
				[63642] = 63641,
				[65639] = 65641,
				[35028] = 22718,
				[8395] = 34406,
				[10796] = 35710,
				[10799] = 35711,
				[23241] = 35713,
				[23242] = 35712,
				[23243] = 35714,
				[16084] = 0,
				[17450] = 0,
				[63635] = 63639,
				[65644] = 65637,
				[22721] = 48027,
			},
		},
		[bloodelf] = {
			[human] = {
			},
			[dwarf] = {
			},
			[nightelf] = {
			},
			[ne] = {
			},
			[gnome] = {
			},
			[draenei] = {
			},
		},
		[be] = {
			[human] = {
			},
			[dwarf] = {
			},
			[nightelf] = {
			},
			[ne] = {
			},
			[gnome] = {
			},
			[draenei] = {
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

		tinsert(t,"\nMount Changes:\n")

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
			if (l == 0) then
				tmount = "Random discontinued mount."
			elseif (l == 1) then
				tmount = "Random mount."
			end
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
			if (l == 0) then
				tmount = "Random discontinued mount."
			elseif (l == 1) then
				tmount = "Random mount."
			end
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

		return tconcat(t,"\n")

	end

end --end-do

local PaneBackdrop  = {
	bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
	edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 3, right = 3, top = 5, bottom = 3 }
}

--- Creates a new frame with the contents of a text dump so you can copy and paste
-- Code borrowed from Antiarc (Chatter) with permission
-- @name FactionTransferAnalyzer:DisplayTextDump
-- @param textdump The text to be dumped
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

	local results = rep .. "\n" .. mounts

	self:DisplayTextDump(results)

end