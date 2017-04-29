module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Hero = require("src/modules/hero/Hero")
local ItemConfig = require("src/config/ItemConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local BagData = require("src/modules/bag/BagData")

local EquipDefine = require("src/modules/equip/EquipDefine")
local EquipLogic = require("src/modules/equip/EquipLogic")
local EquipConfig = require("src/config/EquipConfig").Config
local EquipItemConfig = require("src/config/EquipItemConfig").Config
local EquipLvUpCostConfig = require("src/config/EquipLvUpCostConfig").Config
local EquipColorUpCostConfig = require("src/config/EquipColorUpCostConfig").Config
local EquipOpenLvConfig = require("src/config/EquipOpenLvConfig").Config

function new(heroName, pos)
	local ctrl = Control.new(require("res/equip/UpgradingequipmentSkin"),{"res/equip/Upgradingequipment.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(heroName,pos)
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
	--return UIManager.THIRD_TEMP
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 9, groupId = GuideDefine.GUIDE_EQUIP})
end


function init(self,name,pos)
	self.heroName = name
	self.pos = pos

	function onClose(self, event)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click, onClose, self)

	function onUpColor(self, event)
		--Common.showMsg("升阶")
		--self:equipFx("c")
		Network.sendMsg(PacketID.CG_EQUIP_COLOR_UP, self.heroName, self.pos)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 8})
	end
	self.sj2.right.shengjie:addEventListener(Event.Click, onUpColor, self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.sj2.right.shengjie, step = 8, groupId = GuideDefine.GUIDE_EQUIP})

	function onUpLv(self, event)
		--Common.showMsg("升级")
		--self:equipFx("lv")
		Network.sendMsg(PacketID.CG_EQUIP_LV_UP, self.heroName, self.pos, 1)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 6})
	end
	function onUpLvCnt(self, event)
		--Common.showMsg("升级十次")
		--self:equipFx("lv")
		Network.sendMsg(PacketID.CG_EQUIP_LV_UP, self.heroName, self.pos, 10)
	end
	self.sj1.right.shengji:addEventListener(Event.Click, onUpLv, self)
	self.sj1.right.qianghuashi:addEventListener(Event.Click, onUpLvCnt, self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.sj1.right.shengji, step = 6, groupId = GuideDefine.GUIDE_EQUIP})

	function onChange(self, event)
		local uplv = event.target == self.Upgrading.shengji
		self.sj1:setVisible(uplv)
		self.sj2:setVisible(not uplv)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EQUIP, step = 7})
	end
	self.sj2:setVisible(false)
	self.Upgrading.shengji:setSelected(true)
	self.Upgrading:addEventListener(Event.Change, onChange, self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.Upgrading.shengjie, step = 7, groupId = GuideDefine.GUIDE_EQUIP})

	self.zhuangbei.ghbg:setOpacity(10)
	self.zhuangbei:setBtwSpace(-6)

	self:refreshEquip()

	self:initEquipData()
	self:addEventListener(Event.Frame, refresh, self)
	self:openTimer()
	self:refresh()
end

function initEquipData(self)
	self.frameN = 1
	local equips = {}
	local heros = Hero.getSortedHeroes()
	for _, h in ipairs(heros) do
		for pos = 1, 4 do
			local openlv = EquipOpenLvConfig[pos].openlv
			if h.lv >= openlv then
				table.insert(equips, {name=h.name, pos=pos})
			end
		end
	end
	self.equips = equips 
end

function refresh(self)
	local list = self.zhuangbei
	list:setItemNum(self.frameN)

	local data = self.equips[self.frameN]
	local equip = EquipLogic.getEquip(data.name, data.pos)
	local hero = Hero.getHero(data.name)
	local item = list:getItemByNum(self.frameN)
	item.data = data
	if not item:hasEventListener(Event.TouchEvent, onItemClick) then
		item:addEventListener(Event.TouchEvent, onItemClick, self)
	end

	if data.name == self.heroName and data.pos == self.pos then
		item.light:setVisible(true)
		self.preLight = item.light
		list:showTopItem(self.frameN)
	else
		item.light:setVisible(false)
	end
 
	local itemId = EquipItemConfig[data.name]["item" .. data.pos]
	local grid = item.herobg3
	CommonGrid.bind(grid)
	grid:setItemIcon(itemId, "mIcon")
	grid:setItemColor(equip.c)

	local itemCfg = ItemConfig[itemId]
	item.heroName:setString(hero.cname)
	item.zbName:setString(itemCfg.name)
	item.txtsx:setString("+" .. equip.lv)
	
	self.frameN = self.frameN + 1
	if self.frameN > #self.equips then
		self:closeTimer()
	end
end

function onItemClick(self, event, target)
	if event.etype == Event.Touch_ended then
		self.heroName = target.data.name
		self.pos = target.data.pos
		self:refreshEquip()
		if self.preLight then
			self.preLight:setVisible(false)
		end
		target.light:setVisible(true)
		self.preLight = target.light
	end
