--- PlayerData.lua Class for handling various data related to a specific player
-- Creates 'RCLootCouncil.PlayerData' as a namespace.
-- @author Potdisc
-- Create Date : 19/10/2018 13:01:10

--[[
   Intended to act as a storage class for various data related to a specific player, such as
   class, loot history data, role, ilvl etc. The intend is to load this data asynchronously, with
   each field having it's own data loader.
   I'm not sure if this is overcomplicating the problem.
]]

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local Data = {}
addon.PlayerData = Data

local cache = {}

local proto = {

}
