module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local Hero = require("src/modules/hero/Hero")
local HeroDefine = require("src/modules/hero/HeroDefine")
local BaseMath = require("src/modules/public/BaseMath")

local Logic = require("src/modules/chat/ChatLogic")
local Define = require("src/modules/chat/ChatDefine")
local FlowerDefine = require("src/modules/flower/FlowerDefine")
local FriendsUI = require("src/modules/friends/ui/FriendsUI")

local LIST_TOP_SPACE = 15

local PrivateInputScale = 0.7
local TargetName = nil
local TargetAccount = nil

function new()
    local ctrl = Control.new(require("res/chat/ChatSkin"),{"res/chat/Chat.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function init(self)
	self:adjustTouchBox(0,-self.open:getPositionY(),0,-self:getContentSize().height+self.open:getContentSize().height)

	self.master = Master.getInstance()
	self.chatType = Define.TYPE_WORLD

	--玩家详情
	self.detail:setVisible(false)
	self.detail.chat:addEventListener(Event.Click, onChat , self)
	self.detail.sendflower:addEventListener(Event.Click, onFlower , self)
	self.detail.add:addEventListener(Event.Click, onAdd , self)
	--self.detail.close:addEventListener(Event.Click, function(self,event,target) target._parent:setVisible(false) end, self)
	--[[
	local lvLabel = self.detail.lvLabel
	local lvNum = cc.LabelBMFont:create("",  "res/common/lvnumsmall.fnt")
	lvNum:setAnchorPoint(0,0)
	lvNum:setPosition(lvLabel:getPosition())
	lvLabel:setVisible(false)
	self.detail._ccnode:addChild(lvNum)
	self.detail.lvLabel:removeFromParent()
	self.detail.lvLabel = lvNum
	--]]

	--窗口开关
	self.hidePosX = self.open:getPositionX()
	self.open:addEventListener(Event.TouchEvent, onOpen, self)
	self.close:addEventListener(Event.TouchEvent, onClose, self)

	--输入框
	self.lastChatTxt = ""
	self.targetLabel:setVisible(false)
	Common.setLabelCenter(self.targetLabel)
	self.sinputbg:setVisible(false)
	self.inputbg:setAnchorPoint(1,0)
	self.inputbg:setPositionX(self.inputbg:getContentSize().width + self.inputbg:getPositionX())
	self.inputOffsetWidth = self.inputbg:getContentSize().width * (1-PrivateInputScale)
	self.editBox = Common.createEditBox(self.inputLabel,function(eventType) self:onEditInput(eventType) end)
	self.editBox:setMaxLength(50)
    --self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
	self.editBoxSize = self.editBox:getContentSize() 
	self.editBoxPosX = self.editBox:getPositionX()
	self._ccnode:addChild(self.editBox)
	self.send:addEventListener(Event.Click, onSend, self)
	--self._drawBox = Common.getDrawBoxNode(self.editBox:getBoundingBox(),cc.c4b(255,255,0,100))
	--self._ccnode:addChild(self._drawBox)

	--tab
	self.channel:addEventListener(Event.Change, onChangeChannel, self)
	self.channel.world:setSelected(true)
	self.channelTb = {
		[Define.TYPE_PRIVATE] = self.channel.private,
		[Define.TYPE_WORLD] = self.channel.world,
		[Define.TYPE_GUILD] = self.channel.guild,
	}

	--self.chatList:setTopSpace(LIST_TOP_SPACE)
	--监听是否开启帮会聊天
	self.master:removeEventListener(Event.MasterRefresh,onMasterRefresh)
	self.master:addEventListener(Event.MasterRefresh,onMasterRefresh,self)
	local btn = Button.new(self.channel.guild._skin)
	btn.name = "closeGuild"
	btn:setPosition(self.channel.guild:getPosition())
	self.channel:addChild(btn)
	self.closeGuild = btn
	btn:addEventListener(Event.Click, function() 
		Common.showMsg("加入公会才能愉快聊天哦！")
	end, self)
	self.closeGuild:setEnabled(self.master.guildId == 0)
	self.closeGuild:setVisible(self.master.guildId == 0)
	self.channel.guild:setEnabled(self.master.guildId ~= 0)

	self.selectBtn = self.channel.world
	self:refresh(self.chatType)
	self:addEventListener(Event.Frame, onFrameAddItem,self)
end

function clear(self)
	Control.clear(self)
	self.master:removeEventListener(Event.MasterRefresh,onMasterRefresh)
end

function onMasterRefresh(self)
	self.closeGuild:setVisible(self.master.guildId == 0)
	self.closeGuild:setEnabled(self.master.guildId == 0)
	self.channel.guild:setEnabled(self.master.guildId ~= 0)
end

function addStage(self)
	--self.open:setVisible(true)
	self.open:setVisible(false)
	self.close:setVisible(false)
	self:adjustTouchBox(0,-self.open:getPositionY(),0,-self:getContentSize().height+self.open:getContentSize().height)
	self:marginLeft(-self.hidePosX)
end

function doShow(self)
	self:stopAllActions()
	local move = cc.MoveTo:create(0.2,cc.p(0,self:getPositionY()))
	local cb = cc.CallFunc:create(function()
		--self.open:setVisible(false)
		self.close:setVisible(true)
		--Dot.check(self.open,"mop")
		if Stage.currentScene.name == 'main' then
			local mainui = Stage.currentScene:getUI()
			Dot.check(mainui.mainBtn2.chat,"mop")
		end
	end)
	self.getBoundingBox = DisplayObject.getBoundingBox
	self:runAction(cc.Sequence:create({move,cb}))
end
function onOpen(self,event)
	if event.etype == Event.Touch_began then
		self.preX = event.p.x
	elseif event.etype == Event.Touch_moved then
		if self.preX and event.p.x >= self.preX then
			local offset = event.p.x - self.preX
			self.preX = event.p.x
			local pos = self:getPositionX() + offset
			if pos < 0 then
				self:setPositionX(pos)
			else
				self:setPositionX(0)
			end
		end
	elseif self.preX and event.etype == Event.Touch_ended then
		self:doShow()
	elseif self.preX and event.etype == Event.Touch_out then
		self:doShow()
	end
end

function doHide(self)
	self:stopAllActions()
	local move = cc.MoveTo:create(0.2,cc.p(-self.hidePosX,self:getPositionY()))
	local cb = cc.CallFunc:create(function()
		--self.open:setVisible(true)
		self.close:setVisible(false)
		self:adjustTouchBox(0,-self.open:getPositionY(),0,-self:getContentSize().height+self.open:getContentSize().height)
	end)
	self:runAction(cc.Sequence:create({move,cb}))
	self.detail:setVisible(false)
end
function onClose(self,event)
	if event.etype == Event.Touch_began then
		self.preCX = event.p.x
	elseif event.etype == Event.Touch_moved then
		if self.preCX and self.preCX >= event.p.x then
			local offset = self.preCX - event.p.x
			self.preCX = event.p.x
			local pos = self:getPositionX() - offset
			if pos < 0 then
				self:setPositionX(pos)
			end
		end
	elseif self.preCX and event.etype == Event.Touch_ended then
		self.preCX = nil
		self:doHide()
	elseif self.preCX and event.etype == Event.Touch_out then
		self.preCX = nil
		self:doHide()
	end
end

function refresh(self,type)
	self.chatList:removeAllItem()
	self.curChatList = Logic.getChatByType(type)
	self.frameN = 1
	self:openTimer()
end

function onFrameAddItem(self)
	local list = self.curChatList 
	local v = list[self.frameN]
	if v then
		if self.chatType == Define.TYPE_PRIVATE then
			if TargetAccount and (TargetAccount == v.senderAccount or v.senderAccount == self.master.account ) then
				self:addChatItem(v)
			end
		else
			self:addChatItem(v)
		end
	else
		self.chatList:showBottom()
		self:closeTimer()
	end
	self.frameN = self.frameN + 1
end

function addChat(self,chatType,itemData)
	--if self.open:isVisible() then
	--	Dot.check(self.open,"paint")
	--end
	if not self.close:isVisible() then
		if Stage.currentScene.name == 'main' then
			local mainui = Stage.currentScene:getUI()
			Dot.check(mainui.mainBtn2.chat,"paint")
		end
	end
	if chatType == Define.TYPE_PRIVATE and itemData.senderName ~= self.master.name then
		TargetName = TargetName or itemData.senderName
		TargetAccount = TargetAccount or itemData.senderAccount
	end
	if self.chatType ~= chatType and chatType ~= Define.TYPE_SYSTEM then
		Dot.check(self.channelTb[chatType],"paint")
		return 
	end
	if self.chatList.itemNum >= Define.MAX_LINE then
		self.chatList:removeItem(1)
	end
	self:addChatItem(itemData)
	self.chatList:showBottom()
end

local setChatItem = function(item,v)
	local master = Master.getInstance()
	if v.chatType == Define.TYPE_PRIVATE then
		item.lvLabel:setVisible(false)
		--私聊
		local title = string.format(" %s 对你说",v.senderName)
		if v.senderName == master.name then
			title = string.format("对 %s 说",v.receiverName)
		end
		item.nameLabel:setString(title)
	else
		item.nameLabel:setString(v.senderName)
		item.lvLabel:setString(string.format("LV%d",v.lv))
	end
	local lvPosX = item.nameLabel:getContentSize().width + item.nameLabel:getPositionX() + 20
	item.lvLabel:setPositionX(lvPosX)
	item.timeLabel:setString(os.date("%H:%M",v.time))
	--头像
	CommonGrid.bind(item.body)
	item.body:setBodyIcon(v.bodyId,0.45)
	--item.body._icon:setScale(0.5)
	--内容
	item.contentLabel:setAnchorPoint(0,1)
	item.contentLabel:setPositionY(item.contentLabel:getPositionY()+ item.contentLabel:getContentSize().height)
	item.contentLabel:setDimensions(item.contentLabel:getContentSize().width,0)
	local height = item.contentLabel:getContentSize().height
	item.contentLabel:setString(v.content)
	local size = item:getContentSize() 
	local offset = item.contentLabel:getContentSize().height - height
	item.line:setPositionY(item.line:getPositionY() - offset)
	--改变父容器size
	item._parent:setContentSize(cc.size(size.width,size.height + offset))
end
function addChatItem(self,itemData)
	local itemSkin = self.chatList:getItemSkin()
	local skin = {
		name = "itemCtrl",
		x = itemSkin.x,
		y = itemSkin.y,
		width = itemSkin.width,
		height = itemSkin.height,
		children = {itemSkin},
	}
	local ctrl = Control.new(skin)
	local item = ctrl.item
	item.body:addEventListener(Event.TouchEvent,onClickBody,self)
	item.body.info = itemData
	--动态改变contentSize,子元素整体上移,有点猥琐
	setChatItem(item,itemData)
	item:setPosition(0,ctrl:getContentSize().height)
	item:setAnchorPoint(0,1)
	--
	self.chatList:addItem(ctrl)
end

function onChangeChannel(self,event,target)
	self.selectBtn = event.target
	--reset input
	self:scaleInput(true)
	self.inputbg:setScaleX(1)
	self.editBox:setText(self.lastChatTxt)
	Dot.check(event.target,"mop")
	if event.target.name == "world" then
		self.chatType = Define.TYPE_WORLD
		self:refresh(Define.TYPE_WORLD)
	elseif event.target.name == "private" then
		self.chatType = Define.TYPE_PRIVATE
		self:showPrivate()
		self:refresh(Define.TYPE_PRIVATE)
	elseif event.target.name == "guild" then
		if self.master.guildId == 0 then
			Common.showMsg("你没有加入帮会")
		else
			self.chatType = Define.TYPE_GUILD
			self:refresh(Define.TYPE_GUILD)
		end
	end
end

function scaleInput(self,isReset)
	local scale = PrivateInputScale
	local offset = self.inputOffsetWidth
	self.targetLabel:setVisible(not isReset)
	if isReset then
		scale = 1 
		offset = 0 
	end
	self.sinputbg:setVisible(not isReset)
	self.inputbg:setVisible(isReset)
	self.editBox:setPositionX(self.editBoxPosX + offset)
	local size = Common.deepCopy(self.editBoxSize)
	size.width = size.width * scale 
	self.editBox:setContentSize(size)
end


function onSend(self)
	local txt = self.editBox:getText()
	if txt:len() < 1 then
		Common.showMsg("发言内容不能为空")
		return
	end
	if #Common.utf2tb(txt) > Define.CHAT_MAX_CONTENT_LEN then
		Common.showMsg("最多输入%d个字符哦",Define.CHAT_MAX_CONTENT_LEN)
		return
	end
	self.lastChatTxt = ""
	Logic.sendChat(self.chatType,txt,TargetName,TargetAccount)
	self.editBox:setText("")
end


function onClickBody(self,event,target)
	if event.etype == Event.Touch_ended then
		local info = target.info
		if info.senderName == self.master.name then
			Common.showMsg("不能跟自己聊天哦")
			return
		end
		TargetName = info.senderName
		TargetAccount = info.senderAccount
		local block = self.detail
		--block:setVisible(true)
		block.nameLabel:setString(info.senderName)
		block.lvLabel:setString("Lv" .. info.lv)
		block.guildNameLabel:setString(info.guildName)
		CommonGrid.bind(block.bodybg)
		block.bodybg:setBodyIcon(info.bodyId)
		ActionUI.show(self.detail,"scale")
		self:adjustTouchBox(0,0,Stage.width,Stage.height)
		self:getChild("actionGray"):addEventListener(Event.TouchEvent,closeBodyBox,self)
	end
end


function showPrivate(self)
	local name = TargetName or "请选择私聊对象"
	self.targetLabel:setString(name)
	self:scaleInput()
	self.editBox:setText("")
end

function setTarget(account,name)
	TargetName = name
	TargetAccount = account
end

function onFlower(self, evt)
	if Master.getInstance().lv >= FlowerDefine.FLOWER_LIMIT_LV then
		self:closeBodyBox()
		Network.sendMsg(PacketID.CG_FLOWER_GIVE_OPEN, TargetName, FlowerDefine.FLOWER_FROM_TYPE_TALK)
	else
		Common.showMsg('战队等级达到' .. FlowerDefine.FLOWER_LIMIT_LV .. '级开启')
	end
end

function onAdd( self,evt )
	FriendsUI.addFriend(TargetAccount)
end

function closeBodyBox(self)
	ActionUI.hide(self.detail,"scaleHide")
	self.getBoundingBox = DisplayObject.getBoundingBox
end

function onChat(self,event,target)
	self.chatType = Define.TYPE_PRIVATE
	self.selectBtn:setSelected(false)
	self.channel.private:setSelected(true)
	self:closeBodyBox()
	self:showPrivate()
	self:refresh(self.chatType)
end

function onEditInput(self,eventType)
	--@fix editbox控件会重新调整contentsize
    if eventType == "began" then
		self.editBox:setText(self.lastChatTxt)
	elseif eventType == "ended" then
		self.lastChatTxt = self.editBox:getText()
	elseif eventType == "return" then
        if self.chatType == Define.TYPE_PRIVATE then
            self:scaleInput()
        end
    end
end




