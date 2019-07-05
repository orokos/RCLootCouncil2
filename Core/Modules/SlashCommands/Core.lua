--- RCLootCouncil SlashCommands/Core.lua
-- Handles all slashcommands setup by the addon and its modules.
-- @namespace RCLootCouncil.SlashCommands
-- @author Potdisc 2019

local _, addon = ...
local SlashCommands = addon:NewModule("SlashCommands", "AceConsole-3.0")

addon.SlashCommands = SlashCommands
local private = {
   chatCmds = {},
   chatCmdHelp = {}
}

function SlashCommands:OnInitialize()
   self:RegisterChatCommand("rc", private.OnCommand)
   self:RegisterChatCommand("rclc", private.OnCommand)
   self:RegisterChatCommand("rclootcouncil", private.OnCommand)
end

--- @see RCLootCouncil.AddChatCommand()
function SlashCommands:Register(module, cmds, func, cmdDesc, desc)
	for i = 1, #cmds do
      if type(func) == "string" then
         private.chatCmds[cmds[i]] = {module = module,
         func = function(...)
            module[func](module, ...)
         end}
      else
         private.chatCmds[cmds[i]] = {module = module, func = func}
      end
	end
   if desc and desc ~= "" then -- Allow for commands that doesn't get added to the help menu
   	if cmdDesc then
   		tinsert(private.chatCmdHelp, {cmd = cmdDesc, desc = desc, module = module})
   	else
   		tinsert(private.chatCmdHelp, {cmd = cmds[1], desc = desc, module = module})
   	end
   end
end

--- Simply prints all the help info registered.
function SlashCommand:ShowHelp()
   if addon.tVersion then
      print(format(L["chat tVersion string"],addon.version, addon.tVersion))
   else
      print(format(L["chat version String"],addon.version))
   end
   local module
   for _, v in ipairs(SlashCommands.chatCmdHelp) do
      if v.module ~= module then -- Print module name and version
         print "" -- spacer
         if v.module.version and v.module.tVersion then
            print(v.module.baseName, "|cFFFFA500", v.module.version, v.module.tVersion)
         elseif v.module.version then
            print(v.module.baseName, "|cFFFFA500", v.module.version)
         else
            print(v.module.baseName, "|cFFFFA500", GetAddOnMetadata(v.module.baseName, "Version"))
         end
      end
      if v.cmd then
         print("|cff20a200", v.cmd, "|r:", v.desc)
      else
         print(v.desc) -- For backwards compatibility
      end
      module = v.module
   end
   if addon.debug then private:PrintDebugHelp() end
end

function private.OnCommand(msg)
   local input = addon:GetArgs(msg,1)
	local args = {}
	local arg, startpos = nil, input and #input + 1 or 0
	repeat
	    arg, startpos = addon:GetArgs(msg, 1, startpos)
	    if arg then
	         table.insert(args, arg)
	    end
	until arg == nil
	input = strlower(input or "")
	addon.Log.f("<SlashCommand>", input, unpack(args))

   if not input or input:trim() == "" or input == "help" or input == string.lower(_G.HELP_LABEL)
      or not private.chatCmds[input] then
		private:ShowHelp()
   else
      private.chatCmds[input].func(unpack(args))
   end
end

function private:PrintDebugHelp ()
   print("- debug or d - Toggle debugging")
	print("- log - display the debug log")
	print("- clearLog - clear the debug log")
end

do -- Insert Debug functions
   private.chatCmds["d"] = { module = addon,
   func = function()
      addon.debug = not addon.debug
      addon.Log.p("Debug = ", tostring(addon.debug))
   end}
   private.chatCmds["debug"] = private.chatCmds["d"]



end
