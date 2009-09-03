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

local MODNAME	= "Faction Transfer Analzyer

FactionTransferAnalyzer = LibStub("AceAddon-3.0"):NewAddon(MODNAME, "AceConsole-3.0", "AceEvent-3.0")

--@alpha@
FTA = FactionTransferAnalyzer
--@end-alpha@

local addon = LibStub("AceAddon-3.0"):GetAddon(MODNAME)
--local L	= LibStub("AceLocale-3.0"):GetLocale(MODNAME)

function addon:OnInitialize()

	-- Create slash commands
	self:RegisterChatCommand("fta", "ScanCharacter")

end

local FACTION_DEFAULT_HORDE = {
	[68] = 69, -- UC -> Darn
	[530] = 47, -- Darkspear -> IF
	[76] = 72, -- Org -> Stormwind
	[911] = 930, -- Silvermoon -> Exodar
	[81] = 54, -- TB -> Gnomergan
	[729] = 730, -- Frostwolf -> Stormpike
	[947] = 946, -- Thrallmar -> Honor Hold
	[941] = 978, -- Mag'har  -> Kurenai
	[922] = nil, -- Tranquillen -> nil
	[1052] = 1037, -- Horde Exp -> Alliance Vanguard
	[510] = 509, -- Defilers -> Arathor
	[1067] = 1126, -- Hand -> Frostborn
	[1085] = 1050,-- Warsong Offensive -> Valiance
	[889] = 890, -- Warsong Outriders -> Silverwing
	[1064] = 1068, -- Taunka -> Explorer's League
}

do

	local GetNumFactions = GetNumFactions
	local GetFactionInfo = GetFactionInfo
	local CollapseFactionHeader = CollapseFactionHeader
	local ExpandFactionHeader = ExpandFactionHeader
	local rep_list = {}

	function addon:ScanFactions()

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

function addon:ScanCharacter()

end