module("PartnerChainUI",package.seeall)
setmetatable(_M,{__index = Control})
local PartnerData = require("src/modules/partner/PartnerData")
local PartnerChainConfig = require("src/config/PartnerChainConfig").Config
local PartnerConfig = require("src/config/PartnerConfig").Config
local BagData = require("src/modules/bag/BagData")
local ItemConfig = require("src/config/ItemConfig").Config
local HeroDefineConfig = require("src/config/HeroDefineConfig").Config
local HeroDefine = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local kCol = 1
local gridNum = 8
local LastClickId
local LastClickGridId = 1

function new(name)
	local ctrl = Control.new(require("res/partner/PartnerChainSkin.lua"),{"res/partner/PartnerChain.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(name)
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function init(self,name)
	self:addArmatureFrame("res/partner/effect/PartnerGrid.ExportJson")
	self:addArmatureFrame("res/common/effect/complete/Complete.ExportJson")
	self.heroName = name
	local cName = Hero.getCNameByName(name)
	self.txtHeroName:setString(cName)

	local hero1 = Hero.heroes[name]
	hero1:showHeroNameLabel(self.txtHeroName)

	local function onClose(self,event,target)
		UIManager.removeUI(self)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 4})
	end
	self.back:addEventListener(Event.Click,onClose,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.back, step = 4, groupId = GuideDefine.GUIDE_PARTNER})
	local function onCompose(self,event,target)
		Network.sendMsg(PacketID.CG_PARTNER_COMPOSE,self.partnerId)
	end
	local function onEquip(self,event,target)
		local id = self.chainId
		local cfg = PartnerData.getHero2PartnerCfg()[self.heroName]
		local chainList = cfg.chain
		local chainId = chainList[id]
		Network.sendMsg(PacketID.CG_PARTNER_ACTIVE,chainId)
		--local id = self.chainId
		--local cfg = PartnerData.getHero2PartnerCfg()[self.heroName]
		--local chainList = cfg.chain
		--local chainId = chainList[id]
		--Network.sendMsg(PacketID.CG_PARTNER_EQUIP,chainId,self.partnerId)
		--GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 4})
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 3})
	end
	--self.compound:addEventListener(Event.Click,onCompose,self)
	self.equip:setAnchorPoint(0.5,0.5)
	self.equip:setPositionX(self.equip:getPositionX()+self.equip:getContentSize().width/2)
	self.equip:setPositionY(self.equip:getPositionY()+self.equip:getContentSize().height/2)
	self.equip:addEventListener(Event.Click,onEquip,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.equip, step = 3, groupId = GuideDefine.GUIDE_PARTNER}) 
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.equip, addFinishFun = function() 
	--	if PartnerData.hasPartner(7, 1601001) == true then
	--		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 4})
	--		--GuideManager.dispatchEvent(GuideDefine.GUIDE_NEXT_STEP, {})
	--	end
	--end, delayTime = 0, step = 4, groupId = GuideDefine.GUIDE_PARTNER})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.equip, delayTime = 0, step = 6, addFinishFun = function()
	--	if PartnerData.hasPartner(7, 1601029) == true then
	--		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 6})
	--		--GuideManager.dispatchEvent(GuideDefine.GUIDE_NEXT_STEP, {})
	--	end
	--end, groupId = GuideDefine.GUIDE_PARTNER})
	--CommonGrid.bind(self.herobg)
	--CommonGrid.bind(self.partnerBG)
	local function onMaterialClick(self,event,target)
		if event.etype == Event.Touch_ended then
			--UIManager.addChildUI("src/modules/partner/ui/PartnerFragUI",self.partnerId,target.id)
			if target.chainId and target.chainId > 0 
				and target.partnerId and target.partnerId > 0 then
				UIManager.addChildUI("src/modules/partner/ui/PartnerFragUI",target.chainId,target.partnerId)
			end
		end
	end
	for i = 1,gridNum do
		--CommonGrid.bind(self.material["grid"..i].bg,"tips")
		CommonGrid.bind(self.material["grid"..i].bg)
		self.material["grid"..i].num:setFontSize(18)
		--self.material["grid"..i].num:setAnchorPoint(1,0)
		self.material["grid"..i].i = i
		self.material["grid"..i]:addEventListener(Event.TouchEvent,onMaterialClick,self)
	end
	-- 向左，向右切换英雄
	self.leftHero,self.rightHero = Hero.getNeighbours(name)
	local function onNeighbour(self,event,target)
		if target.name == 'left' and self.leftHero ~= nil then
			UIManager.replaceUI('src/modules/partner/ui/PartnerChainUI',self.leftHero)
		elseif target.name == 'right' and self.rightHero ~= nil then
			UIManager.replaceUI('src/modules/partner/ui/PartnerChainUI',self.rightHero)
		end
	end
	self.left:addEventListener(Event.Click,onNeighbour,self)
	self.right:addEventListener(Event.Click,onNeighbour,self)

	--self.txtDesc:setAnchorPoint(0.5,0)
	self:initChainInfo()
	self:refreshChainList()
	Network.sendMsg(PacketID.CG_PARTNER_QUERY)
