dofile "../wow_api.lua"
dofile "../../Libs/LibStub/LibStub.lua"
dofile "../../Libs/AceAddon-3.0/AceAddon-3.0.lua"
rc = LibStub("AceAddon-3.0"):NewAddon("RCLootCouncil")

gsub = string.gsub
strfind = string.find
strsplit = string.split

rc.realmName = "Ourrealm"
local count = 1
local db = {
   PlayerNames = {
      ["Player-000-00000001"] = "Gemenim-Daggerspine",
      ["Player-000-00000002"] = "Potdisc-Ravencrest",
      ["Player-0af-cdea0139"] = "Somedude-Someserver",
   }
}

function rc:Getdb (args)
   return db
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

function GetPlayerInfoByGUID(guid)
   -- Expects 6 return values
   return "","","","","", db.PlayerNames[guid] or "SomeNewDude-Server"
end

function UnitGUID (name)
   local t = tInvert(db.PlayerNames)
   return t[name] or "Player-FFF-ABCDF012"
end

function printTests (Name)
   print("GetName:","\t", Name:GetName())
   print("GetShortName:","\t",Name:GetShortName())
   print("GetGUID:","\t", Name:GetGUID())
   print("GetForStorage:","\t", Name:GetForStorage())
   print("GetTransmitGUID:","\t", Name:GetTransmitGUID())
   print("GetInfo:","\t",Name:GetInfo())
   print("Name:","\t", Name)
end

dofile "../../Classes/PlayerNames.lua"

local Name = rc.Names:Get("Gemenim-Daggerspine")
for k,v in pairs(Name) do print(k,v) end
assert("Gemenim-Daggerspine" == Name:GetName())
assert("Gemenim" == Name:GetShortName())
assert("Player-000-00000001" == Name:GetGUID())
assert("000-00000001" == Name:GetTransmitGUID())
assert("Gemenim-Daggerspine", Name)
Name = rc.Names:Get("Player-000-00000002")
printTests(Name)
printTests(rc.Names:Get("000-00000002"))
printTests(rc.Names:Get("0af-cdea0139"))
