module("MainBg", package.seeall)
setmetatable(MainBg, {__index = Control})
local Chapter = require("src/modules/chapter/Chapter")
local Treasure = require("src/modules/treasure/Treasure")
local PublicLogic = require("src/modules/public/PublicLogic")
local Shop = require("src/modules/shop/Shop")
local OpenLvConfig = require("src/config/OpenLvConfig").Config

function new()
    local ctrl = Control.new(require("res/master/MainBgSkin"),{"res/master/MainBg.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

local BuildingsName = {
	["rank"]=1,
	["chapter"]=1,
	["lottery"]=1,
	["mail"]=1,
	["shop"]=1,
	["weapon"]=1,
	["treasure"]=1,
	["guild"]=1,
}
function showBuildingsName(self)
	if not self.alive then
		return
	end
	for k,v in pairs(OpenLvConfig) do
		if BuildingsName[v.moduleName] then
			local flag = false
			if v.charLv <= Master.getInstance().lv then
				flag = true
			end
			if self[v.moduleName.."name"] then
				self[v.moduleName.."name"]:setVisible(flag)
			end
		end
	end
end

function init(self)
	--夺宝
	self.treasure:addEventListener(Event.Click, function(self, evt,target)
		-- TipsUI.showTipsOnlyConfirm("夺宝功能暂不开放")
		-- Network.sendMsg(PacketID.CG_TREASURE_MAP_INFO)
		if target.ani then
			target.ani:removeFromParent()
			target.ani = nil
		end
		Treasure.openTreasureUI()
	end,self)
	--排行榜
	self.rank:addEventListener(Event.Click, function(self, evt,target)
		if PublicLogic.isModuleOpened("rank") then
			selectPanel(self, target,"src/modules/rank/ui/RankUI")
		end
	end,self)
	--战斗
	self.chapter:addEventListener(Event.Click, function(self,event,target) 
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIRST, step = 2})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_HERO_ACTIVE, step = 6})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SIGN_IN, step = 5})
		if self.finger then
			self.finger:removeFromParent()
			self.finger = nil
		end
		selectPanel(self, target,"src/modules/chapter/ui/ChapterUI")
	end,self)
	if not Chapter.isLevelPassed(110,1) then
		self:addArmatureFrame("res/armature/effect/Finger.ExportJson")
		Common.setBtnAnimation(self.chapter._ccnode,"Finger","特效")
	end
	--公会
	self.guild:addEventListener(Event.Click, function(self,event,target)
		if PublicLogic.isModuleOpened("guild") then
			local master = Master.getInstance()
			if master.guildId == 0 then
				selectPanel(self, target,"src/modules/guild/ui/GuildUI")
			else
				--selectPanel(self, "src/modules/guild/ui/GuildInfoUI")
				local scene = require("src/scene/GuildScene").new()
				Stage.replaceScene(scene)
			end
		end
	end,self)
	--商店
	self.shop:addEventListener(Event.Click, function(self,event,target)
		--selectPanel(self,target, "src/modules/shop/ui/ShopUI")
		selectPanel(self,target, "src/modules/mystery/ui/MysteryShopUI")
	end,self)
	--神兵
	self.sb:addEventListener(Event.Click, function(self,event,target) 
		if PublicLogic.isModuleOpened("weapon") then
			selectPanel(self, target,"src/modules/weapon/ui/WeaponPanel")
		end
	end,self)
	Dot.addNodeToCache(self.sb, DotDefine.DOT_C_WEAPON)
	Dot.checkToCache(DotDefine.DOT_C_WEAPON)	
	Dot.setPosFromCache(DotDefine.DOT_C_WEAPON, cc.p(-self.sb:getContentSize().width/2 + 90, -self.sb:getContentSize().height/2 + 55))

	--抽卡
	self.lottery:addEventListener(Event.Click, function(self,event,target)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SHOP_TREASURE, step = 1})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_EIGHT, step = 1})
		selectPanel(self, target,"src/modules/shop/ui/LotteryUI")
		--selectPanel(self, "src/modules/shop/ui/StrengthShopUI")
		--selectPanel(self, target,"src/ui/NewFuncUI")
	end,self)
	self.lottery:adjustTouchBox(-60,0,-150,0)
	Shop.onLotteryCheckDot(self.lottery)
	--邮件
	self.mail:addEventListener(Event.Click, function(self,event,target)
		selectPanel(self, target,"src/modules/mail/ui/MailListUI")
	end,self)
	Dot.check(self.mail,"mailCheck")
	Dot.setDotAlignment(self.mail,"rTop",{x=60,y=30})
	Dot.setDotScale(self.mail,1.25)

	self:showBuildingsName()
	Master.getInstance():removeEventListener(Event.TeamLvUp,showBuildingsName)
	Master.getInstance():addEventListener(Event.TeamLvUp,showBuildingsName,self)
end

function loadSceneFinish(self)
	local removeFun = function()
		--local levelUI = require("src/modules/chapter/ui/LevelUI").Instance
		--if levelUI then
		--	UIManager.removeUI(levelUI)
		--end
		UIManager.reset()
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 9, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_FIGHT_SCENE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.lottery, step = 1, noDelayFun = function() 
		Stage.currentScene:moveBg(-350)		
		removeFun()
	end, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.lottery, step = 1, preFun = function() 
		Stage.currentScene:moveBg(-350)		
		removeFun()
	end, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, noDelayFun = function()
		Stage.currentScene:moveBg(0)		
		removeFun()
	end,step = 2, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, noDelayFun = function()
		Stage.currentScene:moveBg(0)		
		removeFun()
	end,step = 5, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_SIGN_IN})

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, noDelayFun = function()
		Stage.currentScene:moveBg(0)		
		removeFun()
	end,step = 1, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, noDelayFun = function()
		Stage.currentScene:moveBg(0)		
		removeFun()
	end,step = 1, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, noDelayFun = function()
		Stage.currentScene:moveBg(0)		
		removeFun()
	end,step = 6, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_SKILL_TALK})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_VIP_COPY})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REFRESH_LV)
end

function clear(self)
	Scene.clear(self)
	Dot.clearNodeToCache(DotDefine.DOT_C_WEAPON)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_THIRD})
end

function selectPanel(self, target,url,...)
	if target.ani then
		target.ani:removeFromParent()
		target.ani = nil
	end
	UIManager.replaceUI(url,...)
end

return MainBg
