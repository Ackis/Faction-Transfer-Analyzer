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

function addon:ScanCharacter()

end