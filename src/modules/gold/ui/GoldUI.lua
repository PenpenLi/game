module(..., package.seeall)
setmetatable(_M, {__index = Control})
local GoldConfig = require("src/config/GoldConfig")
local GoldConstConfig = GoldConfig.GoldConstConfig
local GoldCntConfig = GoldConfig.GoldCntConfig
local GoldCostConfig = GoldConfig.GoldCostConfig
local TEN = 10

function new()
	local ctrl = Control.new(require("res/gold/GoldSkin"),{"res/gold/Gold.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function addStage(self)
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function init(self)
	self.tipsList = {}
	self.down:setVisible(false)
	self.tips:setVisible(false)
	self.selected.lookvip:setVisible(false)
	self.selected.txtcsyongwan2:setVisible(false)
	self.selected.txtcsyongwan1:setVisible(false)
	local lv = Master.getInstance().lv
	local money = GoldConstConfig[lv].money
	self.selected.djs.txtquality1:setString("")
	self.selected.djs.txtquality2:setString(money)
	CommonGrid.bind(self.selected.djtb.herobg)
	self.selected.djtb.herobg:setItemIcon(9901001)
	local function onGold(self,event,target)
		Network.sendMsg(PacketID.CG_GOLD_BUY)
	end
	local function onGoldTen(self,event,target)
		local master = Master.getInstance() 
		local vipLv = master.vipLv
		local total = GoldCntConfig[vipLv].cnt
		if self.cnt+TEN > total then
			--Common.showMsg("次数不足")
			local tipsUI = TipsUI.showTips("点金手可用次数不足，请提高VIP等级获得更多次数！")
			tipsUI.yes.skillzi:setString("充值")
			tipsUI.no.skillzi:setString("取消")
			tipsUI:addEventListener(Event.Confirm,function(self, event)
				if event.etype == Event.Confirm_yes then
					UIManager.addUI("src/modules/vip/ui/VipUI")
				end
			end,self)
		else
			local total = 0
			for i = self.cnt+1,self.cnt + TEN do
				local costCnt = i > #GoldCostConfig and #GoldCostConfig or i
				local gold = GoldCostConfig[costCnt].cost
				total = total + gold
			end
			if total > master.rmb then
				Common.showMsg("钻石不足")
			else
				self.tips.txtquality1:setString(total)
				local money = GoldConstConfig[lv].money
				self.tips.txtquality2:setString(money*TEN)
				--self.tips:setVisible(true)
				ActionUI.show(self.tips,"scale")
			end
		end
	end
	local function onVip(self,event,target)
		UIManager.addUI("src/modules/vip/ui/VipUI")
	end
	local function onCancel(self,event,target)
		ActionUI.hide(self.tips,"scaleHide")
	end
	local function onConfirm(self,event,target)
		ActionUI.hide(self.tips,"scaleHide")
		Network.sendMsg(PacketID.CG_GOLD_BUY_TEN,10)
	end
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close1:addEventListener(Event.Click,onClose,self)
	self.tips.cancel:addEventListener(Event.Click,onCancel,self)
	self.tips.confirm:addEventListener(Event.Click,onConfirm,self)
	self.selected.use:addEventListener(Event.Click,onGold,self)
	self.selected.useby:addEventListener(Event.Click,onGoldTen,self)
	self.selected.lookvip:addEventListener(Event.Click,onVip,self)
	Network.sendMsg(PacketID.CG_GOLD_BUY_QUERY)
	self.selected.txtjrky:setVisible(false)
	self.attach:setAnchorPoint(0.5,0.5)
	self.attach:setPositionX(self.attach:getPositionX()+self.attach:getContentSize().width/2)
	self.attach:setPositionY(self.attach:getPositionY()+self.attach:getContentSize().height/2)
	self.attachPosX = self.attach:getPositionX()
	self.attachPosY = self.attach:getPositionY()
	local baoji = cc.LabelBMFont:create(tostring(11),  "res/gold/baoji.fnt")
	baoji:setAnchorPoint(cc.p(0,0))
	baoji:setPositionX(self.attach.bj0:getPositionX())
	baoji:setPositionY(self.attach.bj0:getPositionY()-10)
	self.attach._ccnode:addChild(baoji)
	self.attach.baojinum = baoji
	local jinqian = cc.LabelBMFont:create(tostring(22),  "res/gold/jinqian.fnt")
	jinqian:setAnchorPoint(cc.p(0,0))
	jinqian:setPositionX(self.attach.jq0:getPositionX())
	jinqian:setPositionY(self.attach.jq0:getPositionY()-5)
	self.attach._ccnode:addChild(jinqian)
	self.attach.jinqian = jinqian
	self.attach.bj0:setVisible(false)
	self.attach.jq0:setVisible(false)
	self.attach:setVisible(false)
end

function refreshInfo(self,cnt)
	self.cnt = cnt
	local master = Master.getInstance() 
	local vipLv = master.vipLv
	local total = GoldCntConfig[vipLv].cnt
	self.selected.txtjrky:setVisible(true)
	self.selected.txtjrky:setString(string.format("（今日可用%d/%d）",total-cnt,total))
	if cnt >= total then
		self.selected.use:setVisible(false)
		self.selected.useby:setVisible(false)
		self.selected.lookvip:setVisible(true)
	end
	local costCnt = cnt + 1 > #GoldCostConfig and #GoldCostConfig or cnt + 1
	local gold = GoldCostConfig[costCnt].cost
	self.selected.djs.txtquality1:setString(gold)
end

function refreshBuy(self,data)
	self.down:setVisible(true)
	for i = 1,#data do
		table.insert(self.tipsList,data[i]) 
	end
	local cap = #self.tipsList
	self.down.sm:removeAllItem()
	self.down.sm:setItemNum(cap)
	for i = 1,cap do
		local d = self.tipsList[cap-i+1]
		local ctrl = self.down.sm:getItemByNum(i)
		ctrl.txt2:setString(d.gold)
		ctrl.txt4:setString(d.money)
		local ratedesc = d.rate > 0 and "暴击X"..d.rate or ""
		ctrl.txt5:setString(ratedesc)
	end
	self.attach:setVisible(true)
	if self.tipsList[#self.tipsList].rate > 0 then
		self.attach.baojinum:setVisible(true)
		self.attach.bj10:setVisible(true)
		self.attach.baoji:setVisible(true)
	else
		self.attach.baojinum:setVisible(false)
		self.attach.bj10:setVisible(false)
		self.attach.baoji:setVisible(false)
	end
	self.attach.baojinum:setString(self.tipsList[#self.tipsList].rate)
	self.attach.jinqian:setString(self.tipsList[#self.tipsList].money)
	self.attach:setPositionX(self.attachPosX)
	self.attach:setPositionY(self.attachPosY)
	self.attach:setScale(2.5)
	local seq = cc.Sequence:create(
		--cc.Spawn:create(
		--	cc.ScaleTo:create(0.15,1.2),
		--	--cc.DelayTime:create(0.5),
		--	cc.FadeOut:create(1.2)
		--),
		cc.ScaleTo:create(0.1,1),
		--cc.FadeOut:create(1.2),
		cc.DelayTime:create(0.5),
		cc.MoveBy:create(0.5,cc.p(0,100)),
		cc.CallFunc:create(function() 
			self.attach:setVisible(false)
		end)
	)
	self.attach:stopAllActions()
	self.attach:runAction(seq)
end
