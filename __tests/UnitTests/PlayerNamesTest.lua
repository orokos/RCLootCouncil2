local lu = require("luaunit")

if not RCLootCouncil then dofile "../Init.lua" end

local rc = RCLootCouncil
dofile "../../Classes/PlayerNames.lua" -- Load the rc.Names namespace


rc.realmName = "Ourrealm"
local count = 1
local db = {
   PlayerNames = {
      ["Player-000-00000001"] = "Gemenim-Daggerspine",
      ["Player-000-00000002"] = "Potdisc-Ravencrest",
      ["Player-0af-cdea0139"] = "Somedude-Someserver",
   }
}


-- Set a few helpers (TODO Should use the actual functions when possible)
function rc:Getdb (args)
   return db
end

function rc:Debug(...)
   -- supress for now
end

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

function rc:UnitIsUnit(unit1, unit2)
	if not unit1 or not unit2 then return false end
	-- Remove realm names, if any
	if strfind(unit1, "-", nil, true) ~= nil then
		unit1 = Ambiguate(unit1, "short")
	end
	if strfind(unit2, "-", nil, true) ~= nil then
		unit2 = Ambiguate(unit2, "short")
	end
	-- v2.3.3 There's problems comparing non-ascii characters of different cases using UnitIsUnit()
	-- I.e. UnitIsUnit("Potdisc", "potdisc") works, but UnitIsUnit("Æver", "æver") doesn't.
	-- Since I can't find a way to ensure consistant returns from UnitName(), just lowercase units here before passing them.
	return string.lower(unit1) == string.lower(unit2)
end

-- Define a few WoW global funcs (TODO Move to wow_api.lua)
function GetPlayerInfoByGUID(guid)
   -- Expects 6 return values
   return "","","","","", db.PlayerNames[guid] or "SomeNewDude-Server"
end

function UnitGUID (name)
   local t = tInvert(db.PlayerNames)
   return t[name] or "Player-FFF-ABCDF012"
end

TestPlayerNames = {
   setUp = function(self)
      self.Name = rc.Names:Get("Gemenim-Daggerspine")
      self.Name2 = rc.Names:Get("Player-000-00000001") -- Gemenim-Daggerspine
      self.Name3 = rc.Names:Get("Potdisc-Ravencrest")
   end,

   testBasics = function (self)
      lu.assertIsTable(self.Name)
      lu.assertIsFunction(self.Name.GetName)
      lu.assertIsString(self.Name.guid)
   end,

   testGetName = function (self)
      lu.assertEquals(self.Name:GetName(), "Gemenim-Daggerspine")
      lu.assertEquals(self.Name3:GetName(), "Potdisc-Ravencrest")
   end,

   testShortName = function (self)
      lu.assertEquals(self.Name:GetShortName(), "Gemenim")
      lu.assertEquals(self.Name2:GetShortName(), "Gemenim")
      lu.assertEquals(self.Name3:GetShortName(), "Potdisc")
   end,

   testTwoOfTheSameName = function (self)
      lu.assertEquals(self.Name, self.Name2)
      lu.assertEquals(self.Name:GetGUID(), self.Name2.guid)
   end,

   testFalseCompare = function (self)
      lu.assertNotEquals(self.Name, self.Name3)
   end,

   testGetGuid = function (self)
      lu.assertEquals(self.Name:GetGUID(), "Player-000-00000001")
      lu.assertEquals(self.Name3:GetGUID(), "Player-000-00000002")
   end,

   testGetForStorage = function (args)
      lu.assertEquals({args.Name:GetForStorage()}, {"Player-000-00000001", "Gemenim-Daggerspine"})
      lu.assertEquals({args.Name3:GetForStorage()}, {"Player-000-00000002", "Potdisc-Ravencrest"})
   end,

   testGetTransmitGUID = function (args)
      lu.assertEquals(args.Name:GetTransmitGUID(), "000-00000001")
      lu.assertEquals(args.Name3:GetTransmitGUID(), "000-00000002")
   end,

   testRestoreGUID = function (args)
      local oldguid = args.Name:GetGUID()
      local guid = args.Name:GetTransmitGUID()
      args.Name.guid = nil -- Not normal behavior, but it emulates receiving it
      args.Name:RestoreGUID(guid)
      lu.assertEquals(args.Name.guid, oldguid)
   end,

   testGetInfo = function (args)
      lu.assertEquals(select(6, args.Name:GetInfo()), args.Name.name)
   end,

   testRandomName = function (args)
      local Name = rc.Names:Get("SomeName")
      lu.assertEquals(Name.guid, "Player-FFF-ABCDF012")
      lu.assertEquals(Name.name, "SomeName-Ourrealm")
   end,

   testBlank = function (args)
      local Name = rc.Names:Get("")
      lu.assertEquals(Name:GetName(), "-Ourrealm") -- REVIEW The live version will fail creating this name
      lu.assertEquals(Name:GetGUID(), "Player-FFF-ABCDF012")
   end,

   testPersistantStorage = function (args)
      local Name = rc.Names:Get("NewGuy")
      lu.assertEquals(Name.name, db.PlayerNames["Player-FFF-ABCDF012"])
      lu.assertEquals(Name.guid, "Player-FFF-ABCDF012")
   end,

   testReceivedGuid = function()
      local Name = rc.Names:Get("123-45678900")
      lu.assertEquals(Name.guid, "Player-123-45678900")
      lu.assertEquals(Name.name, 'SomeNewDude-Server')
   end,

   -- testGetRealm = function (self) -- Fails due to strsplit implementation doesn't match Blizzards
   --    print(self.Name, self.Name.guid, self.Name.realm)
   --    lu.assertEquals(self.Name:GetRealm(), "Daggerspine")
   --    lu.assertEquals(self.Name3:GetRealm(), "Ravencrest")
   -- end,
}



os.exit(lu.LuaUnit.run("-v"))
