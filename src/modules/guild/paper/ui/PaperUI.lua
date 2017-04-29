module(..., package.seeall)
setmetatable(_M, {__index = Control})
local PaperData = require("src/modules/guild/paper/PaperData")

function new()
	local ctrl = Control.new(require("res/guild/paper/PaperSkin"),{"res/guild/paper/Paper.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function init(self)
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.close:addEventListener(Event.Click,onClose,self)
	self.send.srsl:setDimensions(self.send.srsl._skin.width,0)
	self.tips:setDimensions(self.tips._skin.width,0)
	function onSelectOption(self,event,target)
		if target.regionId == 2 then
			Network.sendMsg(PacketID.CG_PAPER_QUERY)
			--WaittingUI.create(PacketID.GC_PAPER_QUERY)
		end
		local tb = {[1] = "send",[2] = "paper"}
		self:setViewVisible(tb[target.regionId])
	end
	for i = 1,2 do
		self.group["region"..i]:addEventListener(Event.Click,onSelectOption,self)
		self.group['region'..i].regionId = i
	end
	--local function onCheck(eType)
	--	if eType == "return" then
	--		local str = tonumber(self.editBox:getText())
	--		if str and str >= 0 then
	--		else
	--			self.editBox:setText("")
	--			Common.showMsg("请输入有效数字")
	--		end
	--	end
	--end
	--self.editBox = Common.createEditBox(self.send.enterNum,onCheck)
	--self.editBox:setPlaceHolder("请输入数量")
	--self.editBox:setMaxLength(32)
	--self.send._ccnode:addChild(self.editBox)
	--self.send.enterNum:setVisible(false)

	local function onSend(self,event,target)
		--local sum = tonumber(self.editBox:getText())
		--if sum then
		--	Network.sendMsg(PacketID.CG_SEND_PAPER,sum)
		--else
		--	Common.showMsg("请输入有效数字")
		--end
		local ui = UIManager.addUI("src/modules/vip/ui/VipUI",nil,true)
		ui:refreshRechargePaper()
	end
	self.send.confirm:addEventListener(Event.Click,onSend,self)
	self.send.shuoming1:setString("1. 红包发放时会按照当前公会人数分成对应份数")
	self.send.shuoming2:setString("2. 发出的红包，3天后无人领取的部分将自动回到红包发放人\n的账号")
	self.send.shuoming2:setPositionY(self.send.shuoming2:getPositionY()-12)
	self.send.shuoming3:setVisible(false)

	self:setViewVisible("send")
	self.group['region1']:setSelected(true)
	self.paper:setBgVisiable(false)
	--local master = Master.getInstance()
	--master:removeEventListener(Event.MasterRefresh,setOwnRmb)
	--master:addEventListener(Event.MasterRefresh,setOwnRmb,self)
	--self:setOwnRmb()
	Dot.check(self.group.region2,"guildPaperCheck")
end

function setOwnRmb(self)
	local rmb = Master.getInstance().rmb
	self.send.ownRmb:setString(rmb)
end

function setViewVisible(self,name)
	self.send:setVisible(false)
	self.paper:setVisible(false)
	self.tips:setVisible(false)
	if self[name] then
		self[name]:setVisible(true)
	end
end

function onScratch(self,evnet,target)
	Network.sendMsg(PacketID.CG_GET_PAPER,target.id)
end

function refreshItem(self,id,num)
	Dot.check(self.group.region2,"guildPaperCheck")
	local group = PaperData.getData()
	local list = self.paper
	local row = list:getItemCount()
	for i = 1,row do
		local ctrl = list:getItemByNum(i)
		if ctrl.id == id then
			local data = group[i]
			if num == 0 then
				ctrl.getTips:setVisible(true)
				ctrl.rewardTips:setVisible(false)
				ctrl.getTips.memberName:setString(data.name)
				ctrl.getTips.rmbNum:setString(string.format("%d钻石",data.sum))
				if not ctrl.getTips.scratch:hasEventListener(Event.Click,onScratch) then
					ctrl.getTips.scratch:addEventListener(Event.Click,onScratch,self)
				end
			else
				ctrl.getTips:setVisible(false)
				ctrl.rewardTips:setVisible(true)
				if num > 0 then
					ctrl.rewardTips.rewardTxt:setString(string.format("公会成员【%s】发放了一个【%s】钻石，\n你眼疾手快抢到了一份！",data.name,data.sum))
					ctrl.rewardTips.rewardNum:setString(string.format("您抢到了%d钻石，运气不错呀!",num))
				else
					ctrl.rewardTips.rewardTxt:setString("")
					ctrl.rewardTips.rewardNum:setString(string.format("%d钻石的红包被抢光了!!",data.sum))
				end
			end
			break
		end
	end
end

function refreshInfo(self)
	Dot.check(self.group.region2,"guildPaperCheck")
	local group = PaperData.getData()
	local row = #group
	local list = self.paper
	list:removeAllItem()
	list:setItemNum(row)
	if row > 0 then
		self.tips:setVisible(false)
		for i = 1,row do
			local data = group[i]
			local ctrl = list:getItemByNum(i)
			ctrl.id = data.id
			ctrl.getTips.scratch.id = data.id
			if data.get == 0 then
				ctrl.getTips:setVisible(true)
				ctrl.rewardTips:setVisible(false)
				ctrl.getTips.memberName:setString(data.name)
				ctrl.getTips.rmbNum:setString(string.format("%d钻石",data.sum))
				if not ctrl.getTips.scratch:hasEventListener(Event.Click,onScratch) then
					ctrl.getTips.scratch:addEventListener(Event.Click,onScratch,self)
				end
			else
				ctrl.getTips:setVisible(false)
				ctrl.rewardTips:setVisible(true)
				if data.get > 0 then
					ctrl.rewardTips.rewardTxt:setString(string.format("公会成员【%s】发放了一个【%s】钻石，\n你眼疾手快抢到了一份！",data.name,data.sum))
					ctrl.rewardTips.rewardNum:setString(string.format("您抢到了%d钻石，运气不错呀!",data.get))
				else
					ctrl.rewardTips.rewardTxt:setString("")
					ctrl.rewardTips.rewardNum:setString(string.format("%d钻石的红包被抢光了!!",data.sum))
				end
			end
		end
	else
		self.tips:setVisible(true)
	end
end

function clear(self)
	--Master.getInstance():removeEventListener(Event.MasterRefresh,setOwnRmb)
	Control.clear(self)
end
