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
local history_big
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
   TestMldbMedium = function (args)
      DoPerformanceTests(data.mldb_medium)
   end,
   TestCouncil_1 = function (args)
      DoPerformanceTests(data.council_1)
   end,
   TestCandidates_1 = function (args)
      DoPerformanceTests(data.candidates_1)
   end,
   TestCandidates_2 = function (args)
      DoPerformanceTests(data.candidates_2)
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
   TestLootAck1 = function (args)
      DoPerformanceTests(data.loot_ack1)
   end,
   TestLootAck2 = function (args)
      DoPerformanceTests(data.loot_ack2)
   end,
}

TestHistoryBig = function()
   local s = os.clock()
   local serialized = ser:Serialize(history_big)
   print("\nSerialize time taken:", os.clock() -s )
   DoPerformanceTests(serialized)
end


data = {
   mldb_small = "^1^SMLdb^T^N1^T^SallowNotes^B^Stimeout^N60^SselfVote^B^Sresponses^T^Sdefault^T^t^t^SmultiVote^B^Sbuttons^T^Sdefault^T^t^t^SnumButtons^N3^t^t^^",

   mldb_medium = "^1^SMLdb^T^N1^T^SallowNotes^B^Stimeout^N90^SselfVote^B^Sresponses^T^Sdefault^T^N1^T^Scolor^T^N1^N1^N2^N0.1^N3^N0^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SBest~`in~`Slot^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.54^N3^N0.09^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SStat~`upgrade^Ssort^N2^t^N3^T^Scolor^T^N1^N0.99^N2^N0.9^N3^N0.27^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SIlvl~`upgrade^Ssort^N3^t^N4^T^Scolor^T^N1^N0.16^N2^N0.98^N3^N0.17^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^SOffspec^Ssort^N4^t^N5^T^Scolor^T^N1^N0^N2^N0.52^N3^N0.98^N4^N1^Scolor^T^N1^N1^N2^N1^N3^N1^N4^N1^t^Stext^SResponse^t^Stext^STransmogrification^Ssort^N5^t^t^SAZERITE^T^N1^T^Scolor^T^N1^N1^N2^N0^N3^N0.07^N4^N1^t^Stext^SBest~`in~`Slot^Ssort^N1^t^N2^T^Scolor^T^N1^N1^N2^N0.51^N3^N0^N4^N1^t^Stext^SMajor~`trait~`upgrade^Ssort^N2^t^N3^T^Scolor^T^N1^N0.92^N2^N1^N3^N0^N4^N1^t^Stext^SMinor~`trait~`upgrade^Ssort^N3^t^N4^T^Scolor^T^N1^N0^N2^N1^N3^N0.02^N4^N1^t^Stext^SIlvl~`upgrade^Ssort^N4^t^N5^T^Scolor^T^N1^N0.09^N2^N0.25^N3^N1^N4^N1^t^Stext^SOffspec^Ssort^N5^t^N6^T^Scolor^T^N1^N0.85^N2^N0.12^N3^N1^N4^N1^t^Stext^STransmogrification^Ssort^N6^t^t^t^ShideVotes^B^SmultiVote^B^Sbuttons^T^Sdefault^T^N1^T^Stext^SBiS^t^N2^T^Stext^SStat~`upgrade^t^N3^T^Stext^SIlvl~`upgrade^t^N4^T^Stext^SOffspec^t^N5^T^Stext^STransmog^t^SnumButtons^N5^t^SAZERITE^T^N1^T^Stext^SBiS^t^N2^T^Stext^SMajor~`trait~`upgrade^t^N3^T^Stext^SMinor~`trait~`upgrade^t^N4^T^Stext^SIlvl~`upgrade~`(no~`trait)^t^N5^T^Stext^SOffspec^t^N6^T^Stext^STransmog^t^t^t^SnumButtons^N5^t^t^^",

   council_1 = "^1^Scouncil^T^N1^T^N1^SAelieana-Kazzak^N2^SCorik-Kazzak^N3^SUnigo-Kazzak^t^t^^",

   candidates_1 = "^1^Scandidates^T^N1^T^SDaburà-Kazzak^T^Srole^STANK^SspecID^N250^Senchant_lvl^N13^Sclass^SDEATHKNIGHT^Senchanter^B^Srank^SGuild~`Master^t^SLactia-Kazzak^T^Srole^SDAMAGER^SspecID^N64^Senchant_lvl^N0^Sclass^SMAGE^Srank^SAlt^t^SSoopistab-Kazzak^T^Srole^SDAMAGER^SspecID^N259^Senchant_lvl^N0^Sclass^SROGUE^Srank^SAlt^t^SHanh-Kazzak^T^Srole^STANK^Senchant_lvl^N0^Sclass^SWARRIOR^Srank^SRaider^t^t^t^^",

   candidates_2 = "^1^Scandidates^T^N1^T^SChalky-Ravencrest^T^Srole^SDAMAGER^Senchant_lvl^N0^Sclass^SROGUE^Srank^SRenegades~`Trial^t^SPotdisc-Ravencrest^T^Srole^SHEALER^SspecID^N256^Senchant_lvl^N0^Sclass^SPRIEST^Srank^SRenegades^t^STsompanós-Ravencrest^T^Srole^SDAMAGER^SspecID^N70^Senchant_lvl^N95^Sclass^SPALADIN^Senchanter^B^Srank^SRenegades^t^SCharlamane-Ravencrest^T^Srole^SDAMAGER^Senchant_lvl^N118^Sclass^SPALADIN^Senchanter^B^Srank^SRenegades^t^SVaxthel-Ravencrest^T^Srole^SDAMAGER^SspecID^N64^Senchant_lvl^N0^Sclass^SMAGE^Srank^SRenegades^t^SValhorth-Ravencrest^T^Srole^SDAMAGER^SspecID^N262^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SRenegades^t^SDemonicdave-Ravencrest^T^Srole^STANK^Senchant_lvl^N71^Sclass^SDEMONHUNTER^Senchanter^B^Srank^SRenegades^t^SSwiftshandee-Ravencrest^T^Srole^SDAMAGER^SspecID^N253^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SRenegades^t^SRageasaurus-Ravencrest^T^Srole^SDAMAGER^Senchant_lvl^N0^Sclass^SWARRIOR^Srank^SRenegades~`Trial^t^STomblicker-Ravencrest^T^Srole^SDAMAGER^SspecID^N265^Senchant_lvl^N1^Sclass^SWARLOCK^Senchanter^B^Srank^SRenegades~`Trial^t^SCrawde-Ravencrest^T^Srole^STANK^SspecID^N581^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SAlt^t^SMangochops-Ravencrest^T^Srole^SHEALER^Senchant_lvl^N110^Sclass^SMONK^Senchanter^B^Srank^SOfficer^t^SUlftbeams-Ravencrest^T^Srole^SDAMAGER^SspecID^N577^Senchant_lvl^N0^Sclass^SDEMONHUNTER^Srank^SRenegades~`Trial^t^SIbu-Ravencrest^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SDRUID^Srank^SAlt^t^SCretino-Ravencrest^T^Srole^SDAMAGER^Senchant_lvl^N0^Sclass^SROGUE^Srank^SRenegades^t^SEliarra-Ravencrest^T^Srole^SHEALER^Senchant_lvl^N0^Sclass^SPRIEST^Srank^SRenegades^t^SAngri-Ravencrest^T^Srole^SDAMAGER^SspecID^N253^Senchant_lvl^N0^Sclass^SHUNTER^Srank^SRenegades^t^SBarrow-Ravencrest^T^Srole^SDAMAGER^Senchant_lvl^N0^Sclass^SDRUID^Srank^SOfficer^t^SNaditu-Ravencrest^T^Srole^SDAMAGER^SspecID^N258^Senchant_lvl^N104^Sclass^SPRIEST^Senchanter^B^Srank^SRenegades~`Trial^t^SThuun-Ravencrest^T^Srole^SDAMAGER^SspecID^N263^Senchant_lvl^N0^Sclass^SSHAMAN^Srank^SRenegades^t^SGarandorr-Ravencrest^T^Srole^SDAMAGER^SspecID^N250^Senchant_lvl^N0^Sclass^SDEATHKNIGHT^Srank^SAlt^t^t^t^^",

   playerinfo_1 = "^1^SplayerInfo^T^N1^SBuffysummers-Kazzak^N2^SDEMONHUNTER^N3^SDAMAGER^N4^SAlt^N6^N0^N7^N364.625^N8^N577^t^^",

   tradeable_1 = "^1^Stradable^T^N1^S|cffa335ee|Hitem:159333::::::::120:259::16:3:5010:1542:4786:::|h[Cincture~`of~`the~`Azerite~`Arsenal]|h|r^t^^",
   tradeable_2 = "^1^Stradable^T^N1^Sitem:159293::::::::120:250::16:3:5010:1542:4786^t^^",
   tradeable_3 = "^1^Snot_tradeable^T^N1^S|cffa335ee|Hitem:158348::::::::120:258::16:3:5005:1527:4786:::|h[Wraps~`of~`Everliving~`Fealty]|h|r^N2^S282737^t^^",

   loottable_1 = "^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_WAIST^Silvl^N395^Slink^S|cffa335ee|Hitem:160734::::::::120:250::6:3:4800:1517:4783:::|h[Cord~`of~`Animated~`Contagion]|h|r^Sowner^SRaifu-Kazzak^SsubType^SCloth^Stexture^N2059662^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^t^t^^",
   loottable_2 = "^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_WAIST^Silvl^N370^Slink^S|cffa335ee|Hitem:160633::::::::120:104::5:4:4799:1808:1492:4786:::|h[Titanspark~`Energy~`Girdle]|h|r^Sowner^SSwiftshandee-Ravencrest^SsubType^SMail^Stexture^N1991830^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N2^T^SequipLoc^SINVTYPE_FINGER^Silvl^N370^Slink^S|cffa335ee|Hitem:160647::::::::120:104::5:3:4799:1492:4786:::|h[Ring~`of~`the~`Infinite~`Void]|h|r^Sowner^SFrostitutê-Ravencrest^SsubType^SMiscellaneous^Stexture^N2000824^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N3^T^SequipLoc^SINVTYPE_WEAPON^Silvl^N370^Slink^S|cffa335ee|Hitem:160687::::::::120:104::5:4:4799:42:1492:4786:::|h[Containment~`Analysis~`Baton]|h|r^Sowner^SPotdisc-Ravencrest^SsubType^SOne-Handed~`Maces^Stexture^N2055069^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^t^t^^",
   loottable_3 = "^1^SlootTable^T^N1^T^N1^T^SequipLoc^SINVTYPE_SHOULDER^Silvl^N370^Slink^S|cffa335ee|Hitem:160641::::::::120:104::5:3:4823:1492:4786:::|h[Chitinspine~`Pauldrons]|h|r^Sowner^STsompanós-Ravencrest^SsubType^SPlate^Stexture^N2054631^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N2^T^SequipLoc^SINVTYPE_CHEST^Silvl^N370^Slink^S|cffa335ee|Hitem:160725::::::::120:104::5:3:4823:1492:4786:::|h[C'thraxxi~`General's~`Hauberk]|h|r^Sowner^SEnkuu-Ravencrest^SsubType^SMail^Stexture^N1991834^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N3^T^SequipLoc^SINVTYPE_FINGER^Silvl^N370^Slink^S|cffa335ee|Hitem:160646::::::::120:104::5:3:4799:1492:4786:::|h[Band~`of~`Certain~`Annihilation]|h|r^Sowner^SKossey-Ravencrest^SsubType^SMiscellaneous^Stexture^N2000818^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N4^T^SequipLoc^SINVTYPE_FINGER^Silvl^N370^Slink^S|cffa335ee|Hitem:160646::::::::120:104::5:3:4799:1492:4786:::|h[Band~`of~`Certain~`Annihilation]|h|r^Sowner^SRageasaurus-Ravencrest^SsubType^SMiscellaneous^Stexture^N2000818^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N5^T^SequipLoc^SINVTYPE_FINGER^Silvl^N370^Slink^S|cffa335ee|Hitem:160646::::::::120:104::5:3:4799:1492:4786:::|h[Band~`of~`Certain~`Annihilation]|h|r^Sowner^SMangochops-Ravencrest^SsubType^SMiscellaneous^Stexture^N2000818^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^N6^T^SequipLoc^SINVTYPE_TRINKET^Silvl^N370^Slink^S|cffa335ee|Hitem:160656::::::::120:104::5:3:4799:1492:4786:::|h[Twitching~`Tentacle~`of~`Xalzaix]|h|r^Sowner^SFrostitutê-Ravencrest^SsubType^SMiscellaneous^Stexture^N254105^SisSent^b^Sawarded^b^Sclasses^N4294967295^Sboe^b^Squality^N4^t^t^t^^",

   loot_ack1 = "^1^SlootAck^T^N1^SPotdisc-Ravencrest^N2^N256^N3^N369.1875^N4^T^Sresponse^T^N2^B^N3^B^N4^B^t^Sdiff^T^N1^N-5^N2^N0^N3^N-10^N4^N-5^t^Sgear1^T^N1^Sitem:159294::::::::120:256::16:3:5008:1547:4783^N2^Sitem:159241::::::::120:256::35:3:5055:1542:4786^N3^Sitem:160617::::::::120:256::5:3:4799:1502:4783^N4^Sitem:159262::::::::120:256::16:3:5006:1547:4784^t^Sgear2^T^t^t^t^^",
   loot_ack2 = "^1^SlootAck^T^N1^SAngri-Ravencrest^N2^N253^N3^N369.0625^N4^T^Sresponse^T^N1^B^N2^B^t^Sdiff^T^N1^N0^N2^N0^N3^N0^t^Sgear1^T^N1^Sitem:158046::::::::120:253::28:3:1562:5138:5383^N2^Sitem:158046::::::::120:253::28:3:1562:5138:5383^N3^Sitem:160645:5939:::::::120:253::5:3:4799:1492:4786^t^Sgear2^T^N3^Sitem:160647:5939:::::::120:253::5:3:4799:1492:4786^t^t^t^^",

   rolls_1 = "^1^Srolls^T^N1^N1^N2^T^SKavhi-Kazzak^N65^SKrànk-Kazzak^N45^SLagg-Quel'Thalas^N68^SCiumegu-Kazzak^N100^SNylia-Kazzak^N64^SIndraka-Kazzak^N43^SKaevh-Kazzak^N13^SAnasara-Kazzak^N80^SHakuei-Kazzak^N14^SStalla-Kazzak^N99^SMestertyv-Kazzak^N74^SYimyims-Kazzak^N53^SChargingdead-Kazzak^N48^SAmphy-Kazzak^N16^STheørydh-Kazzak^N6^SVökar-Kazzak^N21^SPathripss-Kazzak^N33^SValianara-Kazzak^N47^SLactia-Kazzak^N31^SSoapea-Kazzak^N34^t^t^^",


   history_1 = "^1^Shistory^T^N1^SVökar-Kazzak^N2^T^SmapID^N1822^Sid^S1539379039-0^Sinstance^SSiege~`of~`Boralus-Mythic~`Keystone^Sclass^SWARLOCK^Sdate^S13/10/18^Sresponse^SPersonal~`Loot~`-~`Non~`tradeable^SgroupSize^N5^SisAwardReason^b^SlootWon^S|cffa335ee|Hitem:159237::::::::120:268::16:3:5010:1542:4786:::|h[Captain's~`Dustfinders]|h|r^SdifficultyID^N8^Sboss^SViq'Goth^SresponseID^SPL^Stime^S00:17:19^Scolor^T^N1^N1^N2^N0.6^N3^N0^N4^N1^t^t^t^^",

   verTest = "^1^SverTest^T^N1^S2.9.2^t^^",
   looted = "^1^Slooted^T^N1^S288644^t^^",
}

