module("StrengthDetails",package.seeall)
setmetatable(_M,{__index = Control})
local MaterialConfig = require("src/config/StrengthMaterialConfig").Config
local ItemConfig = require("src/config/ItemConfig").Config
local StrengthConfig = require("src/config/StrengthConfig").Config
local Hero = require("src/modules/hero/Hero")
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local Chapter = require("src/modules/chapter/Chapter")
local BagData = require("src/modules/bag/BagData")

function new(id)
	local ctrl = Control.new(require("res/strength/StrengthDetailsSkin"),{"res/strength/StrengthDetails.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self,id)
	self.id = id
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)
	self.material.itemList:setBgVisiable(false)
	self.material.itemList:setTopSpace(0)
	self.hero.itemList:setBgVisiable(false)
	self.hero.itemList:setTopSpace(0)
	self.hero.itemList:setBtwSpace(3)
	self.access.itemList:setBgVisiable(false)
	self.access.itemList:setTopSpace(0)
	self:refresh()
end

function refresh(self)
	self:refreshMaterialInfo()
	self:refreshHeroInfo()
	self:refreshAccessInfo()
end

function refreshMaterialInfo(self)
	local composeIds = {}
	for k,v in pairs(MaterialConfig) do
		for id,num in pairs(v.need) do
			if self.id == id then
				table.insert(composeIds,k)
				break
			end
		end
	end
	table.sort(composeIds)
	local cap = #composeIds
	local row = math.ceil(#composeIds / 2)
	self.material.itemList:setItemNum(row)
	for i = 1,cap do
		local ctrl = self.material.itemList:getItemByNum(math.ceil(i/2))
		local item = i%2 == 0 and ctrl.right or ctrl.left
		local itemId = composeIds[i]
		local cfg = ItemConfig[itemId]
		CommonGrid.bind(item.bg)
		item.bg:setItemIcon(itemId)
		item.txtname:setString(cfg.name)
		if i == cap and cap%2 ~= 0 then
			ctrl.right:setVisible(false)
		end
	end
end

function refreshHeroInfo(self)
	local heroes = {}	
	local nextHero = false 
	for heroName,cfg in pairs(StrengthConfig) do
		for pos,strength in pairs(cfg) do
			for strengthId,strengthCfg in pairs(strength) do
				for i = 1,StrengthDefine.kMaxStrengthLv do
					local need = strengthCfg[i].need
					local has = false
					table.foreachi(need,function(k,v)if v == self.id then has = true return end end)
					if has then
						table.insert(heroes,heroName)
						nextHero = true
						break
					end
				end
				break
			end
			if nextHero then
				break
			end
		end
	end
	local cap = #heroes
	local row = math.ceil(#heroes/2)
	self.hero.itemList:setItemNum(row)
	for i = 1,cap do
		local ctrl = self.hero.itemList:getItemByNum(math.ceil(i/2))
		local item = i%2 == 0 and ctrl.right or ctrl.left
		local heroName = heroes[i]
		local cName = Hero.getCNameByName(heroName)
		CommonGrid.bind(item.bg)
		item.bg:setHeroIcon(heroName,"s",0.7)
		item.txtname:setString(cName)
		if i == cap and cap%2 ~= 0 then
			ctrl.right:setVisible(false)
		end
	end
end

function refreshAccessInfo(self)
	local levelList = Chapter.getLevelListByReward(self.id)
	--local levelList = Chapter.getLevelListByReward(1702001)
	--local function sortLevelList(a,b)
	--	local fragA = BagData.getItemNumByItemId(a.fragId)
	--	local fragB = BagData.getItemNumByItemId(b.fragId)
	--	if a.levelId < a.levelId then
	--		return true
	--	elseif a.levelId > a.levelId then
	--		return false
	--	elseif a.difficulty < b.difficulty then
	--		return true
	--	elseif a.difficulty > b.difficulty then 
	--		return false
	--	else
	--		return false
	--	end 
	--end
	--table.sort(levelList,sortLevelList)
	local cap = #levelList
	local row = math.ceil(cap/2)
	self.access.itemList:setItemNum(row)
	for i = 1,cap do
		local ctrl = self.access.itemList:getItemByNum(math.ceil(i/2))
		local item = i%2 == 0 and ctrl.right or ctrl.left
		local fbLevel = levelList[i]
		CommonGrid.bind(item.bg)
		item.bg:setBodyIcon(1,0.7)
		local chapterId = Chapter.getChapterId(fbLevel.levelId)
		local chapterTitle = Chapter.getChapterTitle(chapterId)
		local levelTitle= Chapter.getLevelTitle(fbLevel.levelId)
		item.txtChapter:setFontSize(14)
		item.txtChapter:setString(chapterTitle)
		item.txtLevel:setString(levelTitle)
		if i == cap and cap%2 ~= 0 then
			ctrl.right:setVisible(false)
		end
	end
end

return StrengthDetails
