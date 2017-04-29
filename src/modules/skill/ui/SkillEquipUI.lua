module(..., package.seeall)
setmetatable(_M, {__index = Control})

local Hero = require("src/modules/hero/Hero")
local FightHeroDefine = require("src/modules/fight/Define")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BagData = require("src/modules/bag/BagData")

local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillConfig = require("src/config/SkillConfig").Config
local SkillGroupConfig = require("src/config/SkillGroupConfig").Config
local SkillExpConfig = require("src/config/SkillExpConfig").Config
local Define = require("src/modules/skill/SkillDefine")
local SkillFighter = require("src/modules/skill/ui/SkillFighter")

Instance = nil


TabId2Type={"normal","rage","assist"}
function new(heroName,tabType,skillListUI)
	local ctrl = Control.new(require("res/skill/SkillEquipSkin"),{"res/skill/SkillEquip.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.heroName = heroName
	if type(tabType) == 'number' then tabType = TabId2Type[tabType] end
	ctrl.tabType = tabType or "normal"
	ctrl.skillListUI = skillListUI
	ctrl:init(heroName)
	Instance = ctrl
	return ctrl
end

function addStage(self)
end

function uiEffect()
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	--_M.touch = Common.outSideTouch
	self.back:addEventListener(Event.Click,onBack,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back, step = 11, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})

	self:addArmatureFrame("res/partner/effect/PartnerGrid.ExportJson")
	self.hero = Hero.getHero(self.heroName)
	--CommonGrid.bind(self.heroBg)
	--self.heroBg:setHeroIcon(self.heroName,'s',0.8)
	self.heroGridS = HeroGridS.new(self.heroBg)
	self.heroGridS:setHero(self.hero)
	self.heroGridS:setScale(0.85)
	self.nameLabel:setString(string.format("%s Lv.%d",self.hero.cname,self.hero.lv))
	--self.equipAssist:setVisible(false)
	self:initShowLayer()
	self:addHyperLink()
	self.group:setDirection(List.UI_LIST_HORIZONTAL)
	self:refresh(true,true)
end

function addHyperLink(self)
	self.linkIndex = self.linkIndex or 1
	for k,v in ipairs(TabId2Type) do
		if v == self.tabType then
			self.linkIndex = k 
		end
	end
	local show = function()
		if self.linkIndex == 3 then 
			self.right:setVisible(false)
		elseif self.linkIndex == 1 then 
			self.left:setVisible(false)
		end
		self.tabType = TabId2Type[self.linkIndex]
	end
	local link = function(dir)
		self.left:setVisible(true)
		self.right:setVisible(true)
		self.linkIndex = self.linkIndex + dir
		show()
		self.lastGroup = nil
		self:refresh(true,true)
	end
	show()
	self.left:addEventListener(Event.Click,function() link(-1) end,self)
	self.right:addEventListener(Event.Click,function() link(1) end,self)
	self.left:adjustTouchBox(15)
	self.right:adjustTouchBox(15)
end

local RageboxMap = {[Define.TYPE_COMBO]=1,[Define.TYPE_FINAL]=2,[Define.TYPE_BROKE]=3}
local AssistboxMap = {[Define.TYPE_ASSISTR]=1,[Define.TYPE_ASSIST]=3}
function refresh(self,isCreate,needSort)
	self.equip["txtnormal"]:setVisible(false)
	self.equip["txtrage"]:setVisible(false)
	self.equip["txtassist"]:setVisible(false)
	self.equip.rage:setVisible(true)
	self.equip["skill1"]:setVisible(true)
	self.equip["skill2"]:setVisible(true)
	self.equip["txt" .. self.tabType]:setVisible(true)
	if self.tabType == "normal" then
		self.ctype = Define.CTYPE_NORMAL
		self.equip.rage:setVisible(false)
	elseif self.tabType == "rage" then
		self.ctype = Define.CTYPE_RAGE
		self.equip.rage:setVisible(true)
	elseif self.tabType == "assist" then
		self.ctype = Define.CTYPE_ASSIST
		self.equip.rage:setVisible(false)
		self.equip["skill1"]:setVisible(false)
		self.equip["skill2"]:setVisible(false)
		--self.equipAssist:setVisible(true)
	end
	self.equipGroupList = SkillLogic.getGroupListByCtype(self.hero,self.ctype,true)
	table.sort(self.equipGroupList,function(a,b)
		return a.equipType < b.equipType
	end)
	for i=1,3 do
		local group = self.equipGroupList[i]
		if not group then break end
		local pos = i
		if self.ctype == Define.CTYPE_RAGE then
			pos = RageboxMap[group.type]
		elseif self.ctype == Define.CTYPE_ASSIST then
			pos = AssistboxMap[group.type]
		end
		--默认选中第一个
		if (pos == 1 and not self.lastGroup) or group.type == Define.TYPE_ASSIST then
			self.lastGroup = group
			if self.lastAni then
				self.lastAni:removeFromParent()
			end
			self.lastAni = Common.setBtnAnimation(self.equip["skill" .. pos]._ccnode,"PartnerGrid","1")
			self.lastAni:setScale(0.75)
		end
		local box = self.equip["skill" .. pos]
		print("refreshList=====>",group.equipType)
		local grid = box.skillBg 
		box.group = group
		if not box:hasEventListener(Event.TouchEvent,onSelect) then
			box:addEventListener(Event.TouchEvent,onSelect,self)
		end
		if not grid._icon then
			CommonGrid.bind(grid)
		end
		grid:setSkillGroupIcon(group.groupId,65)
		box.lv:setString(string.format("Lv%d",group.lv))
	end
	self:refreshList(isCreate,needSort)
	self:refreshItem()
end

function refreshItem(self)
	local ui = Stage.currentScene:getUI()
	ui:setTopCoin(1,"skillItem" .. tostring(self.hero.career),BagData.getItemNumByItemId(Define.Career2Item[self.hero.career]))
	ui:setTopCoin(2,"skillItem6",BagData.getItemNumByItemId(Define.Career2Item[6]))
	--ui:setTopCoin(3,"skillItem7",BagData.getItemNumByItemId(Define.Career2Item[7]))
end

function onSelect(self,event,target)
	if event.etype == Event.Touch_ended then
		if self.lastAni then
			self.lastAni:removeFromParent()
		end
		self.lastAni = Common.setBtnAnimation(target._ccnode,"PartnerGrid","1")
		self.lastAni:setScale(0.75)
		self.lastGroup = target.group
		if self.ctype == Define.CTYPE_RAGE then
			self:refreshList(true,true)
		else
			self:refreshList(false,true)
		end
	end
end

function refreshList(self,isCreate,needSort)
	local groupList = SkillLogic.getGroupListByType(self.hero,self.lastGroup.type)
	--self.numLabel:setString(string.format("%d/%d",#self.equipGroupList,#groupList))
	--self.itemIcon:setState(tostring(self.hero.career))
	--self.itemTxt:setString(string.format("%sの残页",HeroDefine.CAREER_NAMES[self.hero.career]))
	--背包data
	--for itemId,itemNum in pairs(groupList[1]:getConf().openItem) do
	--	--self.itemNum:setString(BagData.getItemNumByItemId(itemId))
	--	break
	--end
	if needSort then
		--canOpen() > isOpen() > isEquip() > not canOpen()
		for _,g in pairs(groupList) do
			if g:getCanOpen() then
				g.sort = 1
			elseif g:isEquip() then
				g.sort = 3
			elseif g:getIsOpen() then
				g.sort = 2
			elseif not g:getIsOpen() then
				g.sort = 4
			end
			--print("===>",g:getConf().groupName,g:getCanOpen(),g:isEquip(),g:getIsOpen(),g.sort)
		end
		table.sort(groupList,function(a,b) 
			if a.sort == b.sort then
				return a.groupId < b.groupId
			else
				return a.sort < b.sort
			end
		end)
	end
	self.groupList = groupList
	if isCreate then self.group:removeAllItem() end
	for k,group in ipairs(self.groupList) do
		local itemNum  = k 
		local box = self.group:getItemByNum(itemNum)
		if not box then
			box = self.group:getItemByNum(self.group:addItem())
		end
		if not box.skillBg._icon then
			CommonGrid.bind(box.skillBg)
			Common.setLabelCenter(box.operBtn.operName)
			--克制效果
			local rich = Common.createRichText(box.normal.effectLabel,15,{150,53,0})
			box.normal.effectLabel = rich
			--援助效果
			local rich = Common.createRichText(box.assist.effectLabel,15,{150,53,0})
			box.assist.effectLabel = rich
		end
		if not box.skillBg:hasEventListener(Event.TouchEvent,preview) then
			box.skillBg:addEventListener(Event.TouchEvent,preview,self)
			box.skillBg.touchParent = false
		end
		if not box.preview:hasEventListener(Event.TouchEvent,preview) then
			box.preview:addEventListener(Event.TouchEvent,preview,self)
			box.preview.touchParent = false
		end
		box.preview.groupId = group.groupId
		box.skillBg.groupId = group.groupId
		box.skillBg:setSkillGroupIcon(group.groupId,65)
		box.operBtn.group = group
		box.item1:setVisible(false)
		--box.itemNameLabel:setVisible(false)
		box.operBtn._events = {}
		if group:isEquip() then
			--已上阵
			box.operBtn:setVisible(false)
		elseif group:getIsOpen() then
			--可上阵
			box.operBtn:addEventListener(Event.Click,onEquip,self)
			box.operBtn.operName:setString("上阵")
		else
			--未获得(可激活/不可激活)
			--box.item1.itemIcon:setVisible(true)
			--box.itemIcon:setState(tostring(self.hero.career))
			--box.item1.itemNumLabel:setVisible(true)
			--box.itemNameLabel:setVisible(true)
			box.operBtn.operName:setString("激活")
			box.operBtn:setEnabled(true)
			box.operBtn:addEventListener(Event.Click,onOpen,self)
		end
		box.normal:setVisible(false)
		box.rage:setVisible(false)
		box.assist:setVisible(false)
		box.oppo:setVisible(false)
		box.lvCp:setVisible(false)	    --等级对比
		box.hurtCp:setVisible(false)	--伤害对比
		box.lockDesc:setVisible(false)  --开启克制
		self:setGroupAttr(box,group)
		if group.groupId == 2006 then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=box.operBtn, delayTime = 0.3, step = 9, noDelayFun = function()
				self.group:showTopItem(itemNum)
			end, groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=box.operBtn, delayTime = 0.3, step = 10, noDelayFun = function()
				self.group:showTopItem(itemNum)
			end,groupId = GuideDefine.GUIDE_SKILL_STRENGTH})
		end
	end
end

function setGroupAttr(self,box,group)
	local selectGroup = self.lastGroup 
	local function compare(tag,isUp,upVal,p)
		box[tag]:setVisible(true)
		box[tag].upicon:setVisible(false)
		box[tag].downicon:setVisible(false)
		box[tag].upVal:setVisible(false)
		if isUp then
			box[tag].upicon:setVisible(true)
			box[tag].upVal:setColor(80,142,0)
			box[tag].upVal:setVisible(true)
		elseif not isUp and upVal ~= 0  then
			box[tag].downicon:setVisible(true)
			box[tag].upVal:setColor(255,64,0)
			box[tag].upVal:setVisible(true)
		end
		box[tag].upVal:setString(string.format("%d%s",upVal,p))
	end
	if not group:isEquip() then
		compare("lvCp",group.lv>selectGroup.lv,math.abs(selectGroup.lv-group.lv),"级")
		compare("hurtCp",group:getAtk()>selectGroup:getAtk(),math.abs(selectGroup:getAtk()-group:getAtk()),"")
	end
	--
	local conf = SkillGroupConfig[group.groupId]
	local labelTb = {
		skillNameLabel = {group.name},
		lvLabel = {group.lv},	--等级
		hurt = {group:getAtk()},	--伤害
		--starLabel = {string.format("%d星",conf.star)},
		--itemNumLabel = {group:getUpgradeCost()},		--碎片
	}
	for k,v in pairs(labelTb) do
		box[k]:setString(string.format("%s",v[1]))
	end
	self:setSkillStar(box,conf.star)
	if box[self.tabType] then box[self.tabType]:setVisible(true) end
	box.operBtn:shader()
	if self.ctype == Define.CTYPE_NORMAL then
		--普通招数
		if group:getIsOpenOppo() then
			--已开启克制属性
			box[self.tabType]:setVisible(true)
			--普通技
			local labelTb = {
				oppoNameLabel = {HeroDefine.CAREER_NAMES[conf.career]},	--克制属性
				effectLabel = {group:getEffectDesc()},	--效果
				--oppoLabel = {group:getOppo()},	--克制提升
			}
			for k,v in pairs(labelTb) do
				box.normal[k]:setString(string.format("%s",v[1]))
			end
			--技能碎片
			--box.itemIcon:setState(2)
		else
			box[self.tabType]:setVisible(false)
			box.lockDesc:setVisible(true)
		end
	elseif self.ctype == Define.CTYPE_RAGE then
		--怒技
		box.oppo:setVisible(false)
		box.rage.attrVal1:setString(string.format("%s",group:getAtk()))
	else
		--援助
		box.hurt:setVisible(false)
		box.txtsh:setVisible(false)
		box.assist.effectLabel:setString(group:getEffectDesc())
	end
	if not group:getIsOpen() then
		--未激活的技能
		--技能碎片
		local itemList = {}
		for itemId,itemNum in pairs(conf.openItem) do
			itemList[#itemList+1] = {itemId=itemId,itemNum=itemNum}
		end
		local boxNum = #itemList 
		local gap = 5
		local boxWidth = 50
		local beginX = box:getContentSize().width/2 - (boxNum * boxWidth + (boxNum-1) * gap)/2
		local pos = 1
		for _,v in ipairs(itemList) do
			local grid = box:getChild("item" .. pos)
			if not grid then
				grid = Control.new(box.item1:getSkin())
				grid.name = "item" .. pos
				box:addChild(grid)
			end
			grid:setVisible(true)
			grid:setPositionX(beginX+(gap+boxWidth) * (pos-1))
			grid.itemIcon:setState(tostring(Define.Item2Career[v.itemId]))
			grid.itemNumLabel:setString(v.itemNum)	
			pos = pos + 1
		end
		for i=pos,3 do 
			local grid = box:getChild("item" .. i)
			--if grid then grid:setVisible(false) end
		end
		if group:getCanOpen() then
			box.operBtn.operName:setString("激活")
		else
			box.operBtn:setEnabled(false)
			box.operBtn:shader(Shader.SHADER_TYPE_GRAY)
			box.operBtn.operName:setString("激活")
		end
	end
end

function setSkillStar(self,box,num)
	for i=1,5 do
		if i > num then
			box.star["star" .. i]:setVisible(false)
		else
			box.star["star" .. i]:setVisible(true)
		end
	end
end


--上阵
function onEquip(self,event,target)
	local group = target.group
	local equipType = self.lastGroup.equipType
	--self.lastBox = target.parent
	self.targetGroup = group
	Network.sendMsg(PacketID.CG_SKILL_EQUIP,self.heroName,group.groupId,equipType)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 10})
