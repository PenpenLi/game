module(..., package.seeall)
setmetatable(_M, {__index = Control})
local GuildDefine = require("src/modules/guild/GuildDefine")
local KickConstConfig = require("src/config/KickConstConfig").Config
local KickDefine = require("src/modules/guild/kick/KickDefine")
local KickData = require("src/modules/guild/kick/KickData")

function new()
	local ctrl = Control.new(require("res/guild/GuildKickSkin"),{"res/guild/GuildKick.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function addBg(self)
	local bg = Sprite.new('KickScene','res/guild/Kickbg.jpg')
	bg.touchEnabled = false
	self.bg = bg
	self:addChild(bg,-1)
	bg:setPositionY(-Stage.uiBottom)
end

function init(self)
	local function onCloseGuildMember(self,event,target)
		--self.guildMember:setVisible(false)
		ActionUI.hide(self.guildMember,"scaleHide")
	end
	local function onCloseRecord(self,event,target)
		--self.recordPanel:setVisible(false)
		ActionUI.hide(self.recordPanel,"scaleHide")
	end
	local function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	local function onRecord(self,event,target)
		--self.recordPanel:setVisible(true)
		ActionUI.show(self.recordPanel,"scale")
		Network.sendMsg(PacketID.CG_KICK_RECORD)
		WaittingUI.create(PacketID.GC_KICK_RECORD)
	end
	local function onRule(self,event,target)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleUI.GuildKick)
	end
	self.guildMember.hdtjzi:setAnchorPoint(0.5,0)
	self:addBg()
	self.recordPanel:setVisible(false)
	self.recordPanel.titleLabel:setString("对战记录")
	self.guildMember:setVisible(false)
	self.guild:setBgVisiable(false)
	self.todaycnt:setString("")
	self:openTimer()
	self:addEventListener(Event.Frame, addRankByFrame)
	--self.guildMember.close:addEventListener(Event.Click,onCloseGuildMember,self)
	--self.recordPanel.close:addEventListener(Event.Click,onCloseRecord,self)
	self.record:addEventListener(Event.Click,onRecord,self)
	self.record:setPositionY(-Stage.uiBottom)
	self.rule:addEventListener(Event.Click,onRule,self)
	self.rule:setPositionY(-Stage.uiBottom)
	self.back:addEventListener(Event.Click,onClose,self)
	Network.sendMsg(PacketID.CG_KICK_GUILD)
	WaittingUI.create(PacketID.GC_KICK_GUILD)
	self.recordPanel.jilu.tgjlbg:setVisible(false)
	self.recordPanel.norecord:setVisible(false)
end

function onGuildMember(self,event,target)
	if event.etype == Event.Touch_ended then
		self.guildMember.hdtjzi:setString(target.guildName)
		--self.guildMember:setVisible(true)
		ActionUI.show(self.guildMember,"scale")
		Network.sendMsg(PacketID.CG_KICK_MEMBER,target.guildId)
		WaittingUI.create(PacketID.GC_KICK_MEMBER)
	end
end

function addRankByFrame(self,event)
	local frameRate = 1
	if self.sortedRank and #self.sortedRank > 0 then
		for i = 1,frameRate do
			if self.sortedRank[1] then
				local rank = self.sortedRank[1]
				table.remove(self.sortedRank,1)
				self:addRankToList(rank)
			else
				break
			end
		end
	end
end
function addRankToList(self,data)
	local list = self.recordPanel.jilu
	local no = list:addItem()
	local ctrl = list.itemContainer[no]
	local left = ctrl.left
	left.guildName:setString(data.myGuildName)
	left.charName:setString(data.charName)
	left.lv:setString("Lv."..data.myGuildLv)
	for j = 1,4 do
		if data.charFightlist[j] then
			left["hero"..j]:setVisible(true)
			local pos = data.charFightlist[j].pos
			local grid = HeroGridS.new(left["hero"..j].j,pos)
			local name = data.charFightlist[j].name
			local lv = data.charFightlist[j].lv
			local quality = data.charFightlist[j].quality
			local transferLv = data.charFightlist[j].transferLv
			grid:setHero({name = name,lv = lv,quality = quality,transferLv = transferLv})
			grid:setScale(58/92)
		else
			left["hero"..j]:setVisible(false)
		end
	end
	local right = ctrl.right
	right.guildName:setString(data.enemyGuildName)
	right.charName:setString(data.enemyName)
	right.lv:setString("Lv."..data.enemyGuildLv)
	for j = 1,4 do
		if data.enemyFightlist[j] then
			right["hero"..j]:setVisible(true)
			local pos = data.enemyFightlist[j].pos
			local grid = HeroGridS.new(right["hero"..j].j,pos)
			local name = data.enemyFightlist[j].name
			local lv = data.enemyFightlist[j].lv
			local quality = data.enemyFightlist[j].quality
			local transferLv = data.enemyFightlist[j].transferLv
			grid:setHero({name = name,lv = lv,quality = quality,transferLv = transferLv})
			grid:setScale(58/92)
		else
			right["hero"..j]:setVisible(false)
		end
	end

	if data.result == KickDefine.KICK_WIN then
		left.winzi:setVisible(true)
		right.winzi:setVisible(false)
	else
		left.winzi:setVisible(false)
		right.winzi:setVisible(true)
	end
end

function refreshInfo(self,guildData,cnt)
	local list = self.guild
	local rows = #guildData
	list:removeAllItem()
	list:setItemNum(rows)
	local daytimes = KickConstConfig[1].cnt
	self.todaycnt:setString(string.format("今日次数:%d",daytimes-cnt))
	if rows <= 0 then
		self.norecord:setVisible(true)
	else
		self.norecord:setVisible(false)
		for i = 1,rows do
			local ctrl = list:getItemByNum(i)
			local data = guildData[i]
			ctrl.txtname:setString(data.name)
			ctrl.lvnum:setString(data.lv)
			ctrl.fightval:setString("总战力:"..data.fightVal)
			ctrl.guildId = data.id
			ctrl.guildName = data.name
			setRank(ctrl,data.rank)
			if not ctrl:hasEventListener(Event.TouchEvent,onGuildMember) then
				ctrl:addEventListener(Event.TouchEvent,onGuildMember,self)
			end
		end
	end
end

function setRank(ctrl,rank)
	ctrl.pm1:setVisible(false)
	ctrl.pm2:setVisible(false)
	ctrl.pm3:setVisible(false)
	ctrl.lvnum:setVisible(false)
	if rank > 3 then
		ctrl.lvnum:setVisible(true)
		ctrl.lvnum:setString(rank)
	else
		ctrl["pm"..rank]:setVisible(true)
	end
end

function onFight(self,event,target)
	UIManager.addChildUI("src/modules/guild/kick/ui/KickFightUI",target.guildId,target.memberId)	
	--Network.sendMsg(PacketID.CG_KICK_BEGIN,target.guildId,target.memberId)
end

function refreshGuildMember(self,memberData)
	local list = self.guildMember.member
	local rows = #memberData
	list:removeAllItem()
	list:setItemNum(rows)
	for i = 1,rows do
		local ctrl = list:getItemByNum(i)
		local data = memberData[i]
		ctrl.lvzdl:setString("总战力:"..data.fightVal)
		ctrl.lvTxt:setString("等级:"..data.lv)
		ctrl.nameTxt:setString(data.name)
		CommonGrid.bind(ctrl.zd.chengjiuBG)
		ctrl.zd.chengjiuBG:setBodyIcon(data.icon,0.8)
		ctrl.fight.guildId = data.guildId
		ctrl.fight.memberId = data.memberId
		if not ctrl.fight:hasEventListener(Event.Click,onFight) then
			ctrl.fight:addEventListener(Event.Click,onFight,self)
		end
	end
end

function refreshRecord(self,recordData)
	local list = self.recordPanel.jilu
	list:removeAllItem()
	if #recordData <= 0 then
		self.recordPanel.norecord:setVisible(true)
	else
		self.recordPanel.norecord:setVisible(false)
		self.sortedRank = recordData
	end
end

function clear(self)
	KickData.enemyFightList = {}
	Control.clear(self)
end
