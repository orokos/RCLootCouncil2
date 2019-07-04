--- PlayerNames.lua Class for handling the conversion from player names to GUID and vice versa
-- Creates 'RCLootCouncil.Names' as a namespace for name functions.
-- @author Potdisc
-- Create Date : 5/6/2018 10:32:58

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local Names = {}
addon.Names = Names

-- "Name" class
local name_proto = {
   name = "",
   guid = "",
   realm = "",

   ["GetName"] = function(self)
      return self.name
   end,

   ["GetShortName"] = function(self)
      return Ambiguate(self.name, "short")
   end,

   ["GetRealm"] = function(self)
      return self.realm
   end,

   ["GetGUID"] = function(self)
      return self.guid
   end,

   ["GetForStorage"] = function(self)
      return self.guid, self.name
   end,

   ["GetTransmitGUID"] = function(self)
      -- Remove the "Player-" part of the GUID
      return (gsub(self.guid, "Player%-", ""))
   end,

   ["RestoreGUID"] = function(self, guid)
      self.guid = "Player-"..guid
   end,

   -- Lazy call to GetPlayerInfoByGUID
   ["GetInfo"] = function(self)
      return GetPlayerInfoByGUID(self.guid)
   end,
}


local function NewName(name, guid)
   addon.Log("PlayerNames", "Creating Name:", name, guid)
   local Name = setmetatable(
      {
         name = name or "",
        guid = guid or ""
      },
      {
         __index = name_proto,
         __tostring = function(self)
            return self.name
         end,
         __eq = function(a,b)
            return a.guid == b.guid
         end,
      }
   )
   Name.realm = select(2, strsplit("-", name, 2))
   return Name
end

--- Returns Name object, and stores said name in SV.
-- @param input UnitName, unitid (without '-'), PlayerGUID, or hex-part of GUID
-- @return Name object.
function Names:Get(input)
   -- Decide if input is a GUID or actual name
   -- NOTE: This doesn't take into account if GUID if correct
   if not strmatch(input, "Player%-") and strmatch(input, "%x%x%x%-%x%x%x%x%x%x%x%x") then
      -- GUID without "Player-"
      input = "Player-"..input
   end
   if strmatch(input, "Player%-") and strmatch(input, "%x%x%x%-%x%x%x%x%x%x%x%x") then
      -- Full GUID
      local stored = addon:Getdb().PlayerNames[input]
      if not stored then
         -- TODO Test if GUID can be used in UnitName()
         local name = select(6, GetPlayerInfoByGUID(input))
         if not name then
            return -- REVIEW Queue something??
         end
         name = addon:UnitName(name)
         addon:Getdb().PlayerNames[input] = name
      end
      return NewName(addon:Getdb().PlayerNames[input], input)

   else -- Assume it's a name
      -- Ensure proper name
      input = addon:UnitName(input)
      local guid = FindInTableIf(addon:Getdb().PlayerNames , function(v) addon:UnitIsUnit(input,v) end) -- REVIEW This might be inefficient compared to alternatives
      if not guid then
         guid = UnitGUID(input)
         if guid then -- This might fail
            addon:Getdb().PlayerNames[guid] = input
         end
      end
      return NewName(input, guid)
   end
end
