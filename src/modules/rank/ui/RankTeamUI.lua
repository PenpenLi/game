module(..., package.seeall)

local TeamTipsUI = require("src/ui/TeamTipsUI")

setmetatable(_M, {__index = TeamTipsUI})

function new()
	local ctrl = TeamTipsUI.new()
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "RankTeamUI"
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end
