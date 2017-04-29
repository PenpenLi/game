module("ShopTenUI",package.seeall)
setmetatable(_M,{__index = Control})
local ItemConfig = require("src/config/ItemConfig").Config
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")
local ShopHeroUI = require("src/modules/shop/ui/ShopHeroUI")
local LotteryConfig = require("src/config/LotteryConfig")
local ShopHeroEffectUI = require("src/modules/shop/ui/ShopHeroEffectUI")

function new(items,curIndex,isCommon)
	local ctrl = Control.new(require("res/shop/ShopTenSkin.lua"),{"res/shop/ShopTen.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(items,isCommon)
	Instance = ctrl
	return ctrl
end

function clear(self)
	Control.clear(self)
	Instance = nil
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 4, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function init(self,items,isCommon)
	self:addArmatureFrame("res/shop/effect/ten/ShopTen.ExportJson")
	self:addArmatureFrame("res/shop/effect/ten/ShopTenCard.ExportJson")
	self:addArmatureFrame("res/shop/effect/ten/ShopTenBg.ExportJson")
	local function onClose(self,event,target)
		UIManager.removeUI(self)
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_CHAPTER_EIGHT, step = 4})
	end
	self.back1:addEventListener(Event.Click,onClose,self)
	for i = 1,10 do
		CommonGrid.bind(self.group["items"..i].bg)
		self.group["items"..i].txtname:setFontSize(16)
		self.group["items"..i].txtname:setAnchorPoint(0.5,0)
		self.group["items"..i]:setVisible(false)
		self.group["items"..i]:setAnchorPoint(1,1)
		local item = self.group["items"..i]
		item:setPositionX(item:getPositionX()+item:getContentSize().width)
		item:setPositionY(item:getPositionY()+item:getContentSize().height)
		item.orgPosX = item:getPositionX()
		item.orgPosY = item:getPositionY()
	end
	--self:refreshInfo(items,curIndex,isCommon)
	--local function onOnceMore(self,event,target)
	--	if isCommon then
	--		Network.sendMsg(PacketID.CG_SHOP_COMMON_ONCE)
	--	else
	--		Network.sendMsg(PacketID.CG_SHOP_RARE_ONCE)
	--	end
	--end
	--self.oncemore:addEventListener(Event.Click,onOnceMore,self)
	local function onTenMore(self,event,target)
		if isCommon then
			Network.sendMsg(PacketID.CG_SHOP_COMMON_TEN)
		else
			Network.sendMsg(PacketID.CG_SHOP_RARE_TEN)
		end
	end
	self.tenmore:addEventListener(Event.Click,onTenMore,self)

	if isCommon then
		--local cost = LotteryConfig.ConstantConfig[1].commonOnceCost
		--self.onceCost:setString(cost)
		local cost2 = LotteryConfig.ConstantConfig[1].commonTenCost
		--self.tenCost:setString(cost2)
		self.onceCost:setString(cost2)
		CommonGrid.setCoinIcon(self.jbbicon1,"money")
		--CommonGrid.setCoinIcon(self.jbbicon2,"money")
	else
		--local cost = LotteryConfig.ConstantConfig[1].onceCost
		--self.onceCost:setString(cost)
		local cost2 = LotteryConfig.ConstantConfig[1].tenCost
		--self.tenCost:setString(cost2)
		self.onceCost:setString(cost2)
		CommonGrid.setCoinIcon(self.jbbicon1,"rmb")
		--CommonGrid.setCoinIcon(self.jbbicon2,"rmb")
	end
	--self.oncemore:setVisible(false)
	self.back1:setVisible(false)
	self.tenmore:setVisible(false)
	self.jbbicon1:setVisible(false)
	self.jbbicon2:setVisible(false)
	self.onceCost:setVisible(false)
	self.tenCost:setVisible(false)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.back1, step = 4, delayTime = 0.3, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
end

function refreshBack(self,items,curIndex)
	refreshInfo(self,items,curIndex)
end

function setItemEffect(self,i,id)
	local cfg = ItemConfig[id]
	local color2Name = {[3]="蓝",[4]="紫",[5]="橙"}
	local name = color2Name[cfg.color]
	if name then
		Common.setBtnAnimation(self.group["items"..i].bg1._ccnode,"ShopTen",name)
	end
end

