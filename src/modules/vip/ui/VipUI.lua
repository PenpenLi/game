module(...,package.seeall)
setmetatable(_M, {__index = Control})
 
local VipConfig = require("src/config/VipConfig").Config
local VipDefine = require("src/modules/vip/VipDefine")
local VipRechargeConfig = require("src/config/VipRechargeConfig").Config
local VipData = require("src/modules/vip/VipData")

function new(typeVal,isPaper)
	local ctrl = Control.new(require("res/vip/VipSkin"), {"res/vip/Vip.plist"})
	setmetatable(ctrl, {__index = _M})
	ctrl:init(typeVal,isPaper)
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function init(self, typeVal,isPaper)
	self.isPaper = isPaper
	self.vipmrlq:setVisible(false)
	self.initListPosY = self.rechargeCon.shopList:getPositionY()

	self:initListPos()
	self:initVipIcon()
	self:initHeadIcon()
	self:addDesTxt()
	self:addVipBtn()
	self:initBar()
	self:showCon()
	self:addListener()
	self:checkDot()


	local function onVipCG(self,event,target)
		UIManager.addUI("src/modules/vip/ui/VipLevelUI")
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_VIP_COPY, step = 3})
	end
	self.vipCopyBtn:addEventListener(Event.Click,onVipCG,self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.vipCopyBtn, step = 3, groupId = GuideDefine.GUIDE_VIP_COPY})
end

function initListPos(self)
	if Master.getInstance().recharge == 0 then
		self.rechargeCon.shopList:setPositionY(self.initListPosY - 20)
	else
		self.rechargeCon.ggy:setVisible(false)
		self.rechargeCon.shopList:setPositionY(self.initListPosY)
	end
end

function initVipIcon(self)
	self.topLvTxt = cc.Label:createWithBMFont("res/common/VipNum.fnt", "0")
	self.topLvTxt:setAnchorPoint(0, 0)
	self.vipLvCon._ccnode:addChild(self.topLvTxt)
	self.topLvTxt:setPositionX(self.vipLvCon.vipzi:getPositionX() + 35)
	self.topLvTxt:setPositionY(self.vipLvCon.vipzi:getPositionY() - self.vipLvCon.vipzi:getContentSize().height / 2)

	self.centerLeftLvTxt = cc.Label:createWithBMFont("res/common/VipNum.fnt", "0")
	self.centerLeftLvTxt:setAnchorPoint(0, 0)
	self.privilegeCon.rechargeDesCon.vipLvCon._ccnode:addChild(self.centerLeftLvTxt)
	self.centerLeftLvTxt:setPositionX(self.privilegeCon.rechargeDesCon.vipLvCon.vipzi:getPositionX() + 35)
	self.centerLeftLvTxt:setPositionY(self.privilegeCon.rechargeDesCon.vipLvCon.vipzi:getPositionY() - self.privilegeCon.rechargeDesCon.vipLvCon.vipzi:getContentSize().height / 2)
	
	--self.dailyVipTxt = cc.Label:createWithBMFont("res/common/vipBtnLv.fnt", "0")
	--self.dailyVipTxt:setAnchorPoint(0, 0)

	--local btn = self.vipmrlq.dailyBtn
	--btn._ccnode:addChild(self.dailyVipTxt)
	--self.dailyVipTxt:setPositionX(btn.vipszi:getPositionX() + 30)
	--self.dailyVipTxt:setPositionY(btn.vipszi:getPositionY() - btn.vipszi:getContentSize().height/2 - 5)
end

function initHeadIcon(self)
	local headIcon = cc.Sprite:create("res/common/icon/master/" .. Master.getInstance().bodyId .. '.png')
	headIcon:setAnchorPoint(cc.p(0, 0))
	self.zdtxbg._ccnode:addChild(headIcon)
end

function addDesTxt(self)
	--if self.desRichTxt ~= nil then
	--	self.desRichTxt:removeFromParent()
	--end
	self.desRichTxt = RichText2.new()
	self.desRichTxt:setVerticalSpace(5)
	self.desRichTxt:setTextWidth(400)
	self.desRichTxt:setShadow(false)
	self.desRichTxt:setFontSize(17)
	self.privilegeCon.rechargeDesCon.descView:setDirection(ScrollView.UI_VERTICAL)
	self.privilegeCon.rechargeDesCon.descView:setTopSpace(8)
	self.privilegeCon.rechargeDesCon.descView:setMoveNode(self.desRichTxt)
