local lu = require("luaunit")

dofile "../wow_api.lua"
dofile "../../Libs/LibStub/LibStub.lua"
require "LibDeflate"
dofile "../../Libs/AceAddon-3.0/AceAddon-3.0.lua"
dofile "../../Libs/CallbackHandler-1.0/CallbackHandler-1.0.lua"
dofile "../../Libs/AceComm-3.0/ChatThrottleLib.lua"
dofile "../../Libs/AceComm-3.0/AceComm-3.0.lua"
dofile "../../Libs/AceSerializer-3.0/AceSerializer-3.0.lua"
local ser = LibStub("AceSerializer-3.0")

local debug = false

local rc = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil")
rc.Serialize = ser.Serialize
rc.Deserialize = ser.Deserialize
dofile "../../Classes/Comms.lua"
dofile "../../Classes/PlayerNames.lua" -- Load the rc.Names namespace

function rc:UnitName(unit)
	-- First strip any spaces
	unit = gsub(unit, " ", "")
	-- Then see if we already have a realm name appended
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		return unit
	end
	return unit.."-"..self.realmName
end
rc.Getdb = function() return {PlayerNames = {}} end
rc.Debug = function() end
rc.DebugLog = function(self, ...) if debug then print("\n", ...) end end
rc.playerName = rc.Names:Get("Potdisc-Ravencrest")

TestBasics = {
   Setup = function(self)
      _G.IsInRaidVal = true
      rc.Send = rc.Comms:Register(rc, rc.Comms.Prefixes.MAIN)
   end,
   TestSend = function (args)
      rc:Send("group", "test1", "test data")
   end,
}

TestReceiving = {
   Setup = function(self)
      _G.IsInRaidVal = true
      rc.Send = rc.Comms:Register(rc, rc.Comms.Prefixes.MAIN)
      self.received = false
   end,
   TearDown = function(self)
      lu.assertTrue(self.received)
   end,
   TestReceive = function(args)
      local toSend = "some test data"
      rc.Comms:RegisterCommand(rc, rc.Comms.Prefixes.MAIN, "test",
      function(rc, command, data, distri, sender)
         args.received = true
         lu.assertEquals(command, "test")
         lu.assertEquals(unpack(data), toSend)
         lu.assertEquals(distri, "RAID")
         lu.assertEquals(sender, "Sender")
      end)
      rc:Send("group", "test", toSend)
      WoWAPI_FireUpdate(GetTime()+100)
   end,
   TestReceive2 = function(args)
      local toSend = {bigger = "data", "structure"}
      rc.Comms:RegisterCommand(rc, rc.Comms.Prefixes.MAIN, "test2",
      function(rc, command, data, distri, sender)
         args.received = true
         lu.assertEquals(command, "test2")
         lu.assertEquals(unpack(data), toSend)
         lu.assertEquals(distri, "RAID")
         lu.assertEquals(sender, "Sender")
      end)
      rc:Send("group", "test2", toSend)
      WoWAPI_FireUpdate(GetTime()+100)
   end,

   TestOtherPrefix = function (args)
      rc.Send = rc.Comms:Register(rc, rc.Comms.Prefixes.VERSION)
      local toSend = {version = "3.0.0", tVersion = "Alpha.1"}
      rc.Comms:RegisterCommand(rc, rc.Comms.Prefixes.VERSION, "v",
      function(rc, command, data, distri, sender)
         args.received = true
         lu.assertEquals(command, "v")
         lu.assertEquals(unpack(data), toSend)
         lu.assertEquals(distri, "RAID")
         lu.assertEquals(sender, "Sender")
      end)
      rc:Send("group", "test", toSend)
      WoWAPI_FireUpdate(GetTime()+100)
   end
}

os.exit(lu.LuaUnit.run("-v"))
