module(..., package.seeall)
setmetatable(_M, {__index = Control})
local GuildDefine = require("src/modules/guild/GuildDefine")
local GuildData = require("src/modules/guild/GuildData")
local GuildConstConfig = require("src/config/GuildConstConfig").Config
local GuildView = {
		[1] = "join",	
		[2] = "create",	
		[3] = "search",	
	}

function new()
	local ctrl = Control.new(require("res/guild/GuildSkin"),{"res/guild/Guild.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function init(self)
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	self.back:addEventListener(Event.Click,onClose,self)

	self:initCreateView()
	self:initSearchView()
	self:initResultView()
	self.join.levelrank:setBgVisiable(false)
	function onSelectOption(self,event,target)
		if target.regionId == 1 then
			Network.sendMsg(PacketID.CG_GUILD_QUERY)
		end
		self:setViewVisible(GuildView[target.regionId])
	end
	for i = 1,3 do
		self.selectregion["region"..i]:addEventListener(Event.Click,onSelectOption,self)
		self.selectregion['region'..i].regionId = i
	end
	Network.sendMsg(PacketID.CG_GUILD_QUERY)
	self:setViewVisible("join")
	self.selectregion['region1']:setSelected(true)
end

function initCreateView(self)
	self.create.txttsy:setString("创建公会")
	self.create.txttsy:setVisible(false)
	local cost = GuildConstConfig[1].cost
	self.create.txtmz:setString(cost)
	self.create.editBox = Common.createEditBox(self.create.tipLabel)
	self.create.editBox:setPlaceHolder("请输入公会名")
	self.create.editBox:setMaxLength(32)
	self.create._ccnode:addChild(self.create.editBox)
	self.create.tipLabel:setVisible(false)
	CommonGrid.setCoinIcon(self.create.ybbicon,"rmb")
	function onCreateGuild(self,event,target)
		local content = self.create.editBox:getText()
		if content == "" then
			Common.showMsg(string.format("请输入公会名"))
		else
			Network.sendMsg(PacketID.CG_GUILD_CREATE,content)
		end
	end
	self.create.createbtn:addEventListener(Event.Click,onCreateGuild,self)
end

function initSearchView(self)
	self.search.txtmz:setString("搜索公会")
	self.search.txtmz:setVisible(false)
	self.search.editBox = Common.createEditBox(self.search.tipLabel)
	self.search.editBox:setPlaceHolder("请输入公会ID")
	self.search.editBox:setMaxLength(32)
	self.search._ccnode:addChild(self.search.editBox)
	self.search.tipLabel:setVisible(false)
	self.search.ybbicon:setVisible(false)
	self.search.txttsy:setVisible(false)
	function onSearchGuild(self,event,target)
		local id = tonumber(self.search.editBox:getText())
		if id then
			Network.sendMsg(PacketID.CG_GUILD_SEARCH,id)
		else
			Common.showMsg(string.format("请输入公会id"))
		end
	end
	self.search.searchbtn:addEventListener(Event.Click,onSearchGuild,self)
end

function initResultView(self)
	local function onReSearchGuild(self,event,target)
		self:setViewVisible("search")
	end
	self.result.reSearch:addEventListener(Event.Click,onReSearchGuild,self)
end

function onApplyGuildJoin(self,event,target)
	local guildlist = GuildData.getGuildJoin()
	local guild = guildlist[target.id]
	if guild then
		Network.sendMsg(PacketID.CG_GUILD_APPLY,guild.id)
	end
end

function onApplyGuildJoinCancel(self,event,target)
	local guildlist = GuildData.getGuildJoin()
	local guild = guildlist[target.id]
	if guild then
		Network.sendMsg(PacketID.CG_GUILD_APPLY_CANCEL,guild.id)
	end
end
function onApplyGuildJoinSearchCancel(self,event,target)
	Network.sendMsg(PacketID.CG_GUILD_APPLY_CANCEL,target.id)
end

function onApplyGuildSearch(self,event,target)
	local guild= GuildData.getGuildSearch()
	if guild then
		Network.sendMsg(PacketID.CG_GUILD_APPLY,guild.id)
	end
end

function refreshJoinView(self)
	if self.selectregion['region1']:getSelected() ~= true then
		return
	end
	local guildlist = GuildData.getGuildJoin()
	local rows = #guildlist
	local list = self.join.levelrank
	list:removeAllItem()
	list:setItemNum(rows)
	for i = 1,rows do
		local guild = guildlist[i]
		local ctrl = list:getItemByNum(i)
		ctrl.guildName:setString(guild.name)
		local strtb = Common.utf2tb(guild.announce)
		local announce = ""
		for i = 1,#strtb do
			announce = announce..strtb[i]
			if i > 10 then
				announce = announce.."..."
				break
			end
		end
		ctrl.announce:setString(announce)
		ctrl.level:setString("Lv"..tostring(guild.lv))
		ctrl.txtnum:setString(guild.num)
		ctrl.applyJoin.id = i
		ctrl.applying.id = i
		CommonGrid.bind(ctrl.headBG)
		ctrl.headBG:setBodyIcon(guild.icon)
		if not ctrl.applyJoin:hasEventListener(Event.Click,onApplyGuildJoin) then
			ctrl.applyJoin:addEventListener(Event.Click,onApplyGuildJoin,self)
		end
		if not ctrl.applying:hasEventListener(Event.Click,onApplyGuildJoinCancel) then
			ctrl.applying:addEventListener(Event.Click,onApplyGuildJoinCancel,self)
		end
		if guild.apply == GuildDefine.GUILD_APPLYING then
			ctrl.applying:setVisible(true)
			ctrl.applyJoin:setVisible(false)
		else
			ctrl.applying:setVisible(false)
			ctrl.applyJoin:setVisible(true)
		end
	end
end

function refreshSearchView(self)
	if self.selectregion['region3']:getSelected() ~= true then
		return
	end
	self:setViewVisible("result")
	local guild = GuildData.getGuildSearch()
	local info = self.result.guildInfo
	if guild then
		self.result.txttsy:setVisible(false)
		info:setVisible(true)
		info.guildName:setString(guild.name)
		local strtb = Common.utf2tb(guild.announce)
		local announce = ""
		for i = 1,#strtb do
			announce = announce..strtb[i]
			if i > 10 then
				announce = announce.."..."
				break
			end
		end
		info.announce:setString(announce)
		info.level:setString("Lv"..guild.lv)
		info.txtnum:setString(guild.num)
		CommonGrid.bind(info.headBG)
		info.headBG:setBodyIcon(guild.icon)
		if guild.apply == GuildDefine.GUILD_APPLYING then
			info.applying:setVisible(true)
			info.applyJoin:setVisible(false)
		else
			info.applyJoin:setVisible(true)
			info.applying:setVisible(false)
		end
		if not info.applyJoin:hasEventListener(Event.Click,onApplyGuildSearch) then
			info.applyJoin:addEventListener(Event.Click,onApplyGuildSearch)
		end
		info.applying.id = guild.id
		if not info.applying:hasEventListener(Event.Click,onApplyGuildJoinSearchCancel) then
			info.applying:addEventListener(Event.Click,onApplyGuildJoinSearchCancel,self)
		end
	else
		self.result.txttsy:setVisible(true)
		info:setVisible(false)
	end
end

function setViewVisible(self,view)
	self.result:setVisible(false)
	self.search:setVisible(false)
	self.create:setVisible(false)
	self.join:setVisible(false)
	if view and self[view] then
		self[view]:setVisible(true)
	end
end

function refreshGuildApplyState(self,guildId,name)
	if self.selectregion['region1']:getSelected() ~= true then
		return
	end
	local guildlist = GuildData.getGuildJoin()
	local pos = table.foreachi(guildlist, function(k, v) if v.id == guildId then return k end end)
	if pos then
		local ctrl = self.join.levelrank:getItemByNum(math.ceil(pos))
		ctrl.applying:setVisible(false)
		ctrl.applyJoin:setVisible(false)
		if name then
			ctrl[name]:setVisible(true)
		else
			ctrl.applying:setVisible(true)
		end
	end
end
