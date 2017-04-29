module(..., package.seeall)
local HeroListUI = require("src/ui/HeroListUI")
local Hero = require("src/modules/hero/Hero")
setmetatable(_M, {__index = HeroListUI})


function new(tabType,career)
	local ctrl = HeroListUI.new("recruited",nil,career)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "SkillHeroListUI"
	ctrl.tabType = tabType
	ctrl.career = career
	ctrl:init()
	return ctrl
end

function init(self)
	self.herocnt.txtmedtip:setVisible(false)
end


function onClickRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 2})
		local ui = UIManager.addUI("src/modules/skill/ui/SkillListUI",target.heroName,self.tabType)
		if self.career then
			UIManager.addChildUI("src/modules/skill/ui/SkillEquipUI",target.heroName,self.tabType,ui)
		end
	end
end


function refreshRecruitedHero(self,item)
	local hero = Hero.getHero(item.heroName)
	if Dot.check(item,"skill",hero) then
	end
end