end

function showCon(self)
	if Master.getInstance().vipLv > 0 then
		self.privilegeBtn:setVisible(true)
		self.rechargeBtn:setVisible(false)
		self.privilegeCon:setVisible(true)
		self.rechargeCon:setVisible(false)

		self.curLv = Master.getInstance().vipLv
		if self.curLv == 0 then
			self.curLv = 1
		end
	  	self:showPrivilege()
	else
		self:showRecharge()
	end
end

function initBar(self)
	self.processTxt:setPositionX(self.processTxt:getPositionX() - 135)
	self.processTxt:setDimensions(200,0)
	self.processTxt:setHorizontalAlignment(Label.Alignment.Right)
	self.processTxt:setString("0/10")
	self.expprog:setPercent(0)
end

function addBoxEff(self)
	if self.boxStarEffect == nil then
		self:addArmatureFrame("res/chapter/effect/boxStar.ExportJson")

		self.boxStarEffect = ccs.Armature:create('boxStar')
		self.boxStarEffect:setVisible(false)
		self.boxStarEffect:setPosition(cc.p(self.mrlb:getContentSize().width/2, self.mrlb:getContentSize().height/2))
		self.mrlb._ccnode:addChild(self.boxStarEffect)
	end
end

function checkDot(self)
	Dot.check(self.privilegeBtn,DotDefine.DOT_C_VIP)
	for i=1,VipDefine.VIP_MAX_LV do
		local item = self.privilegeCon.vipList:getItemByNum(i + 1)
		local btn = item.vipBtn
		local daily = VipData.getInstance():getDailyInfo()[i]
		if daily == VipDefine.VIP_DAILY_NO_GET then
			Dot.add(btn)	
		else
			Dot.remove(btn)
		end
	end
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	Network.sendMsg(PacketID.CG_VIP_CHECK)

	GuideManager.dispatchEvent(GuideDefine.GUIDE_TRIGGER_TALK, {step = 7, groupId = GuideDefine.GUIDE_CHAPTER_EIGHT})
end

function addVipBtn(self)
	local list = self.privilegeCon.vipList
	list:setItemNum(VipDefine.VIP_MAX_LV + 1)
	for i=0,VipDefine.VIP_MAX_LV do
		local item = list:getItemByNum(i + 1)
		item.vipBtn.lv = i
		item.vipBtn:addEventListener(Event.TouchEvent, onSelectVip, self)

		local lvTxt = cc.Label:createWithBMFont("res/common/VipNum.fnt", "0")
		lvTxt:setAnchorPoint(0, 0.5)
		item.vipBtn._ccnode:addChild(lvTxt)
		lvTxt:setPositionX(item.vipBtn.vipzi:getPositionX() + 35)
		lvTxt:setPositionY(item.vipBtn.vipzi:getPositionY() + 5)
		lvTxt:setString(i)
	end

	local vipLv = Master.getInstance().vipLv
	local item = list:getItemByNum(vipLv + 1)
	list:showTopItem(item.num)
	item.vipBtn.normalIcon:setVisible(false)
	self.curLv = Master.getInstance().vipLv
	self:refreshPrivilege()
end

function onSelectVip(self, evt, target)
	if evt.etype == Event.Touch_began then
		if target.normalIcon:isVisible() == true then
			target.downIcon:setVisible(false)
		end
	elseif evt.etype == Event.Touch_ended then
		target.downIcon:setVisible(true)
		if self.curLv == target.lv then
			return
		end
		self.curLv = target.lv
		local list = self.privilegeCon.vipList
		for i=0,VipDefine.VIP_MAX_LV do
			local item = list:getItemByNum(i + 1)
			if item.vipBtn.lv ~= self.curLv then
				item.vipBtn.normalIcon:setVisible(true)
			else
				item.vipBtn.normalIcon:setVisible(false)
			end
		end
		self:refreshPrivilege()
	end
end

function addListener(self)
	--self.vipCopyBtn:setVisible(false)
	self.vipCopyBtn:addEventListener(Event.Click, onEnterCopy, self)
	self.back:addEventListener(Event.Click, onClose, self)
	--self.mrlb:addEventListener(Event.Click, onOpenGift, self)
	self.rechargeBtn:addEventListener(Event.Click, onRecharge, self)
	self.privilegeBtn:addEventListener(Event.Click, onPrivilege, self)
	self.privilegeCon.vipGiftCon.get:addEventListener(Event.Click, onBuy, self)
