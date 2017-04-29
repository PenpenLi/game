module("MainBg2", package.seeall)
setmetatable(MainBg2, {__index = Control})
local Chapter = require("src/modules/chapter/Chapter")
local Treasure = require("src/modules/treasure/Treasure")
local PublicLogic = require("src/modules/public/PublicLogic")
local Shop = require("src/modules/shop/Shop")
local OpenLvConfig = require("src/config/OpenLvConfig").Config

function new()
    local ctrl = Control.new(require("res/master/MainBg2Skin"),{"res/master/MainBg2.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

local BuildingsName = {
	["trial"]=1,
	["arena"]=1,
	["expedition"]=1,
	["worldBoss"]=1,
	["orochi"]=1,
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
	--竞技场
	self.arena:addEventListener(Event.Click, function(self,event,target)
		if PublicLogic.isModuleOpened("arena") then
			selectPanel(self, target,"src/modules/peak/ui/ArenaListUI")
		end
	end,self)
	--巡回赛
	self.expedition:addEventListener(Event.Click, function(self, evt,target)
		if PublicLogic.isModuleOpened("expedition") then
			selectPanel(self, target,"src/modules/expedition/ui/ExpeditionUI")
		end
	end,self)
	--夺宝
	--self.treasure:addEventListener(Event.Click, function(self, evt,target)
	--	-- TipsUI.showTipsOnlyConfirm("夺宝功能暂不开放")
	--	-- Network.sendMsg(PacketID.CG_TREASURE_MAP_INFO)
	--	if target.ani then
	--		target.ani:removeFromParent()
	--		target.ani = nil
	--	end
	--	Treasure.openTreasureUI()
	--end,self)
	--闯关
	self.adverture:addEventListener(Event.Click, function(self, evt,target)
		if PublicLogic.isModuleOpened("trial") then
			selectPanel(self, target,"src/modules/trial/ui/TrialUI")
		end
	end,self)
	--大蛇
	self.orochi:addEventListener(Event.Click, function(self, evt,target)
		if PublicLogic.isModuleOpened("orochi") then
			selectPanel(self, target,"src/modules/orochi/ui/OrochiUI")
		end
	end,self)
	
	--世界boss
	self.boss:addEventListener(Event.Click, function(self, evt,target)
		if PublicLogic.isModuleOpened("worldBoss") then
			selectPanel(self, target,"src/modules/worldBoss/ui/WorldBossUI")
		end
	end,self)	

	self:showBuildingsName()
	Master.getInstance():removeEventListener(Event.TeamLvUp,showBuildingsName)
	Master.getInstance():addEventListener(Event.TeamLvUp,showBuildingsName,self)
end

function loadSceneFinish(self)
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 9, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_FIGHT_SCENE})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.lottery, step = 1, noDelayFun = function() 
	--	Stage.currentScene:moveBg(-1000)		
	--end, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.lottery, step = 1, preFun = function() 
	--	Stage.currentScene:moveBg(-1000)		
	--	local levelUI = require("src/modules/chapter/ui/LevelUI").Instance
	--	if levelUI then
	--		UIManager.removeUI(levelUI)
	--		Stage.currentScene:getUI():onFoldMenu(true)
	--	end
	--end, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, step = 2, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, step = 5, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_SIGN_IN})

	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, step = 1, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_CHAPTER_FIGHT_SEC})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.chapter, step = 6, fingerScale = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_HERO_ACTIVE})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 1, componentType = GuideDefine.GUIDE_COMPONENT_MAIN, groupId = GuideDefine.GUIDE_SKILL_TALK})

	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REFRESH_LV)
end

function clear(self)
	Scene.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_SHOP_TREASURE})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_CHAPTER_FIRST})
end

function selectPanel(self, target,url,...)
	if target.ani then
		target.ani:removeFromParent()
		target.ani = nil
	end
	UIManager.replaceUI(url,...)
end

return MainBg2