end

function refreshName(self, name)
	self.heroName = name
	local cName = Hero.getCNameByName(name)
	self.txtHeroName:setString(cName)
	-- 向左，向右切换英雄
	self.leftHero,self.rightHero = Hero.getNeighbours(name)

	self:refreshChainList()
end

function getRealChainId(self)
	local id = self.chainId
	local cfg = PartnerData.getHero2PartnerCfg()[self.heroName]
	local chainList = cfg.chain
	local chainId = chainList[id]
	return chainId
end

function onChainGridClick(self,event,target)
	if event.etype == Event.Touch_ended then
		if not event.isfresh then
			LastClickGridId = 1
		end
		self:setChainLight(target.id)
		self.chainId = target.id
		self:refreshChainInfo(target.id)

		if self.hasRefreshGuide then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 3})
		end
	end
end

function onPartnerGridClick(self,event,target)
	if event.etype == Event.Touch_ended then
		local partnerId = target.partnerId
		self.partnerId = partnerId
		self:onSelectTopGrid(target.id,partnerId)
		--if partnerId == 0 then
		--elseif PartnerData.hasPartner(target.chainId,partnerId) then
		--	--UIManager.addChildUI("src/modules/partner/ui/PartnerComposeUI",target.chainId,partnerId)
		--	self:onSelectTopGrid(target.id,partnerId)
		--else
		--	local num = BagData.getItemNumByItemId(partnerId)
		--	local cfg = ItemConfig[partnerId]
		--	if num > 0 then
		--		local content = string.format("是否将“%s”装备在该关系链中?\n(装备后不可恢复)",cfg.name)
		--		local tipsUI = TipsUI.showTips(content)
		--		tipsUI:addEventListener(Event.Confirm, function(self,event) 
		--			if event.etype == Event.Confirm_yes then
		--				Network.sendMsg(PacketID.CG_PARTNER_EQUIP,target.chainId,partnerId)
		--			end
		--		end,self)
		--	else
		--		self:onSelectTopGrid(target.id,partnerId)
		--		--UIManager.addChildUI("src/modules/partner/ui/PartnerComposeUI",target.chainId,partnerId)
		--	end
		--end
		--GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 5})
	end
end

