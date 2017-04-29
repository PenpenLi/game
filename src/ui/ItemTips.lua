module("ItemTips", package.seeall)
setmetatable(_M, {__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local SkillLogic = require("src/modules/skill/SkillLogic")
local WineItemConfig = require("src/config/WineItemConfig").Config

Instance = nil

function new(grid,pos)
	local ctrl = Control.new(require("res/common/ItemTipsSkin"), {"res/common/ItemTips.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(grid,pos)
	return ctrl
end

function onClose(self,event,target)
	if event.etype == Event.Touch_ended then
		hide()
	end
end

function init(self,grid,pos)
	CommonGrid.bind(self.xem)
	self.sm:setDimensions(self.sm:getContentSize().width,0)
	self.txbk2:setVisible(false)
	self.sm:setAnchorPoint(0,1)
	self.mz:setFontSize(18)
	self:refresh(grid,pos)
	self:addEventListener(Event.TouchEvent,onClose,self)
end

function show(grid,pos)
	if Instance then
		Instance:refresh(grid,pos)
	else
		Instance = new(grid,pos)
		Stage.currentScene:getUI():addChild(Instance)
	end
end

function hide()
	if Instance then
		Instance:setVisible(false)
	end
end

function refresh(self,grid,pos)
	local id = grid._id
	if id then
		self:setTop()
		self:setVisible(true)
		local x = pos.x
		local y = pos.y
		local anchorX = 0
		local anchorY = 0
		if (pos.x + self:getContentSize().width)*Stage.uiScale > Stage.winSize.width then
			anchorX = 1
			x = pos.x+grid:getContentSize().width
		end
		if (pos.y + self:getContentSize().height)*Stage.uiScale > Stage.winSize.height then
			anchorY = 1
			y = pos.y-grid:getContentSize().height
		end
		self:setAnchorPoint(anchorX,anchorY)
		self:setPosition(x,y)
		if WineItemConfig[id] then
			self.xem:setItemIcon(id)
			local num = grid._numId or 0
			self.xem:setItemNum(num)
			local cfg = ItemConfig[id]
			self.mz:setString(cfg.name)
			self.sm:setString(string.format(WineItemConfig[id].desc))
			self.lv:setString("")
			self.boss:setString("")
			self.je:setString("")
		elseif ItemConfig[id] then
			self.xem:setItemIcon(id)
			local num = grid._numId or 0
			self.xem:setItemNum(num)
			local cfg = ItemConfig[id]
			self.mz:setString(cfg.name)
			self.sm:setString(cfg.desc)
			self.lv:setString("")
			self.boss:setString("")
			self.je:setString("")
		elseif SkillGroupConfig[id] then
			self.xem:setSkillGroupIcon(id,70)
			local cfg = SkillGroupConfig[id]
			self.mz:setString(cfg.groupName)
			local trendinfo = HeroDefine.CAREER_NAMES[cfg.career]
			if trendinfo == '' then
				trendinfo = "无"
			end
			self.sm:setString("克制属性:"..trendinfo)
			self.lv:setVisible(true)
			local hero = Hero.heroes[cfg.hero]
			if hero then
				local group = SkillLogic.getSkillGroupById(hero,id)
				if group:getAtk() == 0 then
					self.lv:setVisible(false)
				else
					self.lv:setString("连招伤害:"..group:getAtk())
				end
			else
				self.lv:setVisible(false)
			end
			self.lv:setColor(154,71,11)
			self.boss:setString("")
			self.je:setString("")
		end
	end
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

return ItemTips
