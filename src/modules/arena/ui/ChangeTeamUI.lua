module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})
local ArenaData = require("src/modules/arena/ArenaData")
local ArenaConstConfig = require("src/config/ArenaConstConfig").Config

function new()
	local ctrl = HeroFightListUI.new({})
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "ChangeTeamUI",
	ctrl:init("save")
	return ctrl
end

function addStage(self)
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
		local arenaData = ArenaData.getArenaData()
		if arenaData.rank <= 0 then
			local ArenaUI = Stage.currentScene:getUI():getChild("Arena")
			if ArenaUI then
				ArenaUI:onClose()
			end
		end
	end
end

function onFight(self,event,target)
	local canFight = true
	local fightlist = {}
	if self:getHeroFightListCnt() == 0 then
		TipsUI.showTipsOnlyConfirm("请先上阵英雄，然后开始战斗")
	elseif self:getHeroFightListCnt() == 1 and self.heroFightList[4] ~= nil and self.heroFightList[4] ~= '' then
		TipsUI.showTipsOnlyConfirm("请先上阵非援助英雄，然后开始战斗")
	elseif self.heroFightList[4] == nil or self.heroFightList[4] == '' then
		TipsUI.showTipsOnlyConfirm("请上阵援助英雄，然后开始战斗")
	else
		for i = 1,4 do
			if self.heroFightList[i] then
				table.insert(fightlist,{name = self.heroFightList[i],pos = i})
			end
		end
		Network.sendMsg(PacketID.CG_ARENA_CHANGE_HERO,fightlist)
	end
	--if canFight then
	--	Network.sendMsg(PacketID.CG_ARENA_CHANGE_HERO,fightlist)
	--else
	--	TipsUI.showTipsOnlyConfirm("请先上阵英雄，然后开始战斗")
	--end
end

function init(self)
	HeroFightListUI.init(self)
	local data = ArenaData.getArenaData()
	self:resetHeroFightList(data.fightList)
	self.rec:setVisible(true)
	self:addArmatureFrame("res/common/effect/heroRec/HeroRec.ExportJson")
	Common.setBtnAnimation(self.rec._ccnode,"HeroRec","1",{x=-52,y=7})
end

function resetHeroFightList(self,list)
	local tmp = {}
	for k,v in pairs(list) do
		tmp[k] = v.name
	end
	self.heroFightList = tmp 
	self:showFightList()
	self:refreshHeroList()
end

function onClickRecHero(self)
	local conf = ArenaConstConfig[1]
	local ui = UIManager.addChildUI("src/ui/HeroRec2UI")
	ui:setRec(conf.recType,conf.recDesc,conf.recHero)
end
