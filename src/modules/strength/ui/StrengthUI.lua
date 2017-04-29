module("StrengthUI",package.seeall)
setmetatable(_M,{__index = Control})
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local StrengthLabel = require("src/modules/strength/ui/StrengthLabel")
local StrengthGrid = require("src/modules/strength/ui/StrengthGrid")
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local Hero = require("src/modules/hero/Hero")

function new(name)
	local ctrl = Control.new(require("res/strength/StrengthSkin"),{"res/strength/Strength.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	return ctrl
end

function addStage(self)
	self:setWinCenter()
end

function init(self,name)
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)
	self:initStrength(name)
	self:refreshStrength(name)
end

-- 力量 start --
function initStrength(self,name)
	self.heroName = name
	function onGridClick(self,event,target)
		if event.etype == Event.Touch_ended then
			local grid = self.strength["cell"..target.cellPos].material["grid"..target.gridPos]
			local state = grid.node:getActiveState()
			local child = UIManager.addChildUI("src/modules/strength/ui/StrengthOperate",state,name,target.cellPos,target.gridPos)
			child:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)
		end
	end
	function onLvUp(self,event,target)
    	Network.sendMsg(PacketID.CG_STRENGTH_LV_UP,name,self.pos)
	end
	function onTransfer(self,event,target)
    	Network.sendMsg(PacketID.CG_STRENGTH_TRANSFER,name)
	end
	self.strength.transfer.transBtn:addEventListener(Event.Click,onTransfer,self)
	self.strength.txtdescup:setString("")
	self.strength.txtdescdown:setString("")
	for i = 1,StrengthDefine.kMaxStrengthCellCap do
		local cell = self.strength["cell"..i]
		local textLabel = StrengthLabel.new()
		textLabel:setPosition(cell.strLab:getPosition())
		cell.textLabel = textLabel
		cell:addChild(textLabel)
		cell.pos = i
		for j = 1,3 do
			local grid = StrengthGrid.new()
			grid.cellPos = i
			grid.gridPos = j
			grid:addEventListener(Event.TouchEvent,onGridClick,self)
			cell.material["grid"..j].node = grid
			cell.material["grid"..j]:addChild(grid)
		end
		cell.lvup:addEventListener(Event.Click,onLvUp,cell)
	end
end

function setTransferButton(self,hero)
	local strengthView = self.strength
	strengthView.transGray:setVisible(false)
	strengthView.transfer.transLabel:setVisible(false)
	strengthView.transfer.maxLvLabel:setVisible(false)
	strengthView.transfer:setVisible(false)
	local strength = hero.strength
	if StrengthLogic.isMaxTransfer(strength) then
		strengthView.transfer.maxLvLabel:setVisible(true)
		strengthView.transfer:setVisible(true)
	elseif StrengthLogic.checkCanTransfer(strength) then
		strengthView.transfer.transLabel:setVisible(true)
		strengthView.transfer:setVisible(true)
	else
		strengthView.transGray:setVisible(true)
	end
end

function setStrengthCell(self,hero,pos)
	local cellView = self.strength["cell"..pos]
	cellView.lvup:setVisible(false)
	cellView.highest:setVisible(false)
	local strength = hero.strength
	local cell = strength.cells[pos]
	local cfg = StrengthLogic.getStrengthConfig(hero.name,pos)
	cellView.textLabel:setLabel(cfg.id,cell.lv)
	local attr = cfg.lvCfg[cell.lv+1].attr
	local attrName = ""
	for k,v in pairs(attr) do
		attrName = Hero.getAttrCName(k)
		break
	end
	cellView.material.desc:setString("开启后增加"..attrName)
	if StrengthLogic.isMaxLv(strength,pos) then
		cellView.highest:setVisible(true)
	else
		if StrengthLogic.checkLvUp(strength,hero,pos) then
			cellView.lvup:setVisible(true)
			cellView.highest:setVisible(true)
		end
		local need = cfg.lvCfg[cell.lv+1].need
		for i = 1,#need do
			cellView.material["grid"..i].node:setIcon(need[i])
			local state = StrengthLogic.checkGridState(hero,cell.grids[i].id,need[i])
			cellView.material["grid"..i].node:setActiveState(state)
		end
	end
end

function setStrengthState(self,hero)
	for i = 1,StrengthDefine.kMaxStrengthLv do
		self:setStrengthCell(hero,i)
	end
end

function refreshStrength(self,name)
	local heroName = name or self.heroName
	local hero = Hero.heroes[heroName]
	self:setTransferButton(hero)
	self:setStrengthState(hero)
end
-- 力量 end--

return StrengthUI
