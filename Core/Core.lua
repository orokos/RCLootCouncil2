--- RCLootCouncil Core.lua
-- Startup script and core addon API/elements.
-- @author Potdisc 2019

local a_name, a_table = ...
_G.RCLootCouncil = LibStub("AceAddon-3.0"):NewAddon(addontable,addonname, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
_G.RCLootCouncil.L = LibStub("AceLocale-3.0"):GetLocale(a_name)
RCLootCouncil:SetDefaultModuleState(false)

function RCLootCouncil:OnInitialize()
  	self.version = GetAddOnMetadata("RCLootCouncil", "Version")
	self.nnp = false
	self.debug = false
	self.tVersion = "Beta.1" -- String or nil. Indicates test version, which alters stuff like version check. Is appended to 'version', i.e. "version-tVersion" (max 10 letters for stupid security)


   self.chatCmdHelp = self.Const.CHAT_CMD_HELP
   self.responses = self.Const.DEFAULT_RESPONSES
   self.defaults = self.Const.DEFAULT_OPTIONS


   self.Log:Init()
   self.Log("Done initalizing")
end

----------------------------------------------------------------
-- API
----------------------------------------------------------------

--- Adds chat commands to the "/rc" prefix.
-- @paramsig module, cmds, func[, cmdDesc, desc]
-- @param cmds 	Table. The command(s) the user can input. The first is shown with the help string
-- @param module 	The object to call func on.
-- @param func    The function (funcRef or methodname) to call on module. Passed with module as first arg, followed by user provided args.
-- @param cmdDesc	An optional description of the command - added before desc in the help string. If omitted, then the first command will be used instead.
-- @param desc 	A string shown if the user types /rc help or an invalid command. If omitted, no help string will be added.
-- @usage
-- -- For example in GroupGear:
-- RCLootCouncil:ModuleChatCmd(GroupGear, "Show", nil, "Show the GroupGear window (alt. 'groupgear' or 'gear')", "gg", "groupgear", "gear")
-- -- will result in GroupGear:Show() being called if the user types "/rc gg" (or "/rc groupgear" or "/rc gear")
-- -- "/rc help" will get "gg: Show the GroupGear window (alt. 'groupgear' or 'gear')" added.
function RCLootCouncil:AddChatCommand(module, cmds, func, cmdDesc, desc)
   self.SlashCommands:Register(module, cmds, func, cmdDesc, desc)
end
