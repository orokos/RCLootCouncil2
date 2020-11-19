--- Player.lua Class for holding player related data.
-- @author Potdisc
-- Create Date: 15/04/2020
---@type RCLootCouncil
local _, addon = ...
---@class Data.Player
local Player = addon.Init("Data.Player")
local Log = addon.Require("Log"):Get()
---@type Services.ErrorHandler
local ErrorHandler = addon.Require "Services.ErrorHandler"

local MAX_CACHE_TIME = 60 * 60 * 24 * 2 -- 2 days

local private = {
	cache = setmetatable({}, {
		__index = function(_, id)
			if not addon.db.global.cache.player then addon.db.global.cache.player = {} end
			return addon.db.global.cache.player[id]
		end,
		__newindex = function(_, k, v)
			addon.db.global.cache.player[k] = v
		end
	})
}

local PLAYER_MT = {
	__index = {
		---@return string
		GetName = function(self)
			return self.name
		end,
		---@return string
		GetClass = function(self)
			return self.class
		end,
		---@return string
		GetShortName = function(self)
			return Ambiguate(self.name, "short")
		end,
		---@return string
		GetRealm = function(self)
			return self.realm
		end,
		---@return string
		GetGUID = function(self)
			return self.guid
		end,
		---@return string
		GetForTransmit = function(self)
			return (gsub(self.guid, "Player%-", ""))
		end,
		--- Lazy call to GetPlayerInfoByGUID
		GetInfo = function(self)
			return GetPlayerInfoByGUID(self.guid)
		end,
		--- Update fields in the Player object
		--- @param self Player
		--- @param data table<string,any>
		UpdateFields = function(self, data)
			for k, v in pairs(data) do self[k] = v end
			private:CachePlayer(self)
		end
	},
	__tostring = function(self)
		return self.name
	end,
	__eq = function(a, b)
		return a.guid == b.guid
	end
}

--- Fetches a player
--- @param input string A player name or GUID
--- @return Player
function Player:Get(input)
	-- Decide if input is a name or guid
	local guid
	if input and not strmatch(input, "Player%-")
					and strmatch(input, "%d?%d?%d?%d%-%x%x%x%x%x%x%x%x") then
		-- GUID without "Player-"
		guid = "Player-" .. input
	elseif input and strmatch(input, "Player%-%d?%d?%d?%d%-%x%x%x%x%x%x%x%x") then
		-- GUID with player
		guid = input
	elseif type(input) == "string" then
		-- Assume UnitName
		local name = Ambiguate(input, "none")
		guid = UnitGUID(name)
		-- We can only extract GUID's from people we're grouped with.
		if not guid then
			guid = private:GetGUIDFromPlayerName(name)
			-- It's not in our cache, try the guild.
			if not guid then
				guid = private:GetGUIDFromPlayerNameByGuild(name)
				if not guid then
					-- Not much we can do at this point, so log an error
					ErrorHandler:ThrowSilentError("Couldn't produce GUID for "
                              									.. tostring(input))
				end
			end
		end

	else
		error(format("%s invalid player", tostring(input)), 2)
	end
	return private:GetFromCache(guid) or private:CreatePlayer(guid)
end

function private:CreatePlayer(guid)
	Log:f("<Data.Player>", "CreatePlayer", guid)
	if not guid then return {name = "Unknown"} end
	local _, class, _, _, _, name, realm = GetPlayerInfoByGUID(guid)
	realm = (not realm or realm == "") and select(2, UnitFullName("player")) or realm
	---@class Player
	local player = setmetatable({
		---@field name string
		name = addon.Utils:UnitName(name.."-"..realm),
		guid = guid,
		class = class,
		realm = realm
	}, PLAYER_MT)
	self:CachePlayer(player)
	return player
end

function private:GetFromCache(guid)
	if self.cache[guid] then
		if GetServerTime() - self.cache[guid].cache_time <= MAX_CACHE_TIME then
			return setmetatable(CopyTable(self.cache[guid]), PLAYER_MT)
		end
		-- No need to delete the cache as it will be overwritten shortly
	end
end

function private:CachePlayer(player)
	self.cache[player.guid] = CopyTable(player)
	self.cache[player.guid].cache_time = GetServerTime()
end

function private:GetGUIDFromPlayerName(name)
	for guid, player in pairs(addon.db.global.cache.player) do
		if Ambiguate(player.name, "short") == name then return guid end
	end
end

function private:GetGUIDFromPlayerNameByGuild(name)
	for i = 1, GetNumGuildMembers() do
		local name2, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, guid =
						GetGuildRosterInfo(i)
		if Ambiguate(name2, "short") == name then return guid end
	end
end
