local _, addon = ...

addon.Const.DEFAULT_RESPONSES = {
   default = {
		AWARDED        = { color = {1,1,1,1},				sort = 0.1,		text = L["Awarded"],},
		PL					= { color = {1, 0.6,0,1},			sort = 498,		text = L["Personal Loot - Non tradeable"]},
		PL_REJECT		= { color = {0.2,0,0,1},			sort = 499,		text = L["Personal Loot - Rejected Trade"]},
		NOTANNOUNCED	= { color = {1,0,1,1},				sort = 501,		text = L["Not announced"],},
		ANNOUNCED		= { color = {1,0,1,1},				sort = 502,		text = L["Loot announced, waiting for answer"], },
		WAIT				= { color = {1,1,0,1},				sort = 503,		text = L["Candidate is selecting response, please wait"], },
		TIMEOUT			= { color = {1,0,0,1},				sort = 504,		text = L["Candidate didn't respond on time"], },
		REMOVED			= { color = {0.8,0.5,0,1},			sort = 505,		text = L["Candidate removed"], },
		NOTHING			= { color = {0.5,0.5,0.5,1},		sort = 505,		text = L["Offline or RCLootCouncil not installed"], },
		PASS				= { color = {0.7, 0.7,0.7,1},		sort = 800,		text = _G.PASS,},
		AUTOPASS			= { color = {0.7,0.7,0.7,1},		sort = 801,		text = L["Autopass"], },
		DISABLED			= { color = {0.3,0.35,0.5,1},		sort = 802,		text = L["Candidate has disabled RCLootCouncil"], },
		NOTINRAID		= { color = {0.7,0.6,0,1}, 		sort = 803, 	text = L["Candidate is not in the instance"]},
		DEFAULT			= { color = {1,0,0,1},				sort = 899, 	text = L["Response isn't available. Please upgrade RCLootCouncil."]},
		--[[1]]			  { color = {0,1,0,1},				sort = 1,		text = L["Mainspec/Need"],},
		--[[2]]			  { color = {1,0.5,0,1},			sort = 2,		text = L["Offspec/Greed"],	},
		--[[3]]			  { color = {0,0.7,0.7,1},			sort = 3,		text = L["Minor Upgrade"],},
	},
	['*'] = {
		['*'] = {
			text = L["Response"],
			color = {1,1,1,1},
		},
	}
}
