module(..., package.seeall)

local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})

local worldBossData = require("src/modules/worldBoss/WorldBossData").getInstance()
local Define = require("src/modules/worldBoss/WorldBossDefine")
local Monster = require("src/modules/hero/Monster")

function new()
	local list = {}
	local monster = Monster.new(Define.BOSS_ID)
	table.insert(list, monster)
	local ctrl = HeroFightListUI.new(list)
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "WorldBossFightUI"
	ctrl:init()
	return ctrl
end

function init(self)
	HeroFightListUI.init(self)

	self:resetHeroFightList(worldBossData:getHeroList())
end

function doFight(self)
	local openNum = self:getOpenNum()

	if Common.GetTbNum(self.heroFightList) < openNum and self.isGuide == nil then
		local tip = TipsUI.showTips(string.format("你的出战阵容不足%d人，是否继续？",openNum))
		tip:addEventListener(Event.Confirm,function(self,event) 
			self:setFightEnabled(true)
			if event.etype == Event.Confirm_yes then
				self:sendEnterMsg()
			end
		end,self)
	else
		self:sendEnterMsg()
	end
end

function sendEnterMsg(self)
	local tab = {}
	for i=1,4 do
		local name = worldBossData:getHeroList()[i]
		if name == nil then
			table.insert(tab, '')
		else
			table.insert(tab, name)
		end
	end
	Network.sendMsg(PacketID.CG_WORLD_BOSS_ENTER, tab)
end

function onFightEnd(self,event)
	Network.sendMsg(PacketID.CG_WORLD_BOSS_LEAVE_COPY)
	if event.winer == 'A' then
		local scene = self:returnToMainScene()
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/worldBoss/ui/WorldBossUI")
			if event.winer == 'A' then
				local reputation = worldBossData:getReputationByHurt(worldBossData:getMyHurt())
				TipsUI.showTipsOnlyConfirm("世界BOSS已成功击退，请到邮件领取奖励！")
			end
		end)
	else
		local fun = function()
			local scene = self:returnToMainScene()
			scene:addEventListener(Event.InitEnd, function()
				UIManager.replaceUI("src/modules/worldBoss/ui/WorldBossUI")
			end)
		end
		local loseUI = UIManager.addUI('src/ui/SettlementLoseUI')
		loseUI:init()
		loseUI:setHeroes(worldBossData:getHeroList())
		loseUI:setCloseFun(fun)
	end
end
