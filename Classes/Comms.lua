--- Comms.lua Class for handling all addon communication.
-- Creates 'RCLootCouncil.Comms' as a namespace for comms functions.
-- @author Potdisc
-- Create Date : 18/10/2018 13:20:31

-- GLOBALS: error, IsPartyLFG, IsInRaid, IsInGroup, tinsert
local tostring, ipairs, pairs, tremove, format, type = tostring, ipairs, pairs, tremove, format, type

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local ld = LibStub("LibDeflate")
local Comms = {}
local private = {}
addon.Comms = Comms

addon.Comms.Prefixes = {
   MAIN     = "RCLC",
   VERSION  = "RCLCv",
}

private.commands = {}
-- [prefix][command] = {mod, func} stuff to execute end
for _,v in pairs(addon.Comms.Prefixes) do private.commands[v] = {} end

private.compresslevel = {level = 3}

--- Subscribe to a specific command
--
-- @paramsig mod, prefix, command, func [, order]
-- @param mod Your object to register the function on.
-- @param prefix The comm message prefix to listen for (defaults to RCLootCouncil.Comms.Prefixes.MAIN)
-- @param command The Command to subscribe to.
-- @param func The function to execute when the command is received. Can be string or func.
-- @param order An optional order in which the comm is executed.
function Comms:RegisterCommand (mod, prefix, command, func, order)
   if type(mod) ~= "table" then return error("Error - wrong mod supplied.") end
   prefix = prefix or self.Prefixes.MAIN
   if not private.commands[prefix] then private.commands[prefix] = {} end
   if not private.commands[prefix][command] then
      private.commands[prefix][command] = {func = func, mod = mod}
   elseif order and type(order) == "number" then
      tinsert(private.commands[prefix][command], order, {func = func, mod = mod})
   else
      private.commands[prefix][command][#private.commands[prefix][command]] = {func = func, mod = mod}
   end
end

function Comms:BulkRegisterCommand (mod, prefix, data)
   if type(mod) ~= "table" then return error("Error - wrong mod supplied.") end
   prefix = prefix or self.Prefixes.MAIN
   if not private.commands[prefix] then private.commands[prefix] = {} end
   for command, func in pairs(data) do
      if not private.commands[prefix][command] then
            private.commands[prefix][command] = {func = func, mod = mod}
      else
         private.commands[prefix][command][#private.commands[prefix][command]] = {func = func, mod = mod}
      end
   end
end

function private:SendComm(prefix, channel, target, command, ...)
   local serialized = addon:Serialize(command, {...})
   local compressed = ld:CompressDelfate(serialized, self.compresslevel)
   local encoded    = ld:EncodeForWoWAddonChannel(compressed)

   if channel == "whisper" then
      if target:GetRealm() == addon.realmName then -- Our realm
         addon:SendCommMessage(prefix, encoded, channel, target)
      else
         -- Remake command to be "xrealm" and put target and command in the table
         serialized = addon:Serialize("xrealm", {target, command, ...})
         compressed = ld:CompressDelfate(serialized, self.compresslevel)
         encoded    = ld:EncodeForWoWAddonChannel(compressed)
         addon:SendCommMessage(prefix, encoded, self:GetGroupChannel())
      end
   else
      if target == "group" then
         addon:SendCommMessage(prefix, encoded, self:GetGroupChannel())
      elseif target == "guild" then
         addon:SendCommMessage(prefix, encoded, "GUILD")
      else
         error(format("Unknown channel %s in SendComm. Command = %s", tostring(target), command), 2)
      end
   end
end

function private:ReceiveComm(prefix, encodedMsg, distri, sender)
   -- Unpack message
   local decoded = ld:DecodeForWoWAddonChannel(encodedMsg)
   local decompressed = ld:DecompressDeflate(decoded)
   addon:DebugLog("<Comm>:", decompressed, distri, sender)
   local test, command, data = addon:Deserialize(decompressed)
   if not test then
      return addon:DebugLog("<Error>:", "Deserialization failed with:", decompressed)
   end
   if command == "xrealm" then
      local target = tremove(data, 1)
      if target == addon.playerName then
         command = tremove(data, 1)
         self:FireCmd(prefix, distri, sender, command, data)
      end
   else
      self:FireCmd(prefix, distri, sender, command, data)
   end
end

function private:FireCmd (prefix, distri, sender, command, data)
   for _,v in ipairs(self.commands[prefix][command]) do
      if type(v.func) == "text" then
         v.mod[v.func](v.mod, command, data, distri, sender)
      else
         v.func(v.mod, command, data, distri, sender)
      end
   end
end


function private:GetGroupChannel()
   if IsPartyLFG() then
      return "INSTANCE_CHAT"
   elseif IsInRaid() then
      return "RAID"
   elseif IsInGroup() then
      return "PARTY"
   else
      return "WHISPER", addon.playerName.Name -- Fallback
   end
end