end

function onEnterCopy(self, evt)
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function onOpenGift(self, evt)
	ActionUI.show(self.vipmrlq, "scale")
	self.vipmrlq:adjustTouchBox(-self.vipmrlq.ptbg:getPositionX(), 0, -2 * self.vipmrlq.ptbg:getPositionX(), 0)
	--self:refreshDailyGift()
end

function onRecharge(self, evt)
	--Common.showMsg('充值暂未开放')
	self:showRecharge()
end

function onPrivilege(self, evt)
	self:showPrivilege()
end

function showPrivilege(self)
	self.privilegeBtn:setVisible(false)
	self.rechargeBtn:setVisible(true)
	self.rechargeCon:setVisible(false)
	self.privilegeCon:setVisible(true)
	self:refreshPrivilege()
end

function showRecharge(self)
	self.privilegeBtn:setVisible(true)
	self.rechargeBtn:setVisible(false)
	self.rechargeCon:setVisible(true)
	self.privilegeCon:setVisible(false)
	--self:showPrivilege()
end

function onBuy(self, evt)
	Network.sendMsg(PacketID.CG_VIP_GET_DAILY, self.curLv)	
	--Network.sendMsg(PacketID.CG_VIP_BUY_GIFT, self.curLv)	
end

function onGetDailyGift(listItem, evt)
	--Network.sendMsg(PacketID.CG_VIP_GET_DAILY, listItem.lv)	
end

function refreshDailyGift(self)
	--if VipData.getInstance().hasGetDaily == true then
	--	self.vipmrlq.dailyBtn:setVisible(false)
	--	self.vipmrlq.ylqxiao:setVisible(true)
	--else
	--	self.vipmrlq.dailyBtn:setVisible(true)
	--	self.vipmrlq.ylqxiao:setVisible(false)
	--end
	--self.dailyVipTxt:setString(Master.getInstance().vipLv)
	local list = self.vipmrlq.mrlqList
	local tbLen = Common.GetTbNum(VipConfig)
	list:removeAllItem()
	list:setItemNum(tbLen-1)

	for i=1,tbLen-1 do
		local config = VipConfig[i]
		local listItem = list:getItemByNum(i)
		local vipLvTxt = cc.Label:createWithBMFont("res/common/SVipNum.fnt", "0")
		vipLvTxt:setAnchorPoint(cc.p(0, 0.5))
		vipLvTxt:setString(i)
		vipLvTxt:setPosition(cc.p(listItem.xips.vipszi:getPositionX() + listItem.xips.vipszi:getContentSize().width, listItem.xips.vipszi:getPositionY() + 1))
		listItem.xips._ccnode:addChild(vipLvTxt)
		listItem.lv = i
		
		self:refreshListItem(i)

		for j=1,3 do
			local item = config.dailyGift[j]
			local icon = listItem['grid' .. j]
			if item then
				CommonGrid.bind(icon,"tips")
				icon:setItemIcon(item[1])
				icon:setVisible(true)
				icon:setItemNum(item[2])
			else
				icon:setVisible(false)		
			end
		end
	end
end

function refreshListItem(self, index)
	self:checkDot()
	self:refreshGiftBtnState(index)
end

