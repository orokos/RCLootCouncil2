require "busted.runner"()
local addonName, addon = "RCLootCouncil_Test", {
   db = {global = { log = {}, cache = {}}},
   defaults = { global = {logMaxEntries = 2000}}
}

loadfile(".specs/AddonLoader.lua")(nil, addonName, addon).LoadArray{
   [[Classes/Core.lua]],
   [[Classes/Utils/Log.lua]],
   [[Classes/Data/Player.lua]],
   [[Classes/Utils/TempTable.lua]],
   [[Classes/Data/Council.lua]],
}

addon:InitLogging()
function addon:UnitName(unit)
	unit = gsub(unit, " ", "")
	local find = strfind(unit, "-", nil, true)
	if find and find < #unit then -- "-" isn't the last character
		local name, realm = strsplit("-", unit, 2)
		name = name:lower():gsub("^%l", string.upper)
		return name.."-"..realm
	end
	unit = unit:lower()
	local name, realm = UnitName(unit)
	if not realm or realm == "" then realm = self.realmName or "" end -- Extract our own realm
	if not name then -- if the name isn't set then UnitName couldn't parse unit, most likely because we're not grouped.
		name = unit
	end -- Below won't work without name
	name = name:lower():gsub("^%l", string.upper)
	return name and name.."-"..realm
end

describe("#Council", function()
   local Council
   before_each(function()
      Council = addon.Require "Data.Council"
   end)

   describe("init", function()
      it("should create 'Data.Council' module", function()
         assert.not_nil(Council)
         assert.is.table(Council)
      end)

      it("should have certain functions", function()
         assert.is.Function(Council.Get)
         assert.is.Function(Council.Set)
         assert.is.Function(Council.GetNum)
         assert.is.Function(Council.Add)
         assert.is.Function(Council.Remove)
         assert.is.Function(Council.Contains)
         assert.is.Function(Council.GetForTransmit)
         assert.is.Function(Council.RestoreFromTransmit)
      end)
   end)

   describe("Class", function()
      local Player = addon.Require "Data.Player"
      it("should set the council", function()
         assert.are.same({}, Council:Get())
         assert.are.equal(0, Council:GetNum())
         local newCouncil = {
            [Player:Get("Player1").guid] = Player:Get("Player1")
         }
         Council:Set(newCouncil)
         assert.are.equal(1, Council:GetNum())
         assert.are.equal(newCouncil, Council:Get())
      end)

      it("should create transmitable table", function()
         local expected = {
            ["1-00000001"] = true
         }
         Council:Add(Player:Get("Player1"))
         assert.are.same(expected, Council:GetForTransmit())
      end)

      it("transmitted table should be restoreable", function()
         local transmit = Council:GetForTransmit()
         Council:Add(Player:Get("Player1"))
         Council:Set{} -- set empty
         assert.are.equal(1, Council:RestoreFromTransmit(transmit))
      end)

      it("should add players to the council", function()
         Council:Set{} -- Start fresh
         Council:Add(Player:Get("Player1"))
         Council:Add(Player:Get("Player2"))
         assert.are.equal(2, Council:GetNum())
      end)

      it("should handle contains", function()
         Council:Set{}
         Council:Add(Player:Get("Player1"))
         assert.True(Council:Contains(Player:Get("Player1")))
         assert.False(Council:Contains(Player:Get("Player2")))
      end)

      it("should handle remove", function()
         Council:Set{}
         Council:Add(Player:Get("Player1"))
         Council:Add(Player:Get("Player2"))
         assert.are.equal(2, Council:GetNum())
         assert.True(Council:Contains(Player:Get("Player1")))
         assert.True(Council:Contains(Player:Get("Player2")))
         Council:Remove(Player:Get("Player1"))
         assert.False(Council:Contains(Player:Get("Player1")))
         assert.are.equal(1, Council:GetNum())
      end)

      it("should error out on invalid player object", function()
         assert.has.errors(function()
            Council:Add("test")
         end, "Not a valid 'Player' object")
         assert.has.errors(function()
            Council:Remove{}
         end, "Not a valid 'Player' object")
      end)
   end)
end)
