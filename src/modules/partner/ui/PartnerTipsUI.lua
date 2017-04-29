module("PartnerTipsUI",package.seeall)
setmetatable(_M,{__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local PartnerConfig = require("src/config/PartnerConfig").Config
local Hero = require("src/modules/hero/Hero")
local Chapter = require("src/modules/chapter/Chapter")

function new(id)
	local ctrl = Control.new(require("res/partner/PartnerTipsSkin.lua"),{"res/partner/PartnerTips.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function onGoChapter(self,event,target)
	if event.etype == Event.Touch_ended then
		Chapter.sendLevelStart(target.levelId,target.difficulty)
	end
end

function init(self,id)
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click, onClose, self)
	CommonGrid.bind(self.group.bg)
	self.group.bg:setItemIcon(id)
	local cfg = ItemConfig[id]
	self.group.txtname:setString(cfg.name)

	CommonGrid.bind(self.group.headBG)
	local pCfg = PartnerConfig[id]
	local name = pCfg.hero
	local cName = Hero.getCNameByName(name)
	self.group.headBG:setHeroIcon(name)
	self.group.txtprogress:setString(cName.."的伙伴道具")

	local levelList = Chapter.getLevelListByReward(id)
	local list = self.guankalist
	list:removeAllItem()
	list:setItemNum(#levelList)
	for i = 1,#levelList do
		local fblevel = levelList[i]
		local ctrl = list:getItemByNum(i)
		CommonGrid.bind(ctrl.itembg)
		local chapterId = Chapter.getChapterId(fbLevel.levelId)
		local chapterTitle = Chapter.getChapterTitle(chapterId)
		local levelTitle= Chapter.getLevelTitle(fbLevel.levelId)
		ctrl.txtchapter:setString(chapterTitle)
		ctrl.txtlevel:setString(levelTitle)
		ctrl.chapterId = chapterId
		ctrl.levelId = fbLevel.levelId
		--ctrl.difficulty = fbLevel.difficulty
		ctrl.itembg:setBodyIcon(1)
		if not ctrl:hasEventListener(Event.TouchEvent,onGoChapter) then
			ctrl:addEventListener(Event.TouchEvent,onGoChapter,self)
		end
	end
end

return PartnerTipsUI
