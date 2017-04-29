module(..., package.seeall)
local HeroListUI = require("src/ui/HeroListUI")
local Hero = require("src/modules/hero/Hero")
setmetatable(_M, {__index = HeroListUI})


function new(tabType)
	local ctrl = HeroListUI.new("recruited")
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "GiftHeroListUI"
	ctrl.tabType = tabType
	ctrl:init()
	return ctrl
end

function init(self)
	self.herocnt.txtmedtip:setVisible(false)
end


function onClickRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.addUI("src/modules/gift/ui/GiftUI",target.heroName,self.tabType)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TALENT, step = 2})
	end
end

function refreshRecruitedHero(self,item)
	local hero = Hero.getHero(item.heroName)
	if Dot.check(item,"giftHero",hero) then
	end
end



