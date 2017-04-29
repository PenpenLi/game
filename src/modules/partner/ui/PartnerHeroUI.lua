module(..., package.seeall)
local HeroListUI = require("src/ui/HeroListUI")
setmetatable(_M, {__index = HeroListUI})
local Hero = require("src/modules/hero/Hero")


function new(heroName)
	local ctrl = HeroListUI.new("recruited",heroName)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "PartnerHeroUI"
	ctrl:init()
	return ctrl
end

function init(self)
	self.herocnt.txtmedtip:setVisible(false)
end

function refreshRecruitedHero(self,item)
	Dot.check(item,"partnerHero",item.heroName)
end

function onClickRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 2})
		UIManager.addUI("src/modules/partner/ui/PartnerChainUI",target.heroName)
		UIManager.playMusic('btnClick')
	end
end
