-- Log.lua Class for handling all addon logging.
-- Creates 'RCLootCouncil.Log' as a namespace for log functions.
-- @author Potdisc
-- Create Date : 30/01/2019 18:56:31
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local private = {}
local Log = setmetatable(
   {date_to_debug_log = true},
   {__call = function(self, ...) private:Log("<INFO>", ...) end}
)
addon.Log = Log
local debugLog = addon.db.global.log
local lenght = #debugLog -- Use direct table access for better performance.

-- Clean the log if needed
function Log:Init()
   addon.db.global.logMaxEntries = addon.defaults.global.logMaxEntries -- reset it now for zzz
   if addon.tVersion then
      addon.db.global.logMaxEntries = 4000 -- bump it for test version
   end
   local max = addon.db.global.logMaxEntries
   if lenght > max then
      -- copy
      local tmp = CopyTable(debugLog)
      local j = lenght - max
      j = j > 0 and j or 0
      -- Replace and delete
      for i = 1, i < lenght do --
         if i > max then
            debugLog[i] = nil
         end
         debugLog[i] = tmp[i + j]
      end
      lenght = #debugLog
   end
end

-- Message
function Log.m (...) Log(...) end

-- Debug logging
function Log.d (...) private:Log("<DEBUG>", ...) end

-- Error Logging
function Log.e (...) private:Log("<ERROR>", ...) end

-- Warnings
function Log.w (...) private:Log("<WARNING>", ...) end

-- Print
function Log.p (...) private:Print(...) end

-- Custom prefix
function Log.f (prefix, ...) private:Log(prefix, ...) end

function Log.D(...) Log.d(...) end
function Log.E(...) Log.e(...) end
function Log.W(...) Log.w(...) end
function Log.M(...) Log.m(...) end
function Log.P(...) Log.p(...) end
function Log.F(...) Log.f(...) end

function private:Log(prefix, ...)
   self:Print(prefix, ...)
   if self.date_to_debug_log then tinsert(debugLog, date("%x")); self.date_to_debug_log = false; end
	local time = date("%X", time())
	msg = "<"..time..">"..prefix..":".. tostring(msg)
	for i = 1, select("#", ...) do msg = msg.." "..tostring(select(i,...)) end
	if lenght > addon.db.global.logMaxEntries then
		tremove(debugLog, 1) -- We really want to preserve indicies
      lenght = lenght - 1
	end
   lenght = lenght + 1
	debugLog[lenght] = msg
end

function private:Print(msg, ...)
   if addon.debug then
		if select("#", ...) > 0 then
			addon:Print("|cffcb6700debug:|r "..tostring(msg).."|cffff6767", ...)
		else
			addon:Print("|cffcb6700debug:|r "..tostring(msg).."|r")
		end
	end
end
