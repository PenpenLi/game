module(..., package.seeall)
setmetatable(_M, {__index = Control})
local RechargeConfig = require("src/config/RechargeConfig").Config
local RechargeConstConfig = require("src/config/RechargeConstConfig").Config
local RechargeLogic = require("src/modules/recharge/RechargeLogic")

function new()
	local ctrl = Control.new(require("res/recharge/RechargeSkin"),{"res/recharge/Recharge.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)	
end

function init(self)
	function onClose(self)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click, onClose, self)
	self.actpanel.rewardlist.listbg:setVisible(false)
	function onGet(self,event,target)
		Network.sendMsg(PacketID.CG_RECHARGE_GET,target.id)
	end
	function onOpen(self,event,target)
		local ui = UIManager.addUI("src/modules/vip/ui/VipUI")
		ui:showRecharge()
	end
	self.txtmsg:setDimensions(self.txtmsg._skin.width,0)

	local list = self.actpanel.rewardlist
	local row = #RechargeConfig
	list:setItemNum(row)
	for i = 1,row do
		local ctrl = list:getItemByNum(i)
		local data = RechargeConfig[i]
		local j = 0
		for k,v in pairs(data.item) do
			j = j + 1
			CommonGrid.bind(ctrl["grid"..j].bg,"tips")
			ctrl["grid"..j].bg:setItemIcon(k)
			ctrl["grid"..j].bg:setItemNum(v)
		end
		for n = j+1,5 do
			ctrl["grid"..n].bg:setVisible(false)
		end
		ctrl.recharge:setVisible(false)
		ctrl.get:setVisible(false)
		ctrl.yilingqu:setVisible(false)

		local num = cc.LabelBMFont:create("",  "res/recharge/rechargeNum.fnt")
		num:setString(0)
		num:setAnchorPoint(0,0)
		num:setPositionX(ctrl.rmb.yuan:getPositionX()-num:getContentSize().width)
		num:setPositionY(ctrl.rmb.num:getPositionY()-5)
		ctrl.rmb.num:setVisible(false)
		ctrl.rmb._ccnode:addChild(num)
		ctrl.num = num
		ctrl.get.id = data.id
		ctrl.get:addEventListener(Event.Click,onGet,self)
		ctrl.recharge:addEventListener(Event.Click,onOpen,self)
	end

	local endTime = RechargeLogic.endTime
	local getEndTime = RechargeLogic.getEndTime
	if endTime > 0 and getEndTime >0 then
		local date1 = os.date("*t",RechargeLogic.endTime)
		local date2 = os.date("*t",RechargeLogic.getEndTime)
		--local tb,hourTb = datestr2timestamp(RechargeConstConfig[1].endTime)
		self.actLimitedTime:setString(string.format("活动截止时间：%d年%d月%d日%d时",date1.year,date1.month,date1.day,date1.hour))
		--local tb,hourTb = datestr2timestamp(RechargeConstConfig[1].getEndTime)
		self.getLimitedTime:setString(string.format("领取截止时间：%d年%d月%d日%d时",date2.year,date2.month,date2.day,date2.hour))
	end
	Network.sendMsg(PacketID.CG_RECHARGE_QUERY)
end

function refreshInfo(self,num,status)
	local list = self.actpanel.rewardlist
	for i = 1,#status do
		local ctrl = list:getItemByNum(i)
		local data = RechargeConfig[i]
		local num1 = math.max(0,data.recharge - num)
		ctrl.num:setString(num1)
		ctrl.num:setPositionX(ctrl.rmb.yuan:getPositionX()-ctrl.num:getContentSize().width)
		local state = status[i].state
		print("refreshInfo::state")
		print(state)
		if state == 1 then
			ctrl.recharge:setVisible(true)
			ctrl.get:setVisible(false)
			ctrl.yilingqu:setVisible(false)
		elseif state == 2 then
			ctrl.recharge:setVisible(false)
			ctrl.get:setVisible(true)
			ctrl.yilingqu:setVisible(false)
		elseif state == 3 then
			ctrl.recharge:setVisible(false)
			ctrl.get:setVisible(false)
			ctrl.yilingqu:setVisible(true)
		end
	end
end

function datestr2timestamp(str)
	local tb = Common.Split(str,"-")
	local hourTb = Common.Split(tb[4],":")
	--local time = os.time({year=tb[1],month=tb[2],day=tb[3],hour=hourTb[1],min=hourTb[2]}) 
	--return time
	return tb,hourTb
end