function refreshRechargePaper(self)
	local cfg = {}
	for k,v in pairs(VipRechargeConfig) do
		if v.rechargeType == 3 then
			table.insert(cfg,v)
		end
	end
	self.vipCopyBtn:setVisible(false)
	self.privilegeBtn:setVisible(false)
	self.rechargeBtn:setVisible(false)
	self.rechargeCon:setVisible(true)
	self.privilegeCon:setVisible(false)
	local list = self.rechargeCon.shopList
	local len = #cfg
	local row = math.ceil(len/2)
	list:removeAllItem()
	list:setItemNum(row)
	for i = 1,len do
		local ctrl = list:getItemByNum(math.ceil(i / 2))
		local item = i%2 == 0 and ctrl.right or ctrl.left
		local grid = item.iconBg
		CommonGrid.bind(grid)
		grid._icon:setScale(0.9)
		local v = cfg[i]
		grid:setIcon('item/120/' .. v.icon)
		item.tuijianIcon:setVisible(false)
		item.doubleIcon:setVisible(false)
		item.coin:setVisible(false)
		item.jinbiTxt:setVisible(false)
		item.descTxt:setVisible(false)

		item.yuekaTxt:setString('')
		item.coinTxt:setString(v.rmb)
		item.zuanshiicon:setVisible(true)
		item.liscztBG2:setVisible(false)
		item.liscztBG1:setVisible(true)
		item.txtrmb:setString(v.cash .. "元")

		item:addEventListener(Event.TouchEvent, function(self, event)
			if event.etype == Event.Touch_ended then
				local master = Master.getInstance()
				local payInfo = {}
				payInfo.roleId = master.pAccount
				payInfo.name = master.name
				payInfo.productId = v.id
				payInfo.extra = ""
				UserSDK.charge(v.name,v.cash*100,1,payInfo)
				--Network.sendMsg(PacketID.CG_VIP_RECHARGE, k)	
				--Network.sendMsg(PacketID.CG_SEND_PAPER,v.rmb)
			end
		end, self)
		if k == i and len%2 ~= 0 then
			ctrl.right:setVisible(false)
		end
	end
end

function refreshRecharge(self, shopData)
	self:initListPos()
	local t = {}
	for _,id in ipairs(shopData) do
		t[id] = 1
	end

	local list = self.rechargeCon.shopList
	list:removeAllItem()

	local tbLen = 0
	local realCfg = {}
	for k,cfg in pairs(VipRechargeConfig) do
		if cfg.rechargeType ~= 3 then
			realCfg[k] = cfg
			tbLen = tbLen + 1
		end
	end
	local cols = math.ceil(tbLen / 2)
	list:setItemNum(cols)
	for k,cfg in ipairs(realCfg) do
		local ctrl = list:getItemByNum(math.ceil(k / 2))
		local item = k%2 == 0 and ctrl.right or ctrl.left
		local grid = item.iconBg
		CommonGrid.bind(grid)
		grid._icon:setScale(0.9)
		grid:setIcon('item/120/' .. cfg.icon)
		if cfg.rechargeType == 1 then
			item.yuekaTxt:setString('')
			item.coinTxt:setString(cfg.rmb)
			item.zuanshiicon:setVisible(true)
			item.liscztBG2:setVisible(false)
			item.liscztBG1:setVisible(true)
		else
			--月卡
			item.yuekaTxt:setString(cfg.cash .. '元月卡')
			item.coinTxt:setString('')
			item.zuanshiicon:setVisible(false)
			item.liscztBG2:setVisible(true)
			item.liscztBG1:setVisible(false)
		end
		item.txtrmb:setDimensions(70, 50)
		item.txtrmb:setHorizontalAlignment(Label.Alignment.Right)
		item.txtrmb:setVerticalAlignment(Label.Alignment.Center)
		item.txtrmb:setString(cfg.cash .. "元")
		item:addEventListener(Event.TouchEvent, function(self, event)
			if event.etype == Event.Touch_ended then
				local master = Master.getInstance()
				local payInfo = {}
				payInfo.roleId = master.pAccount
				payInfo.name = master.name
				payInfo.productId = k
				payInfo.extra = ""
				UserSDK.charge(cfg.name,cfg.cash*100,1,payInfo)
				--Network.sendMsg(PacketID.CG_VIP_RECHARGE, k)	
			end
		end, self)
		if k == tbLen and tbLen%2 ~= 0 then
			ctrl.right:setVisible(false)
		end

		item.tuijianIcon:setVisible(false)
		if t[k] then
			item.jinbiTxt:setString(cfg.limitExtraRmb)
			item.doubleIcon:setVisible(true)
		else
			item.jinbiTxt:setString(cfg.extraRmb)
			item.doubleIcon:setVisible(false)
		end
		if cfg.rechargeType == 2 then
			item.tuijianIcon:setVisible(true)
			item.jinbiTxt:setString(cfg.rmb)
		end
	end
end