function onSelectTopGrid(self,id,partnerId)
	LastClickGridId = id
	if partnerId <= 0 then
		return
	end
	if self.lastAni then
		self.lastAni:removeFromParent()
	end
	self.lastAni = Common.setBtnAnimation(self.top["partner"..id].headBG._ccnode,"PartnerGrid","1")
	self.lastAni:setScale(0.75)

	for i = 1,4 do
		self.top["partner"..i].jiantoukuang:setVisible(false)
	end
	self.top["partner"..id].jiantoukuang:setVisible(true)
	local itemCfg = ItemConfig[partnerId]
	--self.txtsmsm:setString(itemCfg.name)
	local partnerCfg = PartnerConfig[partnerId]
	local name = partnerCfg.hero
	local cName = Hero.getCNameByName(name)
	--self.txtsmsm:setString(cName.."的宿命道具")
	--self.herobg:setHeroIcon(name,"s",0.5)
	local need = partnerCfg.need
	local gridId = 1
	for k,v in pairs(need) do
		if self.material["grid"..gridId] then
			self.material["grid"..gridId].id = k
			self.material["grid"..gridId].bg:setItemIcon(k)
			local num = BagData.getItemNumByItemId(k)
			self.material["grid"..gridId].num:setString(num.."/"..v)
			if num < v then
				self.material["grid"..gridId].bg:setShader("Gray")
				self.material["grid"..gridId].num:setColor(255,0,0)
			else
				self.material["grid"..gridId].bg:resetShader()
				self.material["grid"..gridId].num:setColor(0,255,0)
			end
			gridId = gridId + 1
		end
	end
	self.partnerId = partnerId
	local id = self.chainId
	local cfg = PartnerData.getHero2PartnerCfg()[self.heroName]
	local chainList = cfg.chain
	local chainId = chainList[id]
	local itemCfg = ItemConfig[partnerId]
	if PartnerData.hasPartner(chainId,partnerId) then
		self.equip:setVisible(false)
		--self.compound:setVisible(false)
		self.material:setVisible(false)
		--self.partnerBG:setVisible(true)
		--self.partnerBG:setItemIcon(partnerId)
		--self.txtDesc:setString(itemCfg.name.."已激活")
		--self.txtDesc1:setString("已激活")
		--self.txtDesc1:setPositionX(self.txtDesc:getPositionX()+self.txtDesc:getContentSize().width)
		self.txtDesc1:setString("")
	else
		--self.txtDesc:setString("")
		self.txtDesc1:setString("")
		local num = BagData.getItemNumByItemId(partnerId)
		if num > 0 then
			--self.partnerBG:setItemIcon(partnerId)
			--self.partnerBG:setVisible(true)
			self.equip:setVisible(true)
			self.material:setVisible(false)
			--self.compound:setVisible(false)
		else
			--self.partnerBG:setVisible(false)
			self.equip:setVisible(false)
			self.material:setVisible(true)
			--self.compound:setVisible(true)
		end
	end
end

function initChainInfo(self)
	LastClickId = nil
	--self.top:setVisible(false)
	--CommonGrid.bind(self.jnBG)
	self.heroGrid = HeroGridS.new(self.jnBG)
	self.chain:setBgVisiable(false)
	self.chain:setBtwSpace(0)
	--for i = 1,gridNum do
	--	CommonGrid.bind(self.top["partner"..i].headBG)
	--	self.top["partner"..i].id = i
	--	--self.top["partner"..i]:addEventListener(Event.TouchEvent,onPartnerGridClick,self)
	--	self.top["partner"..i].jiantoukuang:setVisible(false)
	--	local icon = self.top["partner"..i].headBG
	--	icon:setPositionX(icon:getPositionX()+icon:getContentSize().width/2)
	--	icon:setPositionY(icon:getPositionY()+icon:getContentSize().height/2)
	--	icon:setAnchorPoint(0.5,0.5)
	--	local txtequip = self.top["partner"..i].txtequip
	--	txtequip:setPositionX(txtequip:getPositionX()+txtequip:getContentSize().width/2)
	--	txtequip:setPositionY(txtequip:getPositionY()+txtequip:getContentSize().height/2)
	--	txtequip:setAnchorPoint(0.5,0.5)
	--	if i == 2 then
	--		GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.top["partner" .. i], addFinishFun = function()
	--			if PartnerData.hasPartner(7, 1601029) == true then
	--				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 5})
	--			end
	--		end, stencilType = GuideDefine.GUIDE_STENCIL_TYPE_CLIP, delayTime = 0, step = 5, groupId = GuideDefine.GUIDE_PARTNER})
	--	end
	--end
	--self.top.attrDesc:setDimensions(self.top.attrDesc._skin.width,0)
	--self.top.chainDesc:setDimensions(self.top.chainDesc._skin.width,0)
	--self.top.chainDesc:setString("激活关系链道具，可对关系中的英雄有加成")
end

