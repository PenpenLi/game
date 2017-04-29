module(..., package.seeall)
local HeroListUI = require("src/ui/HeroListUI")
setmetatable(_M, {__index = HeroListUI})
local Hero = require("src/modules/hero/Hero")


function new(heroName)
	local ctrl = HeroListUI.new("all",heroName)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "HeroNormalListUI"
	ctrl:init()
	return ctrl
end

function init(self)
	self.herocnt.txtmedtip:setVisible(false)
end


function onClickRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.addUI("src/modules/hero/ui/HeroInfoUI",target.heroName)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_POWER, step = 2})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_LV_UP, step = 2})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRAIN, step = 2})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 2})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_GEM_QUICK, step = 2})
		UIManager.playMusic('btnClick')
	end
end

function onClickUnRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
		local heroName = target.heroName
		UIManager.addChildUI('src/modules/hero/ui/HeroFragUI',heroName)
	end
end

function sendComposeHero(self,name)
	local ui = WaittingUI.create(PacketID.GC_HERO_COMPOSE)
	ui:addEventListener(WaittingUI.Event.Timeout,function()
		local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
		tipsUI:setBtnName("重试","退出")
		tipsUI:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				self:sendComposeHero(name)
			elseif event.etype == Event.Confirm_no then
				ui:removeFromParent()
			end
		end)
	end,self)
	Network.sendMsg(PacketID.CG_HERO_COMPOSE,name)
end

function onClickComposeHero(self,event,target)
	local name = target._parent._parent.heroName
	self:sendComposeHero(name)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 2})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE_SHOP, step = 2})
end

function refreshRecruitedHero(self,item)
	local hero = Hero.getHero(item.heroName)
	if Dot.check(item,"strengthHero",hero) 
	or Dot.check(item,"transferHero",hero)
	or Dot.check(item,"starHero",hero) 
	or Dot.check(item,"isBreakThroughEnabled",item.heroName) then
	end
end


