--- RCLootCouncil SlashCommands/BasicSlashCommands.lua
-- Contains and registers the basic slash commands in the addon.
-- @author Potdisc 2019
local _,addon = ...
local SlashCommands = addon.SlashCommands
local L = addon.L

do
   -- Config
   SlashCommands:Register(addon,
   {'config', L["config"], "c", "opt", "options"},
   function()
      -- Call it twice, because reasons..
		InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
		InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame)
   end, nil, L["chat_commands_config"])

   -- Council
   SlashCommands:Register(addon,
   {"council", L["council"]},
   function()
      InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame.ml)
		InterfaceOptionsFrame_OpenToCategory(addon.optionsFrame.ml)
		LibStub("AceConfigDialog-3.0"):SelectGroup("RCLootCouncil", "mlSettings", "councilTab")
   end, nil, L["chat_commands_council"])

   -- Test
   SlashCommands:Register(addon,
   {"test", L["test"]},
   function(num)
      addon:Test(tonumber(num) or 1)
   end, "test [#]", L["chat_commands_test"])

   -- Full Test
   SlashCommands:Register(addon,
   {"fulltest", "ftest"},
   function(num)
      addon:Test(tonumber(num) or 1, true)
   end)




   SlashCommands:Register(addon, function()

   end, nil)
end
