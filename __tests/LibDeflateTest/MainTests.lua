local ld = require("LibDeflate")
local lu = require("LuaUnit")

-- Setup LibCompress/Serializer
dofile "../wow_api.lua"
dofile "../../Libs/LibStub/LibStub.lua"
dofile "LibCompress.lua"
local lc = LibStub("LibCompress")
dofile "../../Libs/AceSerializer-3.0/AceSerializer-3.0.lua"
local ser = LibStub("AceSerializer-3.0")

local data = {}
local private = {}

function TestDataIntegrety (args)
   for k,v in pairs(data) do
      lu.assertTrue((ser:Deserialize(v)), "Failed at index: " .. k)
   end
end

TestPerformance = {
   Setup = function()
      private.start = os.clock()
   end,
   TestAllUncompressedEncodedDataIntegretyLibDeflate = function()
      local s = 0
      local d
      for k,v in pairs(data) do
         local d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(v))
         lu.assertEquals(ld:DecompressDeflate(ld:DecodeForWoWAddonChannel(d)), v, "Failed @ index: " .. k)
         s = s + #d
      end
      print("Size " .. s/1000 .. " kB")
   end,
   TestAllUncompressedDataIntegretyLibCompress = function ()
      local s = 0
      local d
      for k,v in pairs(data) do
         d = lc:CompressHuffman(v)
         lu.assertEquals(lc:DecompressHuffman(d), v, "Failed @ index: " .. k)
         s = s + #d
      end
      print("Size " .. s/1000 .. " kB")
   end,
   TestAllUncompressedDataIntegretyLD = function ()
      local s = 0
      local d
      for k,v in pairs(data) do
         d = ld:CompressDeflate(v)
         lu.assertEquals(ld:DecompressDeflate(d), v, "Failed @ index: " .. k)
         s = s + #d
      end
      print("Size " .. s/1000 .. " kB")
   end,
   TestEncodeForPrint = function()
      print(ld:EncodeForPrint(ld:CompressDeflate(data.mldb_small)))
   end,
   teardown = function()
      print("Time taken:", os.clock() - private.start)
   end,
}

