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

local FACTION_CHANGE_HORDE = {
	[BFAC["Undercity"]] = BFAC["Darnassus"],
	[BFAC["Orgrimmar"]] = BFAC["Stormwind"],
	[BFAC["Thunder Bluff"]] = BFAC["Gnomeregan Exiles"],
	[BFAC["Darkspear Trolls"]] = BFAC["Ironforge"],
	[BFAC["Silvermoon City"]] = BFAC["Exodar"],
}

-- Default factions which always translate
local FACTION_DEFAULT_HORDE = {
	[BFAC["The Defilers"]] = BFAC["The League of Arathor"],
	[BFAC["Tranquillien"]] = 0,
	[BFAC["Frostwolf Clan"]] = BFAC["Stormpike Guard"],
	[BFAC["Warsong Outriders"]] = BFAC["Silverwing Sentinels"],
	[BFAC["The Mag'har"]] = BFAC["Kurenai"],
	[BFAC["Thrallmar"]] = BFAC["Honor Hold"],
	[BFAC["Horde Expedition"]] = BFAC["Alliance Vanguard"],
	[BFAC["The Taunka"]] = BFAC["Explorers League"],
	[BFAC["The Hand of Vengeance"]] = BFAC["The Frostborn"],
	[BFAC["Warsong Offensive"]] = BFAC["Valiance Expedition"],
}

local FACTION_DEFAULT_ALLIANCE = {
	[BFAC["Undercity"]] = BFAC["Darnassus"],
	[BFAC["Orgrimmar"]] = BFAC["Stormwind"],
	[BFAC["Thunder Bluff"]] = BFAC["Gnomergan Exiles"],
	[BFAC["The Defilers"]] = BFAC["The League of Arathor"],
	[BFAC["Darkspear Trolls"]] = BFAC["Ironforge"],
	[BFAC["Frostwolf Clan"]] = BFAC["Stormpike Guard"],
	[BFAC["Warsong Outriders"]] = BFAC["Silverwing Sentinels"],
	[BFAC["Silvermoon City"]] = BFAC["Exodar"],
	[BFAC["The Mag'har"]] = BFAC["Kurenai"],
	[BFAC["Thrallmar"]] = BFAC["Honor Hold"],
	[BFAC["Horde Expedition"]] = BFAC["Alliance Vanguard"],
	[BFAC["The Taunka"]] = BFAC["Explorer's League"],
	[BFAC["The Hand of Vengeance"]] = BFAC["The Frostborn"],
	[BFAC["Warsong Offensive"]] = BFAC["Valiance Expedition"],
}

do

	local GetNumFactions = GetNumFactions
	local GetFactionInfo = GetFactionInfo
	local CollapseFactionHeader = CollapseFactionHeader
	local ExpandFactionHeader = ExpandFactionHeader
	local rep_list = {}

	function addon:ScanFactions(RepTable)

		-- Bug here when I reload UI
		if (not RepTable) then
			return
		end
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

function addon:ParseReps(RepTable, ParseTable)

	local t = {}

	-- Parse all the found reps
	for name, replevel in pairs(RepTable) do
		self:Print(name)
		-- If there's a conversion add it to our output
		if (ParseTable[name]) then
			if (ParseTable[name] == 0) then
				tinsert(t,"- " .. name " -> Removed")
			else
				tinsert(t,"* " .. name " -> " .. ParseTable[name])
			end
		end
	end

	return tconcat(t,"\n")

end

function addon:ScanCharacter()

	local RepTable = {}

	self:ScanFactions(RepTable)
	self:Print(self:ParseReps(RepTable, FACTION_DEFAULT_HORDE))

end