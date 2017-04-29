module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Treasure = require("src/modules/treasure/Treasure")
local TDefine = require("src/modules/treasure/TreasureDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local TreasureConfig = require("src/config/TreasureConfig").Config
local MonsterConfig = require("src/config/MonsterConfig").Config
local ShopDefine = require("src/modules/shop/ShopDefine")
local Shop = require("src/modules/shop/Shop")
local Monster = require("src/modules/hero/Monster")
local Hero = require("src/modules/hero/Hero")
local HeroGridS = require("src/ui/HeroGridS")
function new(mineInfo)
	local ctrl = Control.new(require("res/treasure/TreasureOthersMineSkin"),{"res/treasure/TreasureOthersMine.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(mineInfo)
	return ctrl
end
function addStage(self)
	self:setPositionY(Stage.uiBottom)
end
function uiEffect(self)
	return UIManager.THIRD_TEMP
end



function init(self,mineInfo)
	self.mineId = mineInfo.mineId
	local mineId = mineInfo.mineId
	local rankId = mineInfo.rankId
	local typeId = mineInfo.mineType
	local cfg = TreasureConfig[mineId]
	for i=1,3 do
		if i== mineInfo.rankId then
			self['rank'..i]:setVisible(true)
		else
			self['rank'..i]:setVisible(false)
		end
	end
	-- Common.setLabelCenter(self.occupy.txttitle)
	if mineInfo.account == "" then
		self.occupy.txttitle:setString("立即占领")
		self.txtname:setString(cfg.monsterName)
		self.txtlv:setString(cfg.monsterLv.."级")
		local power = 0
		for i=1,4 do
			if cfg.monster[i] then
				-- CommonGrid.bind(self['hero'..i])
				local m = MonsterConfig[cfg.monster[i]]
				if m then
					local monster = Monster.new(cfg.monster[i])
					self['heroGrid'..i].heroGrid = HeroGridS.new(self['heroGrid'..i].hero,i)
					self['heroGrid'..i].heroGrid:setHero(monster)
					if i < 4 then
						power = power + Hero.getFight(monster)
					end
					-- self['hero'..i]:setHeroIcon(m.name,nil,nil,m.quality)
				end
			end
		end
		self.txtpower:setString("战斗力:"..power)
	else
		self.occupy.txttitle:setString("立即抢夺")
		self.txtname:setString(mineInfo.charName)
		self.txtlv:setString(mineInfo.lv.."级")
		local power = 0
		for i=1,4 do
			if mineInfo.guard[i].name ~= "" then
				-- CommonGrid.bind(self['hero'..i])
				self['heroGrid'..i].heroGrid = HeroGridS.new(self['heroGrid'..i].hero,i)
				local hinfo = mineInfo.guard[i]
				local h = Hero.new(hinfo.name,0,hinfo.lv,hinfo.quality)
				-- self['hero'..i]:setHeroIcon(mineInfo.guard[i].name,nil,nil,mineInfo.guard[i].quality)
				self['heroGrid'..i].heroGrid:setHero(h)
				if i < 4 then
					power = power + mineInfo.guard[i].power
				end
			end
		end
		self.txtpower:setString("战斗力:"..power)
	end

	local function onOccupy(self,event,target)
		if mineInfo.safeEndTime >= Master.getServerTime() then
			TipsUI.showTipsOnlyConfirm("宝藏正在被保护，无法抢夺！")
		else
			Network.sendMsg(PacketID.CG_TREASURE_PREPARE_OCCUPY,mineInfo.mineId)
		end 
	end
	self.occupy:addEventListener(Event.Click,onOccupy,self)

	local items = {}
	for itemId,item in pairs(cfg.fixProduct) do
		table.insert(items,{itemId,item[2]})
	end
	for itemId,item in pairs(cfg.randomProduct) do
		if itemId ~= 'randType' then
			table.insert(items,{itemId,item[3]})
		end 
	end 

	for i=1,8 do
		CommonGrid.bind(self.product['grid'..i],true)
		if items[i] then
			self.product['grid'..i]:setItemIcon(items[i][1],"mIcon")
			self.product['grid'..i]:setItemNum(items[i][2])
		end
	end

	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)

end



