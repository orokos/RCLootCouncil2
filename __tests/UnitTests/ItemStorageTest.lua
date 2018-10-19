local lu = require("luaunit")

dofile "../wow_api.lua"
dofile "../../Libs/LibStub/LibStub.lua"
dofile "../../Libs/AceAddon-3.0/AceAddon-3.0.lua"

-- Enable some globals
gsub = string.gsub
strfind = string.find
strsplit = string.split
tinsert = table.insert
tremove = table.remove
strrep = string.rep

local rc = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil")
local private = {}
local debug = false

local db = {
   itemStorage = {
      {
         link = "|cffa335ee|Hitem:160623::::::::120:577::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r", -- private.items[1]
         type = "to_trade",
         time_added = 1234,
      }
   },
}

-- Init some globals used
NUM_BAG_SLOTS = 4
GetContainerNumSlots = function ()
   return 30
end
GetContainerItemLink = function (c,s)
   return private.items[s]
end

-- Init some RCLootCouncil mockups
function rc:Getdb ()
   return db
end
function rc:ItemIsItem(item1, item2)
	if type(item1) ~= "string" or type(item2) ~= "string" then return item1 == item2 end
	local pattern = "|Hitem:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*"
	local replacement = "|Hitem:%1:%2:%3:%4:%5:%6:%7:::" -- Compare link with uniqueId, linkLevel and SpecID removed
	return item1:gsub(pattern, replacement) == item2:gsub(pattern, replacement)
end
function rc:DebugLog (...)
   return debug and print("DebugLog:", ...)
end
function rc:Debug(...)
   return debug and print("Debug:", ...)
end
function rc:GetContainerItemTradeTimeRemaining (c,s)
   return c * s * 1000
end
dofile "../../Classes/ItemStorage.lua" -- Load the rc.ItemStorage namespace

-------------------------------------------
-- Tests
-------------------------------------------
TestBasicFunctions = {
   TestStorage = function ()
      local Item = rc.ItemStorage:StoreItem(private.items[1], "to_trade", nil)
      lu.assertIsTable(Item)
      lu.assertEquals(Item.link, private.items[1])
      lu.assertEquals(Item.type, "to_trade")
   end,

   TestStorage2 = function ()
      local Item = rc.ItemStorage:StoreItem(private.items[2], nil, nil)
      lu.assertIsTable(Item)
      lu.assertEquals(Item.link, private.items[2])
      lu.assertEquals(Item.type, "other")
   end,

   TestWrongType = function ()
      lu.assertError(rc.ItemStorage.StoreItem, rc.ItemStorage, private.items[1], "wrongType",nil)
   end,
}

TestPersistantStorage = {
   Setup = function()
      dofile "../../Classes/ItemStorage.lua"
      db.itemStorage = {
      {
         link = "|cffa335ee|Hitem:160623::::::::120:577::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r", -- private.items[1]
         type = "to_trade",
         time_added = 1234,
      }
   }
   end,
   TestInitItemStorage = function ()
      rc:InitItemStorage()
      local Item = rc.ItemStorage:GetItem(private.items[1])
      lu.assertIsTable(Item)
      lu.assertEquals(Item.link, private.items[1])
      lu.assertTrue(Item.time_added == 1234)
      lu.assertEquals(Item.type, "to_trade")
   end,
   TestWrongGetItem = function()
      lu.assertErrorMsgEquals("'item' is not a string/ItemLink", rc.ItemStorage.GetItem, rc.ItemStorage, nil)
   end,
   TestRemoveItemWithString = function ()
      rc:InitItemStorage()
      rc.ItemStorage:RemoveItem(private.items[1])
      lu.assertNil(db.itemStorage[1])
      lu.assertEquals(rc.ItemStorage:GetAllItems(), {})
   end,
   TestRemoveItemWithItem = function ()
      rc:InitItemStorage()
      local Item = rc.ItemStorage:GetItem(private.items[1])
      rc.ItemStorage:RemoveItem(Item)
      lu.assertNil(db.itemStorage[1])
      lu.assertEquals(rc.ItemStorage:GetAllItems(), {})
   end,
   TestRemoveAllItemsOfType = function()
      rc:InitItemStorage()
      local Item = rc.ItemStorage:StoreItem(private.items[2], "other", nil)
      lu.assertEquals(#db.itemStorage, 2)
      rc.ItemStorage:StoreItem(private.items[3], "to_trade", nil)
      lu.assertEquals(#db.itemStorage, 3)
      rc.ItemStorage:RemoveAllItemsOfType("to_trade")
      lu.assertEquals(#db.itemStorage, 1)
      printtable(db)
      lu.assertEquals(db.itemStorage[1], Item)

   end,
}


private.items = {
   "|cffa335ee|Hitem:160623::::::::120:577::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
   "|cffa335ee|Hitem:160734::::::::120:267::5:3:4799:1492:4786:::|h[Cord of Animated Contagion]|h|r",
   "|cffa335ee|Hitem:160716::::::::120:267::5:3:4799:1492:4786:::|h[Blighted Anima Greaves]|h|r",
   "|cff9d9d9d|Hitem:155615::::::::120:256::::::|h[Pestilent~`Muck]|h|r",
   "|cffa335ee|Hitem:160643::::::::120:577::5:3:4799:1492:4786:::|h[Fetid~`Horror's~`Tanglecloak]|h|r",

}

os.exit(lu.LuaUnit.run("-v"))