history_big =
   {
      ["Vainglorious-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "WARRIOR",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:10:47",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160679::::::::120:104::3:3:4798:1477:4786:::|h[Khor, Hammer of the Corrupted]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536775847-4",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "16/09/18",
            ["class"] = "WARRIOR",
            ["groupSize"] = 10,
            ["boss"] = "G'huun",
            ["time"] = "19:39:44",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159616::::::::120:104::23:3:4779:1512:4786:::|h[Gore-Crusted Butcher's Block]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "ilvl Upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160654::::::::120:104::3:3:4798:1477:4786:::|h[Vanquished Tendril of G'huun]|h|r",
            ["id"] = "1537123184-3",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158712::::::::120:104::23:3:4779:1517:4783:::|h[Rezan's Gleaming Eye]|h|r",
            ["votes"] = 0,
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159457:5932:::::::120:104::35:4:4946:4802:1527:4783:::|h[Risen Lord's Oversized Gauntlets]|h|r",
            ["id"] = "1537726644-4",
            ["response"] = "Offspec",
            ["date"] = "23/09/18",
            ["class"] = "WARRIOR",
            ["isAwardReason"] = false,
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160635::::::::120:104::3:3:4798:1477:4786:::|h[Waste Disposal Crushers]|h|r",
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:17:24",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 4,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [3]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159410::154127::::::120:104::16:4:4780:4802:1522:4783:::|h[Zancha's Venerated Greatbelt]|h|r",
            ["id"] = "1537986239-6",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "WARRIOR",
            ["difficultyID"] = 15,
            ["response"] = "ilvl Upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "MOTHER",
            ["time"] = "19:23:59",
            ["lootWon"] = "|cffa335ee|Hitem:160638::::::::120:104::5:3:4799:1492:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["votes"] = 0,
            ["responseID"] = 3,
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [4]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160639::::::::120:104::5:3:4799:1492:4786:::|h[Greaves of Unending Vigil]|h|r",
            ["id"] = "1537995325-23",
            ["groupSize"] = 20,
            ["date"] = "26/09/18",
            ["class"] = "WARRIOR",
            ["difficultyID"] = 15,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "Zek'voz",
            ["time"] = "21:55:25",
            ["lootWon"] = "|cffa335ee|Hitem:160718::::::::120:104::5:3:4799:1492:4786:::|h[Greaves of Creeping Darkness]|h|r",
            ["votes"] = 0,
            ["responseID"] = 4,
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "WARRIOR",
            ["groupSize"] = 17,
            ["boss"] = "MOTHER",
            ["time"] = "19:23:48",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5939:154127::::::120:104::23:4:4779:4802:1512:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:3:4798:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1538331828-6",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159463:5939:154127::::::120:104::23:4:4779:4802:1522:4783:::|h[Loop of Pulsing Veins]|h|r",
            ["isAwardReason"] = false,
         }, -- [6]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159412::::::::120:104::16:3:4780:1537:4784:::|h[Auric Puddle Stompers]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Transmogrification",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "WARRIOR",
            ["boss"] = "G'huun",
            ["groupSize"] = 10,
            ["time"] = "20:59:58",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160733::::::::120:104::3:4:4798:1808:1477:4786:::|h[Hematocyst Stompers]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 5,
            ["id"] = "1538337598-5",
            ["instance"] = "Uldir-Normal",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARRIOR",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:05",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780245-81",
         }, -- [8]
      },
      ["Korpe-Ravencrest"] = {
      },
      ["Tidals-Ravencrest"] = {
      },
      ["Fróstheart-Ravencrest"] = {
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536869803-2",
            ["class"] = "DEATHKNIGHT",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:16:43",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Viq'Goth",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Siege of Boralus-Mythic",
         }, -- [1]
         {
            ["mapID"] = 1862,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536872167-9",
            ["class"] = "DEATHKNIGHT",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:56:07",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159455::::::::120:104::23:3:4819:1512:4786:::|h[Pauldrons of the Horned Horror]|h|r",
            ["boss"] = "Gorak Tul",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Waycrest Manor-Mythic",
         }, -- [2]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536875183-21",
            ["class"] = "DEATHKNIGHT",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "22:46:23",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Mogul Razdunk",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
         }, -- [3]
         {
            ["mapID"] = 1763,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536877577-25",
            ["class"] = "DEATHKNIGHT",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "23:26:17",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160212::::::::120:104::23:4:4779:4802:1542:4784:::|h[Shadowshroud Vambraces]|h|r",
            ["boss"] = "Yazma",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Atal'Dazar-Mythic",
         }, -- [4]
         {
            ["mapID"] = 1877,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "DEATHKNIGHT",
            ["instance"] = "Temple of Sethraliss-Mythic",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "22:12:54",
            ["difficultyID"] = 23,
            ["boss"] = "Avatar of Sethraliss",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537045974-1",
         }, -- [5]
      },
      ["Bjæffe-Ravencrest"] = {
      },
      ["Anhility-Ravencrest"] = {
      },
      ["Xorlen-Ravencrest"] = {
      },
      ["Trollomagic-Ravencrest"] = {
      },
      ["Maeglas-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["id"] = "1537126154-9",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160626::::::::120:104::5:3:4799:1492:4786:::|h[Gloves of Involuntary Amputation]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:29:14",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "19/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 17,
            ["votes"] = 0,
            ["time"] = "21:34:47",
            ["itemReplaced1"] = "|cffa335ee|Hitem:161357::::::::120:104::3:3:4822:1477:4786:::|h[Spaulders of the Enveloping Maw]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat Upgrade",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:104::3:3:4822:1477:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["note"] = "AZERITE STATS UPGRADE",
            ["id"] = "1537389287-21",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 21,
            ["boss"] = "MOTHER",
            ["time"] = "19:24:13",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5938:::::::120:104::16:3:5007:1532:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat Upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1537986253-7",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160647:5938:154126::::::120:104::3:4:4798:1808:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["votes"] = 0,
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 21,
            ["boss"] = "Zek'voz",
            ["time"] = "21:55:16",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::5:5:4799:1808:40:1492:4786:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1537995316-21",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160647:5938:154126::::::120:104::3:4:4798:1808:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["votes"] = 0,
         }, -- [4]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1502:4783:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Transmogrification",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "HUNTER",
            ["boss"] = "Zul",
            ["groupSize"] = 18,
            ["time"] = "20:21:35",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1477:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 5,
            ["id"] = "1538335295-3",
            ["instance"] = "Uldir-Normal",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "03/10/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 20,
            ["votes"] = 0,
            ["time"] = "20:40:13",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163401::::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Cincture]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::5:4:4799:1808:1492:4786:::|h[Titanspark Energy Girdle]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["note"] = false,
            ["id"] = "1538595613-14",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521825-2",
            ["class"] = "HUNTER",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:05",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775847-3",
            ["class"] = "HUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:47",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:14",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777014-4",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:29",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778049-32",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:13",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778933-48",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:04",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780244-74",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:23",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781403-102",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:12",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783492-132",
         }, -- [14]
      },
      ["Whistlar-Ravencrest"] = {
      },
      ["Garandor-Ravencrest"] = {
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:163932::::::::120:104::54:3:40:1472:4786:::|h[Wolfpelt Greatcloak]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1536779101-67",
            ["class"] = "DRUID",
            ["difficultyID"] = 14,
            ["groupSize"] = 21,
            ["time"] = "20:05:01",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["votes"] = 0,
            ["boss"] = "Vectis",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "12/09/18",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DRUID",
            ["id"] = "1536783515-149",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160696::::::::120:104::3:3:4798:1477:4786:::|h[Codex of Imminent Ruin]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:35",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["id"] = "1537124480-4",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1502:4783:::|h[Bloodstorm Buckle]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:01:20",
            ["difficultyID"] = 15,
            ["boss"] = "Taloc",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "19:14:12",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160618::::::::120:104::5:3:4799:1497:4783:::|h[Gloves of Descending Madness]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537380852-2",
            ["instance"] = "Uldir-Heroic",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["class"] = "DRUID",
            ["groupSize"] = 21,
            ["boss"] = "MOTHER",
            ["time"] = "19:24:59",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159460:5941:::::::120:104::35:3:5007:1542:4783:::|h[Overseer's Lost Seal]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1537986299-8",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159458:5939:154127::::::120:104::23:4:4779:4802:1512:4786:::|h[Seal of the Regal Loa]|h|r",
            ["votes"] = 0,
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "30/09/18",
            ["class"] = "DRUID",
            ["id"] = "1538333817-17",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160687::::::::120:104::3:4:4798:40:1477:4786:::|h[Containment Analysis Baton]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:56:57",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DRUID",
            ["groupSize"] = 18,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:20:06",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160620::::::::120:104::3:3:4822:1477:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1538335206-0",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "DRUID",
            ["groupSize"] = 18,
            ["boss"] = "Mythrax",
            ["time"] = "20:41:24",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159127::::::::120:104::13::::|h[Darkmoon Deck: Tides]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160656::::::::120:104::3:3:4798:1477:4786:::|h[Twitching Tentacle of Xalzaix]|h|r",
            ["id"] = "1538336484-1",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158163::::::::120:104::26:3:4803:1527:4783:::|h[First Mate's Spyglass]|h|r",
            ["isAwardReason"] = false,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:58:44",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160623::::::::120:104::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538596724-19",
            ["date"] = "03/10/18",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 16,
            ["time"] = "20:43:51",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:104::3:3:4798:1482:4783:::|h[Pathogenic Legwraps]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1538941431-4",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["id"] = "1539196025-8",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160695::::::::120:104::5:3:4799:1492:4786:::|h[Uldir Subject Manifest]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:27:05",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [11]
         {
            ["date"] = "10/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158042::153709::::::120:104::28:4:4803:4802:1547:4784:::|h[Fairweather Trousers]|h|r",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 18,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DRUID",
            ["boss"] = "MOTHER",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "19:28:29",
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:104::5:3:4799:1492:4786:::|h[Pathogenic Legwraps]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["id"] = "1539196109-9",
            ["mapID"] = 1861,
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521845-19",
            ["class"] = "DRUID",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:25",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775859-11",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:59",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:16",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777016-12",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:33",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778053-41",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:35",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778955-64",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:08",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780248-89",
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:48",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781428-122",
         }, -- [19]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539801306-10",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "19:35:06",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1497:4783:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [20]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Mythic",
            ["id"] = "1540155530-0",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "21:58:50",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160618::::::::120:104::6:3:4800:1507:4786:::|h[Gloves of Descending Madness]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 16,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "21/10/18",
         }, -- [21]
      },
      ["Dimebog-Ravencrest"] = {
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:158375::::::::120:104::23:3:4779:1512:4786:::|h[Drape of the Loyal Vassal]|h|r",
            ["mapID"] = 1861,
            ["date"] = "05/09/18",
            ["response"] = "Best in Slot",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["boss"] = "Fetid Devourer",
            ["groupSize"] = 22,
            ["time"] = "20:26:17",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 1,
            ["id"] = "1536175577-1",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
            ["class"] = "WARLOCK",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:17",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::3:3:4798:1482:4783:::|h[Tusk of the Reborn Prophet]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536521837-18",
            ["instance"] = "Uldir-Normal",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "WARLOCK",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:47:31",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160617::::::::120:104::3:3:4798:1477:4786:::|h[Void-Lashed Wristband]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536778051-38",
            ["instance"] = "Uldir-Normal",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "WARLOCK",
            ["id"] = "1536781417-115",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1492:4784:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:37",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["id"] = "1537126152-8",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160615::::::::120:104::5:3:4799:1492:4786:::|h[Leggings of Lingering Infestation]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:29:12",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "WARLOCK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:57:12",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::5:3:4799:1492:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537383432-9",
            ["instance"] = "Uldir-Heroic",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "WARLOCK",
            ["id"] = "1537987140-9",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:00",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [7]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["id"] = "1537991522-15",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "WARLOCK",
            ["difficultyID"] = 15,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:52:02",
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:4:4799:1808:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521836-16",
            ["class"] = "WARLOCK",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:16",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775854-9",
            ["class"] = "WARLOCK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:54",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:18",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777018-16",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:32",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778052-39",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:35",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778955-63",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:08",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780248-90",
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:38",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781418-117",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:30",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783510-147",
         }, -- [16]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536875173-17",
            ["class"] = "WARLOCK",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "22:46:13",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Mogul Razdunk",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
         }, -- [17]
         {
            ["mapID"] = 1763,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536877579-31",
            ["class"] = "WARLOCK",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "23:26:19",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Yazma",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Atal'Dazar-Mythic",
         }, -- [18]
      },
      ["Urganor-Ravencrest"] = {
      },
      ["Calliya-Ravencrest"] = {
      },
      ["Mysticmole-Ravencrest"] = {
      },
      ["Benó-Ravencrest"] = {
      },
      ["Moklu-Ravencrest"] = {
      },
      ["Lamrr-Ravencrest"] = {
      },
      ["Jïnxx-Ravencrest"] = {
      },
      ["Potdisc-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:14",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::3:3:4798:1482:4783:::|h[Tusk of the Reborn Prophet]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536521834-13",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:158315::::::::120:104::23:3:4819:1512:4786:::|h[Secret Spinner's Miter]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1536522123-21",
            ["class"] = "PRIEST",
            ["difficultyID"] = 14,
            ["groupSize"] = 22,
            ["time"] = "20:42:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160719::::::::120:104::3:3:4822:1477:4786:::|h[Visage of the Ascended Prophet]|h|r",
            ["votes"] = 0,
            ["boss"] = "Mythrax",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.04, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 21,
            ["boss"] = "MOTHER",
            ["time"] = "19:34:09",
            ["itemReplaced1"] = "|cffa335ee|Hitem:162544:5939:::::::120:104::23:3:4779:1517:4783:::|h[Jade Ophidian Band]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:3:4798:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1536777249-26",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5939:::::::120:104::2:3:4778:1507:4783:::|h[Thornwoven Band]|h|r",
            ["isAwardReason"] = false,
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["id"] = "1537126206-12",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:30:06",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "19:14:02",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160680::::::::120:104::5:3:4799:1492:4786:::|h[Titanspark Animator]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537380842-1",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 20,
            ["votes"] = 0,
            ["time"] = "19:13:31",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158315::::::::120:104::35:3:5053:1542:4786:::|h[Secret Spinner's Miter]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::3:3:4822:1477:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["note"] = "Lower ilvl, but much better traits. Not too sure if its worth it",
            ["id"] = "1537726411-0",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "21:12:33",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160690::::::::120:104::3:3:4798:1477:4786:::|h[Heptavium, Staff of Torturous Knowledge]|h|r",
            ["boss"] = "G'huun",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537733553-16",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [7]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::3:3:4822:1477:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["id"] = "1537987212-13",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "PRIEST",
            ["difficultyID"] = 15,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:40:12",
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["votes"] = 0,
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [8]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["mapID"] = 1643,
            ["date"] = "26/09/18",
            ["response"] = "Best in Slot",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["boss"] = "Unknown",
            ["groupSize"] = 0,
            ["time"] = "23:32:06",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 0,
            ["responseID"] = 1,
            ["id"] = "1538001126-0",
            ["instance"] = "Kul Tiras-",
         }, -- [9]
         {
            ["mapID"] = 1862,
            ["instance"] = "Waycrest Manor-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["id"] = "1538432128-0",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:159294::::::::120:104::16:3:5008:1547:4783:::|h[Raal's Bib]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:15:28",
            ["difficultyID"] = 8,
            ["boss"] = "Gorak Tul",
            ["responseID"] = "PL",
            ["groupSize"] = 5,
            ["date"] = "01/10/18",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:22:59",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160695::::::::120:104::5:3:4799:1492:4786:::|h[Uldir Subject Manifest]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590979-5",
            ["date"] = "03/10/18",
         }, -- [11]
         {
            ["mapID"] = 1862,
            ["instance"] = "Waycrest Manor-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["time"] = "17:53:44",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159262::::::::120:256::16:3:5006:1547:4784:::|h[Belt of Undying Devotion]|h|r",
            ["boss"] = "Gorak Tul",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["id"] = "1539356024-0",
            ["date"] = "12/10/18",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["id"] = "1539544881-4",
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160714::::::::120:104::3:3:4798:1477:4786:::|h[Volatile Walkers]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:21:21",
            ["difficultyID"] = 14,
            ["boss"] = "Taloc",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [13]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160615::::::::120:104::3:3:4798:1477:4786:::|h[Leggings of Lingering Infestation]|h|r",
            ["id"] = "1539545580-10",
            ["groupSize"] = 19,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["difficultyID"] = 14,
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "MOTHER",
            ["time"] = "20:33:00",
            ["lootWon"] = "|cffa335ee|Hitem:160615::::::::120:104::3:4:4798:41:1477:4786:::|h[Leggings of Lingering Infestation]|h|r",
            ["votes"] = 0,
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 10,
            ["boss"] = "G'huun",
            ["time"] = "22:05:59",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160649::::::::120:104::5:3:4799:1492:4786:::|h[Inoculating Extract]|h|r",
            ["id"] = "1539551159-42",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160654::::::::120:104::3:3:4798:1477:4786:::|h[Vanquished Tendril of G'huun]|h|r",
            ["note"] = "Only have healing trinkets",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159127::::::::120:104::13::::|h[Darkmoon Deck: Tides]|h|r",
            ["votes"] = 0,
         }, -- [15]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160714::::::::120:103::3:3:4798:1477:4786:::|h[Volatile Walkers]|h|r",
            ["boss"] = "Taloc",
            ["mapID"] = 1861,
            ["id"] = "1540404357-4",
            ["class"] = "PRIEST",
            ["lootWon"] = "|cffa335ee|Hitem:160714::::::::120:103::5:3:4799:1492:4786:::|h[Volatile Walkers]|h|r",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "19:05:57",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat upgrade",
            ["responseID"] = 2,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 21,
            ["boss"] = "Taloc",
            ["time"] = "19:06:22",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160649::::::::120:103::5:3:4799:1492:4786:::|h[Inoculating Extract]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Offspec",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:103::5:3:4799:1492:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["id"] = "1540404382-5",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159127::::::::120:103::13::::|h[Darkmoon Deck: Tides]|h|r",
            ["isAwardReason"] = false,
         }, -- [17]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159232::::::::120:103::35:3:5064:1542:4786:::|h[Exquisitely Aerodynamic Shoulderpads]|h|r",
            ["boss"] = "Zek'voz",
            ["mapID"] = 1861,
            ["id"] = "1540407655-27",
            ["class"] = "PRIEST",
            ["lootWon"] = "|cffa335ee|Hitem:160613::::::::120:103::5:3:4823:1492:4786:::|h[Mantle of Contained Corruption]|h|r",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "20:00:55",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["response"] = "Best in Slot",
            ["responseID"] = 1,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775869-12",
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:11:09",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [19]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:22",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777022-20",
         }, -- [20]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:35",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778055-42",
         }, -- [21]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:21",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778941-57",
         }, -- [22]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:09",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780249-94",
         }, -- [23]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:44",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781424-118",
         }, -- [24]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:28",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783508-146",
         }, -- [25]
         {
            ["id"] = "1538001253-1",
            ["mapID"] = 1643,
            ["date"] = "26/09/18",
            ["groupSize"] = 0,
            ["color"] = {
               1, -- [1]
               0.51, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["isAwardReason"] = false,
            ["response"] = "Major trait upgrade",
            ["boss"] = "Unknown",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["time"] = "23:34:13",
            ["difficultyID"] = 0,
            ["responseID"] = 2,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["instance"] = "Kul Tiras-",
         }, -- [26]
         {
            ["id"] = "1538001412-2",
            ["mapID"] = 1643,
            ["date"] = "26/09/18",
            ["groupSize"] = 0,
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["isAwardReason"] = false,
            ["response"] = "Best in Slot",
            ["boss"] = "Unknown",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["time"] = "23:36:52",
            ["difficultyID"] = 0,
            ["responseID"] = 1,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["instance"] = "Kul Tiras-",
         }, -- [27]
         {
            ["id"] = "1538001476-3",
            ["mapID"] = 1643,
            ["date"] = "26/09/18",
            ["groupSize"] = 0,
            ["color"] = {
               1, -- [1]
               0.51, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["isAwardReason"] = false,
            ["response"] = "Major trait upgrade",
            ["boss"] = "Unknown",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["time"] = "23:37:56",
            ["difficultyID"] = 0,
            ["responseID"] = 2,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["instance"] = "Kul Tiras-",
         }, -- [28]
         {
            ["id"] = "1538002519-4",
            ["mapID"] = 1643,
            ["date"] = "26/09/18",
            ["groupSize"] = 0,
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["isAwardReason"] = true,
            ["response"] = "Disenchant",
            ["boss"] = "Unknown",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["time"] = "23:55:19",
            ["difficultyID"] = 0,
            ["responseID"] = 2,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["instance"] = "Kul Tiras-",
         }, -- [29]
      },
      ["Kawaisdesu-Ravencrest"] = {
      },
      ["Aéquítas-Ravencrest"] = {
      },
      ["Intens-Ravencrest"] = {
      },
      ["Tester 4-Stormscale"] = {
      },
      ["Rosexo-Ravencrest"] = {
      },
      ["Steikker-Ravencrest"] = {
      },
      ["Ibu-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DRUID",
            ["time"] = "19:04:57",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:103::5:3:4799:1502:4783:::|h[Bloodstorm Buckle]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540404297-2",
            ["instance"] = "Uldir-Heroic",
         }, -- [1]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159293::::::::120:103::16:3:5009:1537:4786:::|h[Turncoat's Cape]|h|r",
            ["boss"] = "Fetid Devourer",
            ["mapID"] = 1861,
            ["id"] = "1540405545-13",
            ["class"] = "DRUID",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:103::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["groupSize"] = 22,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "19:25:45",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Best in Slot",
            ["responseID"] = 1,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["boss"] = "Zul",
            ["time"] = "20:41:01",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163894:5963:::::::120:103::6:4:5126:40:1562:4786:::|h[7th Legionnaire's Spellhammer]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:103::5:3:4799:1492:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["id"] = "1540410061-32",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158322::::::::120:103::35:3:5010:1552:4783:::|h[Aureus Vessel]|h|r",
            ["isAwardReason"] = false,
         }, -- [3]
      },
      ["Sparklekitty-Ravencrest"] = {
      },
      ["Seryina-Ravencrest"] = {
      },
      ["Ticklenut-Ravencrest"] = {
      },
      ["Angri-Ravencrest"] = {
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:161099::::::::120:104::26:4:41:4803:1547:4784:::|h[Wind-Scoured Greaves]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1536776354-0",
            ["class"] = "HUNTER",
            ["difficultyID"] = 14,
            ["groupSize"] = 20,
            ["time"] = "19:19:14",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::3:4:4798:1808:1477:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["votes"] = 0,
            ["boss"] = "Unknown",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "12/09/18",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "HUNTER",
            ["id"] = "1536780248-92",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:4:4798:1808:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:08",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 22,
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:26:12",
            ["itemReplaced1"] = "|cff0070dd|Hitem:158155::::::::120:104::25:3:4803:1517:4781:::|h[Dinobone Charm]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat Upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160648::::::::120:104::3:4:4798:1808:1477:4786:::|h[Frenetic Corpuscle]|h|r",
            ["id"] = "1536780372-99",
            ["color"] = {
               [3] = 0.09,
               [2] = 0.54,
               ["text"] = "Response",
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cff0070dd|Hitem:158154::::::::120:104::26:3:4803:1517:4785:::|h[Emblem of Zandalar]|h|r",
            ["votes"] = 0,
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "16/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 11,
            ["boss"] = "G'huun",
            ["time"] = "19:38:24",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160648::153710::::::120:104::3:4:4798:1808:1477:4786:::|h[Frenetic Corpuscle]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160654::::::::120:104::3:4:4798:41:1482:4783:::|h[Vanquished Tendril of G'huun]|h|r",
            ["id"] = "1537123104-2",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cff0070dd|Hitem:158155::::::::120:104::25:3:4803:1517:4781:::|h[Dinobone Charm]|h|r",
            ["votes"] = 0,
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["id"] = "1537124481-5",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::5:4:4799:1808:1492:4786:::|h[Construct Overcharger]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:01:21",
            ["difficultyID"] = 15,
            ["boss"] = "Taloc",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "HUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:57:11",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160628::::::::120:104::5:3:4799:1497:4783:::|h[Fused Monstrosity Stompers]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537383431-8",
            ["instance"] = "Uldir-Heroic",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159366:5934:::::::120:104::23:3:4779:1512:4786:::|h[Water Shapers]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "ilvl Upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "HUNTER",
            ["votes"] = 0,
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:161076::::::::120:104::5:3:4799:1492:4786:::|h[Iron-Grip Specimen Handlers]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:17:02",
            ["boss"] = "Fetid Devourer",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "19/09/18",
            ["id"] = "1537384622-12",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 17,
            ["time"] = "19:09:41",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160629::::::::120:104::3:3:4798:1477:4786:::|h[Rubywrought Sparkguards]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1538330981-0",
            ["date"] = "30/09/18",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 17,
            ["boss"] = "MOTHER",
            ["time"] = "19:23:36",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160647:5939:::::::120:104::4:3:4801:1462:4786:::|h[Ring of the Infinite Void]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:4:4798:1808:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1538331816-5",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158314:5939:::::::120:104::23:3:4779:1517:4783:::|h[Seal of Questionable Loyalties]|h|r",
            ["isAwardReason"] = false,
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "30/09/18",
            ["class"] = "HUNTER",
            ["id"] = "1538332986-14",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160678::::::::120:104::3:3:4798:1477:4786:::|h[Bow of Virulent Infection]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:43:06",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:44",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::5:3:4799:1492:4786:::|h[Titanspark Energy Girdle]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538595464-10",
            ["date"] = "03/10/18",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:58:33",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538596713-16",
            ["date"] = "03/10/18",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["id"] = "1539196012-5",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:26:52",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["date"] = "10/10/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 19,
            ["boss"] = "Zek'voz",
            ["time"] = "20:47:40",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::5:3:4799:1492:4786:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1539200860-21",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158362:5938:::::::120:104::16:3:5007:1532:4786:::|h[Lord Waycrest's Signet]|h|r",
            ["isAwardReason"] = false,
         }, -- [14]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160629::::::::120:104::3:3:4798:1477:4786:::|h[Rubywrought Sparkguards]|h|r",
            ["id"] = "1539545002-5",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "HUNTER",
            ["difficultyID"] = 14,
            ["response"] = "Ilvl upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "Taloc",
            ["time"] = "20:23:22",
            ["lootWon"] = "|cffa335ee|Hitem:160629::::::::120:104::3:4:4798:42:1477:4786:::|h[Rubywrought Sparkguards]|h|r",
            ["votes"] = 0,
            ["responseID"] = 3,
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 21,
            ["votes"] = 0,
            ["time"] = "19:45:01",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::::::::120:103::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:103::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["note"] = "Tiny upgrade",
            ["id"] = "1540406701-22",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:09",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780249-93",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:29",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781409-108",
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:16",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783496-141",
         }, -- [19]
         {
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:163351::::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Chain Drape]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Best in Slot",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "HUNTER",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "19:37:52",
            ["boss"] = "Fetid Devourer",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["date"] = "17/10/18",
            ["id"] = "1539801472-12",
         }, -- [20]
      },
      ["Mujosan-LaughingSkull"] = {
      },
      ["Finobolt-Ravencrest"] = {
      },
      ["Embearassing-Ravencrest"] = {
      },
      ["Kanaky-Ravencrest"] = {
      },
      ["Angridin-Ravencrest"] = {
      },
      ["Zeátrem-Ravencrest"] = {
      },
      ["Elskafto-Ravencrest"] = {
      },
      ["Babycatjuh-Ravencrest"] = {
      },
      ["Puffpasspuff-Ravencrest"] = {
      },
      ["Parsnips-Ravencrest"] = {
      },
      ["Floofster-Ravencrest"] = {
      },
      ["Valhorth-Ravencrest"] = {
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159368::::::::120:104::23:3:4819:1512:4786:::|h[Spaulders of Prime Emperor]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "ilvl Upgrade",
            ["id"] = "1536777151-24",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 14,
            ["groupSize"] = 21,
            ["time"] = "19:32:31",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:104::3:3:4822:1477:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["votes"] = 0,
            ["boss"] = "MOTHER",
            ["responseID"] = 3,
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "12/09/18",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["id"] = "1537127646-14",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::5:3:4799:1492:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:54:06",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163947::::::::120:104::54:3:42:1472:4786:::|h[Robust Legwraps of D'nusa]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "ilvl Upgrade",
            ["instance"] = "Uldir-Normal",
            ["class"] = "SHAMAN",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::3:4:4798:1808:1477:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "21:25:57",
            ["boss"] = "Taloc",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "19/09/18",
            ["id"] = "1537388757-17",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "19/09/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 17,
            ["boss"] = "MOTHER",
            ["time"] = "21:35:13",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158362:5939:::::::120:104::23:3:4779:1517:4783:::|h[Lord Waycrest's Signet]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:3:4798:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1537389313-22",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159459:5943:::::::120:104::16:3:5005:1527:4786:::|h[Ritual Binder's Ring]|h|r",
            ["isAwardReason"] = false,
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159386::::::::120:104::23:4:4779:40:1522:4783:::|h[Anchor Chain Girdle]|h|r",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Best in Slot",
            ["instance"] = "Uldir-Normal",
            ["class"] = "SHAMAN",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::3:3:4798:1477:4786:::|h[Titanspark Energy Girdle]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "21:49:16",
            ["boss"] = "Zek'voz",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["date"] = "19/09/18",
            ["id"] = "1537390156-26",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "SHAMAN",
            ["id"] = "1537986113-4",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:21:53",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [6]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160631::153709::::::120:104::3:4:4798:1808:1477:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["id"] = "1537991538-17",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 15,
            ["response"] = "Stat Upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:52:18",
            ["lootWon"] = "|cffa335ee|Hitem:160716::::::::120:104::5:3:4799:1492:4786:::|h[Blighted Anima Greaves]|h|r",
            ["votes"] = 0,
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 17,
            ["boss"] = "Taloc",
            ["time"] = "19:13:01",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159620::::::::120:104::23:4:4779:42:1527:4784:::|h[Conch of Dark Whispers]|h|r",
            ["id"] = "1538331181-2",
            ["votes"] = 0,
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::3:3:4798:1477:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["note"] = "AOE spec",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159630::::::::120:104::35:3:5006:1537:4783:::|h[Balefire Branch]|h|r",
            ["instance"] = "Uldir-Normal",
         }, -- [8]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:163398::::::::120:104::3:3:5124:1532:4786:::|h[7th Legionnaire's Chainmail]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Best in Slot",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["boss"] = "Mythrax",
            ["groupSize"] = 18,
            ["time"] = "20:40:18",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160725::::::::120:104::3:3:4822:1477:4786:::|h[C'thraxxi General's Hauberk]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 1,
            ["id"] = "1538336418-0",
            ["instance"] = "Uldir-Normal",
         }, -- [9]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:163398::::::::120:104::3:3:5124:1532:4786:::|h[7th Legionnaire's Chainmail]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["id"] = "1538595588-12",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 15,
            ["groupSize"] = 20,
            ["time"] = "20:39:48",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160627::::::::120:104::5:3:4823:1492:4786:::|h[Chainvest of Assured Quality]|h|r",
            ["votes"] = 0,
            ["boss"] = "Zek'voz",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["date"] = "03/10/18",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 16,
            ["boss"] = "Taloc",
            ["time"] = "20:37:43",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159620::::::::120:104::23:4:4779:42:1527:4784:::|h[Conch of Dark Whispers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::3:3:4798:1477:4786:::|h[Construct Overcharger]|h|r",
            ["id"] = "1538941063-2",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159630::::::::120:104::35:3:5006:1537:4783:::|h[Balefire Branch]|h|r",
            ["isAwardReason"] = false,
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163277::154127::::::120:104::3:4:5124:4802:1532:4786:::|h[7th Legionnaire's Bindings]|h|r",
            ["id"] = "1538942349-11",
            ["response"] = "Ilvl upgrade",
            ["date"] = "07/10/18",
            ["class"] = "SHAMAN",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:161073::::::::120:104::3:3:4798:1477:4786:::|h[Reinforced Test Subject Shackles]|h|r",
            ["boss"] = "Vectis",
            ["time"] = "20:59:09",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 3,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:161464::::::::120:104::3:4:5120:1492:4786:4775:::|h[Alliance Bowman's Coif]|h|r",
            ["id"] = "1538944892-22",
            ["response"] = "Offspec",
            ["date"] = "07/10/18",
            ["class"] = "SHAMAN",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160630::::::::120:104::3:3:4822:1477:4786:::|h[Crest of the Undying Visionary]|h|r",
            ["boss"] = "Zul",
            ["time"] = "21:41:32",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 5,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 16,
            ["boss"] = "Mythrax",
            ["time"] = "21:54:20",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159620::::::::120:104::23:4:4779:42:1527:4784:::|h[Conch of Dark Whispers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160656::::::::120:104::3:3:4798:1477:4786:::|h[Twitching Tentacle of Xalzaix]|h|r",
            ["id"] = "1538945660-27",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159630::::::::120:104::35:3:5006:1537:4783:::|h[Balefire Branch]|h|r",
            ["isAwardReason"] = false,
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["id"] = "1539198034-14",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160698::::::::120:104::5:3:4799:1492:4786:::|h[Vector Deflector]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:00:34",
            ["difficultyID"] = 15,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 19,
            ["boss"] = "MOTHER",
            ["time"] = "20:32:48",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163894:5963:154127::::::120:104::6:4:5126:4802:1562:4786:::|h[7th Legionnaire's Spellhammer]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160682::::::::120:104::3:4:4798:1808:1477:4786:::|h[Mother's Twin Gaze]|h|r",
            ["id"] = "1539545568-9",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160698::::::::120:104::5:3:4799:1492:4786:::|h[Vector Deflector]|h|r",
            ["votes"] = 0,
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 19,
            ["boss"] = "MOTHER",
            ["time"] = "20:33:37",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160645:5943:::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:4:4798:1808:1482:4783:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1539545617-11",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158314:5943:154127::::::120:104::16:4:5006:4802:1527:4786:::|h[Seal of Questionable Loyalties]|h|r",
            ["votes"] = 0,
         }, -- [17]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160627::::::::120:104::5:3:4823:1492:4786:::|h[Chainvest of Assured Quality]|h|r",
            ["id"] = "1539547839-26",
            ["groupSize"] = 19,
            ["date"] = "14/10/18",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 14,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "Zek'voz",
            ["time"] = "21:10:39",
            ["lootWon"] = "|cffa335ee|Hitem:160627::::::::120:104::3:3:4822:1477:4786:::|h[Chainvest of Assured Quality]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 19,
            ["boss"] = "Zek'voz",
            ["time"] = "21:11:09",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160645:5943:::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:4:4798:1808:1482:4783:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1539547869-27",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158314:5943:154127::::::120:104::16:4:5006:4802:1527:4786:::|h[Seal of Questionable Loyalties]|h|r",
            ["votes"] = 0,
         }, -- [19]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521850-20",
            ["class"] = "SHAMAN",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:30",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [20]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775846-0",
            ["class"] = "SHAMAN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:46",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [21]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:21",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777021-17",
         }, -- [22]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:28",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778048-28",
         }, -- [23]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:29",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778949-59",
         }, -- [24]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:06",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780246-85",
         }, -- [25]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:52",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781432-124",
         }, -- [26]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:11",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783491-128",
         }, -- [27]
         {
            ["mapID"] = 1763,
            ["date"] = "20/09/18",
            ["id"] = "1537477705-1",
            ["class"] = "SHAMAN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["time"] = "22:08:25",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:158309::::::::120:104::16:3:5005:1527:4786:::|h[Wristlinks of Alchemical Transfusion]|h|r",
            ["boss"] = "Yazma",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["instance"] = "Atal'Dazar-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [28]
         {
            ["mapID"] = 1762,
            ["date"] = "24/09/18",
            ["instance"] = "Kings' Rest-Mythic Keystone",
            ["class"] = "SHAMAN",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:159371::::::::120:104::16:3:5007:1532:4786:::|h[Boots of the Headlong Conqueror]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "22:21:18",
            ["difficultyID"] = 8,
            ["boss"] = "King Dazar",
            ["responseID"] = "PL",
            ["groupSize"] = 5,
            ["id"] = "1537824078-0",
         }, -- [29]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539799737-1",
            ["class"] = "SHAMAN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:08:57",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160629::::::::120:104::5:3:4799:1497:4783:::|h[Rubywrought Sparkguards]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [30]
         {
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:163389::::::::120:104::28:4:5125:1562:5140:5382:::|h[7th Legionnaire's Monnion]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Best in Slot",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "SHAMAN",
            ["votes"] = 0,
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:104::5:3:4823:1492:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "19:19:47",
            ["boss"] = "MOTHER",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["date"] = "17/10/18",
            ["id"] = "1539800387-6",
         }, -- [31]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 19,
            ["boss"] = "Zul",
            ["time"] = "21:28:25",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1497:4783:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["note"] = "aoe spec",
            ["id"] = "1539808105-25",
         }, -- [32]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Mythic",
            ["id"] = "1540155542-3",
            ["class"] = "SHAMAN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "21:59:02",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::6:3:4800:1507:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 16,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "21/10/18",
         }, -- [33]
      },
      ["Dernhelm-Ravencrest"] = {
      },
      ["Roberval-Ravencrest"] = {
      },
      ["ömar-Ravencrest"] = {
      },
      ["Denolos-Ravencrest"] = {
      },
      ["Shadewind-Ravencrest"] = {
      },
      ["Eqóz-Ravencrest"] = {
      },
      ["Omnomkfc-Ravencrest"] = {
      },
      ["Ballademager-Ravencrest"] = {
      },
      ["Murillo-Ravencrest"] = {
      },
      ["Naditu-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["id"] = "1539196014-7",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160615::::::::120:104::5:3:4799:1497:4783:::|h[Leggings of Lingering Infestation]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:26:54",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["id"] = "1539196781-11",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::5:3:4799:1492:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:41",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [2]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163246::::::::120:104::3:3:5124:1547:4784:::|h[7th Legionnaire's Silk Cloak]|h|r",
            ["id"] = "1539546869-20",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:54:29",
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [3]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160616::::::::120:104::3:3:4822:1477:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["id"] = "1539549074-34",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["difficultyID"] = 14,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["boss"] = "Zul",
            ["time"] = "21:31:14",
            ["lootWon"] = "|cffa335ee|Hitem:160719::::::::120:104::3:3:4822:1477:4786:::|h[Visage of the Ascended Prophet]|h|r",
            ["votes"] = 0,
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "PRIEST",
            ["time"] = "19:42:44",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160734::::::::120:103::5:3:4799:1492:4786:::|h[Cord of Animated Contagion]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540406564-19",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:163246::::::::120:104::3:3:5124:1547:4784:::|h[7th Legionnaire's Silk Cloak]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Ilvl upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "PRIEST",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "21:28:33",
            ["boss"] = "Mythrax",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "17/10/18",
            ["id"] = "1539808113-27",
         }, -- [6]
      },
      ["Sidney-Ravencrest"] = {
      },
      ["Azuritia-Ravencrest"] = {
      },
      ["Vynthor-Ravencrest"] = {
      },
      ["Zenroh-Ravencrest"] = {
      },
      ["Inriss-Ravencrest"] = {
      },
      ["Béno-Ravencrest"] = {
      },
      ["Bhalsith-Ravencrest"] = {
      },
      ["Shkia-Ravencrest"] = {
      },
      ["Téssitura-Ravencrest"] = {
      },
      ["Muskelmyran-Ravencrest"] = {
      },
      ["Lougy-Ravencrest"] = {
      },
      ["Btheone-Ravencrest"] = {
      },
      ["Beelzor-Ravencrest"] = {
      },
      ["Magelecius-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:11:31",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160714::::::::120:104::5:3:4799:1492:4786:::|h[Volatile Walkers]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590291-2",
            ["date"] = "03/10/18",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159129:5949:154129::::::120:104::16:4:5002:4802:1522:4786:::|h[Flamecaster Botefeux]|h|r",
            ["id"] = "1538941067-3",
            ["response"] = "Ilvl upgrade",
            ["date"] = "07/10/18",
            ["class"] = "MAGE",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160680::::::::120:104::3:4:4798:1808:1477:4786:::|h[Titanspark Animator]|h|r",
            ["boss"] = "Taloc",
            ["time"] = "20:37:47",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 3,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159279::::::::120:104::35:3:5047:1527:4786:::|h[Soulfuel Headdress]|h|r",
            ["id"] = "1538942049-8",
            ["response"] = "Major trait upgrade",
            ["date"] = "07/10/18",
            ["class"] = "MAGE",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::3:3:4822:1477:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:54:09",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.51, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159129:5949:154129::::::120:104::16:4:5002:4802:1522:4786:::|h[Flamecaster Botefeux]|h|r",
            ["id"] = "1538942062-9",
            ["response"] = "Stat upgrade",
            ["date"] = "07/10/18",
            ["class"] = "MAGE",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::3:4:4798:41:1477:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:54:22",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163275::::::::120:104::3:3:5124:1532:4786:::|h[7th Legionnaire's Cuffs]|h|r",
            ["id"] = "1538943850-17",
            ["response"] = "Stat upgrade",
            ["date"] = "07/10/18",
            ["class"] = "MAGE",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160617::::::::120:104::3:3:4798:1482:4783:::|h[Void-Lashed Wristband]|h|r",
            ["boss"] = "Zek'voz",
            ["time"] = "21:24:10",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "MAGE",
            ["groupSize"] = 16,
            ["boss"] = "Zek'voz",
            ["time"] = "21:28:22",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160647:5938:::::::120:104::3:3:4798:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:3:4798:1482:4783:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1538944102-19",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158366:5938:::::::120:104::16:3:4946:1517:4786:::|h[Charged Sandstone Band]|h|r",
            ["isAwardReason"] = false,
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "MAGE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 16,
            ["time"] = "21:51:48",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160614::::::::120:104::3:3:4822:1477:4786:::|h[Robes of the Unraveler]|h|r",
            ["boss"] = "Mythrax",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1538945508-25",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "MAGE",
            ["groupSize"] = 16,
            ["boss"] = "Mythrax",
            ["time"] = "21:54:23",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160647::::::::120:104::3:3:4798:1482:4783:::|h[Ring of the Infinite Void]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160646::::::::120:104::3:3:4798:1477:4786:::|h[Band of Certain Annihilation]|h|r",
            ["id"] = "1538945663-28",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158366:5938:::::::120:104::16:3:4946:1517:4786:::|h[Charged Sandstone Band]|h|r",
            ["isAwardReason"] = false,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["id"] = "1539196013-6",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160695::::::::120:104::5:3:4799:1492:4786:::|h[Uldir Subject Manifest]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:26:53",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [9]
         {
            ["date"] = "10/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163339::::::::120:104::28:4:5125:1547:5136:5378:::|h[7th Legionnaire's Hood]|h|r",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["groupSize"] = 18,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MAGE",
            ["boss"] = "Fetid Devourer",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "19:41:03",
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["id"] = "1539196863-13",
            ["mapID"] = 1861,
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "10/10/18",
            ["class"] = "MAGE",
            ["groupSize"] = 18,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:43:41",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160617::::::::120:104::5:3:4799:1497:4783:::|h[Void-Lashed Wristband]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1539200621-18",
            ["instance"] = "Uldir-Heroic",
         }, -- [11]
      },
      ["Crawde-Ravencrest"] = {
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163278::::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Bracers]|h|r",
            ["id"] = "1539549056-33",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "DEMONHUNTER",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Zul",
            ["time"] = "21:30:56",
            ["lootWon"] = "|cffa335ee|Hitem:160720::::::::120:104::3:3:4798:1477:4786:::|h[Armbands of Sacrosanct Acts]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [1]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160623::::::::120:104::3:3:4822:1477:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["id"] = "1539550108-37",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "DEMONHUNTER",
            ["difficultyID"] = 14,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "Mythrax",
            ["time"] = "21:48:28",
            ["lootWon"] = "|cffa335ee|Hitem:163596::::::::120:104::3:3:4822:1477:4786:::|h[Cowl of Dark Portents]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [2]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:161717::::::::120:104::56:4:5068:5129:1562:4783:::|h[Dread Gladiator's Leather Footguards]|h|r",
            ["id"] = "1539551059-40",
            ["groupSize"] = 10,
            ["date"] = "14/10/18",
            ["class"] = "DEMONHUNTER",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "G'huun",
            ["time"] = "22:04:19",
            ["lootWon"] = "|cffa335ee|Hitem:160729::::::::120:104::3:3:4798:1477:4786:::|h[Striders of the Putrescent Path]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [3]
      },
      ["Hänkz-Ravencrest"] = {
      },
      ["Ríccóbi-Ravencrest"] = {
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536868710-0",
            ["class"] = "HUNTER",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:58:30",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159379::::::::120:104::23:3:4779:1512:4786:::|h[Sure-Foot Sabatons]|h|r",
            ["boss"] = "Dread Captain Lockwood",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Siege of Boralus-Mythic",
         }, -- [1]
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536869796-1",
            ["class"] = "HUNTER",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:16:36",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159376::::::::120:104::23:3:4819:1512:4786:::|h[Hook-Barbed Spaulders]|h|r",
            ["boss"] = "Viq'Goth",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Siege of Boralus-Mythic",
         }, -- [2]
         {
            ["mapID"] = 1862,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536871976-8",
            ["class"] = "HUNTER",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:52:56",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159403::::::::120:104::23:3:4779:1512:4786:::|h[Waistguard of Deteriorating Grace]|h|r",
            ["boss"] = "Lord and Lady Waycrest",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Waycrest Manor-Mythic",
         }, -- [3]
      },
      ["Silversong-Ravencrest"] = {
      },
      ["Neìra-Ravencrest"] = {
      },
      ["Gniewna-TheMaelstrom"] = {
      },
      ["Svendishkhan-Ravencrest"] = {
      },
      ["Mangochops-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
            ["class"] = "MONK",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:10",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1477:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536521830-7",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "MONK",
            ["id"] = "1536780245-77",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::3:4:4798:40:1477:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:05",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "MONK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:40:56",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537382456-5",
            ["instance"] = "Uldir-Heroic",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "MONK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 17,
            ["time"] = "21:25:24",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::3:3:4798:1477:4786:::|h[Bloodstorm Buckle]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537388724-16",
            ["instance"] = "Uldir-Normal",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160622::::::::120:104::3:3:4798:1477:4786:::|h[Bloodstorm Buckle]|h|r",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["instance"] = "Uldir-Normal",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160638::::::::120:104::3:3:4798:1477:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "21:34:39",
            ["boss"] = "MOTHER",
            ["isAwardReason"] = true,
            ["responseID"] = "AUTOPASS",
            ["date"] = "19/09/18",
            ["id"] = "1537389279-20",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160622::::::::120:104::3:3:4798:1477:4786:::|h[Bloodstorm Buckle]|h|r",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Best in Slot",
            ["instance"] = "Uldir-Normal",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160717::::::::120:104::3:3:4798:1477:4786:::|h[Replicated Chitin Cord]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "21:48:31",
            ["boss"] = "Zek'voz",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["date"] = "19/09/18",
            ["id"] = "1537390111-24",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160214::::::::120:104::23:3:4779:1517:4783:::|h[Venerated Raptorhide Bindings]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "ilvl Upgrade",
            ["instance"] = "Uldir-Normal",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 13,
            ["lootWon"] = "|cffa335ee|Hitem:160621::::::::120:104::3:3:4798:1482:4783:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "22:05:02",
            ["boss"] = "Vectis",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "19/09/18",
            ["id"] = "1537391102-30",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:164385::::::::120:104::3:3:4798:1477:4786:::|h[Desert Nomad's Wrap]|h|r",
            ["id"] = "1537727655-6",
            ["response"] = "Best in Slot",
            ["date"] = "23/09/18",
            ["class"] = "MONK",
            ["isAwardReason"] = false,
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1482:4783:::|h[Cloak of Rippling Whispers]|h|r",
            ["boss"] = "Zul",
            ["time"] = "19:34:15",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "MONK",
            ["groupSize"] = 21,
            ["boss"] = "Mythrax",
            ["time"] = "19:57:46",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159620::::::::120:104::23:3:4779:1537:4784:::|h[Conch of Dark Whispers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160656::::::::120:104::3:3:4798:1482:4783:::|h[Twitching Tentacle of Xalzaix]|h|r",
            ["id"] = "1537729066-12",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159127::::::::120:104::13::::|h[Darkmoon Deck: Tides]|h|r",
            ["isAwardReason"] = false,
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "MONK",
            ["groupSize"] = 20,
            ["boss"] = "G'huun",
            ["time"] = "21:14:41",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159620::::::::120:104::23:3:4779:1537:4784:::|h[Conch of Dark Whispers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160654::::::::120:104::3:3:4798:1477:4786:::|h[Vanquished Tendril of G'huun]|h|r",
            ["id"] = "1537733681-20",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160656::::::::120:104::3:3:4798:1482:4783:::|h[Twitching Tentacle of Xalzaix]|h|r",
            ["isAwardReason"] = false,
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160717::::::::120:104::3:3:4798:1477:4786:::|h[Replicated Chitin Cord]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "ilvl Upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "19:08:31",
            ["boss"] = "Taloc",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "26/09/18",
            ["id"] = "1537985311-2",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MONK",
            ["id"] = "1537987159-12",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::5:3:4799:1492:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:19",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:58:38",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160623::::::::120:104::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538596718-17",
            ["date"] = "03/10/18",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["groupSize"] = 20,
            ["boss"] = "Taloc",
            ["time"] = "20:23:39",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160649::::::::120:104::5:3:4799:1492:4786:::|h[Inoculating Extract]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::3:3:4798:1477:4786:::|h[Construct Overcharger]|h|r",
            ["id"] = "1539545019-6",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:161472::::::::120:104::3:3:5119:1492:4786:::|h[Lion's Grace]|h|r",
            ["votes"] = 0,
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["groupSize"] = 20,
            ["votes"] = 0,
            ["time"] = "20:55:04",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160621:5971:::::::120:104::3:3:4798:1482:4783:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["id"] = "1539546904-23",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160621::::::::120:104::3:3:4798:1477:4786:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["note"] = "for M+",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
         }, -- [15]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160621:5971:::::::120:104::3:3:4798:1482:4783:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["id"] = "1539549053-32",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["difficultyID"] = 14,
            ["response"] = "Disenchant",
            ["isAwardReason"] = true,
            ["boss"] = "Zul",
            ["time"] = "21:30:53",
            ["lootWon"] = "|cffa335ee|Hitem:160723::::::::120:104::3:3:4798:1477:4786:::|h[Imperious Vambraces]|h|r",
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["id"] = "1539550021-35",
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160696::::::::120:104::3:3:4798:1482:4783:::|h[Codex of Imminent Ruin]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:47:01",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [17]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158038::::::::120:104::28:3:1562:5138:5383:::|h[Fairweather Tunic]|h|r",
            ["id"] = "1539550092-36",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["difficultyID"] = 14,
            ["response"] = "Disenchant",
            ["isAwardReason"] = true,
            ["boss"] = "Mythrax",
            ["time"] = "21:48:12",
            ["lootWon"] = "|cffa335ee|Hitem:160725::::::::120:104::3:3:4822:1477:4786:::|h[C'thraxxi General's Hauberk]|h|r",
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [18]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160623::::::::120:104::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["id"] = "1539550112-38",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["difficultyID"] = 14,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "Mythrax",
            ["time"] = "21:48:32",
            ["lootWon"] = "|cffa335ee|Hitem:163596::::::::120:104::3:3:4822:1477:4786:::|h[Cowl of Dark Portents]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [19]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158038::::::::120:104::28:3:1562:5138:5383:::|h[Fairweather Tunic]|h|r",
            ["id"] = "1539551081-41",
            ["groupSize"] = 10,
            ["date"] = "14/10/18",
            ["class"] = "MONK",
            ["difficultyID"] = 14,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "G'huun",
            ["time"] = "22:04:41",
            ["lootWon"] = "|cffa335ee|Hitem:160728::::::::120:104::3:3:4822:1477:4786:::|h[Tunic of the Sanguine Deity]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [20]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160620::::::::120:103::5:3:4823:1492:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["boss"] = "MOTHER",
            ["mapID"] = 1861,
            ["id"] = "1540404884-8",
            ["class"] = "MONK",
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:103::5:3:4823:1492:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["groupSize"] = 22,
            ["isAwardReason"] = true,
            ["votes"] = 0,
            ["time"] = "19:14:44",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [21]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160620::::::::120:103::5:3:4823:1492:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["boss"] = "MOTHER",
            ["mapID"] = 1861,
            ["id"] = "1540404887-9",
            ["class"] = "MONK",
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:103::5:3:4823:1492:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["groupSize"] = 22,
            ["isAwardReason"] = true,
            ["votes"] = 0,
            ["time"] = "19:14:47",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["responseID"] = "AWARDED",
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [22]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159322::::::::120:103::16:3:5008:1547:4783:::|h[Seawalker's Pantaloons]|h|r",
            ["boss"] = "MOTHER",
            ["mapID"] = 1861,
            ["id"] = "1540404892-10",
            ["class"] = "MONK",
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:103::5:3:4799:1492:4786:::|h[Pathogenic Legwraps]|h|r",
            ["groupSize"] = 22,
            ["isAwardReason"] = true,
            ["votes"] = 0,
            ["time"] = "19:14:52",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["responseID"] = "PASS",
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [23]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:155862::::::::120:103::35:3:5009:1552:4784:::|h[Kragg's Rigging Scalers]|h|r",
            ["boss"] = "Zek'voz",
            ["mapID"] = 1861,
            ["id"] = "1540407525-24",
            ["class"] = "MONK",
            ["lootWon"] = "|cffa335ee|Hitem:160640::::::::120:103::5:3:4799:1492:4786:::|h[Warboots of Absolute Eradication]|h|r",
            ["groupSize"] = 21,
            ["isAwardReason"] = true,
            ["votes"] = 0,
            ["time"] = "19:58:45",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [24]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "MONK",
            ["time"] = "20:39:48",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160720::::::::120:103::5:3:4799:1492:4786:::|h[Armbands of Sacrosanct Acts]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540409988-31",
            ["instance"] = "Uldir-Heroic",
         }, -- [25]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775848-6",
            ["class"] = "MONK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:48",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [26]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:16",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777016-13",
         }, -- [27]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:32",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778052-40",
         }, -- [28]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:31",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778951-60",
         }, -- [29]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:23",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780263-98",
         }, -- [30]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:45",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781425-119",
         }, -- [31]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:20",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783500-144",
         }, -- [32]
         {
            ["mapID"] = 1841,
            ["instance"] = "The Underrot-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MONK",
            ["date"] = "12/09/18",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:38:20",
            ["difficultyID"] = 8,
            ["boss"] = "Unbound Abomination",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536791900-162",
         }, -- [33]
         {
            ["mapID"] = 1822,
            ["date"] = "08/10/18",
            ["id"] = "1539037213-1",
            ["class"] = "MONK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["time"] = "23:20:13",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159322::::::::120:104::16:3:5008:1547:4783:::|h[Seawalker's Pantaloons]|h|r",
            ["boss"] = "Viq'Goth",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["instance"] = "Siege of Boralus-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [34]
         {
            ["date"] = "14/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1482:4783:::|h[Cloak of Rippling Whispers]|h|r",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 18,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MONK",
            ["boss"] = "Zul",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "19:47:35",
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["mapID"] = 1861,
            ["id"] = "1539542855-1",
         }, -- [35]
         {
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Disenchant",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "19:24:06",
            ["boss"] = "MOTHER",
            ["isAwardReason"] = true,
            ["responseID"] = "PASS",
            ["date"] = "17/10/18",
            ["id"] = "1539800646-9",
         }, -- [36]
         {
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:158038::::::::120:104::28:3:1562:5138:5383:::|h[Fairweather Tunic]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Disenchant",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160627::::::::120:104::5:3:4823:1492:4786:::|h[Chainvest of Assured Quality]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:44:14",
            ["boss"] = "Zek'voz",
            ["isAwardReason"] = true,
            ["responseID"] = "AUTOPASS",
            ["date"] = "17/10/18",
            ["id"] = "1539805454-21",
         }, -- [37]
         {
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Disenchant",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MONK",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::5:3:4799:1492:4786:::|h[Titanspark Energy Girdle]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:44:18",
            ["boss"] = "Zek'voz",
            ["isAwardReason"] = true,
            ["responseID"] = "AUTOPASS",
            ["date"] = "17/10/18",
            ["id"] = "1539805458-22",
         }, -- [38]
      },
      ["Shiyanze-Ravencrest"] = {
      },
      ["Hypherix-Ravencrest"] = {
      },
      ["Xefy-Ravencrest"] = {
      },
      ["Luniix-Ravencrest"] = {
      },
      ["Eliarra-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:40:55",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160695::::::::120:104::5:3:4799:1492:4786:::|h[Uldir Subject Manifest]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537382455-4",
            ["instance"] = "Uldir-Heroic",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "19/09/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 17,
            ["boss"] = "MOTHER",
            ["time"] = "21:35:16",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5942:::::::120:104::23:3:4779:1512:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:3:4798:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1537389316-23",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158366:5942:::::::120:104::16:3:4780:1517:4786:::|h[Charged Sandstone Band]|h|r",
            ["isAwardReason"] = false,
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 17,
            ["time"] = "22:04:07",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537391047-28",
            ["instance"] = "Uldir-Normal",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163341::154127::::::120:104::5:4:5125:4802:1532:4786:::|h[7th Legionnaire's Handwraps]|h|r",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Best in Slot",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PRIEST",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160715::::::::120:104::3:3:4798:1477:4786:::|h[Mutagenic Protofluid Handwraps]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "22:04:36",
            ["boss"] = "Vectis",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["date"] = "19/09/18",
            ["id"] = "1537391076-29",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "26/09/18",
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "19:07:53",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::5:3:4799:1492:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537985273-1",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "PRIEST",
            ["id"] = "1537995209-19",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160617::::::::120:104::5:3:4799:1492:4786:::|h[Void-Lashed Wristband]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:53:29",
            ["difficultyID"] = 15,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:32:18",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::3:3:4798:1477:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1538332338-7",
            ["date"] = "30/09/18",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 18,
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:33:38",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163894:5963:::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Spellhammer]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Transmogrification",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::3:3:4798:1477:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["id"] = "1538332418-9",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 5,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160695::::::::120:104::5:3:4799:1492:4786:::|h[Uldir Subject Manifest]|h|r",
            ["isAwardReason"] = false,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat upgrade",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PRIEST",
            ["votes"] = 0,
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "19:34:57",
            ["boss"] = "Fetid Devourer",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "30/09/18",
            ["id"] = "1538332497-10",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "30/09/18",
            ["class"] = "PRIEST",
            ["id"] = "1538332983-12",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160734::::::::120:104::3:4:4798:40:1477:4786:::|h[Cord of Animated Contagion]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:43:03",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [10]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Offspec",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "PRIEST",
            ["boss"] = "Zul",
            ["groupSize"] = 18,
            ["time"] = "20:21:10",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1477:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 4,
            ["id"] = "1538335270-2",
            ["instance"] = "Uldir-Normal",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:23:02",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160615::::::::120:104::5:3:4799:1492:4786:::|h[Leggings of Lingering Infestation]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590982-7",
            ["date"] = "03/10/18",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:58:44",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538596724-18",
            ["date"] = "03/10/18",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160615::::::::120:104::5:3:4799:1492:4786:::|h[Leggings of Lingering Infestation]|h|r",
            ["id"] = "1538941486-7",
            ["response"] = "Transmogrification",
            ["date"] = "07/10/18",
            ["class"] = "PRIEST",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160615::::::::120:104::3:3:4798:1477:4786:::|h[Leggings of Lingering Infestation]|h|r",
            ["boss"] = "MOTHER",
            ["time"] = "20:44:46",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 5,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 16,
            ["boss"] = "Zek'voz",
            ["time"] = "21:28:18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5942:::::::120:104::23:3:4779:1512:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["id"] = "1538944098-18",
            ["votes"] = 0,
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:4:4798:1808:1482:4783:::|h[Ring of the Infinite Void]|h|r",
            ["note"] = "10% upgrade",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160645:5943:::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["instance"] = "Uldir-Normal",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:158344::::::::120:104::23:3:4819:1512:4786:::|h[Mantle of Ceremonial Ascension]|h|r",
            ["id"] = "1538946581-32",
            ["response"] = "Best in Slot",
            ["date"] = "07/10/18",
            ["class"] = "PRIEST",
            ["isAwardReason"] = false,
            ["groupSize"] = 13,
            ["lootWon"] = "|cffa335ee|Hitem:160726::::::::120:104::3:3:4822:1477:4786:::|h[Amice of Corrupting Horror]|h|r",
            ["boss"] = "G'huun",
            ["time"] = "22:09:41",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PRIEST",
            ["id"] = "1539196785-12",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:45",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 20,
            ["boss"] = "Taloc",
            ["time"] = "20:23:45",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159126::::::::120:104::13::::|h[Darkmoon Deck: Squalls]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::3:3:4798:1477:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["id"] = "1539545025-7",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160651::::::::120:104::5:3:4799:1492:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["votes"] = 0,
         }, -- [18]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644:6088:::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["id"] = "1539546178-13",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["difficultyID"] = 14,
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:42:58",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:4:4798:1808:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [19]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "PRIEST",
            ["time"] = "19:04:52",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160680::::::::120:103::5:3:4799:1502:4783:::|h[Titanspark Animator]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540404292-1",
            ["instance"] = "Uldir-Heroic",
         }, -- [20]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163248::::::::120:104::28:4:5125:1562:5138:5383:::|h[7th Legionnaire's Robes]|h|r",
            ["boss"] = "Mythrax",
            ["mapID"] = 1861,
            ["id"] = "1540412017-38",
            ["class"] = "PRIEST",
            ["lootWon"] = "|cffa335ee|Hitem:160614::::::::120:104::5:3:4823:1492:4786:::|h[Robes of the Unraveler]|h|r",
            ["groupSize"] = 18,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "21:13:37",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["response"] = "Best in Slot",
            ["responseID"] = 1,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [21]
         {
            ["mapID"] = 1877,
            ["date"] = "05/09/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 5,
            ["isAwardReason"] = false,
            ["time"] = "23:09:22",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159458:5939:::::::120:104::23:3:4779:1512:4786:::|h[Seal of the Regal Loa]|h|r",
            ["instance"] = "Temple of Sethraliss-Mythic Keystone",
            ["response"] = "ilvl Upgrade",
            ["boss"] = "Avatar of Sethraliss",
            ["difficultyID"] = 8,
            ["lootWon"] = "|cffa335ee|Hitem:158366::::::::120:104::16:3:4780:1517:4786:::|h[Charged Sandstone Band]|h|r",
            ["id"] = "1536185362-3",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cff0070dd|Hitem:158161:5939:154127::::::120:104::27:5:4803:4802:42:1502:4785:::|h[Spearfisher's Band]|h|r",
            ["votes"] = 0,
         }, -- [22]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521832-10",
            ["class"] = "PRIEST",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:12",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [23]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "PRIEST",
            ["groupSize"] = 18,
            ["votes"] = 0,
            ["time"] = "19:49:02",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163894:5963:::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Spellhammer]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["boss"] = "Zul",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::5:3:4799:1492:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["id"] = "1539542942-3",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160695::::::::120:104::5:3:4799:1492:4786:::|h[Uldir Subject Manifest]|h|r",
            ["isAwardReason"] = false,
         }, -- [24]
         {
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:163342::154126::::::120:104::28:4:5125:4802:1542:4783:::|h[7th Legionnaire's Cord]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Stat upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "PRIEST",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160734::::::::120:104::5:3:4799:1492:4786:::|h[Cord of Animated Contagion]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:15:15",
            ["boss"] = "Vectis",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "17/10/18",
            ["id"] = "1539803715-17",
         }, -- [25]
      },
      ["Lyth-Ravencrest"] = {
      },
      ["Alleyena-Ravencrest"] = {
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159247::::::::120:104::23:3:4779:1512:4786:::|h[Handwraps of Oscillating Polarity]|h|r",
            ["id"] = "1539546889-21",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "MAGE",
            ["difficultyID"] = 14,
            ["response"] = "Ilvl upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:54:49",
            ["lootWon"] = "|cffa335ee|Hitem:160715::::::::120:104::3:3:4798:1477:4786:::|h[Mutagenic Protofluid Handwraps]|h|r",
            ["votes"] = 0,
            ["responseID"] = 3,
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "14/10/18",
            ["class"] = "MAGE",
            ["id"] = "1539548991-30",
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160719::::::::120:104::3:3:4822:1477:4786:::|h[Visage of the Ascended Prophet]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:29:51",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [2]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cff0070dd|Hitem:160968::::::::120:104::26:3:4803:1517:4785:::|h[Skycaller Spellstaff]|h|r",
            ["id"] = "1539551231-43",
            ["groupSize"] = 10,
            ["date"] = "14/10/18",
            ["class"] = "MAGE",
            ["difficultyID"] = 14,
            ["response"] = "Ilvl upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "G'huun",
            ["time"] = "22:07:11",
            ["lootWon"] = "|cffa335ee|Hitem:160690::::::::120:104::3:4:4798:1808:1477:4786:::|h[Heptavium, Staff of Torturous Knowledge]|h|r",
            ["votes"] = 0,
            ["responseID"] = 3,
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [3]
         {
            ["mapID"] = 1877,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "MAGE",
            ["instance"] = "Temple of Sethraliss-Mythic",
            ["groupSize"] = 5,
            ["lootWon"] = "|cffa335ee|Hitem:159247::::::::120:104::23:3:4779:1512:4786:::|h[Handwraps of Oscillating Polarity]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:56:44",
            ["difficultyID"] = 23,
            ["boss"] = "Galvazzt",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537045004-0",
         }, -- [4]
         {
            ["mapID"] = 1862,
            ["date"] = "20/09/18",
            ["id"] = "1537472749-0",
            ["class"] = "MAGE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["time"] = "20:45:49",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:159282::::::::120:104::2:3:4778:1502:4781:::|h[Drust-Thatched Wristwraps]|h|r",
            ["boss"] = "Soulbound Goliath",
            ["difficultyID"] = 2,
            ["responseID"] = "PL",
            ["instance"] = "Waycrest Manor-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [5]
      },
      ["Cráw-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 21,
            ["votes"] = 0,
            ["time"] = "19:33:29",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158360::::::::120:104::16:3:5007:1537:4783:::|h[Sharkbait Harness Girdle]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160638::::::::120:104::3:3:4798:1477:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["note"] = "transmog",
            ["id"] = "1536777209-25",
         }, -- [1]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:157990::::::::120:104::28:2:1532:5138:::|h[Harbormaster Cuirass]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1536779158-68",
            ["class"] = "PALADIN",
            ["difficultyID"] = 14,
            ["groupSize"] = 21,
            ["time"] = "20:05:58",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160636::::::::120:104::3:3:4822:1477:4786:::|h[Chestguard of Virulent Mutagens]|h|r",
            ["votes"] = 0,
            ["boss"] = "Vectis",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "12/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PALADIN",
            ["id"] = "1536783521-156",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160641::::::::120:104::3:3:4822:1477:4786:::|h[Chitinspine Pauldrons]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:41",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [3]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159430::::::::120:104::23:3:4819:1512:4786:::|h[Helm of Abyssal Malevolence]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Best in Slot",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["boss"] = "G'huun",
            ["groupSize"] = 10,
            ["time"] = "20:59:49",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160732::::::::120:104::3:3:4822:1477:4786:::|h[Helm of the Defiled Laboratorium]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 1,
            ["id"] = "1538337589-4",
            ["instance"] = "Uldir-Normal",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 16,
            ["boss"] = "Vectis",
            ["time"] = "21:05:43",
            ["itemReplaced1"] = "|cffa335ee|Hitem:161474::::::::120:104::3:3:5119:1492:4786:::|h[Lion's Strength]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160649::::::::120:104::3:3:4798:1477:4786:::|h[Inoculating Extract]|h|r",
            ["id"] = "1538942743-12",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159619::::::::120:104::16:3:5008:1537:4786:::|h[Briny Barnacle]|h|r",
            ["isAwardReason"] = false,
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159412::::::::120:104::35:3:5010:1552:4783:::|h[Auric Puddle Stompers]|h|r",
            ["id"] = "1538946532-29",
            ["response"] = "Transmogrification",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160733::::::::120:104::3:3:4798:1477:4786:::|h[Hematocyst Stompers]|h|r",
            ["boss"] = "G'huun",
            ["time"] = "22:08:52",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 5,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160636::::::::120:104::3:3:4822:1477:4786:::|h[Chestguard of Virulent Mutagens]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:12:17",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536779537-69",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:12:18",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536779538-71",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:11",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780251-97",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:50",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781430-123",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:40",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783520-154",
         }, -- [11]
      },
      ["Mackmanaman-Ravencrest"] = {
      },
      ["Thaiyró-Ravencrest"] = {
      },
      ["Nutyy-Ravencrest"] = {
      },
      ["Enkku-Ravencrest"] = {
      },
      ["Tinyhorror-Ravencrest"] = {
      },
      ["Tester 1-Stormscale"] = {
      },
      ["Caoillainne-Ravencrest"] = {
      },
      ["Westrock-Ravencrest"] = {
      },
      ["Rattlebeard-Ravencrest"] = {
      },
      ["Yéren-Ravencrest"] = {
      },
      ["Logy-Ravencrest"] = {
      },
      ["Boudi-Ravencrest"] = {
      },
      ["Linneax-Ravencrest"] = {
      },
      ["Nessyy-Ravencrest"] = {
      },
      ["Thorsker-Ravencrest"] = {
      },
      ["Stylea-Ravencrest"] = {
      },
      ["Lookeri-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "WARLOCK",
            ["id"] = "1536781407-105",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::3:3:4798:1477:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:27",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["class"] = "WARLOCK",
            ["groupSize"] = 21,
            ["boss"] = "Mythrax",
            ["time"] = "21:21:21",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159620::::::::120:104::23:3:4779:1512:4786:::|h[Conch of Dark Whispers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160656::::::::120:104::3:4:4798:1808:1477:4786:::|h[Twitching Tentacle of Xalzaix]|h|r",
            ["id"] = "1536783681-157",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159126::::::::120:104::13::::|h[Darkmoon Deck: Squalls]|h|r",
            ["votes"] = 0,
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["id"] = "1537122985-1",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160727::::::::120:104::3:3:4798:1477:4786:::|h[Cord of Septic Envelopment]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:36:25",
            ["difficultyID"] = 14,
            ["boss"] = "G'huun",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "WARLOCK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:41:11",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537382471-7",
            ["instance"] = "Uldir-Heroic",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "WARLOCK",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "20:46:26",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:4:4799:41:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537386386-14",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159266::::::::120:104::23:3:4779:1522:4783:::|h[Claw-Slit Brawler's Handwraps]|h|r",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat Upgrade",
            ["instance"] = "Uldir-Normal",
            ["class"] = "WARLOCK",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160612::::::::120:104::3:3:4798:1477:4786:::|h[Spellbound Specimen Handlers]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "21:56:31",
            ["boss"] = "Vectis",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "19/09/18",
            ["id"] = "1537390591-27",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521826-3",
            ["class"] = "WARLOCK",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:06",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:06",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780246-84",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "WARLOCK",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:13",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783493-137",
         }, -- [9]
      },
      ["Cidth-Ravencrest"] = {
      },
      ["Coókkiiée-Ravencrest"] = {
      },
      ["Demonicdave-Ravencrest"] = {
         {
            ["id"] = "1536781541-125",
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "DEMONHUNTER",
            ["isAwardReason"] = false,
            ["response"] = "Best in Slot",
            ["boss"] = "Zul",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160620::::::::120:104::3:3:4822:1477:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["time"] = "20:45:41",
            ["difficultyID"] = 14,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158043::::::::120:104::28:2:1532:5140:::|h[Fairweather Shoulderpads]|h|r",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEMONHUNTER",
            ["id"] = "1537127661-17",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160619::::::::120:104::5:3:4823:1492:4786:::|h[Jerkin of the Aberrant Chimera]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:54:21",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "DEMONHUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:57:30",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160648::::::::120:104::5:4:4799:41:1492:4786:::|h[Frenetic Corpuscle]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537383450-10",
            ["instance"] = "Uldir-Heroic",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "DEMONHUNTER",
            ["groupSize"] = 20,
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:13:47",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160681:5962:::::::120:104::3:3:4798:1477:4786:::|h[Glaive of the Keepers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "ilvl Upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160685::::::::120:104::3:4:4798:43:1477:4786:::|h[Biomelding Cleaver]|h|r",
            ["id"] = "1537726427-2",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158118:5963:::::::120:104::27:3:4803:1532:4783:::|h[Razorbone Claws]|h|r",
            ["isAwardReason"] = false,
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "DEMONHUNTER",
            ["groupSize"] = 21,
            ["boss"] = "Mythrax",
            ["time"] = "19:56:34",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159460:5939:::::::120:104::23:3:4779:1512:4786:::|h[Overseer's Lost Seal]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160646::::::::120:104::3:3:4798:1477:4786:::|h[Band of Certain Annihilation]|h|r",
            ["id"] = "1537728994-11",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5939:::::::120:104::23:3:4779:1512:4786:::|h[Thornwoven Band]|h|r",
            ["isAwardReason"] = false,
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DEMONHUNTER",
            ["id"] = "1537991432-14",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:50:32",
            ["difficultyID"] = 15,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160625::::::::120:104::3:3:4798:1482:4783:::|h[Pathogenic Legwraps]|h|r",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DEMONHUNTER",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::3:4:4798:1808:1477:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "19:12:41",
            ["boss"] = "Taloc",
            ["isAwardReason"] = true,
            ["responseID"] = "AUTOPASS",
            ["date"] = "30/09/18",
            ["id"] = "1538331161-1",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:161072:5971:::::::120:104::5:3:4799:1492:4786:::|h[Splatterguards]|h|r",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["response"] = "Disenchant",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DEMONHUNTER",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160629::::::::120:104::3:3:4798:1477:4786:::|h[Rubywrought Sparkguards]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "19:13:28",
            ["boss"] = "Taloc",
            ["isAwardReason"] = true,
            ["responseID"] = "AUTOPASS",
            ["date"] = "30/09/18",
            ["id"] = "1538331208-3",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "DEMONHUNTER",
            ["groupSize"] = 18,
            ["boss"] = "Zek'voz",
            ["time"] = "19:57:51",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160646:5939:::::::120:104::3:3:4798:1477:4786:::|h[Band of Certain Annihilation]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Ilvl upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:3:4798:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1538333871-19",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5939:::::::120:104::23:3:4779:1512:4786:::|h[Thornwoven Band]|h|r",
            ["votes"] = 0,
         }, -- [9]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:160620::::::::120:104::3:3:4822:1477:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Disenchant",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["class"] = "DEMONHUNTER",
            ["boss"] = "G'huun",
            ["groupSize"] = 17,
            ["time"] = "20:58:48",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160731::::::::120:104::3:3:4822:1477:4786:::|h[Spaulders of Coagulated Viscera]|h|r",
            ["isAwardReason"] = true,
            ["difficultyID"] = 14,
            ["responseID"] = "AUTOPASS",
            ["id"] = "1538337528-3",
            ["instance"] = "Uldir-Normal",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEMONHUNTER",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:11:31",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::5:3:4799:1502:4783:::|h[Construct Overcharger]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590291-1",
            ["date"] = "03/10/18",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["class"] = "DEMONHUNTER",
            ["groupSize"] = 16,
            ["boss"] = "MOTHER",
            ["time"] = "20:44:41",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160646:5939:::::::120:104::3:3:4798:1477:4786:::|h[Band of Certain Annihilation]|h|r",
            ["id"] = "1538941481-6",
            ["votes"] = 0,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:4:4798:1808:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["note"] = "best from raid for me",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5939:::::::120:104::23:3:4779:1512:4786:::|h[Thornwoven Band]|h|r",
            ["instance"] = "Uldir-Normal",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["id"] = "1538942778-15",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "DEMONHUNTER",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["time"] = "21:06:18",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "PASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEMONHUNTER",
            ["id"] = "1539195245-1",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160618::::::::120:104::5:3:4799:1492:4786:::|h[Gloves of Descending Madness]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:14:05",
            ["difficultyID"] = 15,
            ["boss"] = "Taloc",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DEMONHUNTER",
            ["time"] = "19:14:02",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 22,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160681::::::::120:103::5:3:4799:1492:4786:::|h[Glaive of the Keepers]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540404842-7",
            ["instance"] = "Uldir-Heroic",
         }, -- [15]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:161072:5971:::::::120:103::5:3:4799:1492:4786:::|h[Splatterguards]|h|r",
            ["boss"] = "Zek'voz",
            ["mapID"] = 1861,
            ["id"] = "1540408536-28",
            ["class"] = "DEMONHUNTER",
            ["lootWon"] = "|cffa335ee|Hitem:161072::::::::120:103::5:3:4799:1502:4783:::|h[Splatterguards]|h|r",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "20:15:36",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Best in Slot",
            ["responseID"] = 1,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DEMONHUNTER",
            ["time"] = "20:39:46",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160620::::::::120:103::5:3:4823:1492:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540409986-30",
            ["instance"] = "Uldir-Heroic",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEMONHUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:48",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781428-121",
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEMONHUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:19",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783499-143",
         }, -- [19]
         {
            ["date"] = "14/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 18,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DEMONHUNTER",
            ["boss"] = "Zul",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "19:48:05",
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["mapID"] = 1861,
            ["id"] = "1539542885-2",
         }, -- [20]
      },
      ["Phreepeat-Ravencrest"] = {
      },
      ["Renestrae-Ravencrest"] = {
      },
      ["Kossey-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "DRUID",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:47:28",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:3:4798:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536778048-29",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["id"] = "1537126196-11",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:29:56",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:158353::153711::::::120:104::23:4:4779:4802:1517:4783:::|h[Servo-Arm Bindings]|h|r",
            ["id"] = "1537727600-5",
            ["response"] = "ilvl Upgrade",
            ["date"] = "23/09/18",
            ["class"] = "DRUID",
            ["isAwardReason"] = false,
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160720::::::::120:104::3:3:4798:1477:4786:::|h[Armbands of Sacrosanct Acts]|h|r",
            ["boss"] = "Zul",
            ["time"] = "19:33:20",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 3,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["boss"] = "G'huun",
            ["time"] = "21:14:37",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159126::::::::120:104::13::::|h[Darkmoon Deck: Squalls]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160654::::::::120:104::3:3:4798:1477:4786:::|h[Vanquished Tendril of G'huun]|h|r",
            ["id"] = "1537733677-19",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160651::::::::120:104::5:3:4799:1497:4783:::|h[Vigilant's Bloodshaper]|h|r",
            ["isAwardReason"] = false,
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DRUID",
            ["id"] = "1537987145-10",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160619::::::::120:104::5:3:4823:1492:4786:::|h[Jerkin of the Aberrant Chimera]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:05",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "30/09/18",
            ["class"] = "DRUID",
            ["id"] = "1538332984-13",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160621::::::::120:104::3:3:4798:1487:4783:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:43:04",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [6]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159129:5963:::::::120:104::35:3:5006:1537:4783:::|h[Flamecaster Botefeux]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Offspec",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "DRUID",
            ["boss"] = "Zul",
            ["groupSize"] = 18,
            ["time"] = "20:21:50",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::3:3:4798:1477:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 4,
            ["id"] = "1538335310-4",
            ["instance"] = "Uldir-Normal",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:23:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:104::5:3:4799:1492:4786:::|h[Pathogenic Legwraps]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590983-8",
            ["date"] = "03/10/18",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159129:5963:::::::120:104::35:3:5006:1537:4783:::|h[Flamecaster Botefeux]|h|r",
            ["id"] = "1538945618-26",
            ["response"] = "Stat upgrade",
            ["date"] = "07/10/18",
            ["class"] = "DRUID",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160696::::::::120:104::3:3:4798:1487:4783:::|h[Codex of Imminent Ruin]|h|r",
            ["boss"] = "Mythrax",
            ["time"] = "21:53:38",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159320::153711::::::120:104::35:4:5008:4802:1542:4783:::|h[Besieger's Deckstalkers]|h|r",
            ["id"] = "1538946538-30",
            ["response"] = "Offspec",
            ["date"] = "07/10/18",
            ["class"] = "DRUID",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160729::::::::120:104::3:3:4798:1477:4786:::|h[Striders of the Putrescent Path]|h|r",
            ["boss"] = "G'huun",
            ["time"] = "22:08:58",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 4,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["boss"] = "Taloc",
            ["time"] = "20:23:54",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159126::::::::120:104::13::::|h[Darkmoon Deck: Squalls]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::3:3:4798:1477:4786:::|h[Construct Overcharger]|h|r",
            ["id"] = "1539545034-8",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160651::::::::120:104::5:3:4799:1497:4783:::|h[Vigilant's Bloodshaper]|h|r",
            ["votes"] = 0,
         }, -- [11]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163380::::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Visage]|h|r",
            ["id"] = "1539546898-22",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "DRUID",
            ["difficultyID"] = 14,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:54:58",
            ["lootWon"] = "|cffa335ee|Hitem:160623::::::::120:104::3:3:4822:1477:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["votes"] = 0,
            ["time"] = "20:58:31",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159968:5932:::::::120:104::16:3:4946:1517:4786:::|h[Gloves of the Iron Reavers]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["id"] = "1539547111-24",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:161075::::::::120:104::3:4:4798:40:1487:4783:::|h[Antiseptic Specimen Handlers]|h|r",
            ["note"] = "Stat and ilvl upgrade",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
         }, -- [13]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["id"] = "1539549048-31",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "DRUID",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Zul",
            ["time"] = "21:30:48",
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:4:4798:40:1477:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:24",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777024-22",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:33",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778953-62",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:07",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780247-87",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:35",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781415-113",
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:16",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783496-142",
         }, -- [19]
         {
            ["mapID"] = 1841,
            ["instance"] = "The Underrot-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:38:19",
            ["difficultyID"] = 8,
            ["boss"] = "Unbound Abomination",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536791899-160",
         }, -- [20]
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "DRUID",
            ["instance"] = "Siege of Boralus-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:04:04",
            ["difficultyID"] = 8,
            ["boss"] = "Viq'Goth",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537049044-5",
         }, -- [21]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "DRUID",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:55:36",
            ["difficultyID"] = 8,
            ["boss"] = "Mogul Razdunk",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537052136-11",
         }, -- [22]
         {
            ["mapID"] = 1754,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "16/09/18",
            ["class"] = "DRUID",
            ["instance"] = "Freehold-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "00:53:24",
            ["difficultyID"] = 8,
            ["boss"] = "Lord Harlan Sweete",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537055604-13",
         }, -- [23]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "14/10/18",
            ["class"] = "DRUID",
            ["instance"] = "Uldir-Heroic",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::5:3:4799:1492:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:45:01",
            ["difficultyID"] = 15,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1539542701-0",
         }, -- [24]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539803662-15",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "20:14:22",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160621::::::::120:104::5:3:4799:1492:4786:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [25]
         {
            ["color"] = {
               1, -- [1]
               0.51, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:163380::::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Visage]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Major trait upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DRUID",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160623::::::::120:104::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:14:56",
            ["boss"] = "Vectis",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "17/10/18",
            ["id"] = "1539803696-16",
         }, -- [26]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "DRUID",
            ["groupSize"] = 19,
            ["isAwardReason"] = false,
            ["time"] = "20:45:59",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158314:5939:::::::120:104::16:3:5006:1527:4786:::|h[Seal of Questionable Loyalties]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Ilvl upgrade",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::5:3:4799:1492:4786:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1539805559-23",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160645:5939:::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["votes"] = 0,
         }, -- [27]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Mythic",
            ["id"] = "1540155537-1",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "21:58:57",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::6:3:4800:1507:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 16,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "21/10/18",
         }, -- [28]
      },
      ["Regenbob-Ravencrest"] = {
      },
      ["Fuzzywuggles-Ravencrest"] = {
      },
      ["Ulftbeams-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DEMONHUNTER",
            ["time"] = "19:13:53",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 22,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:103::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540404833-6",
            ["instance"] = "Uldir-Heroic",
         }, -- [1]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160642::::::::120:103::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["boss"] = "Fetid Devourer",
            ["mapID"] = 1861,
            ["id"] = "1540405551-15",
            ["class"] = "DEMONHUNTER",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:103::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["groupSize"] = 22,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "19:25:51",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat upgrade",
            ["responseID"] = 2,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [2]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160623::::::::120:103::3:4:4822:1477:4786:4775:::|h[Hood of Pestilent Ichor]|h|r",
            ["boss"] = "Vectis",
            ["mapID"] = 1861,
            ["id"] = "1540406686-20",
            ["class"] = "DEMONHUNTER",
            ["lootWon"] = "|cffa335ee|Hitem:160623::::::::120:103::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "19:44:46",
            ["color"] = {
               1, -- [1]
               0, -- [2]
               0.07, -- [3]
               1, -- [4]
            },
            ["response"] = "Best in Slot",
            ["responseID"] = 1,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DEMONHUNTER",
            ["time"] = "20:39:44",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160620::::::::120:103::5:3:4823:1492:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540409984-29",
            ["instance"] = "Uldir-Heroic",
         }, -- [4]
         {
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:163730::154127::::::120:104::8:5:4982:4802:5129:1532:4786:::|h[Dread Gladiator's Greatcloak]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Ilvl upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DEMONHUNTER",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:15:51",
            ["boss"] = "Vectis",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "17/10/18",
            ["id"] = "1539803751-18",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "DEMONHUNTER",
            ["groupSize"] = 19,
            ["boss"] = "Zul",
            ["time"] = "21:28:30",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["note"] = "got 370 but this has versatility",
            ["id"] = "1539808110-26",
         }, -- [6]
         {
            ["mapID"] = 1877,
            ["instance"] = "Temple of Sethraliss-Mythic Keystone",
            ["id"] = "1540161855-5",
            ["class"] = "DEMONHUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["time"] = "23:44:15",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:158714::::::::120:104::16:3:5007:1532:4786:::|h[Swarm's Edge]|h|r",
            ["boss"] = "Avatar of Sethraliss",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "21/10/18",
         }, -- [7]
      },
      ["Espie-Ravencrest"] = {
      },
      ["Whistlebrew-Ravencrest"] = {
      },
      ["Sannaris-Ravencrest"] = {
      },
      ["Plexu-Ravencrest"] = {
      },
      ["Flushn-Ravencrest"] = {
      },
      ["Smlzlkecrt-Ravencrest"] = {
      },
      ["Lysandra-Ravencrest"] = {
      },
      ["Tyxie-Ravencrest"] = {
      },
      ["Kismus-Ravencrest"] = {
      },
      ["Feorath-Silvermoon"] = {
      },
      ["Zeadk-Ravencrest"] = {
      },
      ["Felwielder-Ravencrest"] = {
      },
      ["Htay-Outland"] = {
      },
      ["Fozz-Ravencrest"] = {
      },
      ["Senzys-Ravencrest"] = {
      },
      ["Stryx-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 21,
            ["boss"] = "Mythrax",
            ["time"] = "19:57:50",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158162::::::::120:104::28:3:4803:1532:4786:::|h[Pearl Diver's Compass]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160656::::::::120:104::3:3:4798:1477:4786:::|h[Twitching Tentacle of Xalzaix]|h|r",
            ["id"] = "1537729070-13",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162897::::::::120:104::47:2:1532:4783:::|h[Dread Aspirant's Medallion]|h|r",
            ["isAwardReason"] = false,
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "21:12:37",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160654::::::::120:104::3:3:4798:1477:4786:::|h[Vanquished Tendril of G'huun]|h|r",
            ["boss"] = "G'huun",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537733557-17",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "PALADIN",
            ["id"] = "1537995237-20",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160650::::::::120:104::5:3:4799:1492:4786:::|h[Disc of Systematic Regression]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:53:57",
            ["difficultyID"] = 15,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [3]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:163403::::::::120:104::6:3:5126:1562:4786:::|h[7th Legionnaire's Armguards]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["id"] = "1538590350-4",
            ["class"] = "PALADIN",
            ["difficultyID"] = 15,
            ["groupSize"] = 20,
            ["time"] = "19:12:30",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160637::::::::120:104::5:4:4799:42:1492:4786:::|h[Crimson Colossus Armguards]|h|r",
            ["votes"] = 0,
            ["boss"] = "Taloc",
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "03/10/18",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:38:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160640::::::::120:104::5:3:4799:1492:4786:::|h[Warboots of Absolute Eradication]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538595483-11",
            ["date"] = "03/10/18",
         }, -- [5]
         {
            ["date"] = "10/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158313::::::::120:104::35:3:5010:1552:4783:::|h[Legplates of Beaten Gold]|h|r",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 18,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "PALADIN",
            ["boss"] = "Taloc",
            ["response"] = "Transmogrification",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "19:14:49",
            ["lootWon"] = "|cffa335ee|Hitem:160639::::::::120:104::5:3:4799:1492:4786:::|h[Greaves of Unending Vigil]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 5,
            ["id"] = "1539195289-2",
            ["mapID"] = 1861,
         }, -- [6]
         {
            ["date"] = "10/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159287::::::::120:104::16:3:5007:1537:4783:::|h[Cloak of Questionable Intent]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 16,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "PALADIN",
            ["boss"] = "Vectis",
            ["response"] = "Ilvl upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "20:03:30",
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["id"] = "1539198210-17",
            ["mapID"] = 1861,
         }, -- [7]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163119:5963:::::::120:104::3:3:4798:1482:4783:::|h[Khor, Hammer of the Guardian]|h|r",
            ["id"] = "1539547833-25",
            ["groupSize"] = 19,
            ["date"] = "14/10/18",
            ["class"] = "PALADIN",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Zek'voz",
            ["time"] = "21:10:33",
            ["lootWon"] = "|cffa335ee|Hitem:160687::::::::120:104::3:3:4798:1477:4786:::|h[Containment Analysis Baton]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521828-4",
            ["class"] = "PALADIN",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:08",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Mythic",
            ["id"] = "1540155542-2",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "21:59:02",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160639::::::::120:104::6:3:4800:1512:4783:::|h[Greaves of Unending Vigil]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 16,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "21/10/18",
         }, -- [10]
      },
      ["Holyzack-Ravencrest"] = {
      },
      ["Tsompanós-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159431::::::::120:104::23:3:4819:1512:4786:::|h[Kraken Shell Pauldrons]|h|r",
            ["id"] = "1537729517-14",
            ["response"] = "Stat Upgrade",
            ["date"] = "23/09/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160641::::::::120:104::3:3:4822:1477:4786:::|h[Chitinspine Pauldrons]|h|r",
            ["boss"] = "Mythrax",
            ["time"] = "20:05:17",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:161719:5932:::::::120:104::39:4:4986:5129:1552:4786:::|h[Dread Gladiator's Plate Gloves]|h|r",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Transmogrification",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PALADIN",
            ["votes"] = 0,
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160635::::::::120:104::3:3:4798:1477:4786:::|h[Waste Disposal Crushers]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "19:33:08",
            ["boss"] = "Fetid Devourer",
            ["isAwardReason"] = false,
            ["responseID"] = 5,
            ["date"] = "30/09/18",
            ["id"] = "1538332388-8",
         }, -- [2]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:160212::154127::::::120:104::23:4:4779:4802:1512:4786:::|h[Shadowshroud Vambraces]|h|r",
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["response"] = "Transmogrification",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "PALADIN",
            ["boss"] = "Zul",
            ["groupSize"] = 18,
            ["time"] = "20:20:45",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160723::::::::120:104::3:3:4798:1477:4786:::|h[Imperious Vambraces]|h|r",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["responseID"] = 5,
            ["id"] = "1538335245-1",
            ["instance"] = "Uldir-Normal",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:11:31",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160637::::::::120:104::5:3:4799:1492:4786:::|h[Crimson Colossus Armguards]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590291-0",
            ["date"] = "03/10/18",
         }, -- [4]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:161719:5932:::::::120:104::39:4:4986:5129:1552:4786:::|h[Dread Gladiator's Plate Gloves]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["id"] = "1538598783-22",
            ["class"] = "PALADIN",
            ["difficultyID"] = 15,
            ["groupSize"] = 18,
            ["time"] = "21:33:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160635::::::::120:104::5:4:4799:1808:1492:4786:::|h[Waste Disposal Crushers]|h|r",
            ["votes"] = 0,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "03/10/18",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160636::::::::120:104::5:3:4823:1492:4786:::|h[Chestguard of Virulent Mutagens]|h|r",
            ["id"] = "1538942758-13",
            ["response"] = "Ilvl upgrade",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160636::::::::120:104::3:3:4822:1477:4786:::|h[Chestguard of Virulent Mutagens]|h|r",
            ["boss"] = "Vectis",
            ["time"] = "21:05:58",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 4,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0, -- [1]
               1, -- [2]
               0.02, -- [3]
               1, -- [4]
            },
         }, -- [6]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159289::::::::120:104::16:4:4780:42:1567:4784:::|h[Void-Drenched Cape]|h|r",
            ["id"] = "1539546220-15",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "PALADIN",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:43:40",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [7]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159289::::::::120:104::16:4:4780:42:1567:4784:::|h[Void-Drenched Cape]|h|r",
            ["id"] = "1539546865-19",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "PALADIN",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:54:25",
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 22,
            ["votes"] = 0,
            ["time"] = "19:15:11",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163410::::::::120:103::28:4:5125:1562:5136:5381:::|h[7th Legionnaire's Headpiece]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Offspec",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160634::::::::120:103::5:3:4823:1492:4786:::|h[Gridrunner Galea]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
            ["responseID"] = 5,
            ["note"] = "PVP HEALER",
            ["id"] = "1540404911-11",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521824-0",
            ["class"] = "PALADIN",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:04",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775846-1",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:46",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:21",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777021-18",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:41",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778061-47",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:15",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778935-54",
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:06",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780246-82",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:34",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781414-111",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:37",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783517-151",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539805395-19",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "20:43:15",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160640::::::::120:104::5:3:4799:1512:4784:::|h[Warboots of Absolute Eradication]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [18]
      },
      ["Furydad-Ravencrest"] = {
      },
      ["Zeapal-Ravencrest"] = {
      },
      ["Vaxthel-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "MAGE",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:47:37",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160613::::::::120:104::3:3:4822:1477:4786:::|h[Mantle of Contained Corruption]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536778057-45",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159266:5932:::::::120:104::23:3:4779:1512:4786:::|h[Claw-Slit Brawler's Handwraps]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1536779027-65",
            ["class"] = "MAGE",
            ["difficultyID"] = 14,
            ["groupSize"] = 21,
            ["time"] = "20:03:47",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160715::::::::120:104::3:3:4798:1477:4786:::|h[Mutagenic Protofluid Handwraps]|h|r",
            ["votes"] = 0,
            ["boss"] = "Vectis",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "12/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:158371:5949:::::::120:104::23:3:4779:1512:4786:::|h[Seabreeze]|h|r",
            ["id"] = "1537726418-1",
            ["response"] = "ilvl Upgrade",
            ["date"] = "23/09/18",
            ["class"] = "MAGE",
            ["isAwardReason"] = false,
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::3:3:4798:1477:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:13:38",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 3,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160689::::::::120:104::3:3:4798:1477:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["id"] = "1537727698-8",
            ["response"] = "Best in Slot",
            ["date"] = "23/09/18",
            ["class"] = "MAGE",
            ["isAwardReason"] = false,
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:104::3:3:4798:1477:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["boss"] = "Zul",
            ["time"] = "19:34:58",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [4]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159253::::::::120:104::16:3:5006:1527:4786:::|h[Gloves of Staunched Wounds]|h|r",
            ["id"] = "1537992580-18",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "MAGE",
            ["difficultyID"] = 15,
            ["response"] = "Stat Upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "21:09:40",
            ["lootWon"] = "|cffa335ee|Hitem:160715::::::::120:104::5:3:4799:1492:4786:::|h[Mutagenic Protofluid Handwraps]|h|r",
            ["votes"] = 0,
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "MAGE",
            ["groupSize"] = 10,
            ["boss"] = "G'huun",
            ["time"] = "21:00:11",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158321:5949:::::::120:104::16:3:5008:1537:4786:::|h[Wand of Zealous Purification]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Transmogrification",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160690::::::::120:104::3:3:4798:1477:4786:::|h[Heptavium, Staff of Torturous Knowledge]|h|r",
            ["id"] = "1538337611-6",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 5,
            ["itemReplaced2"] = "|cffa335ee|Hitem:163892::::::::120:104::3:3:5124:1532:4786:::|h[7th Legionnaire's Censer]|h|r",
            ["isAwardReason"] = false,
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["groupSize"] = 18,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:29:53",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160616::::::::120:104::5:3:4823:1492:4786:::|h[Horrific Amalgam's Hood]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538598593-20",
            ["date"] = "03/10/18",
         }, -- [7]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::154126::::::120:104::5:4:4799:1808:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["id"] = "1539546217-14",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "MAGE",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:43:37",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [8]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:163892::::::::120:104::3:3:5124:1532:4786:::|h[7th Legionnaire's Censer]|h|r",
            ["id"] = "1539550123-39",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "MAGE",
            ["difficultyID"] = 14,
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["boss"] = "Mythrax",
            ["time"] = "21:48:43",
            ["lootWon"] = "|cffa335ee|Hitem:160696::::::::120:104::3:3:4798:1477:4786:::|h[Codex of Imminent Ruin]|h|r",
            ["votes"] = 0,
            ["responseID"] = 2,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "MAGE",
            ["time"] = "19:24:32",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 22,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:103::5:3:4799:1502:4783:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540405472-12",
            ["instance"] = "Uldir-Heroic",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "MAGE",
            ["time"] = "21:08:59",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160614::::::::120:104::5:3:4823:1492:4786:::|h[Robes of the Unraveler]|h|r",
            ["boss"] = "Mythrax",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540411739-35",
            ["instance"] = "Uldir-Heroic",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["id"] = "1536521833-11",
            ["class"] = "MAGE",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:13",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775856-10",
            ["class"] = "MAGE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:56",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:36",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777036-23",
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:20",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778940-56",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:10",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780250-96",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:35",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781415-114",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "MAGE",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:39",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783519-153",
         }, -- [18]
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536869812-6",
            ["class"] = "MAGE",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:16:52",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Viq'Goth",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Siege of Boralus-Mythic",
         }, -- [19]
         {
            ["mapID"] = 1862,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536872190-15",
            ["class"] = "MAGE",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:56:30",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Gorak Tul",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Waycrest Manor-Mythic",
         }, -- [20]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536875189-23",
            ["class"] = "MAGE",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "22:46:29",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Mogul Razdunk",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
         }, -- [21]
         {
            ["mapID"] = 1763,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536877580-33",
            ["class"] = "MAGE",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "23:26:20",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Yazma",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Atal'Dazar-Mythic",
         }, -- [22]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539799752-3",
            ["class"] = "MAGE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:09:12",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::5:4:4799:1808:1492:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [23]
         {
            ["color"] = {
               0.92, -- [1]
               1, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:160613::::::::120:104::3:3:4822:1477:4786:::|h[Mantle of Contained Corruption]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Minor trait upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "MAGE",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160613::::::::120:104::5:3:4823:1492:4786:::|h[Mantle of Contained Corruption]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "20:44:06",
            ["boss"] = "Zek'voz",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "17/10/18",
            ["id"] = "1539805446-20",
         }, -- [24]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Mythic",
            ["id"] = "1540155549-4",
            ["class"] = "MAGE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "21:59:09",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160651::::::::120:104::6:3:4800:1507:4786:::|h[Vigilant's Bloodshaper]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 16,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "21/10/18",
         }, -- [25]
      },
      ["Tinybrenda-Ravencrest"] = {
      },
      ["Soddit-Ravencrest"] = {
      },
      ["Alitea-Ravencrest"] = {
      },
      ["Ouriana-Ravencrest"] = {
      },
      ["Sibelius-Ravencrest"] = {
      },
      ["Swiftshandee-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:10:49",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::3:3:4798:1477:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536775849-7",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "HUNTER",
            ["id"] = "1536783495-139",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160725::::::::120:104::3:3:4822:1477:4786:::|h[C'thraxxi General's Hauberk]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:15",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "HUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:41:07",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:104::5:3:4823:1492:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537382467-6",
            ["instance"] = "Uldir-Heroic",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160631::::::::120:104::3:3:4798:1477:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "ilvl Upgrade",
            ["instance"] = "Uldir-Normal",
            ["class"] = "HUNTER",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::3:3:4798:1487:4783:::|h[Legguards of Coalescing Plasma]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "21:28:15",
            ["boss"] = "Taloc",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["date"] = "19/09/18",
            ["id"] = "1537388895-18",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "HUNTER",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "21:12:25",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160694::::::::120:104::3:3:4798:1477:4786:::|h[Re-Origination Pulse Rifle]|h|r",
            ["boss"] = "G'huun",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537733545-15",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:155884::::::::120:104::35:3:5002:1532:4783:::|h[Parrotfeather Cloak]|h|r",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat upgrade",
            ["instance"] = "Uldir-Normal",
            ["class"] = "HUNTER",
            ["votes"] = 0,
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:4:4798:40:1487:4783:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "19:35:13",
            ["boss"] = "Fetid Devourer",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "30/09/18",
            ["id"] = "1538332513-11",
         }, -- [6]
         {
            ["date"] = "10/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159375::::::::120:104::35:3:5007:1542:4783:::|h[Legguards of the Awakening Brood]|h|r",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 18,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "HUNTER",
            ["boss"] = "Taloc",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "19:15:30",
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::5:3:4799:1492:4786:::|h[Legguards of Coalescing Plasma]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["id"] = "1539195330-4",
            ["mapID"] = 1861,
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["id"] = "1539198048-15",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:00:48",
            ["difficultyID"] = 15,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 19,
            ["boss"] = "Zek'voz",
            ["time"] = "21:11:12",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160645:5942:::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:3:4798:1482:4783:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1539547872-28",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159459:5942:::::::120:104::16:3:5007:1532:4786:::|h[Ritual Binder's Ring]|h|r",
            ["votes"] = 0,
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:07",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780247-88",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:25",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781405-103",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "HUNTER",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:16",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783496-140",
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "HUNTER",
            ["groupSize"] = 19,
            ["isAwardReason"] = false,
            ["time"] = "19:38:24",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158163::::::::120:104::28:4:4803:40:1532:4786:::|h[First Mate's Spyglass]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160648::::::::120:104::5:3:4799:1492:4786:::|h[Frenetic Corpuscle]|h|r",
            ["id"] = "1539801504-14",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160652::::::::120:104::5:3:4799:1492:4786:::|h[Construct Overcharger]|h|r",
            ["votes"] = 0,
         }, -- [13]
      },
      ["Samplle-Ravencrest"] = {
      },
      ["Vangh-Ravencrest"] = {
      },
      ["Tester 5-Stormscale"] = {
      },
      ["Tester 2-Stormscale"] = {
      },
      ["Dárkzo-Ravencrest"] = {
      },
      ["Kiffkaff-Ravencrest"] = {
      },
      ["Hunterhailz-Ravencrest"] = {
      },
      ["Brandy-Ravencrest"] = {
      },
      ["Lunastria-Ravencrest"] = {
      },
      ["Prazmaster-Ravencrest"] = {
      },
      ["Kajkae-Ravencrest"] = {
      },
      ["Craaw-Ravencrest"] = {
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "23/10/18",
            ["class"] = "WARRIOR",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cffa335ee|Hitem:159638::::::::120:71::16:3:5009:1537:4786:::|h[Electro-Arm Bludgeoner]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "02:16:57",
            ["difficultyID"] = 8,
            ["boss"] = "Mogul Razdunk",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1540250217-0",
         }, -- [1]
         {
            ["mapID"] = 1877,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "25/10/18",
            ["class"] = "WARRIOR",
            ["time"] = "00:11:41",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159442::::::::120:66::16:3:5007:1537:4783:::|h[Sand-Scoured Greatbelt]|h|r",
            ["boss"] = "Avatar of Sethraliss",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["id"] = "1540415501-0",
            ["instance"] = "Temple of Sethraliss-Mythic Keystone",
         }, -- [2]
      },
      ["Thorsk-Magtheridon"] = {
      },
      ["Mellyndia-Ravencrest"] = {
      },
      ["Dorfism-Ravencrest"] = {
      },
      ["Chalky-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "10/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 18,
            ["boss"] = "Taloc",
            ["time"] = "19:15:16",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159125::::::::120:104::13::::|h[Darkmoon Deck: Fathoms]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Ilvl upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::5:4:4799:40:1492:4786:::|h[Construct Overcharger]|h|r",
            ["id"] = "1539195316-3",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158374::::::::120:104::35:3:5010:1552:4783:::|h[Tiny Electromental in a Jar]|h|r",
            ["votes"] = 0,
         }, -- [1]
         {
            ["date"] = "10/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159287::154127::::::120:104::23:4:4779:4802:1512:4786:::|h[Cloak of Questionable Intent]|h|r",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["groupSize"] = 16,
            ["instance"] = "Uldir-Heroic",
            ["class"] = "ROGUE",
            ["boss"] = "Vectis",
            ["response"] = "Ilvl upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["time"] = "20:03:19",
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["isAwardReason"] = false,
            ["responseID"] = 3,
            ["id"] = "1539198199-16",
            ["mapID"] = 1861,
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 19,
            ["boss"] = "MOTHER",
            ["time"] = "20:33:41",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5938:153708::::::120:104::16:4:5005:4802:1527:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["id"] = "1539545621-12",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:3:4798:1482:4783:::|h[Rot-Scour Ring]|h|r",
            ["note"] = "minor stat upgrade (no socket)",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5938:::::::120:104::35:3:5007:1542:4783:::|h[Thornwoven Band]|h|r",
            ["votes"] = 0,
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 19,
            ["boss"] = "Zek'voz",
            ["time"] = "21:11:15",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5938:153708::::::120:104::16:4:5005:4802:1527:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["id"] = "1539547875-29",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat upgrade",
            ["isAwardReason"] = false,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::3:4:4798:40:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["note"] = "Sub AOE ",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5938:::::::120:104::35:3:5007:1542:4783:::|h[Thornwoven Band]|h|r",
            ["votes"] = 0,
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "ROGUE",
            ["time"] = "19:04:50",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160618::::::::120:103::5:3:4799:1492:4786:::|h[Gloves of Descending Madness]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540404290-0",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:103::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Fetid Devourer",
            ["mapID"] = 1861,
            ["id"] = "1540405548-14",
            ["class"] = "ROGUE",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:103::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["groupSize"] = 22,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "19:25:48",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat upgrade",
            ["responseID"] = 2,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 21,
            ["boss"] = "Zek'voz",
            ["time"] = "19:59:41",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159461:5938:153708::::::120:103::16:4:5005:4802:1527:4786:::|h[Band of the Ancient Dredger]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:103::5:3:4799:1492:4786:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1540407581-26",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160645:5938:::::::120:103::5:3:4799:1497:4783:::|h[Rot-Scour Ring]|h|r",
            ["isAwardReason"] = false,
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 20,
            ["boss"] = "Zul",
            ["time"] = "20:41:14",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159135:5965:154126::::::120:103::35:4:5009:4802:1547:4783:::|h[Deep Fathom's Bite]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Transmogrification",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160691::::::::120:103::5:3:4799:1492:4786:::|h[Tusk of the Reborn Prophet]|h|r",
            ["id"] = "1540410074-33",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 5,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160683:5963:::::::120:103::5:3:4799:1492:4786:::|h[Latticework Scalpel]|h|r",
            ["isAwardReason"] = false,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539799736-0",
            ["class"] = "ROGUE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:08:56",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539800331-4",
            ["class"] = "ROGUE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:18:51",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:104::5:4:4799:1808:1497:4783:::|h[Pathogenic Legwraps]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [10]
      },
      ["Surpression-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "09/09/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 22,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:37:08",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160723::::::::120:104::3:3:4798:1477:4786:::|h[Imperious Vambraces]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536521828-6",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["id"] = "1537124607-7",
            ["mapID"] = 1861,
            ["date"] = "16/09/18",
            ["groupSize"] = 21,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["response"] = "Best in Slot",
            ["boss"] = "Taloc",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160639::::::::120:104::5:4:4799:1808:1492:4786:::|h[Greaves of Unending Vigil]|h|r",
            ["time"] = "20:03:27",
            ["difficultyID"] = 15,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158313::::::::120:104::23:3:4779:1512:4786:::|h[Legplates of Beaten Gold]|h|r",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:14",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777014-6",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:31",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778051-36",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:14",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778934-51",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:09",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780249-95",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:29",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781409-109",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:12",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783492-133",
         }, -- [8]
         {
            ["mapID"] = 1841,
            ["instance"] = "The Underrot-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:38:31",
            ["difficultyID"] = 8,
            ["boss"] = "Unbound Abomination",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536791911-168",
         }, -- [9]
      },
      ["Bellætrix-Ravencrest"] = {
      },
      ["Bahmunt-Ravencrest"] = {
      },
      ["Stari-Ravencrest"] = {
      },
      ["Fungkoo-Ravencrest"] = {
      },
      ["Hypods-Ravencrest"] = {
      },
      ["Aledrra-Ravencrest"] = {
      },
      ["Charlamane-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:30:16",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160634::::::::120:104::3:3:4822:1477:4786:::|h[Gridrunner Galea]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536777016-11",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["id"] = "1536781618-126",
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["response"] = "Best in Slot",
            ["boss"] = "Zul",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160722::::::::120:104::3:3:4822:1477:4786:::|h[Chestplate of Apocalyptic Machinations]|h|r",
            ["time"] = "20:46:58",
            ["difficultyID"] = 14,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158054::::::::120:104::28:2:1532:5138:::|h[Shoalbreach Breastplate]|h|r",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PALADIN",
            ["id"] = "1536783492-134",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160646::::::::120:104::3:3:4798:1482:4783:::|h[Band of Certain Annihilation]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:12",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["id"] = "1537127647-16",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160685::::::::120:104::5:3:4799:1492:4786:::|h[Biomelding Cleaver]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:54:07",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 17,
            ["time"] = "21:25:24",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160679::::::::120:104::3:3:4798:1482:4783:::|h[Khor, Hammer of the Corrupted]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537388724-15",
            ["instance"] = "Uldir-Normal",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "19/09/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 17,
            ["boss"] = "Zek'voz",
            ["time"] = "21:48:35",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160653::::::::120:104::3:3:4798:1477:4786:::|h[Xalzaix's Veiled Eye]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Stat Upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160650::::::::120:104::3:3:4798:1477:4786:::|h[Disc of Systematic Regression]|h|r",
            ["id"] = "1537390115-25",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:158712::::::::120:104::16:3:5002:1522:4786:::|h[Rezan's Gleaming Eye]|h|r",
            ["isAwardReason"] = false,
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Offspec",
            ["date"] = "19/09/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["groupSize"] = 10,
            ["lootWon"] = "|cffa335ee|Hitem:160698::::::::120:104::3:3:4798:1477:4786:::|h[Vector Deflector]|h|r",
            ["boss"] = "Vectis",
            ["time"] = "22:05:55",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 4,
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["id"] = "1537391155-31",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["id"] = "1537733671-18",
            ["response"] = "Offspec",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "PALADIN",
            ["isAwardReason"] = false,
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160699::::::::120:104::3:3:4798:1477:4786:::|h[Barricade of Purifying Resolve]|h|r",
            ["boss"] = "G'huun",
            ["time"] = "21:14:31",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 4,
            ["date"] = "23/09/18",
            ["instance"] = "Uldir-Normal",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:158360::::::::120:104::23:3:4779:1527:4784:::|h[Sharkbait Harness Girdle]|h|r",
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Transmogrification",
            ["instance"] = "Uldir-Normal",
            ["class"] = "PALADIN",
            ["votes"] = 0,
            ["groupSize"] = 17,
            ["lootWon"] = "|cffa335ee|Hitem:160638::::::::120:104::3:3:4798:1477:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["difficultyID"] = 14,
            ["time"] = "19:22:27",
            ["boss"] = "MOTHER",
            ["isAwardReason"] = false,
            ["responseID"] = 5,
            ["date"] = "30/09/18",
            ["id"] = "1538331747-4",
         }, -- [9]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:158360::::::::120:104::23:3:4779:1527:4784:::|h[Sharkbait Harness Girdle]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Ilvl upgrade",
            ["id"] = "1538591056-9",
            ["class"] = "PALADIN",
            ["difficultyID"] = 15,
            ["groupSize"] = 20,
            ["time"] = "19:24:16",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160638::::::::120:104::5:3:4799:1492:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["votes"] = 0,
            ["boss"] = "MOTHER",
            ["responseID"] = 3,
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "03/10/18",
         }, -- [10]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159292::::::::120:104::16:3:5008:1542:4783:::|h[Sporecaller's Shroud]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["id"] = "1538598696-21",
            ["class"] = "PALADIN",
            ["difficultyID"] = 15,
            ["groupSize"] = 18,
            ["time"] = "21:31:36",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["votes"] = 0,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "03/10/18",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160638::::::::120:104::5:3:4799:1492:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["id"] = "1538941046-0",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::3:3:4798:1477:4786:::|h[Bloodstorm Buckle]|h|r",
            ["boss"] = "Taloc",
            ["time"] = "20:37:26",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [12]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:158361::::::::120:104::35:3:5009:1547:4783:::|h[Sharkwater Waders]|h|r",
            ["id"] = "1538941052-1",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160631::::::::120:104::3:3:4798:1482:4783:::|h[Legguards of Coalescing Plasma]|h|r",
            ["boss"] = "Taloc",
            ["time"] = "20:37:32",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159423::::::::120:104::23:3:4819:1512:4786:::|h[Pauldrons of the Great Unifier]|h|r",
            ["id"] = "1538941466-5",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:104::3:3:4822:1477:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["boss"] = "MOTHER",
            ["time"] = "20:44:26",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159433:5936:::::::120:104::35:4:5008:40:1557:4784:::|h[Phosphorescent Armplates]|h|r",
            ["id"] = "1538942763-14",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160621::::::::120:104::3:3:4798:1477:4786:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["boss"] = "Vectis",
            ["time"] = "21:06:03",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163421::::::::120:104::6:4:5126:41:1562:4786:::|h[7th Legionnaire's Greaves]|h|r",
            ["id"] = "1538943840-16",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160640::::::::120:104::3:3:4798:1477:4786:::|h[Warboots of Absolute Eradication]|h|r",
            ["boss"] = "Zek'voz",
            ["time"] = "21:24:00",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "PASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160638::::::::120:104::5:3:4799:1492:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["id"] = "1538944896-23",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160724::::::::120:104::3:3:4798:1477:4786:::|h[Cincture of Profane Deeds]|h|r",
            ["boss"] = "Zul",
            ["time"] = "21:41:36",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160638::::::::120:104::5:3:4799:1492:4786:::|h[Decontaminator's Greatbelt]|h|r",
            ["id"] = "1538944899-24",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160724::::::::120:104::3:3:4798:1477:4786:::|h[Cincture of Profane Deeds]|h|r",
            ["boss"] = "Zul",
            ["time"] = "21:41:39",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AWARDED",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160679:5963:::::::120:104::3:3:4798:1482:4783:::|h[Khor, Hammer of the Corrupted]|h|r",
            ["id"] = "1538946551-31",
            ["response"] = "Disenchant",
            ["date"] = "07/10/18",
            ["class"] = "PALADIN",
            ["isAwardReason"] = true,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160694::::::::120:104::3:3:4798:1477:4786:::|h[Re-Origination Pulse Rifle]|h|r",
            ["boss"] = "G'huun",
            ["time"] = "22:09:11",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = "AUTOPASS",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [19]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["id"] = "1539195229-0",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160679::::::::120:104::5:3:4799:1492:4786:::|h[Khor, Hammer of the Corrupted]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:13:49",
            ["difficultyID"] = 15,
            ["boss"] = "Taloc",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [20]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:158361::::::::120:104::35:3:5009:1547:4783:::|h[Sharkwater Waders]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Transmogrification",
            ["id"] = "1539200752-20",
            ["class"] = "PALADIN",
            ["difficultyID"] = 15,
            ["groupSize"] = 18,
            ["time"] = "20:45:52",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160718::::::::120:104::5:3:4799:1492:4786:::|h[Greaves of Creeping Darkness]|h|r",
            ["votes"] = 0,
            ["boss"] = "Zek'voz",
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "10/10/18",
         }, -- [21]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 21,
            ["votes"] = 0,
            ["time"] = "19:33:07",
            ["itemReplaced1"] = "|cffa335ee|Hitem:155864:5932:::::::120:103::16:3:5009:1537:4786:::|h[Power-Assisted Vicegrips]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:161077::::::::120:103::5:3:4799:1492:4786:::|h[Fluid-Resistant Specimen Handlers]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["note"] = "Small stat from 65 to 70 And better stats",
            ["id"] = "1540405987-17",
         }, -- [22]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "PALADIN",
            ["groupSize"] = 21,
            ["boss"] = "Zek'voz",
            ["time"] = "19:59:30",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160650::::::::120:103::3:3:4798:1477:4786:::|h[Disc of Systematic Regression]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Stat upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160650::::::::120:103::5:3:4799:1492:4786:::|h[Disc of Systematic Regression]|h|r",
            ["id"] = "1540407570-25",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 2,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160655::::::::120:103::5:3:4799:1507:4784:::|h[Syringe of Bloodborne Infirmity]|h|r",
            ["isAwardReason"] = false,
         }, -- [23]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775847-5",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:47",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [24]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:31",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778951-61",
         }, -- [25]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:07",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780247-86",
         }, -- [26]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:47",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781427-120",
         }, -- [27]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "PALADIN",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:13",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783493-136",
         }, -- [28]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539800334-5",
            ["class"] = "PALADIN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:18:54",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160638::::::::120:104::5:3:4799:1512:4784:::|h[Decontaminator's Greatbelt]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [29]
      },
      ["Alieca-Ravencrest"] = {
      },
      ["Adálith-Ravencrest"] = {
      },
      ["Angrilock-Ravencrest"] = {
      },
      ["Bjc-Ravencrest"] = {
      },
      ["Passeroth-Ravencrest"] = {
      },
      ["Selonthyxx-Ravencrest"] = {
      },
      ["Volfram-Ravencrest"] = {
      },
      ["Dukarg-Ravencrest"] = {
      },
      ["Tiladian-Silvermoon"] = {
         {
            ["mapID"] = 1841,
            ["instance"] = "The Underrot-Mythic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["date"] = "06/10/18",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:159323::::::::120:259::23:3:4819:1512:4786:::|h[Shoulders of the Sanguine Monstrosity]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "03:11:45",
            ["difficultyID"] = 23,
            ["boss"] = "Unbound Abomination",
            ["responseID"] = "PL",
            ["groupSize"] = 5,
            ["id"] = "1538784705-0",
         }, -- [1]
      },
      ["Drunkdrîver-Ravencrest"] = {
      },
      ["Mohandas-Ravencrest"] = {
      },
      ["Rhany-Ravencrest"] = {
      },
      ["Alleyena-Magtheridon"] = {
      },
      ["Ruuh-Ravencrest"] = {
      },
      ["Miladon-Ravencrest"] = {
      },
      ["Pinterhd-Ravencrest"] = {
      },
      ["Tomtànks-Ravencrest"] = {
      },
      ["Skillster-Ravencrest"] = {
      },
      ["Barrow-Ravencrest"] = {
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159325::::::::120:104::23:3:4779:1512:4786:::|h[Bloodfeaster Belt]|h|r",
            ["id"] = "1536172219-0",
            ["groupSize"] = 22,
            ["date"] = "05/09/18",
            ["class"] = "DRUID",
            ["difficultyID"] = 14,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["boss"] = "Taloc",
            ["time"] = "19:30:19",
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::3:3:4798:1477:4786:::|h[Bloodstorm Buckle]|h|r",
            ["votes"] = 0,
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["mapID"] = 1861,
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DRUID",
            ["id"] = "1536780244-75",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160619::::::::120:104::3:3:4822:1477:4786:::|h[Jerkin of the Aberrant Chimera]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:04",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["id"] = "1537122983-0",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160729::::::::120:104::3:3:4798:1477:4786:::|h[Striders of the Putrescent Path]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:36:23",
            ["difficultyID"] = 14,
            ["boss"] = "G'huun",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "19:14:19",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537380859-3",
            ["instance"] = "Uldir-Heroic",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:57:42",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["boss"] = "Fetid Devourer",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537383462-11",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 17,
            ["time"] = "21:33:24",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::3:3:4798:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537389204-19",
            ["instance"] = "Uldir-Normal",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "30/09/18",
            ["class"] = "DRUID",
            ["id"] = "1538333795-16",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160688::::::::120:104::3:3:4798:1487:4783:::|h[Void-Binder]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:56:35",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:23:01",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:104::5:3:4799:1492:4786:::|h[Pathogenic Legwraps]|h|r",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538590981-6",
            ["date"] = "03/10/18",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160619::::::::120:104::3:3:4822:1477:4786:::|h[Jerkin of the Aberrant Chimera]|h|r",
            ["id"] = "1538942130-10",
            ["response"] = "Offspec",
            ["date"] = "07/10/18",
            ["class"] = "DRUID",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160619::::::::120:104::3:3:4822:1477:4786:::|h[Jerkin of the Aberrant Chimera]|h|r",
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:55:30",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 5,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.09, -- [1]
               0.25, -- [2]
               1, -- [3]
               1, -- [4]
            },
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["date"] = "07/10/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 16,
            ["time"] = "21:40:09",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160620::::::::120:104::3:3:4822:1477:4786:::|h[Usurper's Bloodcaked Spaulders]|h|r",
            ["boss"] = "Zul",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1538944809-20",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "10/10/18",
            ["class"] = "DRUID",
            ["groupSize"] = 18,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:43:52",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160688::::::::120:104::5:3:4799:1492:4786:::|h[Void-Binder]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1539200632-19",
            ["instance"] = "Uldir-Heroic",
         }, -- [11]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["id"] = "1539546237-16",
            ["groupSize"] = 20,
            ["date"] = "14/10/18",
            ["class"] = "DRUID",
            ["difficultyID"] = 14,
            ["response"] = "Transmogrification",
            ["isAwardReason"] = false,
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:43:57",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:3:4798:1477:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["votes"] = 0,
            ["responseID"] = 5,
            ["color"] = {
               0, -- [1]
               0.52, -- [2]
               0.98, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [12]
         {
            ["difficultyID"] = 15,
            ["itemReplaced1"] = "|cffa335ee|Hitem:155888::::::::120:103::35:3:5059:1542:4786:::|h[Irontide Captain's Hat]|h|r",
            ["boss"] = "Vectis",
            ["mapID"] = 1861,
            ["id"] = "1540406689-21",
            ["class"] = "DRUID",
            ["lootWon"] = "|cffa335ee|Hitem:160623::::::::120:103::5:3:4823:1492:4786:::|h[Hood of Pestilent Ichor]|h|r",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "19:44:49",
            ["color"] = {
               1, -- [1]
               0.51, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["response"] = "Major trait upgrade",
            ["responseID"] = 2,
            ["instance"] = "Uldir-Heroic",
            ["date"] = "24/10/18",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["id"] = "1536775853-8",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:10:53",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:24",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777024-21",
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:36",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778056-43",
         }, -- [16]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:22",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778942-58",
         }, -- [17]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:05",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780245-79",
         }, -- [18]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:30",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781410-110",
         }, -- [19]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:24",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783504-145",
         }, -- [20]
         {
            ["mapID"] = 1841,
            ["instance"] = "The Underrot-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "12/09/18",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:38:24",
            ["difficultyID"] = 8,
            ["boss"] = "Unbound Abomination",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536791904-164",
         }, -- [21]
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536869804-4",
            ["class"] = "DRUID",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:16:44",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Viq'Goth",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Siege of Boralus-Mythic",
         }, -- [22]
         {
            ["mapID"] = 1862,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536872178-13",
            ["class"] = "DRUID",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:56:18",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Gorak Tul",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Waycrest Manor-Mythic",
         }, -- [23]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536875182-19",
            ["class"] = "DRUID",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "22:46:22",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Mogul Razdunk",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
         }, -- [24]
         {
            ["mapID"] = 1763,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1536877578-29",
            ["class"] = "DRUID",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "23:26:18",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["boss"] = "Yazma",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["date"] = "13/09/18",
            ["instance"] = "Atal'Dazar-Mythic",
         }, -- [25]
         {
            ["mapID"] = 1877,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "DRUID",
            ["instance"] = "Temple of Sethraliss-Mythic",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "22:13:08",
            ["difficultyID"] = 23,
            ["boss"] = "Avatar of Sethraliss",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537045988-3",
         }, -- [26]
         {
            ["mapID"] = 1822,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "DRUID",
            ["instance"] = "Siege of Boralus-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:04:31",
            ["difficultyID"] = 8,
            ["boss"] = "Viq'Goth",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537049071-7",
         }, -- [27]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "15/09/18",
            ["class"] = "DRUID",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:55:35",
            ["difficultyID"] = 8,
            ["boss"] = "Mogul Razdunk",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537052135-9",
         }, -- [28]
         {
            ["mapID"] = 1754,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "16/09/18",
            ["class"] = "DRUID",
            ["instance"] = "Freehold-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "00:53:26",
            ["difficultyID"] = 8,
            ["boss"] = "Lord Harlan Sweete",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1537055606-15",
         }, -- [29]
         {
            ["mapID"] = 1877,
            ["date"] = "08/10/18",
            ["id"] = "1539033243-0",
            ["class"] = "DRUID",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 5,
            ["time"] = "22:14:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159337::::::::120:104::16:3:5007:1532:4786:::|h[Grips of Electrified Defense]|h|r",
            ["boss"] = "Avatar of Sethraliss",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["instance"] = "Temple of Sethraliss-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [30]
         {
            ["date"] = "14/10/18",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160621:5971:::::::120:104::3:3:4798:1482:4783:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
            },
            ["note"] = "for M+",
            ["instance"] = "Uldir-Normal",
            ["class"] = "DRUID",
            ["groupSize"] = 20,
            ["response"] = "Offspec",
            ["time"] = "20:55:04",
            ["boss"] = "Vectis",
            ["lootWon"] = "|cffa335ee|Hitem:160621::::::::120:104::3:3:4798:1477:4786:::|h[Wristwraps of Coursing Miasma]|h|r",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["responseID"] = 4,
            ["mapID"] = 1861,
            ["id"] = "1539546904-23",
         }, -- [31]
         {
            ["mapID"] = 1763,
            ["instance"] = "Atal'Dazar-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "17/10/18",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:158322::::::::120:66::16:3:4946:1517:4786:::|h[Aureus Vessel]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "01:35:51",
            ["difficultyID"] = 8,
            ["boss"] = "Yazma",
            ["responseID"] = "PL",
            ["groupSize"] = 5,
            ["id"] = "1539729351-0",
         }, -- [32]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "DRUID",
            ["groupSize"] = 18,
            ["isAwardReason"] = false,
            ["time"] = "19:20:04",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159458:5944:::::::120:104::35:4:5007:41:1542:4783:::|h[Seal of the Regal Loa]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Offspec",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1539800404-8",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:162548:5944:::::::120:104::35:3:5006:1537:4783:::|h[Thornwoven Band]|h|r",
            ["votes"] = 0,
         }, -- [33]
         {
            ["mapID"] = 1864,
            ["instance"] = "Shrine of the Storm-Mythic Keystone",
            ["id"] = "1539985782-0",
            ["class"] = "DRUID",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "00:49:42",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159620::::::::120:581::16:3:4780:1517:4786:::|h[Conch of Dark Whispers]|h|r",
            ["boss"] = "Vol'zith the Whisperer",
            ["difficultyID"] = 8,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "20/10/18",
         }, -- [34]
         {
            ["mapID"] = 1594,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "23/10/18",
            ["class"] = "DRUID",
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cffa335ee|Hitem:159305::::::::120:577::16:3:5010:1542:4786:::|h[Corrosive Handler's Gloves]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "00:29:24",
            ["difficultyID"] = 8,
            ["boss"] = "Mogul Razdunk",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1540243764-0",
         }, -- [35]
      },
      ["Tæskenissen-Ravencrest"] = {
      },
      ["Daveon-TheMaelstrom"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["id"] = "1539546287-17",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "DEATHKNIGHT",
            ["boss"] = "Fetid Devourer",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "20:44:47",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::3:4:4798:40:1482:4783:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["responseID"] = 3,
            ["response"] = "Ilvl upgrade",
            ["instance"] = "Uldir-Normal",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "14/10/18",
            ["id"] = "1539546300-18",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "DEATHKNIGHT",
            ["boss"] = "Fetid Devourer",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["votes"] = 0,
            ["time"] = "20:45:00",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160635::::::::120:104::3:3:4798:1477:4786:::|h[Waste Disposal Crushers]|h|r",
            ["responseID"] = 3,
            ["response"] = "Ilvl upgrade",
            ["instance"] = "Uldir-Normal",
         }, -- [2]
         {
            ["instance"] = "Uldir-Normal",
            ["itemReplaced1"] = "|cffa335ee|Hitem:161371::::::::120:104::3:3:4798:1477:4786:::|h[Galebreaker's Sabatons]|h|r",
            ["id"] = "1539551236-44",
            ["groupSize"] = 10,
            ["date"] = "14/10/18",
            ["class"] = "DEATHKNIGHT",
            ["difficultyID"] = 14,
            ["response"] = "Offspec",
            ["isAwardReason"] = false,
            ["boss"] = "G'huun",
            ["time"] = "22:07:16",
            ["lootWon"] = "|cffa335ee|Hitem:160733::::::::120:104::3:3:4798:1477:4786:::|h[Hematocyst Stompers]|h|r",
            ["votes"] = 0,
            ["responseID"] = 4,
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [3]
      },
      ["Tomblicker-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "WARLOCK",
            ["time"] = "21:08:56",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160696::::::::120:104::5:3:4799:1492:4786:::|h[Codex of Imminent Ruin]|h|r",
            ["boss"] = "Mythrax",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540411736-34",
            ["instance"] = "Uldir-Heroic",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "WARLOCK",
            ["groupSize"] = 20,
            ["boss"] = "Mythrax",
            ["time"] = "21:11:40",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159463:5943:::::::120:104::16:3:5008:1542:4783:::|h[Loop of Pulsing Veins]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160646::::::::120:104::5:4:4799:1808:1492:4786:::|h[Band of Certain Annihilation]|h|r",
            ["id"] = "1540411900-37",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159462:5943:154127::::::120:104::16:4:5006:4802:1527:4786:::|h[Footbomb Championship Ring]|h|r",
            ["isAwardReason"] = false,
         }, -- [2]
      },
      ["Garandorr-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DEATHKNIGHT",
            ["time"] = "19:05:01",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160679::::::::120:103::5:3:4799:1492:4786:::|h[Khor, Hammer of the Corrupted]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540404301-3",
            ["instance"] = "Uldir-Heroic",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "DEATHKNIGHT",
            ["time"] = "19:42:36",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160655::::::::120:103::5:3:4799:1497:4783:::|h[Syringe of Bloodborne Infirmity]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540406556-18",
            ["instance"] = "Uldir-Heroic",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "DEATHKNIGHT",
            ["groupSize"] = 20,
            ["boss"] = "Mythrax",
            ["time"] = "21:10:28",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159658:3370:::::::120:104::16:3:5005:1527:4786:::|h[Cudgel of Correctional Oversight]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Offspec",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160686::::::::120:104::5:3:4799:1492:4786:::|h[Voror, Gleaming Blade of the Stalwart]|h|r",
            ["id"] = "1540411828-36",
            ["color"] = {
               0.16, -- [1]
               0.98, -- [2]
               0.17, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 4,
            ["itemReplaced2"] = "|cffa335ee|Hitem:161708:3368:::::::120:104::25:4:5110:5128:1537:4786:::|h[Dread Gladiator's Slicer]|h|r",
            ["isAwardReason"] = false,
         }, -- [3]
         {
            ["mapID"] = 1763,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "22/10/18",
            ["class"] = "DEATHKNIGHT",
            ["instance"] = "Atal'Dazar-Mythic Keystone",
            ["groupSize"] = 5,
            ["lootWon"] = "|cffa335ee|Hitem:158313::::::::120:104::16:3:5009:1537:4786:::|h[Legplates of Beaten Gold]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:40:12",
            ["difficultyID"] = 8,
            ["boss"] = "Yazma",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1540240812-0",
         }, -- [4]
      },
      ["Brewswayne-Ravencrest"] = {
      },
      ["Xynthe-Ravencrest"] = {
      },
      ["Monkoar-Ravencrest"] = {
      },
      ["Féra-Ravencrest"] = {
         {
            ["mapID"] = 1594,
            ["instance"] = "The MOTHERLODE!!-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DRUID",
            ["date"] = "17/10/18",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:159287::::::::120:250::16:3:5002:1522:4786:::|h[Cloak of Questionable Intent]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "00:39:01",
            ["difficultyID"] = 8,
            ["boss"] = "Mogul Razdunk",
            ["responseID"] = "PL",
            ["groupSize"] = 5,
            ["id"] = "1539725941-0",
         }, -- [1]
      },
      ["Fluushn-Ravencrest"] = {
      },
      ["Enkuu-Ravencrest"] = {
         {
            ["id"] = "1537126327-13",
            ["mapID"] = 1861,
            ["date"] = "16/09/18",
            ["groupSize"] = 21,
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["class"] = "SHAMAN",
            ["isAwardReason"] = false,
            ["response"] = "Stat Upgrade",
            ["boss"] = "MOTHER",
            ["votes"] = 0,
            ["lootWon"] = "|cffa335ee|Hitem:160699::::::::120:104::3:3:4798:1477:4786:::|h[Barricade of Purifying Resolve]|h|r",
            ["time"] = "20:32:07",
            ["difficultyID"] = 15,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159666::::::::120:104::23:3:4779:1512:4786:::|h[Improvised Riot Shield]|h|r",
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:159294::::::::120:104::2:3:4778:1517:4784:::|h[Raal's Bib]|h|r",
            ["id"] = "1537727680-7",
            ["response"] = "Stat Upgrade",
            ["date"] = "23/09/18",
            ["class"] = "SHAMAN",
            ["isAwardReason"] = false,
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::3:3:4798:1477:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["boss"] = "Zul",
            ["time"] = "19:34:40",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["groupSize"] = 20,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "20:58:33",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1538596713-15",
            ["date"] = "03/10/18",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:158017::::::::120:104::28:2:1532:5136:::|h[Ashenwood Helm]|h|r",
            ["id"] = "1538944888-21",
            ["response"] = "Minor trait upgrade",
            ["date"] = "07/10/18",
            ["class"] = "SHAMAN",
            ["isAwardReason"] = false,
            ["groupSize"] = 16,
            ["lootWon"] = "|cffa335ee|Hitem:160630::::::::120:104::3:3:4822:1477:4786:::|h[Crest of the Undying Visionary]|h|r",
            ["boss"] = "Zul",
            ["time"] = "21:41:28",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 3,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               0.92, -- [1]
               1, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "SHAMAN",
            ["id"] = "1539196780-10",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160689::::::::120:104::5:3:4799:1492:4786:::|h[Regurgitated Purifier's Flamestaff]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:40",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["date"] = "10/10/18",
         }, -- [5]
      },
      ["Gattso-Ravencrest"] = {
      },
      ["Dillerjørgen-Ravencrest"] = {
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159425::153707::::::120:104::23:4:4779:4802:1512:4786:::|h[Shard-Tipped Vambraces]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Candidate is selecting response, please wait",
            ["id"] = "1536776442-1",
            ["class"] = "DEATHKNIGHT",
            ["difficultyID"] = 14,
            ["groupSize"] = 20,
            ["time"] = "19:20:42",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160637::::::::120:104::3:3:4798:1477:4786:::|h[Crimson Colossus Armguards]|h|r",
            ["votes"] = 0,
            ["boss"] = "Unknown",
            ["responseID"] = "WAIT",
            ["color"] = {
               1, -- [1]
               1, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
         }, -- [1]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:159288::::::::120:104::16:3:5007:1527:4786:::|h[Cloak of the Restless Tribes]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1536779086-66",
            ["class"] = "DEATHKNIGHT",
            ["difficultyID"] = 14,
            ["groupSize"] = 21,
            ["time"] = "20:04:46",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::3:3:4798:1477:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["votes"] = 0,
            ["boss"] = "Vectis",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "12/09/18",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["id"] = "1537124482-6",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160639::::::::120:104::5:3:4799:1492:4786:::|h[Greaves of Unending Vigil]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:01:22",
            ["difficultyID"] = 15,
            ["boss"] = "Taloc",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:155890::::::::120:104::16:3:5005:1527:4786:::|h[Sharktooth-Knuckled Grips]|h|r",
            ["id"] = "1537726640-3",
            ["response"] = "Stat Upgrade",
            ["date"] = "23/09/18",
            ["class"] = "DEATHKNIGHT",
            ["isAwardReason"] = false,
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160635::::::::120:104::3:3:4798:1477:4786:::|h[Waste Disposal Crushers]|h|r",
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:17:20",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 2,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:163403::154126::::::120:104::6:4:5126:4802:1562:4786:::|h[7th Legionnaire's Armguards]|h|r",
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["response"] = "Stat Upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "DEATHKNIGHT",
            ["votes"] = 0,
            ["groupSize"] = 20,
            ["lootWon"] = "|cffa335ee|Hitem:160637::::::::120:104::5:3:4799:1492:4786:::|h[Crimson Colossus Armguards]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "19:08:57",
            ["boss"] = "Taloc",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "26/09/18",
            ["id"] = "1537985337-3",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["class"] = "DEATHKNIGHT",
            ["groupSize"] = 20,
            ["boss"] = "Zek'voz",
            ["time"] = "21:55:20",
            ["itemReplaced1"] = "|cffa335ee|Hitem:162541:5938:::::::120:104::16:3:5010:1542:4786:::|h[Band of the Roving Scalawag]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160647::::::::120:104::5:3:4799:1492:4786:::|h[Ring of the Infinite Void]|h|r",
            ["id"] = "1537995320-22",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160647:5938:154126::::::120:104::4:4:4801:1808:1462:4786:::|h[Ring of the Infinite Void]|h|r",
            ["votes"] = 0,
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:16",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777016-8",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:47:27",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778047-27",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:13",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778933-49",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:04",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780244-72",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:29",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781409-107",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "DEATHKNIGHT",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:11",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536783491-127",
         }, -- [12]
      },
      ["Benoid-Ravencrest"] = {
      },
      ["Whurgrim-Ravencrest"] = {
      },
      ["Knüde-Ravencrest"] = {
      },
      ["Callmejumper-Ravencrest"] = {
      },
      ["Bolox-Ravencrest"] = {
      },
      ["Samsin-Ravencrest"] = {
      },
      ["Caoileann-Ravencrest"] = {
      },
      ["Fruknude-Ravencrest"] = {
      },
      ["Whurggrim-Ravencrest"] = {
      },
      ["Mowz-Ravencrest"] = {
      },
      ["Stonie-Ravencrest"] = {
      },
      ["Asmødai-Ravencrest"] = {
      },
      ["Thuun-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "23/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "SHAMAN",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["time"] = "19:53:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160725::::::::120:104::3:3:4822:1477:4786:::|h[C'thraxxi General's Hauberk]|h|r",
            ["boss"] = "Mythrax",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1537728783-9",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["itemReplaced1"] = "|cffa335ee|Hitem:160213::::::::120:104::23:3:4779:1512:4786:::|h[Sepulchral Construct's Gloves]|h|r",
            ["id"] = "1537728989-10",
            ["response"] = "Best in Slot",
            ["date"] = "23/09/18",
            ["class"] = "SHAMAN",
            ["isAwardReason"] = false,
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160721::::::::120:104::3:4:4798:1808:1477:4786:::|h[Oblivion Crushers]|h|r",
            ["boss"] = "Mythrax",
            ["time"] = "19:56:29",
            ["difficultyID"] = 14,
            ["votes"] = 0,
            ["responseID"] = 1,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
         }, -- [2]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:158019::::::::120:104::28:2:1532:5140:::|h[Ashenwood Spaulders]|h|r",
            ["id"] = "1537986204-5",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 15,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["boss"] = "MOTHER",
            ["time"] = "19:23:24",
            ["lootWon"] = "|cffa335ee|Hitem:160632::::::::120:104::5:3:4823:1492:4786:::|h[Flame-Sterilized Spaulders]|h|r",
            ["votes"] = 0,
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["date"] = "26/09/18",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "SHAMAN",
            ["id"] = "1537987151-11",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:160628::::::::120:104::5:3:4799:1497:4783:::|h[Fused Monstrosity Stompers]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:39:11",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [4]
         {
            ["instance"] = "Uldir-Heroic",
            ["itemReplaced1"] = "|cffa335ee|Hitem:157954::::::::120:104::25:4:4803:41:1532:4784:::|h[Bilewing Legguards]|h|r",
            ["id"] = "1537991529-16",
            ["groupSize"] = 21,
            ["date"] = "26/09/18",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 15,
            ["response"] = "Best in Slot",
            ["isAwardReason"] = false,
            ["boss"] = "Vectis",
            ["time"] = "20:52:09",
            ["lootWon"] = "|cffa335ee|Hitem:160716::::::::120:104::5:4:4799:1808:1492:4786:::|h[Blighted Anima Greaves]|h|r",
            ["votes"] = 0,
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["mapID"] = 1861,
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "30/09/18",
            ["class"] = "SHAMAN",
            ["id"] = "1538333793-15",
            ["groupSize"] = 18,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::3:3:4798:1477:4786:::|h[Titanspark Energy Girdle]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:56:33",
            ["difficultyID"] = 14,
            ["boss"] = "Zek'voz",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["instance"] = "Uldir-Normal",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 18,
            ["votes"] = 0,
            ["time"] = "19:57:41",
            ["itemReplaced1"] = "|cffa335ee|Hitem:159402::::::::120:104::23:3:4779:1512:4786:::|h[Waistguard of Sanguine Fervor]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["id"] = "1538333861-18",
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::3:3:4798:1482:4783:::|h[Titanspark Energy Girdle]|h|r",
            ["note"] = "ilvl upgrade",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["isAwardReason"] = false,
            ["boss"] = "Zek'voz",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["date"] = "30/09/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 18,
            ["boss"] = "Mythrax",
            ["time"] = "20:41:35",
            ["itemReplaced1"] = "|cffa335ee|Hitem:162541:5939:::::::120:104::23:3:4779:1517:4783:::|h[Band of the Roving Scalawag]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160646::::::::120:104::3:4:4798:1808:1477:4786:::|h[Band of Certain Annihilation]|h|r",
            ["id"] = "1538336495-2",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160645:5943:::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["isAwardReason"] = false,
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["date"] = "03/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 20,
            ["boss"] = "Taloc",
            ["time"] = "19:12:13",
            ["itemReplaced1"] = "|cffa335ee|Hitem:161113::::::::120:104::25:3:4803:1537:4784:::|h[Incessantly Ticking Clock]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::5:3:4799:1492:4786:::|h[Construct Overcharger]|h|r",
            ["id"] = "1538590333-3",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160648::154127::::::120:104::4:4:4801:1808:1462:4786:::|h[Frenetic Corpuscle]|h|r",
            ["isAwardReason"] = false,
         }, -- [9]
         {
            ["itemReplaced1"] = "|cffa335ee|Hitem:161368::::::::120:104::3:3:4798:1492:4784:::|h[Freezing Tempest Waistguard]|h|r",
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["id"] = "1538595603-13",
            ["class"] = "SHAMAN",
            ["difficultyID"] = 15,
            ["groupSize"] = 20,
            ["time"] = "20:40:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160633::::::::120:104::5:3:4799:1492:4786:::|h[Titanspark Energy Girdle]|h|r",
            ["votes"] = 0,
            ["boss"] = "Zek'voz",
            ["responseID"] = 1,
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["date"] = "03/10/18",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["date"] = "24/10/18",
            ["class"] = "SHAMAN",
            ["groupSize"] = 22,
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:26:35",
            ["itemReplaced1"] = "|cffa335ee|Hitem:161113::::::::120:103::25:3:4803:1537:4784:::|h[Incessantly Ticking Clock]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Best in Slot",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160648::::::::120:103::5:3:4799:1492:4786:::|h[Frenetic Corpuscle]|h|r",
            ["id"] = "1540405595-16",
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 1,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160652::::::::120:103::5:3:4799:1492:4786:::|h[Construct Overcharger]|h|r",
            ["isAwardReason"] = false,
         }, -- [11]
         {
            ["color"] = {
               1, -- [1]
               0.1, -- [2]
               0, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::154127::::::120:104::5:4:4799:1808:1492:4786:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Best in Slot",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "SHAMAN",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "19:37:57",
            ["boss"] = "Fetid Devourer",
            ["isAwardReason"] = false,
            ["responseID"] = 1,
            ["date"] = "17/10/18",
            ["id"] = "1539801477-13",
         }, -- [12]
      },
      ["Dmpale-Ravencrest"] = {
      },
      ["Hotwolf-Ravencrest"] = {
      },
      ["Quamo-Outland"] = {
      },
      ["Finopuff-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["id"] = "1537127646-15",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160643::::::::120:104::5:3:4799:1492:4786:::|h[Fetid Horror's Tanglecloak]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:54:06",
            ["difficultyID"] = 15,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [1]
      },
      ["Pastramis-Ravencrest"] = {
         {
            ["mapID"] = 1754,
            ["instance"] = "Freehold-Mythic",
            ["id"] = "1537302230-0",
            ["class"] = "ROGUE",
            ["groupSize"] = 5,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "21:23:50",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:159299::::::::120:253::23:3:4819:1512:4786:::|h[Gold-Tasseled Epaulets]|h|r",
            ["boss"] = "Lord Harlan Sweete",
            ["difficultyID"] = 23,
            ["responseID"] = "PL",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "18/09/18",
         }, -- [1]
      },
      ["Deadlyblaze-Ravencrest"] = {
      },
      ["Gombon-Ravencrest"] = {
      },
      ["Crawmode-Ravencrest"] = {
      },
      ["Cretino-Ravencrest"] = {
         {
            ["mapID"] = 1861,
            ["date"] = "05/09/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 22,
            ["boss"] = "Fetid Devourer",
            ["time"] = "20:26:52",
            ["itemReplaced1"] = "|cff0070dd|Hitem:158374::::::::120:104::2:4:4778:40:1497:4785:::|h[Tiny Electromental in a Jar]|h|r",
            ["instance"] = "Uldir-Normal",
            ["response"] = "ilvl Upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 14,
            ["lootWon"] = "|cffa335ee|Hitem:160648::::::::120:104::3:3:4798:1477:4786:::|h[Frenetic Corpuscle]|h|r",
            ["id"] = "1536175612-2",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:159628::::::::120:104::23:3:4779:1512:4786:::|h[Kul Tiran Cannonball Runner]|h|r",
            ["isAwardReason"] = false,
         }, -- [1]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "12/09/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 21,
            ["response"] = "Personal Loot - Non tradeable",
            ["time"] = "19:47:30",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160717::::::::120:104::3:3:4798:1487:4783:::|h[Replicated Chitin Cord]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 14,
            ["responseID"] = "PL",
            ["id"] = "1536778050-33",
            ["instance"] = "Uldir-Normal",
         }, -- [2]
         {
            ["mapID"] = 1861,
            ["date"] = "12/09/18",
            ["instance"] = "Uldir-Normal",
            ["class"] = "ROGUE",
            ["id"] = "1536783492-130",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160646::::::::120:104::3:3:4798:1482:4783:::|h[Band of Certain Annihilation]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "21:18:12",
            ["difficultyID"] = 14,
            ["boss"] = "Mythrax",
            ["responseID"] = "PL",
            ["groupSize"] = 22,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
         }, -- [3]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Heroic",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["id"] = "1537126155-10",
            ["response"] = "Personal Loot - Non tradeable",
            ["lootWon"] = "|cffa335ee|Hitem:160625::::::::120:104::5:4:4799:1808:1492:4786:::|h[Pathogenic Legwraps]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:29:15",
            ["difficultyID"] = 15,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["groupSize"] = 21,
            ["date"] = "16/09/18",
         }, -- [4]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "ROGUE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 19,
            ["time"] = "19:13:49",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160652::::::::120:104::5:4:4799:1808:1492:4786:::|h[Construct Overcharger]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537380829-0",
            ["instance"] = "Uldir-Heroic",
         }, -- [5]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "19/09/18",
            ["class"] = "ROGUE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "20:46:14",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1497:4783:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["boss"] = "Vectis",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537386374-13",
            ["instance"] = "Uldir-Heroic",
         }, -- [6]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "26/09/18",
            ["class"] = "ROGUE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 20,
            ["time"] = "19:07:49",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160618::::::::120:104::5:4:4799:1808:1492:4786:::|h[Gloves of Descending Madness]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1537985269-0",
            ["instance"] = "Uldir-Heroic",
         }, -- [7]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["date"] = "24/10/18",
            ["class"] = "ROGUE",
            ["time"] = "19:57:26",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 21,
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160624::::::::120:103::5:3:4799:1492:4786:::|h[Quarantine Protocol Treads]|h|r",
            ["boss"] = "Zek'voz",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["id"] = "1540407446-23",
            ["instance"] = "Uldir-Heroic",
         }, -- [8]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "19:30:14",
            ["difficultyID"] = 14,
            ["boss"] = "MOTHER",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536777014-2",
         }, -- [9]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["date"] = "12/09/18",
            ["groupSize"] = 21,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:02:15",
            ["difficultyID"] = 14,
            ["boss"] = "Vectis",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536778935-52",
         }, -- [10]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:24:05",
            ["difficultyID"] = 14,
            ["boss"] = "Fetid Devourer",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536780245-80",
         }, -- [11]
         {
            ["mapID"] = 1861,
            ["instance"] = "Uldir-Normal",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["date"] = "12/09/18",
            ["groupSize"] = 22,
            ["lootWon"] = "|cffa335ee|Hitem:162461::::::::120:104::::::|h[Sanguicell]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "20:43:21",
            ["difficultyID"] = 14,
            ["boss"] = "Zul",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536781401-100",
         }, -- [12]
         {
            ["mapID"] = 1841,
            ["instance"] = "The Underrot-Mythic Keystone",
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["class"] = "ROGUE",
            ["date"] = "12/09/18",
            ["groupSize"] = 5,
            ["lootWon"] = "|cff0070dd|Hitem:162460::::::::120:104::::::|h[Hydrocore]|h|r",
            ["isAwardReason"] = false,
            ["time"] = "23:38:17",
            ["difficultyID"] = 8,
            ["boss"] = "Unbound Abomination",
            ["responseID"] = "PL",
            ["response"] = "Personal Loot - Non tradeable",
            ["id"] = "1536791897-158",
         }, -- [13]
         {
            ["mapID"] = 1861,
            ["color"] = {
               1, -- [1]
               0.6, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["id"] = "1539799743-2",
            ["class"] = "ROGUE",
            ["response"] = "Personal Loot - Non tradeable",
            ["groupSize"] = 18,
            ["time"] = "19:09:03",
            ["isAwardReason"] = false,
            ["lootWon"] = "|cffa335ee|Hitem:160622::::::::120:104::5:3:4799:1492:4786:::|h[Bloodstorm Buckle]|h|r",
            ["boss"] = "Taloc",
            ["difficultyID"] = 15,
            ["responseID"] = "PL",
            ["date"] = "17/10/18",
            ["instance"] = "Uldir-Heroic",
         }, -- [14]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 18,
            ["isAwardReason"] = false,
            ["time"] = "19:20:01",
            ["itemReplaced1"] = "|cffa335ee|Hitem:160647:5939:154126::::::120:104::3:4:4798:1808:1477:4786:::|h[Ring of the Infinite Void]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Ilvl upgrade",
            ["boss"] = "MOTHER",
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160645::::::::120:104::5:3:4799:1492:4786:::|h[Rot-Scour Ring]|h|r",
            ["id"] = "1539800401-7",
            ["color"] = {
               0.99, -- [1]
               0.9, -- [2]
               0.27, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["responseID"] = 3,
            ["itemReplaced2"] = "|cffa335ee|Hitem:160645:5942:::::::120:104::3:3:4798:1477:4786:::|h[Rot-Scour Ring]|h|r",
            ["votes"] = 0,
         }, -- [15]
         {
            ["mapID"] = 1861,
            ["date"] = "17/10/18",
            ["class"] = "ROGUE",
            ["groupSize"] = 19,
            ["boss"] = "Fetid Devourer",
            ["time"] = "19:37:36",
            ["itemReplaced1"] = "|cffa335ee|Hitem:157974::::::::120:104::28:3:1547:5138:5380:::|h[Seafarer Vest]|h|r",
            ["instance"] = "Uldir-Heroic",
            ["response"] = "Major trait upgrade",
            ["votes"] = 0,
            ["difficultyID"] = 15,
            ["lootWon"] = "|cffa335ee|Hitem:160619::::::::120:104::5:3:4823:1492:4786:::|h[Jerkin of the Aberrant Chimera]|h|r",
            ["isAwardReason"] = false,
            ["color"] = {
               1, -- [1]
               0.51, -- [2]
               0, -- [3]
               1, -- [4]
            },
            ["responseID"] = 2,
            ["note"] = "ilvl upgrade",
            ["id"] = "1539801456-11",
         }, -- [16]
         {
            ["color"] = {
               1, -- [1]
               0.54, -- [2]
               0.09, -- [3]
               1, -- [4]
               ["color"] = {
                  1, -- [1]
                  1, -- [2]
                  1, -- [3]
                  1, -- [4]
               },
               ["text"] = "Response",
            },
            ["itemReplaced1"] = "|cffa335ee|Hitem:160644::::::::120:104::5:3:4799:1497:4783:::|h[Plasma-Spattered Greatcloak]|h|r",
            ["mapID"] = 1861,
            ["response"] = "Stat upgrade",
            ["instance"] = "Uldir-Heroic",
            ["class"] = "ROGUE",
            ["votes"] = 0,
            ["groupSize"] = 19,
            ["lootWon"] = "|cffa335ee|Hitem:160642::::::::120:104::5:3:4799:1492:4786:::|h[Cloak of Rippling Whispers]|h|r",
            ["difficultyID"] = 15,
            ["time"] = "21:28:18",
            ["boss"] = "Zul",
            ["isAwardReason"] = false,
            ["responseID"] = 2,
            ["date"] = "17/10/18",
            ["id"] = "1539808098-24",
         }, -- [17]
      },
      ["Fckalli-Ravencrest"] = {
      },
      ["Battlecat-Ravencrest"] = {
      },
   }



os.exit(lu.LuaUnit.run("-v"))
