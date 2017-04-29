module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local BaseMath = require("src/modules/public/BaseMath")
local MasterDefine = require("src/modules/master/MasterDefine")
local GuildData = require("src/modules/guild/GuildData")
local GuildDefine = require("src/modules/guild/GuildDefine")
local SensitiveFilter = require("src/modules/public/SensitiveFilter")
local PublicLogic = require("src/modules/public/PublicLogic")
local BodyConfig = require("src/config/BodyConfig").Config
local Hero = require("src/modules/hero/Hero")

function new()
    local ctrl = Control.new(require("res/master/SettingSkin"),{"res/master/Setting.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect(self)
	--return UIManager.SECOND_TEMP
	return UIManager.THIRD_TEMP
end

function addStage(self)
	--self:setPositionY(Stage.uiBottom)
end

function init(self)
	self.master = Master.getInstance()

	self.exchange:setVisible(false)
	self.chkName:setVisible(false)
	self.chkBody:setVisible(false)

	local setMain = function()
		--self.main.exchange:setVisible(false)
		--self.main.announce:setVisible(false)
		--self.main.herotujian:setVisible(false)
		self.main.close:addEventListener(Event.Click,function() UIManager.removeUI(self) end,self)
		self.main.chkName:addEventListener(Event.Click,function() self:showChkName() end,self)
		self.main.chkBody:addEventListener(Event.Click,function() self:showChkBody() end,self)
		self.main.setting:addEventListener(Event.Click,function() 
			UIManager.addChildUI("src/modules/master/ui/System")
		end,self)
		self.main.announce:addEventListener(Event.Click,function() 
			UIManager.addUI("src/modules/announce/ui/AnnounceUI",require("src/modules/announce/Announce").getLoginAnnounce())
		end,self)
		self.main.exchange:addEventListener(Event.Click,function() self.exchange:setVisible(true) end,self)
		self.main.herotujian:addEventListener(Event.Click,function() Common.showMsg("功能暂未开放") end,self)
	end
	--改名
	local setChkName = function()
		--self.chkName.close:addEventListener(Event.Click,function() self.chkName:setVisible(false) end,self)
		self.chkName.cancel:addEventListener(Event.Click,function() 
			self.chkName.tipLabel:setString("")
			self.chkName:setVisible(false) 
		end,self)
		self.chkName.confirm:addEventListener(Event.Click,onChangeName,self)
		self.chkName.dice:addEventListener(Event.Click,onDice,self)
		self.editBox = Common.createEditBox(self.chkName.nameLabel,function(eventType) 
			if eventType == "began" then
				self.chkName.tipLabel:setVisible(false)
			end
		end)
		self.editBox:setMaxLength(MasterDefine.MAX_NAME)
		self.chkName.nameLabel:setVisible(false)
		self.chkName.tipLabel:setVisible(false)
		Common.setLabelCenter(self.chkName.tipLabel)
		self.chkName._ccnode:addChild(self.editBox)
	end
	--改头像
	local setChkBody = function()
		--self.chkBody.close:addEventListener(Event.Click,function() self.chkBody:setVisible(false) end,self)
		self.chkBody.close:setVisible(false)
		self:createBodyList()
	end
	--帮会信息
	local setGuildInfo = function()
		self.main.quitGuild:addEventListener(Event.Click,function() 
						local tips = TipsUI.showTips("确定退出公会?")
						tips:addEventListener(Event.Confirm,function(self,event) 
							if event.etype == Event.Confirm_yes then
								Network.sendMsg(PacketID.CG_GUILD_QUIT)
							end
						end)
					end,self)
		self.main.joinGuild:addEventListener(Event.Click,function() 
						if PublicLogic.checkModuleOpen("guild") then
							UIManager.replaceUI("src/modules/guild/ui/GuildUI")
						end
					end,self)
		self.main.destroyGuild:addEventListener(Event.Click,function() 
						local tips = TipsUI.showTips("确定解散公会?")
						tips:addEventListener(Event.Confirm,function(self,event) 
							if event.etype == Event.Confirm_yes then
								Network.sendMsg(PacketID.CG_GUILD_DESTROY)
							end
						end)
					end,self)
		self:setGuildOpVisible()
	end
	--兑换礼品
	local setExchange = function()
		self.exchangeEditBox = Common.createEditBox(self.exchange.codeLabel,function(eventType) 
    		if eventType == "began" then
				self.exchangeEditBox:setText(self.exchangeCode)
			elseif eventType == "ended" then
				self.exchangeCode = self.exchangeEditBox:getText()
			end
		end)
		self.exchange.confirm:addEventListener(Event.Click,function() 
			local code = self.exchangeEditBox:getText()
			if code:len() > 0 then
				WaittingUI.create(PacketID.GC_GIFT_CODE,5)
				Network.sendMsg(PacketID.CG_GIFT_CODE,code,Config.SvrId)
			end
			self.exchange:setVisible(false) 
		end,self)
		self.exchange._ccnode:addChild(self.exchangeEditBox)
		--self.chkBody.close:addEventListener(Event.Click,function() self.chkBody:setVisible(false) end,self)
	end

	setMain()
	setChkName()
	setChkBody()
	setGuildInfo()
	setExchange()
	self:syncGuildInfo()
	self:setAttr()
end

function clear(self)
	Control.clear(self)
end

function setGuildOpVisible(self,op)
	self.main.quitGuild:setVisible(false)
	self.main.joinGuild:setVisible(false)
	self.main.destroyGuild:setVisible(false)
	if op then
		self.main[op]:setVisible(true)
	end
end

function syncGuildInfo(self)
	if self.master.guildId > 0 then
		Network.sendMsg(PacketID.CG_GUILD_INFO_QUERY)
	else
		local guildName = GuildData.getGuildName()
		self.main.txtGuildName:setString(guildName)
		self:setGuildOpVisible("joinGuild")
	end
end

function refreshGuildInfo(self)
	local guildName = GuildData.getGuildName()
	self.main.txtGuildName:setString(guildName)
	if self.master.guildId > 0 then
		local guildPos = GuildData.getGuildPos()
		if guildPos == GuildDefine.GUILD_LEADER then
			self:setGuildOpVisible("destroyGuild")
		else
			self:setGuildOpVisible("quitGuild")
		end
	else
		self:setGuildOpVisible("joinGuild")
	end
end

function setAttr(self)
	if self.body then
		self.main:removeChild(self.body)
	end
	CommonGrid.bind(self.main.bodyGrid)
	self.main.bodyGrid:setBodyIcon(self.master.bodyId)
	self.main.bodyGrid._icon:setScaleX(-1)

	self.main.nameLabel:setString(self.master.name)
	self.main.lvLabel:setString(self.master.lv)
	self.main.maxLvLabel:setString(MasterDefine.MAX_LV)
	local expStr = tostring(self.master.exp)
	local nextExp = BaseMath.getHumanLvUpExp(self.master.lv + 1)
	if nextExp then
		expStr = string.format("%d/%d",self.master.exp,nextExp)
	end
	self.main.expLabel:setString(expStr)
	self.editBox:setText(self.master.name)
	self.main.flowerCnt:setString(self.master.flowerCount)
end

function onDice(self)
	local name = Common.randomRoleName()
	self.editBox:setText(name)
end

function showChkName(self)
	local block = self.chkName
	block:setVisible(true)
	self.editBox:setText(self.master.name)
end

function showChkBody(self)
	self.chkBody:setVisible(true)
	ActionUI.show(self.chkBody,"scale")
	self:getChild("actionGray"):addEventListener(Event.TouchEvent,function() 
		ActionUI.hide(self.chkBody,"scaleHide")
		self.chkBody:setVisible(false)
	end,self)
end

function onChangeName(self)
	local name = self.editBox:getText()
	self.chkName.tipLabel:setVisible(true)
	if name:len() < 1 then
		self.chkName.tipLabel:setString("昵称不能为空")
		return 
	end
	if #Common.utf2tb(name) > MasterDefine.MAX_NAME then
		self.chkName.tipLabel:setString(string.format("最多可输入%d个字符",MasterDefine.MAX_NAME))
		return 
	end
	local isSensitive = SensitiveFilter.hasSensitiveWord(name)
	if isSensitive then
		self.chkName.tipLabel:setString("名字不合法")
	else
		if name == self.master.name then
			self:onFinishRename(true)
		else
			if self.master.renameCnt == 0 then
				Network.sendMsg(PacketID.CG_RENAME,name)
			else
				local tips = TipsUI.showTips(string.format("改名需花费%d钻石,是否继续?",MasterDefine.RENAME_RMB))
				tips:addEventListener(Event.Confirm,function(self,event) 
					if event.etype == Event.Confirm_yes then
						Network.sendMsg(PacketID.CG_RENAME,name)
					end
				end)
			end
		end
	end
end

function onFinishRename(self,isSuccess,tip)
	self.chkName.tipLabel:setVisible(true)
	self.chkName.tipLabel:setString(tip)
	if isSuccess then
		self:setAttr()
		self.chkName.tipLabel:setString("")
		self.chkName:setVisible(false)
	end
end

function onFinishChkBody(self)
	ActionUI.hide(self.chkBody,"scaleHide")
	self:setAttr()
end

local kCols = 5
function createBodyList(self)
	local list = self.chkBody.body
	local rows = math.ceil(#BodyConfig / kCols)
	list:setItemNum(rows)
	local col = 1
	local row = 1
	for _,v  in ipairs(BodyConfig) do
		local item = list:getItemByNum(row)
		local target = item["grid" .. col]
		CommonGrid.bind(target)
		target:setBodyIcon(v.id)
		target._icon:setScaleX(-1)
		target._icon:setPositionY(target._icon:getPositionY()+5)
		target.bodyId = v.id
		target.name = v.hero
		target:addEventListener(Event.TouchEvent,onSelectBody,self)
		if col == kCols then
			col = 0
			row = row + 1
		end
		col = col + 1
		if Hero.getHero(v.hero) then
			target.isOpen = true
			target.lock:setVisible(false)
		else
			target.lock:setTop()
			target:shader(Shader.SHADER_TYPE_GRAY)
		end
	end
	local item = list:getItemByNum(row)
	for i=col,kCols do
		local target = item["grid" .. i]
		target:setVisible(false)
	end
end

function onSelectBody(self,event,target)
	if event.etype == Event.Touch_ended then
		if target.isOpen then
			local bodyId = target.bodyId
			Network.sendMsg(PacketID.CG_CHANGE_BODY,bodyId)
		else
			Common.showMsg(string.format("获得%s才能激活该头像哦",Hero.getCNameByName(target.name) or ""))
		end
	end
end








