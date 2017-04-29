module(..., package.seeall)
setmetatable(_M, {__index = Control})
local GuildDefine = require("src/modules/guild/GuildDefine")
local GuildData = require("src/modules/guild/GuildData")
local FlowerDefine = require("src/modules/flower/FlowerDefine")

function new(index)
	local ctrl = Control.new(require("res/guild/MemberListSkin"),{"res/guild/MemberList.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	return ctrl
end

function uiEffect()
	return UIManager.SECOND_TEMP
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onClose(self,event,target)
	UIManager.removeUI(self)
end

function init(self,index)
	self:initOperate()
	self:initMemDetail()
	self.close:addEventListener(Event.Click,onClose,self)
	function onSelectOption(self,event,target)
		self:onSelectTag(target.regionId)
	end
	for i = 1,2 do
		self.region['region'..i]:addEventListener(Event.Click,onSelectOption,self)
		self.region['region'..i].regionId = i
	end
	local pos = GuildData.getGuildPos()
	if pos ~= GuildDefine.GUILD_LEADER and
		pos ~= GuildDefine.GUILD_SENIOR  then
		self.region.region2:setVisible(false)
	else
		self.region.region2:setVisible(true)
	end

	self:onSelectTag(index)
end

function onSelectTag(self,id)
	self.region['region'..id]:setSelected(true)
	if id == GuildDefine.MEMBER_TAG then
		Network.sendMsg(PacketID.CG_GUILD_MEMBER_QUERY)
	elseif id == GuildDefine.APPLY_TAG then
		Network.sendMsg(PacketID.CG_GUILD_APPLY_QUERY)
	end
end

function initMemDetail(self)
	local function onCloseDetail(self,event,target)
		self.detail:setVisible(false)
	end
	function sendFlower(self,event,target)
		if Master.getInstance().lv >= FlowerDefine.FLOWER_LIMIT_LV then
			local mem = self.detail.mem
			local name = mem.name
			Network.sendMsg(PacketID.CG_FLOWER_GIVE_OPEN, name, FlowerDefine.FLOWER_FROM_TYPE_TALK)
		else
			Common.showMsg('战队等级达到' .. FlowerDefine.FLOWER_LIMIT_LV .. '级开启')
		end
	end
	function onChat(self,event,target)
		--local GuildInfoUI = Stage.currentScene:getUI():getChild("GuildInfo")
		--if GuildInfoUI then
		--	UIManager.removeUI(GuildInfoUI)
		--end
		local mem = self.detail.mem
		local mMem,memberList = GuildData.getMemberData()
		if mMem.id == mem.id then
			Common.showMsg('不能对自己聊天')
		else
			UIManager.reset()
			UIManager.setChatUI(true)
			local ChatUI = Stage.currentScene:getUI():getChild("Chat")
			ChatUI:doShow()
			local mem = self.detail.mem
			ChatUI.setTarget(mem.account,mem.name)
			ChatUI:onChat()
		end
	end
	CommonGrid.bind(self.detail.bodybg)
	self.detail.close:addEventListener(Event.Click,onCloseDetail,self)
	self.detail:setVisible(false)
	self.detail.sendflower:addEventListener(Event.Click,sendFlower,self)
	self.detail.chat:addEventListener(Event.Click,onChat,self)
end

function initOperate(self)
	local function onCloseOperate(self,event,target)
		self.operate:setVisible(false)
	end
	self.operate.close:addEventListener(Event.Click,onCloseOperate,self)

	function onOperate(kType,event,target)
		if kType == GuildDefine.GUILD_MEM_OPERATE.kAppoint
			and self.operate.mem.pos == GuildDefine.GUILD_SENIOR then
			kType = GuildDefine.GUILD_MEM_OPERATE.kRemove
		end
		local content = {[1] = "任命长老",[2] = "转交会长",[3] = "踢出公会",[4] = "卸任长老"}
		local tipsUI = TipsUI.showTips("是否确定"..content[kType].."?")
		tipsUI:addEventListener(Event.Confirm, function(self,event) 
			if event.etype == Event.Confirm_yes then
				Network.sendMsg(PacketID.CG_GUILD_MEM_OPERATE,self.operate.mem.id,kType)
				self.operate:setVisible(false)
			end
		end,self)
	end
	self.operate.kickoff:addEventListener(Event.Click,onOperate,GuildDefine.GUILD_MEM_OPERATE.kKickoff)
	self.operate.appoint:addEventListener(Event.Click,onOperate,GuildDefine.GUILD_MEM_OPERATE.kAppoint)
	self.operate.passto:addEventListener(Event.Click,onOperate,GuildDefine.GUILD_MEM_OPERATE.kPassto)

	CommonGrid.bind(self.operate.headBG)
	self.operate:setVisible(false)
end

function onMemQuit(self,event,target)
	local tipsUI = TipsUI.showTips("确定退出公会?")
	tipsUI:addEventListener(Event.Confirm, function(self,event) 
		if event.etype == Event.Confirm_yes then
			Network.sendMsg(PacketID.CG_GUILD_QUIT)
			local scene = require("src/scene/MainScene").new()
			Stage.replaceScene(scene)
		end
	end,self)
end

function onMemOperate(self,event,target)
	local mMem,memberList = GuildData.getMemberData()
	if mMem.pos ~= GuildDefine.GUILD_LEADER then
		Common.showMsg(GuildDefine.NO_AUTH_TIPS)
		return 
	end
	if mMem.id == target.mem.id then
		Common.showMsg("不能对自己操作")
		return 
	end
	if target.mem.pos == GuildDefine.GUILD_SENIOR then
		self.operate.appoint.txtzhaomu:setString("卸任长老")
	else
		self.operate.appoint.txtzhaomu:setString("任命长老")
	end
	self.operate:setVisible(true)
	self.operate.mem = target.mem
	self.operate.txtname:setString(target.mem.name)
	self.operate.lv:setString("lv."..target.mem.lv)
	local txtlv = cc.LabelAtlas:_create("0123456789", "res/common/HeroLv.png", 18, 28, string.byte('0'))
	txtlv:setString(tostring(target.mem.lv))
	txtlv:setAnchorPoint(0,0)
	--txtlv:setPositionX(self.operate.lvbg:getContentSize().width)
	txtlv:setPositionY(-5)
	--self.operate.lvbg._ccnode:addChild(txtlv)
	self.operate.headBG:setBodyIcon(target.mem.icon)
end

function onMemDetail(self,event,target)
	if event.etype == Event.Touch_ended then
		local child = getTouchedChild(target, event.p)
		if child and (child.name == "op" or child.name == "quit") then
		else
			local mem = target.mem
			self.detail.mem = mem
			self.detail:setVisible(true)
			self.detail.guildNameLabel:setString(GuildData.getGuildName())
			self.detail.nameLabel:setString(mem.name)
			self.detail.lvLabel:setString("lv."..mem.lv)
			self.detail.bodybg:setBodyIcon(mem.icon)
		end
	end
end

function refreshMemberInfo(self)
	local mMem,memberList = GuildData.getMemberData()
	self.apply:setVisible(false)
	self.member:setVisible(true)
	local rows = #memberList
	local list = self.member
	list:removeAllItem()
	list:setItemNum(rows)
	list.levelrankbg:setVisible(false)
	for i = 1,rows do
		local mem = memberList[i]
		local ctrl = list:getItemByNum(i)
		ctrl.txtname:setString(mem.name)
		local txtlv = cc.LabelAtlas:_create("0123456789", "res/common/HeroLv.png", 18, 28, string.byte('0'))
		txtlv:setString(tostring(mem.lv))
		txtlv:setAnchorPoint(0,0)
		--txtlv:setPositionX(ctrl.lvbg:getContentSize().width)
		txtlv:setPositionY(-5)
		--ctrl.lvbg._ccnode:addChild(txtlv)
		ctrl.lv:setString("lv."..mem.lv)
		ctrl.txtpos:setString(GuildDefine.GUILD_POS[mem.pos] or "")
		if not ctrl.headBG._icon then
			CommonGrid.bind(ctrl.headBG)
		end
		ctrl.headBG:setBodyIcon(mem.icon)
		--ctrl.headBG.mem = mem
		--if not ctrl.headBG:hasEventListener(Event.TouchEvent,onMemDetail) then
		--	ctrl.headBG:addEventListener(Event.TouchEvent,onMemDetail,self)
		--end
		ctrl.mem = mem
		if not ctrl:hasEventListener(Event.TouchEvent,onMemDetail) then
			ctrl:addEventListener(Event.TouchEvent,onMemDetail,self)
		end
		local str = "在线"
		if mem.lastLogin > 0 then
			if mem.lastLogin > 3600 then
				local hour = math.floor(mem.lastLogin / 3600)
				if hour > 24 then
					str = string.format("最后上线时间：%d天%d小时前",math.floor(hour/24),hour%24)
				else
					str = string.format("最后上线时间：%d小时前",math.floor(mem.lastLogin / 3600))
				end
			elseif mem.lastLogin > 60 then
				str = string.format("最后上线时间：%d分钟前",math.floor(mem.lastLogin / 60))
			else
				str = string.format("最后上线时间：1分钟前")
			end
		end
		ctrl.lastLogin:setString(str)
		if mMem.pos == GuildDefine.GUILD_LEADER then
			if mMem.id == mem.id then
				ctrl.op:setVisible(false)
			else
				ctrl.op:setVisible(true)
				ctrl.op.mem = mem
				ctrl.op:removeEventListener(Event.Click,onMemOperate)
				ctrl.op:addEventListener(Event.Click,onMemOperate,self)
			end
			ctrl.quit:setVisible(false)
		else
			if mMem.id == mem.id then
				ctrl.quit:setVisible(true)
				ctrl.quit:removeEventListener(Event.Click,onMemQuit)
				ctrl.quit:addEventListener(Event.Click,onMemQuit,self)
			else
				ctrl.quit:setVisible(false)
			end
			ctrl.op:setVisible(false)
		end
	end
end

function onAcceptApply(id,event,target)
	Network.sendMsg(PacketID.CG_GUILD_ACCEPT,id,GuildDefine.GUILD_ACCEPT.kAgree)
end

function onRejectApply(id,event,target)
	Network.sendMsg(PacketID.CG_GUILD_ACCEPT,id,GuildDefine.GUILD_ACCEPT.kReject)
end

function refreshApplyInfo(self,applyList)
	Dot.check(self.region.region2,"guildApplyCheck")
	self.member:setVisible(false)
	self.apply:setVisible(true)
	local rows = #applyList
	local list = self.apply
	list:removeAllItem()
	list:setItemNum(rows)
	list.levelrankbg:setVisible(false)
	for i = 1,rows do
		local mem = applyList[i]
		local ctrl = list:getItemByNum(i)
		ctrl.memName:setString(mem.name)
		local txtlv = cc.LabelAtlas:_create("0123456789", "res/common/HeroLv.png", 18, 28, string.byte('0'))
		txtlv:setString(tostring(mem.lv))
		txtlv:setAnchorPoint(0,0)
		--txtlv:setPositionX(ctrl.lvbg:getContentSize().width)
		txtlv:setPositionY(-5)
		--ctrl.lvbg._ccnode:addChild(txtlv)
		ctrl.lv:setString("lv."..mem.lv)
		if not ctrl.headBG._icon then
			CommonGrid.bind(ctrl.headBG)
		end
		ctrl.headBG:setBodyIcon(mem.icon)
		ctrl.accept:removeEventListener(Event.Click,onAcceptApply)
		ctrl.accept:addEventListener(Event.Click,onAcceptApply,mem.id)
		ctrl.reject:removeEventListener(Event.Click,onRejectApply)
		ctrl.reject:addEventListener(Event.Click,onRejectApply,mem.id)
	end
end
