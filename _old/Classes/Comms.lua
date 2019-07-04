--- Comms.lua Class for handling all addon communication.
-- Creates 'RCLootCouncil.Comms' as a namespace for comms functions.
-- @author Potdisc
-- Create Date : 18/10/2018 13:20:31

-- GLOBALS: error, IsPartyLFG, IsInRaid, IsInGroup, assert
local tostring, ipairs, pairs, tremove, format, type, tinsert = tostring, ipairs, pairs, tremove, format, type, tinsert

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local ld = LibStub("LibDeflate")
local Comms = {}
local private = {}
addon.Comms = Comms
Comms.private = private

addon.Comms.Prefixes = {
   MAIN     = "RCLC",
   VERSION  = "RCLCv",
}

LibStub("AceComm-3.0"):Embed(private)

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
      private.commands[prefix][command] = {}
   end
   if order and type(order) == "number" then
      tinsert(private.commands[prefix][command], order, {func = func, mod = mod})
   else
      private.commands[prefix][command][#private.commands[prefix][command] + 1] = {func = func, mod = mod}
   end
end

function Comms:BulkRegisterCommand (mod, prefix, data)
   if type(mod) ~= "table" then return error("Error - wrong mod supplied.") end
   if type(data) ~= "table" then return error("Error - wrong data supplied.") end
   for command, func in pairs(data) do
      self:RegisterCommand(mod, prefix, command, func)
   end
end

function Comms:Register(mod, prefix)
   private:RegisterComm(prefix, "ReceiveComm")
   -- TODO Add to self.Prefixes?
   return function(mod, target, command, ...)
      private:SendComm(prefix, target, "NORMAL", nil, nil, command, ...)
   end
end

function Comms:Send (args)
   assert(args.data)
   assert(args.command)
   private:SendComm(args.prefix or self.Prefixes.MAIN, args.target or "group", args.prio, args.callback, args.callbackarg, args.command, args.data)
end

function private:SendComm(prefix, target, prio, callback, callbackarg, command, ...)
   local serialized = addon:Serialize(command, {...})
   local compressed = ld:CompressDeflate(serialized, self.compresslevel)
   local encoded    = ld:EncodeForWoWAddonChannel(compressed)

   if target == "group" then
      self:SendCommMessage(prefix, encoded, self:GetGroupChannel(), nil, prio, callback, callbackarg)
   elseif target == "guild" then
      self:SendCommMessage(prefix, encoded, "GUILD", nil, prio, callback, callbackarg)
   else
      if target:GetRealm() == addon.realmName then -- Our realm
         self:SendCommMessage(prefix, encoded, "WHISPER", target, prio, callback, callbackarg)
      else
         -- Remake command to be "xrealm" and put target and command in the table
         serialized = addon:Serialize("xrealm", {target, command, ...})
         compressed = ld:CompressDelfate(serialized, self.compresslevel)
         encoded    = ld:EncodeForWoWAddonChannel(compressed)
         self:SendCommMessage(prefix, encoded, self:GetGroupChannel(), nil, prio, callback, callbackarg)
      end
   end
end

function private:ReceiveComm(prefix, encodedMsg, distri, sender)
   -- Unpack message
   local decoded = ld:DecodeForWoWAddonChannel(encodedMsg)
   local decompressed = ld:DecompressDeflate(decoded)
   addon.Log.f("<Comm>", decompressed, distri, sender)
   local test, command, data = addon:Deserialize(decompressed)
   if not test then
      return addon.Log.e("<Comm>", "Deserialization failed with:", decompressed)
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
   if self.commands[prefix][command] then
      for _,v in ipairs(self.commands[prefix][command]) do
         if type(v.func) == "text" then
            v.mod[v.func](v.mod, command, data, distri, sender)
         else
            v.func(v.mod, command, data, distri, sender)
         end
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
