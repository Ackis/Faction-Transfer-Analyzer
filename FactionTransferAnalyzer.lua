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
-- transfer factions with the current character.
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

local tinsert = table.insert
local tconcat = table.concat
local twipe = table.wipe

function addon:OnInitialize()

	-- Create slash commands
	self:RegisterChatCommand("fta", "SlashHandler")

end

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

local RaceListHorde = {
	[string.lower(BRACE["Orc"])] = BFAC["Orgrimmar"],
	[string.lower(BRACE["Troll"])] = BFAC["Darkspear Trolls"],
	[string.lower(BRACE["Undead"])] = BFAC["Undercity"],
	[string.lower(BRACE["Tauren"])] = BFAC["Thunder Bluff"],
	[string.gsub(string.lower(BRACE["Blood Elf"]), " ", "")] = BFAC["Silvermoon City"],
	["be"] = BFAC["Silvermoon City"], -- People are lazy and BloodElf is too long to type
}

local RaceListAlliance = {
	[string.lower(BRACE["Human"])] = BFAC["Stormwind"],
	[string.lower(BRACE["Gnome"])] = BFAC["Gnomeregan Exiles"],
	[string.lower(BRACE["Dwarf"])] = BFAC["Ironforge"],
	[string.lower(BRACE["Draenei"])] = BFAC["Exodar"],
	[string.gsub(string.lower(BRACE["Night Elf"]), " ", "")] = BFAC["Darnassus"],
	["ne"] = BFAC["Darnassus"], -- People are lazy and NightElf is too long to type
}

function addon:ParseReps(RepTable, DefaultFactionTable, ChangeFactionTable, ORace, TRace, RaceTable)
self:Print("Current race: " .. ORace)
self:Print("Target race: " .. TRace)
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
			if (name ~= RaceTable[ORace]) then
				tinsert(t,"* " .. name .. " -> " .. ChangeFactionTable[name])
			else
				self:Print(RaceTable[ORace])
				tinsert(t,"* " .. name .. " -> " .. ChangeFactionTable[RaceTable[TRace]])
			end
		end
	end

	return tconcat(t,"\n")

end

function addon:ScanCharacter(TRace, ORace)

	playerFaction = UnitFactionGroup("player")

	local RepTable = {}

	self:ScanFactions(RepTable)

	if (playerFaction == "Horde") then
		self:Print(self:ParseReps(RepTable, FACTION_DEFAULT_HORDE, FACTION_CHANGE_HORDE, ORace, TRace))
	else
		self:Print(self:ParseReps(RepTable, FACTION_DEFAULT_ALLIANCE, FACTION_CHANGE_ALLIANCE, ORace, TRace))
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
		if (not TFaction) then
			self:Print("Error, you must specify which race you will be transferring to.")
		else
			if (not OFaction) then
				OFaction = string.gsub(string.lower(UnitRace("player")), " ", "")
			end
			if ((RaceListHorde[TFaction]) and (RaceListHorde[OFaction])) or
			((RaceListAlliance[TFaction]) and (RaceListAlliance[OFaction])) then
				self:Print("Error, this transfer is not currently possible (Transfers must be from one faction to the other only).")
			else
				self:ScanCharacter(TFaction, OFaction)
			end
		end
	end

end