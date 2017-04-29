module(..., package.seeall)
setmetatable(_M, {__index = Control})
local PublicLogic = require("src/modules/public/PublicLogic")

function new()
	local ctrl = Control.new(require("res/flower/FlowerLinkSkin"), {"res/flower/FlowerLink.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.THIRD_TEMP
end

function init(self)
	_M.touch = Common.outSideTouch
	self.rankCon.rankBtn:addEventListener(Event.Click, onRank, self)
	self.guildCon.guildBtn:addEventListener(Event.Click, onGuild, self)
	self.chatCon.chatBtn:addEventListener(Event.Click, onChat, self)
	self.friendCon.friendBtn:addEventListener(Event.Click, onFriend, self)
	self:addBg()
end

function addBg(self)
	local spr = cc.Sprite:create('res/flower/flowerLinkBg.png')
	spr:setAnchorPoint(0, 0.5)
	spr:setPosition(cc.p(self.guildCon._skin.width/2 - 15, self.guildCon:getPositionY() + self.guildCon._skin.height/2))
	spr:setLocalZOrder(-1)
	self._ccnode:addChild(spr)
end

function onFriend(self, evt)
	UIManager.addUI('src/modules/friends/ui/FriendsUI')
end

function onRank(self, evt)
	if PublicLogic.checkModuleOpen("rank") then
		UIManager.addUI('src/modules/rank/ui/RankUI')
	end
end

function onGuild(self, evt)
	if PublicLogic.checkModuleOpen("guild") then
		if Master.getInstance().guildId > 0 then
			UIManager.addUI("src/modules/guild/ui/MemberListUI", 1)
		else
			UIManager.addUI("src/modules/guild/ui/GuildUI")
		end
	end
end

function onChat(self, evt)
	UIManager.reset()
	UIManager.setChatUI(true)
	local ChatUI = Stage.currentScene:getUI():getChild("Chat")
	ChatUI:doShow()
end
