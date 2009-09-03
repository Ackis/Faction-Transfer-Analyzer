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
	self:RegisterChatCommand("fta", "ScanCharacter")

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

function addon:ParseReps(RepTable, DefaultFactionTable, ChangeFactionTable)

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
				tinsert(t,"* " .. name .. " -> " .. ChangeFactionTable[name])
		end
	end

	return tconcat(t,"\n")

end

function addon:ScanCharacter()

	playerFaction = UnitFactionGroup("player")

	local RepTable = {}

	self:ScanFactions(RepTable)

	if (playerFaction == "Horde") then
		self:Print(self:ParseReps(RepTable, FACTION_DEFAULT_HORDE, FACTION_CHANGE_HORDE))
	else
		self:Print(self:ParseReps(RepTable, FACTION_DEFAULT_ALLIANCE, FACTION_CHANGE_ALLIANCE))
	end

end