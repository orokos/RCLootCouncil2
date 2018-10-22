--- Comms.lua Class for handling all addon communication.
-- Creates 'RCLootCouncil.Comms' as a namespace for comms functions.
-- @author Potdisc
-- Create Date : 18/10/2018 13:20:31

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local ld = LibStub("LibDeflate")
local Comms = {}
local private = {}
addon.Comms = Comms

addon.Comms.Prefixes = {
   MAIN     = "RCLC",
   VERSION  = "RCLCV",
}

local commands = {
   -- [command] = function(msg, sender, channel) stuff to execute end
}

private.compresslevel = {level = 3}

function private.SendComm(prefix, channel, target, command, ...)
   local serialized = addon:Serialize(command, ...)
   local compressed = ld:CompressDelfate(serialized, private.compresslevel)
   local encoded    = ld:EncodeForWoWAddonChannel(compressed)

   if channel == "whisper" then
      if target:GetRealm() == addon.realmName then -- Our realm
         addon:SendCommMessage(prefex, encoded, channel, target)
      else

      end
   else

   end
end