end

function onEquipSucceed(self)
	self.lastGroup = self.targetGroup 
	self:refresh(false,true)
	Common.showMsg("上阵成功")
end

--激活
function onOpen(self,event,target)
	local group = target.group
	Network.sendMsg(PacketID.CG_SKILL_OPEN,self.heroName,group.groupId)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 9})
end

function preview(self,event,target)
	if event.etype == Event.Touch_ended then 
		self.showLayer:setVisible(true)
		return self.skillListUI:preview(event,target)
	end
end

--技能展示
function initShowLayer(self)
	local back = LayerColor.new("showbackgroud",0,0,0,200,Stage.width,Stage.height)
	back:setPositionY(-Stage.uiBottom)
	self:addChild(back)
	self.showLayer = back
	self:addEventListener(Event.TouchEvent,function(self,event,target) 
		if self.alive and event.etype == Event.Touch_ended then
			self.showLayer:setVisible(false)
			if self.skillListUI.fighter then
				self.skillListUI.fighter:setVisible(false)
			end
			self.skillListUI.showLayer:setVisible(false)
		end
	end,self)
	self.showLayer:setVisible(false)
end

function clear(self)
	local ui = Stage.currentScene:getUI()
	ui:resetTopCoin()
	Control.clear(self)
	if self.skillListUI.Instance then
		self.skillListUI:refresh(self.heroName)
	end
end

function onBack(self,event)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_SKILL_STRENGTH, step = 11})
	UIManager.removeUI(self)
end






