local lu = require("luaunit")

if not RCLootCouncil then dofile "../Init.lua" end

local rc = RCLootCouncil
local private = {}
local debug = false
local db = rc.db

rc.db.itemStorage = {
   {
      link = "|cffa335ee|Hitem:160623::::::::120:577::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r", -- private.items[1]
      type = "to_trade",
      time_added = 1234,
   }
}

-- Init some globals used
NUM_BAG_SLOTS = 4
GetContainerNumSlots = function (c)
   return c == 0 and 0 or 30
end
GetContainerItemLink = function (c,s)
   return private.items[s]
end

-- Init some RCLootCouncil mockups
function rc:Getdb ()
   return self.db
end
function rc:ItemIsItem(item1, item2)
	if type(item1) ~= "string" or type(item2) ~= "string" then return item1 == item2 end
	local pattern = "|Hitem:(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):(%d*):%d*:%d*:%d*"
	local replacement = "|Hitem:%1:%2:%3:%4:%5:%6:%7:::" -- Compare link with uniqueId, linkLevel and SpecID removed
	return item1:gsub(pattern, replacement) == item2:gsub(pattern, replacement)
end
function rc:GetContainerItemTradeTimeRemaining (c,s)
   return c * s * 1000
end
dofile "../../Classes/ItemStorage.lua" -- Load the rc.ItemStorage namespace

-------------------------------------------
-- Tests
-------------------------------------------
TestBasicFunctions = {
   Setup = function()
      dofile "../../Classes/ItemStorage.lua"
      rc.db.itemStorage = {
      {
         link = "|cffa335ee|Hitem:160623::::::::120:577::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r", -- private.items[1]
         type = "to_trade",
         time_added = 1234,
      }
   }
      rc:InitItemStorage()
   end,
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
   TestGetItem = function (args)
      lu.assertEquals(rc.ItemStorage:GetItem(private.items[1]).link, private.items[1])
      lu.assertNil(rc.ItemStorage:GetItem("nonexistant"))
   end,
   TestGetAllItems = function ()
      lu.assertEquals(#rc.ItemStorage:GetAllItems(), 1)
      local Item = rc.ItemStorage:StoreItem(private.items[4], "other", nil)
      local all = rc.ItemStorage:GetAllItems()
      lu.assertEquals(#all, 2)
      lu.assertEquals(all[2], Item)
   end,
   TestGetAllItemsLessTimeRemaining = function (args)
      lu.assertEquals(#rc.ItemStorage:GetAllItemsLessTimeRemaining(), 0)
      lu.assertEquals(#rc.ItemStorage:GetAllItemsLessTimeRemaining(1000), 1)
      local Item = rc.ItemStorage:StoreItem(private.items[5], nil,nil)
      lu.assertEquals(#rc.ItemStorage:GetAllItemsLessTimeRemaining(5000), 2)
      lu.assertEquals(rc.ItemStorage:GetAllItemsLessTimeRemaining(5000)[2], Item)
   end,
   TestGetAllItemsMultiPred = function (args)
      lu.assertEquals(rc.ItemStorage:GetAllItemsMultiPred(
         function(item)
            return item.type == "to_trade"
         end)[1].link,
         private.items[1]
      )
      local Item = rc.ItemStorage:StoreItem(private.items[5], "other",nil)
      lu.assertEquals(rc.ItemStorage:GetAllItemsMultiPred(
         function(item)
            return item.type == "other"
         end)[1],
         Item
      )
      lu.assertEquals(#rc.ItemStorage:GetAllItemsMultiPred(
         function(item)
            return item.type == "to_trade" or item.type == "other"
         end,
         function(item)
            return item.time_added == 0
         end),
         2
      )
   end,
   TestGetItemContainerSlot = function (args)
      lu.assertEquals({rc.ItemStorage:GetItemContainerSlot(private.items[1])}, {1,1})
      rc.ItemStorage:StoreItem(private.items[4], nil,nil)
      lu.assertEquals({rc.ItemStorage:GetItemContainerSlot(private.items[4])}, {1,4})
   end
}

TestPersistantStorage = {
   Setup = function()
      dofile "../../Classes/ItemStorage.lua"
      rc.db.itemStorage = {
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
      lu.assertNil(rc.db.itemStorage[1])
      lu.assertEquals(rc.ItemStorage:GetAllItems(), {})
   end,
   TestRemoveItemWithItem = function ()
      rc:InitItemStorage()
      local Item = rc.ItemStorage:GetItem(private.items[1])
      rc.ItemStorage:RemoveItem(Item)
      lu.assertNil(rc.db.itemStorage[1])
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