function refreshChainList(self,isfresh)
	--local chainList = PartnerData.getSortChainList()
	local name = self.heroName
	if name then
		name = name
		self.heroName = name
	end
	local cfg = PartnerData.getHero2PartnerCfg()[name]
	if not cfg then
		print("PartnerChainUI: not name:"..name)
		return 
	end
	local chainList = cfg.chain
	if not chainList then
		print("PartnerChainUI: not chainList:"..name)
		return 
	end
	--self.jnBG:setHeroIcon(name,"s",0.6)
	if not isfresh then
		local hero = Hero.heroes[name]
		self.heroGrid:setHero(hero)
		self.heroGrid:setScale(0.7)
		
		local list = self.chain
		list:removeAllItem()
		local rows = math.ceil(#chainList / kCol)
		list:setItemNum(rows)
		local hasDot
		for i = 1,rows do
			local ctrl = list:getItemByNum(i)
			local grid = ctrl["grid1"]
			grid.light:setVisible(false)
			grid.id = i
			local chainId = chainList[i]
			local chainCfg = PartnerChainConfig[chainId]
			local icon = chainCfg.icon
			local res = string.format("res/common/icon/partner/%s.png",icon)
			grid.chainIcon._ccnode:setTexture(res)
			if Dot.check(grid.chainIcon,"partnerChain",chainId) then
				if not hasDot then
					LastClickId = i
					hasDot = true
				end
			end
			if not PartnerData.checkChainActive(chainId) then
				Shader.setShader(grid.chainIcon._ccnode,"Gray")
				if not hasDot and not LastClickId  then
					LastClickId = i
				end
			else
				Shader.setShader(grid.chainIcon._ccnode)
			end
			if not grid:hasEventListener(Event.TouchEvent,onChainGridClick) then
				grid:addEventListener(Event.TouchEvent,onChainGridClick,self)
			end
		end
		LastClickId = LastClickId or 1
		local grid = self:getGridById(LastClickId)
		grid:dispatchEvent(Event.TouchEvent,{etype=Event.Touch_ended,isfresh = isfresh})
		self.chain:showTopItem(LastClickId)
		if self.chain:getItemCount() >=3 and self.chain.moveNode:getPositionY() > 0 then
			self.chain.moveNode:setPositionY(0)
		end
	else
		local grid = self:getGridById(LastClickId)
		local chainId = chainList[LastClickId]
		local chainCfg = PartnerChainConfig[chainId]
		Dot.check(grid.chainIcon,"partnerChain",chainId)
		if not PartnerData.checkChainActive(chainId) then
			Shader.setShader(grid.chainIcon._ccnode,"Gray")
		else
			Shader.setShader(grid.chainIcon._ccnode)
		end
	end
end

function refreshGuide(self)
	self.hasRefreshGuide = true
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component = self.chain:getItemByNum(2)["grid1"], delayTime = 0, addFinishFun = function()
	--	--if PartnerData.checkChainActive(7) == true then
	--	--	GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PARTNER, step = 3})
	--	--end
	--end, stencilType = GuideDefine.GUIDE_STENCIL_TYPE_CLIP, step = 3, groupId = GuideDefine.GUIDE_PARTNER})
end

function getGridById(self,id)
	local row = math.ceil(id/kCol)
	local col = (id-1) % kCol + 1
	local ctrl = self.chain:getItemByNum(row)
	return ctrl and ctrl["grid"..col] or nil
end

function setChainLight(self,id)
	if LastClickId then
		local grid = self:getGridById(LastClickId)
		grid.light:setVisible(false)
	end
	LastClickId = id
	local grid = self:getGridById(id)
	grid.light:setVisible(true)
end

