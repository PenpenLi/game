module(..., package.seeall)

local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI})

local Monster = require("src/modules/hero/Monster")
local Data = require("src/modules/crazy/Data")
local CrazyDefine = require("src/config/CrazyDefineConfig").Defined
local Chapter = require("src/modules/chapter/Chapter")

function new()
	local index = Data.getBossIndex()
	local list = {}
	local monster = Monster.new(CrazyDefine.monsters[index])
	monster.fightAttr = {hp=monster.dyAttr.maxHp - Data.getBoss(index).harm}
	table.insert(list, monster)
	local ctrl = HeroFightListUI.new(list)
	ctrl.preHp = monster.fightAttr.hp
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "CrazyFightUI"
	ctrl:init()
	return ctrl
end

function init(self)
	HeroFightListUI.init(self)

	--self:resetHeroFightList(worldBossData:getHeroList())
	self:resetHeroFightList(Chapter.fightHeroes)
end

--[[
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
	Network.sendMsg(PacketID.CG_CRAZY_FIGHT)
end
--]]

function doFight(self)
	if Data.isOpen() then
		HeroFightListUI.doFight(self)
	else
		Common.showMsg("活动已结束。")
	end
end

function sendFightMsg(self)
	Network.sendMsg(PacketID.CG_CRAZY_FIGHT)
end

function onFightEnd(self,event)
	local heroList = {}
	for k = 1,4 do
		table.insert(heroList,tostring(Chapter.fightHeroes[k] or ""))
	end
	--Network.sendMsg(PacketID.CG_CRAZY_SUMIT,(event.winer == "A") and 1 or 0,self.preHp - event.infoB.hp,Chapter.fightHeroes)
	Network.sendMsg(PacketID.CG_CRAZY_SUMIT,(event.winer == "A") and 1 or 0,self.preHp - event.infoB.hp,heroList)
	--local scene = self:returnToMainScene()
	--UIManager.replaceUI("src/modules/crazy/ui/CrazyUI")
	---[[
	if event.winer == 'A' then
		local scene = self:returnToMainScene()
		scene:addEventListener(Event.InitEnd, function()
			UIManager.replaceUI("src/modules/crazy/ui/CrazyUI")
		end)
	else
		local fun = function()
			local scene = self:returnToMainScene()
			scene:addEventListener(Event.InitEnd, function()
				UIManager.replaceUI("src/modules/crazy/ui/CrazyUI")
			end)
		end
		local loseUI = UIManager.addUI('src/ui/SettlementLoseUI')
		loseUI:init()
		loseUI:setHeroes(Chapter.fightHeroes)
		loseUI:setCloseFun(fun)
	end
	--]]
end

