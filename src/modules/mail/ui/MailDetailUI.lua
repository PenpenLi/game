module(..., package.seeall)
setmetatable(_M, {__index = Control})
local MailData = require("src/modules/mail/MailData")
local BagDefine = require("src/modules/bag/BagDefine")

function new(id)
	local ctrl = Control.new(require("res/mail/MailDetailSkin"),{"res/mail/MailDetail.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(id)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function init(self,id)
	self.id = id
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	--self.close:addEventListener(Event.Click,onClose,self)
	function onDelete(self,event,target)
		local mailData = MailData.getData()
		local data = mailData[self.id]
		Network.sendMsg(PacketID.CG_DEL_MAIL,data.id)
		onClose(self)
	end
	self.detail.delete:addEventListener(Event.Click,onDelete,self)
	self.detail.get:addEventListener(Event.Click,onDelete,self)
	for i = 1,10 do
		CommonGrid.bind(self.detail.attach.row["grid"..i].bg,"tips")
	end
	local mailData = MailData.getData()
	local data = mailData[self.id]
	Network.sendMsg(PacketID.CG_ASK_MAIL_DETAIL,data.id)
	WaittingUI.create(PacketID.GC_ASK_MAIL_DETAIL)
	--self:refreshInfo()
end

function touch(self,event)
	local child = self:getTouchedChild(event.p)
	if child then
		Control.touch(self,event)
	else
		if event.etype == Event.Touch_ended then
			UIManager.removeUI(self)
		end
	end
end

function refreshInfo(self)
	local mailData = MailData.getData()
	local data = mailData[self.id]
	self.detail.mailTitle:setString(data.title)
	self.detail.mailContent:setString(Common.urlDecode(data.content))
	self.detail.mailContent:setDimensions(self.detail.mailContent._skin.width,0)
	local adjustY = self.detail.mailContent:getContentSize().height
	self.detail.mailContent:setPositionY(self.detail.mailContent:getPositionY()+100-adjustY)
	self.detail.mailContent:setVerticalAlignment(Label.Alignment.Top)
	--self.detail.attach.icon1:setVisible(false)
	--self.detail.attach.icon2:setVisible(false)
	--self.detail.attach.icon3:setVisible(false)
	--self.detail.attach.num1:setString("")
	--self.detail.attach.num2:setString("")
	--self.detail.attach.num3:setString("")
	local gridId = 1
	local virItemId = 1
	for i = 1,#data.attachment do
		local attach = data.attachment[i]
		if attach then
			--local name = BagDefine.VIRITEMID2NAME[attach.id]
			local name = nil
			if name then
				if self.detail.attach["icon"..virItemId] then
					self.detail.attach["icon"..virItemId]:setVisible(true)
					self.detail.attach["num"..virItemId]:setVisible(true)
					CommonGrid.setCoinIcon(self.detail.attach["icon"..virItemId],name)
					self.detail.attach["num"..virItemId]:setString(attach.num)
					virItemId = virItemId + 1
				end
			else
				local grid = self.detail.attach.row["grid"..gridId]
				if grid then
					grid.bg:setItemIcon(attach.id,"mIcon")
					grid.bg:setItemNum(attach.num)
					gridId = gridId + 1
				end
			end
		end
	end
	for i = gridId,10 do
		local grid = self.detail.attach.row["grid".. i]
		grid.bg:setItemIcon()
	end
	if #data.attachment > 0 then
		self.detail.delete:setVisible(false)
		self.detail.get:setVisible(true)
	else
		self.detail.delete:setVisible(true)
		self.detail.get:setVisible(false)
	end
end

function clear(self)
	Control.clear(self)
end
