module(..., package.seeall)
local HeroListUI = require("src/ui/HeroListUI")

setmetatable(_M, {__index = HeroListUI})

local Hero = require("src/modules/hero/Hero")
local Define = require("src/modules/peak/PeakDefine")
local Data = require("src/modules/peak/PeakData")

function new()
	local ctrl = HeroListUI.new("recruited")
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "PeakHeroListUI"
	ctrl:init()
	return ctrl
end

function init(self)
	self.herocnt.txtmedtip:setVisible(false)
	self.herocnt.selCntTxt:setVisible(true)
	self.ok:setVisible(true)
	self.ok:addEventListener(Event.Click, onOk, self)

	self.selectHeroList = Common.deepCopy(Data.getInstance():getHeroNameList())
	self.herocnt.selCntTxt:setString("当前已选择英雄：" .. #self.selectHeroList .. '/' .. Define.HERO_COUNT)
end

function onOk(self, evt)
	if #self.selectHeroList ~= Define.HERO_COUNT then
		Common.showMsg('请选择' .. Define.HERO_COUNT .. '个英雄')
		return
	end
	UIManager.removeUI(self)
	Network.sendMsg(PacketID.CG_PEAK_TEAM_CONFIRM,self.selectHeroList)
end

function refreshRecruitedHero(self, item)
	HeroListUI.refreshRecruitedHero(self, item)
	local index = self:getHeroIndex(item.heroName)
	if index ~= nil then
		item.selectIcon._ccnode:setLocalZOrder(10)
		item.selectIcon:setVisible(true)
	end
end

function onClickRecruitedHero(self,event,target)
	if event.etype == Event.Touch_ended then
		if target.selectIcon:isVisible() == true then
			target.selectIcon:setVisible(false)
			local index = self:getHeroIndex(target.heroName)
			table.remove(self.selectHeroList, index)
		else
			if #self.selectHeroList < Define.HERO_COUNT then
				target.selectIcon._ccnode:setLocalZOrder(10)
				target.selectIcon:setVisible(true)
				table.insert(self.selectHeroList, target.heroName)
			else
				Common.showMsg('请选择' .. Define.HERO_COUNT .. '个英雄')
			end
		end
		self.herocnt.selCntTxt:setString("当前已选择英雄：" .. #self.selectHeroList .. '/' .. Define.HERO_COUNT)
	end
end

function getHeroIndex(self, heroName)
	for index,name in ipairs(self.selectHeroList) do
		if name == heroName then
			return index
		end
	end
end