local function DoPerformanceTests (input)
   print("\n\tOriginal:", #input/1000 .. " kB")
   local s = os.clock()
   local d = lc:CompressHuffman(input)
   print("\tCompress:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input))
   print("\tDeflate:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressZlib(input))
   print("\tZlib:   ", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input, {level = 3}))
   print("\tLevel 3:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input, {level = 4}))
   print("\tLevel 4:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input, {level = 5}))
   print("\tLevel 5:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input, {level = 6}))
   print("\tLevel 6:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input, {level = 7}))
   print("\tLevel 7:", #d/1000 .. " kB", os.clock() - s)
   s = os.clock()
   d = ld:EncodeForWoWAddonChannel(ld:CompressDeflate(input, {level = 8}))
   print("\tLevel 8:", #d/1000 .. " kB", os.clock() - s)
   print "----------------------------------------------------"
end


TestSizesAndTime = {
   TestMldbSmall = function (args)
      DoPerformanceTests(data.mldb_small)
   end,
   TestCouncil_1 = function (args)
      DoPerformanceTests(data.council_1)
   end,
   TestCandidates_1 = function (args)
      DoPerformanceTests(data.candidates_1)
   end,
   TestPlayerinfo_1 = function (args)
      DoPerformanceTests(data.playerinfo_1)

   end,
   TestTradeable_1 = function (args)
      DoPerformanceTests(data.tradeable_1)
   end,
   TestTradeable_2 = function (args)
      DoPerformanceTests(data.tradeable_2)
   end,
   TestTradeable_3 = function (args)
      DoPerformanceTests(data.tradeable_3)
   end,

   TestLootTable_1 = function (args)
      DoPerformanceTests(data.loottable_1)
   end,
   TestLootTable_2 = function (args)
      DoPerformanceTests(data.loottable_2)
   end,
   TestLootTable_3 = function (args)
      DoPerformanceTests(data.loottable_3)
   end,

   TestHistory_1= function (args)
      DoPerformanceTests(data.history_1)
   end,
   TestVerTest = function (args)
      DoPerformanceTests(data.verTest)
   end,
   TestLooted= function (args)
      DoPerformanceTests(data.looted)
   end,
}

data = {
   mldb_small = "^1^SMLdb^T^N1^T^SallowNotes^B^Stimeout^N60^SselfVote^B^Sresponses^T^Sdefault^T^t^t^SmultiVote^B^Sbuttons^T^Sdefault^T^t^t^SnumButtons^N3^t^t^^",

   council_1 = "^1^Scouncil^T^N1^T^N1^SAelieana-Kazzak^N2^SCorik-Kazzak^N3^SUnigo-Kazzak^t^t^^",

   candidates_1 = "^1^Scandidates^T^N1^T^SDaburà-Kazzak^T^Srole^STANK^SspecID^N250^Senchant_lvl^N13^Sclass^SDEATHKNIGHT^Senchanter^B^Srank^SGuild~`Master^t^SLactia-Kazzak^T^Srole^SDAMAGER^SspecID^N64^Senchant_lvl^N0^Sclass^SMAGE^Srank^SAlt^t^SSoopistab-Kazzak^T^Srole^SDAMAGER^SspecID^N259^Senchant_lvl^N0^Sclass^SROGUE^Srank^SAlt^t^SHanh-Kazzak^T^Srole^STANK^Senchant_lvl^N0^Sclass^SWARRIOR^Srank^SRaider^t^t^t^^",

   playerinfo_1 = "^1^SplayerInfo^T^N1^SBuffysummers-Kazzak^N2^SDEMONHUNTER^N3^SDAMAGER^N4^SAlt^N6^N0^N7^N364.625^N8^N577^t^^",

   tradeable_1 = "^1^Stradable^T^N1^S|cffa335ee|Hitem:159333::::::::120:259::16:3:5010:1542:4786:::|h[Cincture~`of~`the~`Azerite~`Arsenal]|h|r^t^^",
   tradeable_2 = "^1^Stradable^T^N1^S|cffa335ee|Hitem:159293::::::::120:250::16:3:5010:1542:4786:::|h[Turncoat's~`Cape]|h|r^t^^",
   tradeable_3 = "^1^Snot_tradeable^T^N1^S|cffa335ee|Hitem:158348::::::::120:258::16:3:5005:1527:4786:::|h[Wraps~`of~`Everliving~`Fealty]|h|r^N2^S282737^t^^",

   loottable_1 = "^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_WAIST^Silvl^N395^Slink^S|cffa335ee|Hitem:160734::::::::120:250::6:3:4800:1517:4783:::|h[Cord~`of~`Animated~`Contagion]|h|r^Sowner^SRaifu-Kazzak^SsubType^SCloth^Stexture^N2059662^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^t^t^^",
   loottable_2 = "^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_HAND^Silvl^N370^Slink^S|cffa335ee|Hitem:160618::::::::120:267::5:3:4799:1492:4786:::|h[Gloves~`of~`Descending~`Madness]|h|r^Sowner^STheørydh-Kazzak^SsubType^SLeather^Stexture^N2021684^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^t^t^^",
   loottable_3 = "^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_HAND^Silvl^N370^Slink^S|cffa335ee|Hitem:160626::::::::120:267::5:3:4799:1492:4786:::|h[Gloves~`of~`Involuntary~`Amputation]|h|r^Sowner^SAnasara-Kazzak^SsubType^SMail^Stexture^N1991835^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^t^t^^",

   rolls_1 = "^1^Srolls^T^N1^N1^N2^T^SKavhi-Kazzak^N65^SKrànk-Kazzak^N45^SLagg-Quel'Thalas^N68^SCiumegu-Kazzak^N100^SNylia-Kazzak^N64^SIndraka-Kazzak^N43^SKaevh-Kazzak^N13^SAnasara-Kazzak^N80^SHakuei-Kazzak^N14^SStalla-Kazzak^N99^SMestertyv-Kazzak^N74^SYimyims-Kazzak^N53^SChargingdead-Kazzak^N48^SAmphy-Kazzak^N16^STheørydh-Kazzak^N6^SVökar-Kazzak^N21^SPathripss-Kazzak^N33^SValianara-Kazzak^N47^SLactia-Kazzak^N31^SSoapea-Kazzak^N34^t^t^^",


   history_1 = "^1^Shistory^T^N1^SVökar-Kazzak^N2^T^SmapID^N1822^Sid^S1539379039-0^Sinstance^SSiege~`of~`Boralus-Mythic~`Keystone^Sclass^SWARLOCK^Sdate^S13/10/18^Sresponse^SPersonal~`Loot~`-~`Non~`tradeable^SgroupSize^N5^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:159237::::::::120:268::16:3:5010:1542:4786:::|h[Captain's~`Dustfinders]|h|r^SdifficultyID^N8^Sboss^SViq'Goth^SresponseID^SPL^Stime^S00:17:19^Scolor^T^N1^N1^N2^N0.6^N3^N0^N4^N1^t^t^t^^",

   verTest = "^1^SverTest^T^N1^S2.9.2^t^^",
   looted = "^1^Slooted^T^N1^S288644^t^^",
}

os.exit(lu.LuaUnit.run("-v"))
