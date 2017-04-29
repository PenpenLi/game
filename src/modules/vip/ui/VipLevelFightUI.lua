module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI}) 

local MonsterConfig = require("src/config/MonsterConfig").Config
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")
local Monster = require("src/modules/hero/Monster")
local Enemy = require("src/modules/hero/Enemy")
local SkillGroup = require("src/modules/skill/SkillGroup")
local VipLevelConfig = require("src/config/VipLevelConfig").Config
local Define = require("src/modules/vip/VipDefine")
local FightDefine = require("src/modules/fight/Define")

Instance = nil

function new(levelId)
	local cfg = VipLevelConfig[levelId]
	if cfg then
		local monster = Monster.getMonsterObjectByIdList(cfg.monster)
	    local ctrl = HeroFightListUI.new(monster)
	    setmetatable(ctrl,{__index = _M})
	    ctrl:init(levelId)
		Instance = ctrl
		ctrl.cfg = cfg
	    return ctrl
	end
end

function init(self,levelId)
	-- self.hadFightHeroList = Logic.getHadFightHeroList()
	HeroFightListUI.init(self)
	self.levelId = levelId
	self.rec:setVisible(true)
	self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	Common.setBtnAnimation(self.rec._ccnode,"HeroRec","1",{x=-52,y=7})
end

-- function showHeroes(self)
-- 	HeroFightListUI.showHeroes(self)
-- 	for _,heroName in pairs(self.hadFightHeroList) do
-- 		local item = self.heroGridList[heroName]
-- 		item:shader(Shader.SHADER_TYPE_GRAY)
-- 	end
-- end

-- function clickHero(self, event, target, hero, hitem)
-- 	if self.hadFightHeroList[hero.name] == hero.name then
-- 		Common.showMsg(string.format("%s","该英雄无法在该层中再次挑战"))
-- 		return
-- 	end
-- 	HeroFightListUI.clickHero(self, event, target, hero, hitem)
-- end

-- function getHeroList(self)
-- 	local hlist = HeroFightListUI.getHeroList(self)
-- 	table.sort(hlist,function(a,b) 
-- 		if self.hadFightHeroList[a.name] ==  self.hadFightHeroList[b.name] then
-- 			return a.lv > b.lv
-- 		else
-- 			return not self.hadFightHeroList[a.name] 
-- 		end
-- 	end)
-- 	return hlist
-- end

function clear(self)
	HeroFightListUI.clear(self)
	Instance = nil
end

function addStage(self)
	--self:setPositionY(Stage.uiBottom)
end


-- local clickTime = 0
-- function onFight(self,event,target)
-- 	if (os.time() - clickTime) < 1 then
-- 		return
-- 	else
-- 		clickTime = os.time()
-- 	end
-- 	if self:canFight() then
-- 		Network.sendMsg(PacketID.CG_VIP_LEVEL_START,levelId,self.heroFightList)
-- 	end
-- end

function doFight(self)
	HeroFightListUI.doFight(self)
