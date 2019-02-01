local lu = require("luaunit")

if not RCLootCouncil then dofile "../Init.lua" end

require "LibDeflate"

local ser = LibStub("AceSerializer-3.0")

local debug = false

local rc = RCLootCouncil
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
		WoWAPI_FireUpdate(GetTime()+100)
   end,

	TestSend2 = function()
		rc.Comms:Send{command = "command", target = "group", data = "test data"}
		WoWAPI_FireUpdate(GetTime()+100)
	end,
}

TestReceiving = {
   Setup = function(self)
      _G.IsInRaidVal = true
      rc.Send = rc.Comms:Register(rc, rc.Comms.Prefixes.MAIN)
      self.received = false
   end,
   TearDown = function(self)
		WoWAPI_FireUpdate(GetTime()+100)
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
   end,

	TestBulkRegisterCommand = function(args)
		local toSend = "some test data"
		rc.Comms:BulkRegisterCommand(rc, rc.Comms.Prefixes.MAIN,
			{
				test10 = function(rc, command, data, distri, sender)
		         args.received1 = true
		         lu.assertEquals(command, "test10")
		         lu.assertEquals(unpack(data), toSend)
		         lu.assertEquals(distri, "RAID")
		         lu.assertEquals(sender, "Sender")
		      end,
				test11 = function(rc, command, data, distri, sender)
					lu.assertTrue(args.received1)
		         args.received = true
		         lu.assertEquals(command, "test11")
		         lu.assertEquals(unpack(data), toSend)
		         lu.assertEquals(distri, "RAID")
		         lu.assertEquals(sender, "Sender")
		      end
			})
		rc:Send("group", "test10", toSend)
		rc:Send("group", "test11", toSend)
	end,

	TestxPersistency = function(args) -- x to run last
		-- Check if the commands registered in the previous tests still works
		local toSend = "some test data"
		rc:Send("group", "test10", toSend)
		rc:Send("group", "test11", toSend)
		WoWAPI_FireUpdate(GetTime()+100)
		lu.assertTrue(args.received)
		args.received = false
		rc:Send("group", "test", toSend)
		WoWAPI_FireUpdate(GetTime()+100)
		lu.assertTrue(args.received)
		args.received = false
		toSend = {bigger = "data", "structure"}
		rc:Send("group", "test2", toSend)
	end,

	TestReceiveCommsSend = function (args)
		-- Should be received with TestReceive
		rc.Comms:Send{command = "test", data = "some test data"}
	end
}

TestOtherPrefixes = {
	Setup = function(self)
      _G.IsInRaidVal = true
      self.received = false
   end,
   TearDown = function(self)
		WoWAPI_FireUpdate(GetTime()+100)
      lu.assertTrue(self.received)
   end,

	TestVersionPrefix = function (args)
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
      rc:Send("group", "v", toSend)
   end,

	TestNewPrefix = function(args)
		rc.Send = rc.Comms:Register(rc, "newPrefix")
		local toSend = {data = "this is", some = "data"}
		rc.Comms:RegisterCommand(rc, "newPrefix", "test",
			function(rc, command, data, distri, sender)
				args.received = true
         lu.assertEquals(command, "test")
         lu.assertEquals(unpack(data), toSend)
         lu.assertEquals(distri, "RAID")
         lu.assertEquals(sender, "Sender")
			end)
		rc:Send("group", "test", toSend)
	end,

	TestXCommsSend = function (args)
		rc.Comms:Send{prefix = "newPrefix", data = {data = "this is", some = "data"}, command = "test"}
	end
}

TestGuildComms = {
	Setup = function(self)
		rc.Send = rc.Comms:Register(rc, rc.Comms.Prefixes.VERSION)
      self.received = false
   end,
   TearDown = function(self)
		WoWAPI_FireUpdate(GetTime()+100)
      lu.assertTrue(self.received)
   end,
	TestGuildComm = function (args)
		local toSend = {version = "3.0.0", tVersion = "Alpha.1"}
      rc.Comms:RegisterCommand(rc, rc.Comms.Prefixes.VERSION, "ver",
      function(rc, command, data, distri, sender)
         args.received = true
         lu.assertEquals(command, "ver")
         lu.assertEquals(unpack(data), toSend)
         lu.assertEquals(distri, "GUILD")
         lu.assertEquals(sender, "Sender")
      end)
      rc:Send("guild", "ver", toSend)
   end
}

TestPartyComms = {
	Setup = function(self)
		_G.IsInRaidVal = false
		_G.IsInGroupVal = true
		self.Send = rc.Comms:Register(rc, "party")
      self.received = false
   end,
   TearDown = function(self)
		WoWAPI_FireUpdate(GetTime()+100)
      lu.assertTrue(self.received)
   end,
	TestPartyComm1 = function (self)
		local toSend = "some party data"
		rc.Comms:RegisterCommand(rc, "party", "test",
		function(rc, command, data, distri, sender)
			self.received = true
	      lu.assertEquals(command, "test")
	      lu.assertEquals(unpack(data), toSend)
	      lu.assertEquals(distri, "PARTY")
	      lu.assertEquals(sender, "Sender")
		end)
		self:Send("group", "test", toSend)
	end
}

os.exit(lu.LuaUnit.run("-v"))
