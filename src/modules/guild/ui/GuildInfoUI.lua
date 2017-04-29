module(..., package.seeall)
setmetatable(_M, {__index = Control})
local GuildDefine = require("src/modules/guild/GuildDefine")
local GuildLvConfig = require("src/config/GuildLvConfig").Config
local GuildData = require("src/modules/guild/GuildData")

local ANNOUNCE_LEN = 30

function new()
	local ctrl = Control.new(require("res/guild/GuildInfoSkin"),{"res/guild/GuildInfo.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function addStage(self)
end

function init(self)
	self:initGuildInfo()
	self:initAnnounce()
	Network.sendMsg(PacketID.CG_GUILD_INFO_QUERY)
end

function initGuildInfo(self)
	local function onClose(self,event,target)
		UIManager.removeUI(self)	
	end
	self.guildInfo.close:addEventListener(Event.Click,onClose,self)
	local function onModifyAnnounce(self,event,target)
		local pos = GuildData.getGuildPos()
		if pos ~= GuildDefine.GUILD_LEADER and
			pos ~= GuildDefine.GUILD_SENIOR  then
			Common.showMsg(GuildDefine.NO_AUTH_TIPS)
			return 
		end
		--self.announce:setVisible(true)
		ActionUI.show(self.announce,"scale")
	end
	local function onShowMemList(self,event,target)
		UIManager.addUI("src/modules/guild/ui/MemberListUI",GuildDefine.MEMBER_TAG)
	end
	local function onShowApplyList(self,event,target)
		UIManager.addUI("src/modules/guild/ui/MemberListUI",GuildDefine.APPLY_TAG)
	end
	self.guildInfo.announce:addEventListener(Event.Click,onModifyAnnounce,self)
	self.guildInfo.applyList:addEventListener(Event.Click,onShowApplyList,self)
	self.guildInfo.applyList:setVisible(false)
	self.guildInfo.memList:addEventListener(Event.Click,onShowMemList,self)
	self.guildInfo.info:setVisible(false)
	self.guildInfo.txtannounce:setDimensions(self.guildInfo.txtannounce:getContentSize().width,0)
	self.guildInfo.txtannounce:setAnchorPoint(0,1)
	self.guildInfo.txtannounce:setVisible(false)
	self.guildInfo.expprog:setPercent(0)
	CommonGrid.bind(self.guildInfo.headBG)
end

function initAnnounce(self)
	local function onClose(self,event,target)
		--self.announce:setVisible(false)
		ActionUI.hide(self.announce,"scaleHide")
	end
	self.announce.close:addEventListener(Event.Click,onClose,self)
	function onEditcontent(eType) 
		if eType == "return" then
			local strTb = Common.utf2tb(self.announce.editBox:getText())
			local strlen = #strTb > ANNOUNCE_LEN and ANNOUNCE_LEN or #strTb
			local str = ""
			for i = 1,strlen do
				str = str .. strTb[i]
			end
			--self.announce.content:setString(str)
			--self.announce.content:setVisible(true)
			self.announce.editBox:setText(str)
			self.announce.contentlen:setString(strlen.."/"..ANNOUNCE_LEN)
		end
	end

	self.announce.editBox = createEditBox(self.announce.content,onEditcontent)
	self.announce.editBox:setMaxLength(150)
	self.announce._ccnode:addChild(self.announce.editBox)

	self.announce.content:setDimensions(self.announce.content:getContentSize().width,0)
	self.announce.content:setVerticalAlignment(Label.Alignment.Top)
	--self.announce.content:setAnchorPoint(0,1)
	self.announce.content:setString("")
	self.announce.content:setVisible(false)
	self.announce.content:setPositionY(self.announce.content:getPositionY()+self.announce.content:getContentSize().height)

	local function onConfirm(self,event,target)
		--local content = self.announce.content:getString()
		local content = self.announce.editBox:getText()
		Network.sendMsg(PacketID.CG_GUILD_MOD_ANNOUNCE,content)
		--self.announce:setVisible(false)
		ActionUI.hide(self.announce,"scaleHide")
		--self.guildInfo.txtannounce:setString(content)
	end
	self.announce.confirm:addEventListener(Event.Click,onConfirm,self)
	self.announce:setVisible(false)
end

function createEditBox(editLabel,callback)
	editLabel:setVisible(false)
	local sprite9 = cc.Scale9Sprite:create("res/common/non.png")
	local size = editLabel:getContentSize()
	size = {width=size.width,height=size.height * 1.8}
	local editBox = cc.EditBox:create(size,sprite9)
	editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DEFAULT)
	editBox:setAnchorPoint(0,0.5)
	editBox:setPosition(editLabel:getPosition())
	local size = editLabel:getContentSize()
	editBox:setPositionY(editLabel:getPositionY() + size.height/2)

	local function onStartEditor(eventType)
		if eventType == "began" then
			editBox:setText("")
		end
		if callback then callback(eventType) end
	end
	editBox:registerScriptEditBoxHandler(onStartEditor)
	editBox:setMaxLength(50)
	return editBox
end


function refreshInfo(self,id,name,lv,icon,announce,num,active)
	local info = self.guildInfo.info
	info:setVisible(true)
	info.guildId.txtid:setString(id)
	info.guildName.txtname:setString(name)
	info.txtlv:setString(lv)
	local cfg = GuildLvConfig[lv]
	info.memNum.txtNum:setString(num.."/"..cfg.memCount)
	self.guildInfo.txtannounce:setVisible(true)
	self.guildInfo.txtannounce:setString(announce == "" and "公会宣言空空如也，赶紧发布吧" or announce)

	info.txthyd:setString("（活跃度"..active.."/"..cfg.activeness.."）")
	self.guildInfo.expprog:setPercent(active/cfg.activeness * 100)
	self.guildInfo.headBG:setBodyIcon(icon)
	local pos = GuildData.getGuildPos()
	if pos ~= GuildDefine.GUILD_LEADER and
		pos ~= GuildDefine.GUILD_SENIOR  then
		self.guildInfo.applyList:setVisible(false)
	else
		self.guildInfo.applyList:setVisible(true)
		Dot.check(self.guildInfo.applyList,"guildApplyCheck")
	end
end

function refreshAnnounce(self,content)
	self.guildInfo.txtannounce:setString(content)
end