end

function refreshItem(self)
	local list = self.zhuangbei
	for i=1, list.itemNum do
		local item = list:getItemByNum(i)
		if item.data.name == self.heroName 
			and item.data.pos == self.pos then
			local equip = EquipLogic.getEquip(self.heroName, self.pos)
			item.txtsx:setString("+" .. equip.lv)
			local grid = item.herobg3
			grid:setItemColor(equip.c)
			return
		end
	end
end

function refreshEquip(self)
	local hero = Hero.getHero(self.heroName)
	local equip = EquipLogic.getEquip(self.heroName, self.pos)

	local itemId = EquipItemConfig[self.heroName]["item" .. self.pos]
	local grid = self.herobg2
	CommonGrid.bind(grid)
	grid:setItemIcon(itemId)
	grid:setItemColor(equip.c)

	local itemCfg = ItemConfig[itemId]
	self.shuxing.zbname:setString(itemCfg.name)
	self.shuxing.txtww:setString("+" .. equip.lv)
	self.shuxing.leixing:setString("类型: " .. EquipDefine.EQUIP_ATTR[self.pos].item)

	local openlv = EquipOpenLvConfig[self.pos].openlv
	self.shuxing.txtsz:setString(openlv)

	local c = HeroDefine.HERO_QUALITY[equip.c]
	self.shuxing.txtpz:setString(c.name)
	self.shuxing.txtpz:setColor(c.r, c.g, c.b)
	self.shuxing.txtpz:enableShadow(2, -2)

	local cfg = EquipConfig[equip.c * 1000 + equip.lv]
	local nextLvCfg =  EquipConfig[equip.c * 1000 + equip.lv + 1]
	local nextColorCfg =  EquipConfig[(equip.c + 1) * 1000 + equip.lv]

	self.sj1.txtgj1:setString(EquipDefine.EQUIP_ATTR[self.pos].cname)
	self.sj1.txtgjsx1:setString(cfg["attr" .. self.pos])
	self.sj1.right.txtgj2:setString(EquipDefine.EQUIP_ATTR[self.pos].cname)
	if nextLvCfg then
		self.sj1.right.txtgjsx2:setString(nextLvCfg["attr" .. self.pos])
		self.sj1.right:setVisible(true)
		self.sj1.top:setVisible(false)
	else
		self.sj1.right:setVisible(false)
		self.sj1.top:setVisible(true)
	end

	local money = EquipLvUpCostConfig[equip.lv].cost
	self.sj1.right.moneyLabel:setString(tostring(money))
	money = EquipColorUpCostConfig[equip.c].cost
	local need = EquipColorUpCostConfig[equip.c].need
	local fragmentNum = BagData.getItemNumByItemId(EquipDefine.EQUIP_COLOR_ITEM)
	self.sj2.right.moneyLabel:setString(money)
	self.sj2.right.stoneLabel:setString( fragmentNum .. "/" .. need)

	self.sj2.right.txtpj1:setString(c.name)
	self.sj2.right.txtpj1:setColor(c.r, c.g, c.b)
	self.sj2.right.txtpj1:enableShadow(2, -2)

	self.sj2.right.txtpj2:setColor(c.r, c.g, c.b)
	if equip.c < 5 then
		c = HeroDefine.HERO_QUALITY[equip.c+1]
		self.sj2.right.txtpj2:setString(c.name)
		self.sj2.right.txtpj2:setColor(c.r, c.g, c.b)
		self.sj2.right.txtpj2:enableShadow(2, -2)
	end

	self.sj2.txtgj1:setString(EquipDefine.EQUIP_ATTR[self.pos].cname)
	self.sj2.txtgjsx1:setString(cfg["attr" .. self.pos])
	self.sj2.right.txtgj2:setString(EquipDefine.EQUIP_ATTR[self.pos].cname)
	if nextColorCfg then
		self.sj2.right.txtgjsx2:setString(nextColorCfg["attr" .. self.pos])
		self.sj2.right:setVisible(true)
		self.sj2.top:setVisible(false)
	else
		self.sj2.right:setVisible(false)
		self.sj2.top:setVisible(true)
	end
end

function equipFx(self, fxName)
	if not self.fx then
		self:addArmatureFrame("res/equip/EquipFx.ExportJson")
		local bone = ccs.Armature:create("EquipFx")
		local skin = self.herobg2:getSkin()
		bone:setAnchorPoint(0.5,0.5)
		bone:setPosition(skin.x + skin.width / 2, skin.y + skin.height / 2)
		self._ccnode:addChild(bone)
		self.fx = bone 
		--self.fx:setVisible(false)
	end
	if fxName == "lv"  then
		self.fx:getAnimation():play("装备升级特效", -1, 0)
	else
		self.fx:getAnimation():play("装备升阶特效", -1, 0)
	end
end


