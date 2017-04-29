module(..., package.seeall)
setmetatable(_M, {__index = Control})

local ItemConfig = require("src/config/ItemConfig").Config
local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")

local EquipDefine = require("src/modules/equip/EquipDefine")
local EquipLogic = require("src/modules/equip/EquipLogic")
local EquipConfig = require("src/config/EquipConfig").Config
local EquipItemConfig = require("src/config/EquipItemConfig").Config
local EquipLvUpCostConfig = require("src/config/EquipLvUpCostConfig").Config
local EquipColorUpCostConfig = require("src/config/EquipColorUpCostConfig").Config
local EquipOpenLvConfig = require("src/config/EquipOpenLvConfig").Config

function new(heroName, pos)
	local ctrl = Control.new(require("res/equip/EquipmentstrengtheningSkin"),{"res/equip/Equipmentstrengthening.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(heroName, pos)
	return ctrl
end

function init(self, name, pos)
	local hero = Hero.getHero(name)
	local itemId = EquipItemConfig[name]["item" .. pos]
	local equip = EquipLogic.getEquip(name, pos)
	local id = equip.c * 1000 + equip.lv 
	local cfg = EquipConfig[id]

	local grid = self.daoju.itembg
	CommonGrid.bind(grid)
	grid:setItemIcon(itemId, "descIcon")
	grid:setItemColor(equip.c)
	
	local itemCfg = ItemConfig[itemId]
	local skin = self.txtshuoming:getSkin()
	self.txtshuoming:setDimensions(270)
	self.txtshuoming:setString(itemCfg.extraDesc)
	local size = self.txtshuoming:getContentSize()
	self.txtshuoming:setPositionY(skin.y + skin.height - size.height)
	self.txtzbname:setString(itemCfg.name)

	local c = HeroDefine.HERO_QUALITY[equip.c]
	self.txtpz:setString(c.name)
	self.txtpz:setColor(c.r, c.g, c.b)
	self.txtpz:enableShadow(2, -2)

	self.txtjiasx:setString("+" .. equip.lv)
	self.txtsx:setString("+" .. cfg["attr" .. pos])
	self.txtfangyu:setString(EquipDefine.EQUIP_ATTR[pos].cname)

	self.zbqianghua:addEventListener(Event.Click, function()
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 5})
		UIManager.addUI("src/modules/equip/ui/EquipUI", name, pos)
	end)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.zbqianghua, delayTime=0.3, step = 5, groupId = GuideDefine.GUIDE_EQUIP})
end

function uiEffect(self)
	--return UIManager.FIRST_TEMP_RAW
	return UIManager.THIRD_TEMP
end

function touch(self,event)
	Common.outSideTouch(self, event)
end