function refreshInfo(self,items,curIndex,isCommon)
	self:stopAllActions()
	local index = curIndex or 0
	local index2 = index
	for i = 1,#items do
		local id = items[i].id
		local disFrag = items[i].disFrag or 0
		local cfg = ItemConfig[id]
		self.group["items"..i].id = id
		self.group["items"..i].disFrag = disFrag
		self.group["items"..i].bg:setItemIcon(id,"descIcon")
		self.group["items"..i].bg:setItemNum(items[i].num)
		self.group["items"..i].txtname:setString(cfg.name)
		if i <= index then
			self.group["items"..i]:setVisible(true)
			self:setItemEffect(i,id)
		else
			self.group["items"..i]:setVisible(false)
		end
	end
	local function cbfunc()
		if index < #items then
			local dt = cc.DelayTime:create(0)
			local cb = cc.CallFunc:create(function() 
				index = index + 1
				local itemId = self.group["items"..index].id
				local disFrag = self.group["items"..index].disFrag
				self.group["items"..index]:setVisible(true)
				self.group["items"..index].bg:setVisible(false)
				self.group["items"..index].bg1:setVisible(false)
				self.group["items"..index].txtname:setVisible(false)
				self.group["items"..index].zjbg1:setVisible(false)

				--local adjustX = -150
				--local adjustY = 30
				--local delay = 0.2
				--self.group["items"..index]:setRotation(60)
				--self.group["items"..index]:setScale(delay)
				--self.group["items"..index]:setPositionX(self.group["items"..index].orgPosX + adjustX)
				--self.group["items"..index]:setPositionY(self.group["items"..index].orgPosY + adjustY)

				--local rotateTo = cc.RotateTo:create(delay/2,0)
				--local scaleTo = cc.ScaleTo:create(delay/2,1,1)
				--local moveBy = cc.MoveBy:create(delay/2,cc.p(-adjustX,-adjustY))
				--local callback = cc.CallFunc:create(function()
				--	Common.setBtnAnimation(self.group["items"..index].bg._ccnode,"ShopTenCard","1")
				--end)
				--local spawn = cc.Spawn:create(rotateTo,scaleTo,moveBy)
				--local seq = cc.Sequence:create({spawn,callback})
				--self.group["items"..index]:runAction(seq)
				local bone = Common.setBtnAnimation(self.group["items"..index]._ccnode,"ShopTenCard","1",{y=20})
				bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
					index2 = index2 + 1
					self.group["items"..index2].bg:setVisible(true)
					self.group["items"..index2].bg1:setVisible(true)
					self.group["items"..index2].txtname:setVisible(true)
					self.group["items"..index2].zjbg1:setVisible(true)
					self:setItemEffect(index2,itemId)

					local cfg = ItemConfig[itemId]
					if cfg.attr["addHero"] then
						local dt2 = cc.DelayTime:create(delay)
						local cb2 = cc.CallFunc:create(function()
							--UIManager.removeUI(self)
							--ShopHeroUI.pushCache({url = "src/modules/shop/ui/ShopTenUI",params = {items,index,isCommon}})
							--UIManager.addChildUI("src/modules/shop/ui/ShopHeroUI",itemId,disFrag)
							--if disFrag == 1 then
							--	ShopHeroUI.pushCache({url = "src/modules/shop/ui/ShopTenUI",params = {items,index}})
							--	UIManager.addChildUI("src/modules/shop/ui/ShopHeroUI",itemId,disFrag)
							--else
							--	ShopHeroEffectUI.pushCache({url = "src/modules/shop/ui/ShopTenUI",params = {items,index}})
							--	local name = cfg.attr["addHero"].name
							--	UIManager.addChildUI("src/modules/shop/ui/ShopHeroEffectUI",name)
							--end
							UIManager.removeUI(self)
							ShopHeroEffectUI.pushCache({url = "src/modules/shop/ui/ShopTenUI",params = {items,index}})
							local name = cfg.attr["addHero"].name
							local star = cfg.attr["addHero"].star
							local color = cfg.color
							local fragNum = cfg.attr["addHero"].frag
							local ui = UIManager.addChildUI("src/modules/shop/ui/ShopHeroEffectUI",name,star,color,fragNum,disFrag)
							ui:playEffect()
						end)
						local seq2 = cc.Sequence:create({dt2,cb2})
						self:runAction(seq2)
					end
					UIManager.playMusic("lotteryItem")
					cbfunc()
				end)
			end)
			local seq = cc.Sequence:create({dt,cb})
			self:runAction(seq)
		else
			showBtn(self.tenmore)
			showBtn(self.back1)
			--showBtn(self.oncemore)
			self.jbbicon1:setVisible(true)
			--self.jbbicon2:setVisible(true)
			self.onceCost:setVisible(true)
			--self.tenCost:setVisible(true)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 3, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
		end
	end
	cbfunc()
end

function showBtn(ui)
	ui:setVisible(true)
	ui:setAnchorPoint(0.5,0.5)
	ui:setScale(0.2)
	ui:setPositionX(ui:getPositionX()+ui:getContentSize().width/2)
	ui:setPositionY(ui:getPositionY()+ui:getContentSize().height/2)
	local original = 1
	local scaleTo = cc.ScaleTo:create(0.15,original*1.1,original*1.1)
	local sineOut = cc.EaseSineOut:create(scaleTo)
	local scaleTo2 = cc.ScaleTo:create(0.2,original,original)
	local sineOut2 = cc.EaseSineOut:create(scaleTo2)
	local seq = cc.Sequence:create({sineOut,sineOut2})
	ui:runAction(seq)
end


return ShopTenUI
