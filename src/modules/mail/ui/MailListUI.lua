module(..., package.seeall)
setmetatable(_M, {__index = Control})
local MailData = require("src/modules/mail/MailData")

function new()
	local ctrl = Control.new(require("res/mail/MailListSkin"),{"res/mail/MailList.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function addStage(self)
	--self:setPositionY(Stage.uiBottom)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
end

function uiEffect(self)
	return UIManager.THIRD_TEMP
end

function init(self)
	--function onClose(self,event,target)
	--	UIManager.removeUI(self)
	--end
	--self.close:addEventListener(Event.Click,onClose,self)
	self.maillist.mail:setBgVisiable(false)
	self.maillist.txttips:setAnchorPoint(0.5,0)
	self.maillist.txttips:setString("当前未收到任何邮件")
	Network.sendMsg(PacketID.CG_ASK_MAIL_LIST)

	self:openTimer()
	self:addEventListener(Event.Frame, addListByFrame)
end

function onMailChoose(self,event,target)
	if event.etype == Event.Touch_ended then
		local mailData = MailData.getData()
		local data = mailData[target.id]
		Network.sendMsg(PacketID.CG_READ_MAIL,data.id)
		UIManager.addChildUI("src/modules/mail/ui/MailDetailUI",target.id)
	end
end

function addListByFrame(self,event)
	local frameRate = 1
	if self.sortedMails and #self.sortedMails > 0 then
		for i = 1,frameRate do
			if self.sortedMails[1] then
				local mail = self.sortedMails[1]
				table.remove(self.sortedMails,1)
				self:addMailToList(mail)
			else
				break
			end
		end
	end
end

function addMailToList(self,mail)
	local no = self.maillist.mail:addItem()
	local ctrl = self.maillist.mail.itemContainer[no]
	ctrl.id = no
	if not ctrl:hasEventListener(Event.TouchEvent,onMailChoose) then
		ctrl:addEventListener(Event.TouchEvent,onMailChoose,self)
	end
	CommonGrid.bind(ctrl.gezi1.bg)
	ctrl.title:setString(mail.title)
	ctrl.txtname:setString(mail.sender)
	local timestr = os.date("%Y-%m-%d",mail.sendtime)
	ctrl.time:setString(timestr)
	--ctrl.gezi1.bg:setBodyIcon(1)
	local res = "res/common/icon/item/120/yj.png"
	ctrl.gezi1.bg._icon:setTexture(res)
	ctrl.gezi1.bg._icon:setScale(72/82)
end

function refresh(self)
	local mailData = MailData.getData()
	local list = self.maillist.mail
	local len = #mailData
	if len > 0 then
		self.maillist.txttips:setVisible(false)
	else
		self.maillist.txttips:setVisible(true)
	end
	list:removeAllItem()
	self.sortedMails = Common.deepCopy(mailData)
end

_M.touch = function(self,event)
	Common.outSideTouch(self,event)
end