function refreshChainInfo(self)
	local id = self.chainId
	local cfg = PartnerData.getHero2PartnerCfg()[self.heroName]
	local chainList = cfg.chain
	if not chainList then
		print("PartnerChainUI:refreshChainInfo: not chainList:"..self.heroName)
		return 
	end
	local chainId = chainList[id]
	local chainCfg = PartnerChainConfig[chainId]
	self.top.chainName:setString("【"..chainCfg.name.."】")
	local name = ""
	--for i = 1,#chainCfg.group do
	for id,val in pairs(chainCfg.group) do
		--local partnerId = chainCfg.group[i]
		local partnerId = id
		local partnerCfg = PartnerConfig[partnerId]
		if partnerCfg then
			local heroName= partnerCfg.hero
			local cName = HeroDefine.DefineConfig[heroName] and HeroDefine.DefineConfig[heroName].cname or heroName
			name = name .. cName .. ","
		end
	end
	local str = string.format("对%s属性加成:",string.sub(name,1,-2))
	self.top.attrDesc:setString(str)
	--local attrName = ""
	--local attrVal = ""
	local attrId = 1
	for k,v in pairs(chainCfg.attr) do
		attrName = HeroDefine.DyAttrCName[k]	
		local nameLabel = self.top["attrname"..attrId]
		nameLabel:setString(attrName)
		self.top["attrVal"..attrId]:setPositionX(nameLabel:getPositionX()+nameLabel:getContentSize().width)
		self.top["attrVal"..attrId]:setString("+"..v.."%")
		attrId = attrId + 1
		if attrId > 3 then
			break
		end
	end
	for i = attrId,3 do
		self.top["attrname"..i]:setString()
		self.top["attrVal"..i]:setString()
	end
	--self.top.attrName:setPositionX(self.top.attrDesc:getPositionX()+self.top.attrDesc:getContentSize().width)
	--self.top.attrName:setString(attrName)

	local hasActive = PartnerData.checkChainActive(chainId)
	local index = 1
	local canActive = true
	for k,v in pairs(chainCfg.group) do
		local partnerId = k
		local num = BagData.getItemNumByItemId(k)
		self.material["grid"..index].chainId = chainId
		self.material["grid"..index].partnerId = partnerId
		self.material["grid"..index].bg:setVisible(true)
		self.material["grid"..index].szbg:setVisible(true)
		self.material["grid"..index].num:setVisible(true)
		self.material["grid"..index].num:setAnchorPoint(0.5,0)
		if hasActive then
			self.material["grid"..index].num:setString("")
			self.material["grid"..index].szbg:setVisible(false)
		else
			self.material["grid"..index].num:setString(num .. "/" .. v)
			self.material["grid"..index].szbg:setVisible(true)
		end
		if num >= v then
			self.material["grid"..index].num:setColor(0,255,0)
		else
			self.material["grid"..index].num:setColor(255,0,0)
			canActive = false
		end
		self.material["grid"..index].bg:setItemIcon(partnerId)
		index = index + 1
	end
	for i = index,gridNum do
		self.material["grid"..i].partnerId = 0
		self.material["grid"..i].bg:setIcon()
		self.material["grid"..i].bg:setVisible(false)
		self.material["grid"..i].szbg:setVisible(false)
		self.material["grid"..i].num:setVisible(false)
	end
	if hasActive then
		self.equip:setVisible(false)
	else
		self.equip:setVisible(true)
		if canActive then
			ActionUI.bounce({self.equip})
		else
			ActionUI.stop({self.equip})
		end
	end
end

function checkGridState()
	local num = BagData.getItemNumByItemId(partnerId)
end

function setGridState(grid,state)
	if state == "equip" then
		ActionUI.bounce({grid.headBG,grid.txtequip})
	else
		ActionUI.stop({grid.headBG,grid.txtequip})
	end
	grid.txtcompose:setVisible(false)
	grid.txtequip:setVisible(false)
	--grid.crosscompose:setVisible(false)
	--grid.crossequip:setVisible(false)
	if grid["txt"..state] then
		grid["txt"..state]:setVisible(true)
	end
	--if grid["cross"..state] then
	--	grid["cross"..state]:setVisible(true)
	--end
end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 3, groupId = GuideDefine.GUIDE_PARTNER})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_PARTNER})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 5, groupId = GuideDefine.GUIDE_PARTNER})
	--GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 7, groupId = GuideDefine.GUIDE_PARTNER})
end

function playEffect(self,name)
	--Common.setBtnAnimation(self.partnerBG._ccnode,"Complete",name,{y=50})
end
return PartnerChainUI 
