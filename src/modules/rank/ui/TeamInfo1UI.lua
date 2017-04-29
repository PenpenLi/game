module(..., package.seeall)
setmetatable(_M, {__index = Control})

local FlowerDefine = require("src/modules/flower/FlowerDefine")
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local PublicLogic = require("src/modules/public/PublicLogic")

function new(team)
	local ctrl = Control.new(require("res/rank/TeamInfo1Skin"),{"res/rank/TeamInfo1.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(team)
	return ctrl
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end

function init(self,team)
	self.applyBtn:addEventListener(Event.Click, onApply, self)
end

function onApply(self, evt)
	if PublicLogic.checkModuleOpen("guild") then
		Network.sendMsg(PacketID.CG_GUILD_APPLY, self.guildId)
	end
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function refreshInfo(self,team)
	if not team then
		return
	end
	self.guildId = team.flowerCount
	self.infoCon.nameCon.guildNameTxt:setString(team.guild)
	self.infoCon.fightCon.fightTxt:setString(team.fightVal)
	self.infoCon.rankTxt:setString(team.rank)
	self.bossNameTxt:setString(team.name)
	self.humanCntTxt:setString(team.win)
	self.guildLvTxt:setString(team.lv)
	CommonGrid.bind(self.infoCon.headbg)
	self.infoCon.headbg:setBodyIcon(tonumber(team.bodyId))
end