function refreshPrivilege(self)
	self:checkDot()
	self:showVipLv()	
	
	--描述
	local vipCon = self.privilegeCon.rechargeDesCon.vipLvCon
	self.centerLeftLvTxt:setString(self.curLv)

	local curShowConfig = VipConfig[self.curLv]
	--self.privilegeCon.rechargeDesCon.accumulateTxt:setString("累积充值" .. (self:getAccumulateRmb() * 10) .. "钻石即可享受该VIP特权")

	self.desRichTxt:setString(curShowConfig.desc)
	self.desRichTxt:reverse()
	self.privilegeCon.rechargeDesCon.descView:refreshMoveNode()

	--礼包
	if self.curLv == 0 then
		self.privilegeCon.vipGiftCon:setVisible(false)
	else
		self.privilegeCon.vipGiftCon:setVisible(true)
		self:refreshGiftBtnState(self.curLv)
	end
	local giftCon = self.privilegeCon.vipGiftCon
	--giftCon.oldPriceTxt:setString("原价：" .. curShowConfig.oldPrice)
	--giftCon.newPriceTxt:setString("特价：" .. curShowConfig.newPrice)

	--giftCon.coin1:setPositionX(giftCon.oldPriceTxt:getPositionX() + giftCon.oldPriceTxt:getContentSize().width)
	--giftCon.coin2:setPositionX(giftCon.newPriceTxt:getPositionX() + giftCon.newPriceTxt:getContentSize().width)
	
	local item = curShowConfig.dailyGift
	if item ~= nil then
		CommonGrid.bind(giftCon.row.gezi1,"tips")
		giftCon.row.gezi1:setItemIcon(item, "descIcon")
		giftCon.row.gezi1:setVisible(true)
	else
		giftCon.row.gezi1:setVisible(false)
	end
	giftCon.row.gezi1.itembg:setVisible(false)
end

function refreshGiftBtnState(self, lv)
	local daily = VipData.getInstance():getDailyInfo()[lv]
	if daily == VipDefine.VIP_DAILY_NO_GET then
		self.privilegeCon.vipGiftCon.ylqxiao:setVisible(false)
		self.privilegeCon.vipGiftCon.get:setVisible(true)
		self.privilegeCon.vipGiftCon.get:setEnabled(true)
		self.privilegeCon.vipGiftCon.get:setState(Button.UI_BUTTON_NORMAL)
	elseif daily == VipDefine.VIP_DAILY_GET then
		self.privilegeCon.vipGiftCon.ylqxiao:setVisible(true)
		self.privilegeCon.vipGiftCon.get:setVisible(false)
	else
		self.privilegeCon.vipGiftCon.ylqxiao:setVisible(false)
		self.privilegeCon.vipGiftCon.get:setVisible(true)
		self.privilegeCon.vipGiftCon.get:setEnabled(false)
		self.privilegeCon.vipGiftCon.get:setState(Button.UI_BUTTON_DISABLE)
	end
end

function getAccumulateRmb(self)
	local sum = 0
	for i=1,self.curLv do
		sum = sum + VipConfig[i].needRmb
	end
	return sum
end

function refreshRechargeRmb(self, rmb)
	self:showVipLv()
	
	local config = VipConfig[Master.getInstance().vipLv]
	if config == nil then
		config = VipConfig[1]
	end

	local temp = rmb * VipDefine.VIP_RECHARGE_EXP
	local nextConfig = nil
	for _,vipConfig in ipairs(VipConfig) do
		if temp < vipConfig.needRmb * VipDefine.VIP_RECHARGE_EXP then
			nextConfig = vipConfig
			break
		end
		temp = temp - vipConfig.needRmb	* VipDefine.VIP_RECHARGE_EXP
	end

	if nextConfig ~= nil then
		local nextRmb = nextConfig.needRmb * VipDefine.VIP_RECHARGE_EXP
		self.processTxt:setString(temp .. "/" .. nextRmb)
		self.expprog:setPercent(temp / nextRmb * 100)
		self.needRechargeTxt:setString("再充" .. (nextRmb - temp) .. "钻石可获VIP" .. nextConfig.vipLv)	
	else
		nextConfig = VipConfig[VipDefine.VIP_MAX_LV]
		local nextRmb = nextConfig.needRmb * VipDefine.VIP_RECHARGE_EXP
		self.processTxt:setString(nextRmb .. "/" .. nextRmb)
		self.expprog:setPercent(100)
		self.needRechargeTxt:setString("已达最大VIP等级")
	end
end

function showVipLv(self)
	local lv = Master.getInstance().vipLv
	self.topLvTxt:setString(lv)
end
