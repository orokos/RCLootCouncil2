-- Setup RCLootCouncil global along with it's minimum requirements
-- REVIEW: Must be called from "/UnitTests" for now
dofile "../wow_api.lua"
dofile "../__load_libs.lua"
RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil", "AceConsole-3.0")
RCLootCouncil.debug = false

RCLootCouncil.db = {
   profile = {},
   global = {
      log = {},
   },
}
RCLootCouncil.defaults = {
   global = {
      logMaxEntries = 2000,
   },
}

-- Setup Log
dofile "../../Classes/Log.lua"
RCLootCouncil.Log:Init()