end
--[[
function prepareHeroes(self)
	HeroFightListUI.prepareHeroes(self)
	local heros = self.AHeroes
	local conf = Config[self.levelId]
	local list = {}
	for _,hero in ipairs(heros) do
		hero.harmFunc = function(skill,baseHarm,fighter) return self:doHarm(skill,baseHarm,fighter) end
		list[#list+1] = hero
	end
	--怪物属性增强
	local newMonsters = {}
	for i=1,4 do
		local h = self.enemyFightList[i]
		if h then
			h.harmFunc = function(skill,baseHarm,fighter) return self:doHarm(skill,baseHarm,fighter) end
			newMonsters[#newMonsters+1] = h
		end
	end
	self.AHeroes = list
	self.BHeroes = newMonsters 
end

function doHarm(self,skill,baseHarm,fighter)
	local conf = Config[self.levelId]
	local param = conf.param
	--针对英雄
	local isTargetA = false
	if param.heroA then
		for _,name in pairs(param.heroA) do
			if fighter.name == "heroA" and fighter.hero.name == name then
				isTargetA = true
				break
			end
			if fighter.name == "heroB" and fighter.enemy.hero.name == name then
				isTargetA = true
				break
			end
		end
	end
	--连击
	if param.combo and fighter.name == "heroA" then
		if isTargetA then
			for _,v in ipairs(param.combo) do
				if fighter.comboCnt <= v[1] then
					baseHarm = baseHarm * (1+v[2])
					if v[2] ~= skill.comboCntFactor then
						skill.comboCntChk = true
					end
					skill.comboCntFactor = v[2]
					break
				end
			end
		end
	end
	--必杀
	if param.power and fighter.name == "heroA" then
		if skill.type == SkillDefine.TYPE_FINAL then
			for _,v in ipairs(conf.param.power) do
				if fighter:getInfo():getPower() <= v[1] then
					baseHarm = baseHarm * (1+v[2])
					break
				end
			end
		end
	end
	--暴击
	if param.crtHit then
		if not isTargetA and skill.isCrtHit then
			if param.crtHit[1] == "B" and fighter.name == "heroB" then
				baseHarm = baseHarm * param.crtHit[2]
			end
		end
	end
	--增强最终伤害
	if param.finalHarm then
		if fighter.name == "heroA" and param.finalHarm.trend == fighter.hero.trend then
			baseHarm = baseHarm * (1 + param.finalHarm.factor)
		end
	end
	return baseHarm
end
--]]

function sendFBEnd(result,levelId,fightHeroes)
	local ui = WaittingUI.create(PacketID.GC_VIP_LEVEL_END)
	ui:addEventListener(WaittingUI.Event.Timeout,function()
		local tipsUI = TipsUI.showTopTips("网络不太好哦,请重试")
		tipsUI:setBtnName("重试","退出")
		tipsUI:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				sendFBEnd(winer,levelId,fightHeroes)
			elseif event.etype == Event.Confirm_no then
				ui:removeFromParent()
				local scene = require("src/scene/MainScene").new()
				Stage.replaceScene(scene)
			end
		end)
	end,self)
	Network.sendMsg(PacketID.CG_VIP_LEVEL_END,levelId,result,fightHeroes)
end

function onFightEnd(self,event)
	local fightHeroes = {}
	for i=1,4 do
		if self.heroFightList[i] then
			fightHeroes[i] = self.heroFightList[i]
		else
			fightHeroes[i] = ''
		end
	end
	if event.winer == "A" then
		res = Define.WIN 
	elseif event.winer == "B" then
		res = Define.DEFEATED
	end
	if event.winer == "" then
		local scene = require("src/scene/MainScene").new()
		Stage.replaceScene(scene)
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/vip/ui/VipLevelUI")
		end)
	else
		sendFBEnd(res,self.levelId,fightHeroes)
		-- Network.sendMsg(PacketID.CG_VIP_LEVEL_END,res,self.levelId,fightHeroes)
	end
	-- local heros = self.AHeroes
	-- for _,hero in ipairs(heros) do
	-- 	hero.harmFunc = nil
	-- end
	-- for _,h in ipairs(self.enemyFightList) do
	-- 	h.harmFunc = nil
	-- end
end

function toFightScene(self)
	local fightScene = HeroFightListUI.toFightScene(self,FightDefine.FightType.vipLevel,{vipLevelId=self.levelId})
	local function onFightRound(self,event,target)
		local cfg = VipLevelConfig[self.levelId]
		local effectFlag = false
		local effectValue = 0
		for _,r in ipairs(cfg.relation) do 
			if r[1] == fightScene.heroA.hero.name and r[2] == fightScene.heroB.hero.name and r[3].atk then
				
				effectValue = r[3].atk
				effectFlag = true
				break
			end
		end
		if effectFlag then
			fightScene.ui:setVipCopyEffect(true,effectValue.."%")
		else
			fightScene.ui:setVipCopyEffect(false)
		end
	end
	fightScene:addEventListener(Event.FightRound,onFightRound,self)
	--fightScene:setCareerVisiable(true)
end

function onClickRecHero(self)
	local conf = VipLevelConfig[self.levelId]
	local recHeroes = {}
	for i,r in pairs(conf.relation) do 
		table.insert(recHeroes,r[1])
	end
	local ui = HeroFightListUI.onClickRecHero(self)
	-- local ui = UIManager.addChildUI("src/ui/HeroRec2UI")
	ui:setRec("推荐英雄",self.cfg.recDesc,recHeroes)
	-- ui.group.recDesc.wanfa:setVisible(false)
end 

