module(..., package.seeall)
setmetatable(_M, {__index = Control})
local GuildBossDefine = require("src/modules/guild/boss/GuildBossDefine")
local GuildBossLogic = require("src/modules/guild/boss/GuildBossLogic")

function new()
	local ctrl = Control.new(require("res/worldBoss/WorldBossSkin"), {"res/worldBoss/WorldBoss.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "GuildBossUI"
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_RAW
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function addBg(self)
	local spr = cc.Sprite:create('res/guild/GuildBossBg.png')
	spr:setPosition(cc.p(self._skin.width/2, self._skin.height/2))
	spr:setLocalZOrder(-1)
	self._ccnode:addChild(spr)
end

function init(self)
	self:addBg()
	local function onClose(self, evt)
		UIManager.removeUI(self)
	end
	local function onRule(self,evt)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleScrollUI.GuildBoss)
	end
	self.shuoming:addEventListener(Event.Click,onRule,self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.openCon.challangeBtn:addEventListener(Event.Click, onChallange, self)
	local function onClickOtherRank(self, evt)
		UIManager.addChildUI("src/modules/guild/boss/ui/GuildBossRankUI")
	end
	self.otherRankBtn:addEventListener(Event.Click, onClickOtherRank, self)
	
	self.openCon:setVisible(false)
	self.rankCon:setVisible(false)

	self:openTimer()
	self.leftTime = Common.getCronEventLeftTime(GuildBossDefine.EVENT_ID)
	self.refreshTimer = self:addTimer(onRefreshTime,1,-1,self)
	onRefreshTime(self)
	self.openCon.coolTimeTxt:setString("")
	self.openCon.txttz:setVisible(false)
	self.txttz1:setString("对八神伤害越高获得金币越多。")
	self.txttz3:setString("对八神造成最后一击额外获得钻石。")

	Network.sendMsg(PacketID.CG_GUILD_BOSS_QUERY)
	Network.sendMsg(PacketID.CG_GUILD_BOSS_RANK)
	WaittingUI.create(PacketID.GC_GUILD_BOSS_QUERY)
end

function onCdTime(self,event,target)
	self.coolTime = self.coolTime - 1
	if self.coolTime <= 0 then
		self.openCon.txttz:setVisible(false)
		self.openCon.coolTimeTxt:setString("")
		if self.cdTimer then
			self:delTimer(self.cdTimer)
			self.cdTimer = nil
		end
	else
		self.openCon.txttz:setVisible(true)
		local str = Common.getDCTime(self.coolTime)
		self.openCon.coolTimeTxt:setString(str)
	end
end

function onRefreshTime(self,event,target)
	self.leftTime = self.leftTime - 1
	if self.leftTime <= 0 then
		self.closeCon.countDownTxt:setColor(249,226,155)
		self.closeCon.countDownTxt:setString("已开启")
		if self.refreshTimer then
			self:delTimer(self.refreshTimer)
			self.refreshTime = nil
		end
	else
		self.closeCon.countDownTxt:setColor(255,0,0)
		local str = Common.getDCTime(self.leftTime)
		self.closeCon.countDownTxt:setString(str)
	end
end

function refreshInfo(self,hasStart,coolTime,hurt,heroList)
	if hasStart == 1 then
		self.openCon:setVisible(true)
		self.leftTime = 0
		onRefreshTime(self)
	end
	self.coolTime = coolTime
	if coolTime > 0 then
		self.cdTimer = self:addTimer(onCdTime,1,-1,self)
		onCdTime(self)
	end
	local str = Common.getCronEventHMStr(GuildBossDefine.EVENT_ID)
	self.closeCon.txtkqsj:setString(str)
	self.myCon.myHurtTxt:setString(hurt)
	local money = GuildBossLogic.getRewardByHurt(hurt)
	self.myCon.reputationTxt:setString(money)
	self.heroList = heroList
end

function onChallange(self, evt)
	if self.coolTime > 0 then
		Common.showMsg("进入CD中")
	else
		Network.sendMsg(PacketID.CG_GUILD_BOSS_ENTER_QUERY)
	end
end

function refreshRank(self,list)
	if #list <= 0 then
		self.rankCon:setVisible(false)
		self.noRankTipTxt:setVisible(true)
	else
		self.rankCon:setVisible(true)
		self.noRankTipTxt:setVisible(false)
		for i=1,3 do
			local data = list[i]
			if data then
				self.rankCon["rank" .. i]:setVisible(true)
				self.rankCon["rank" .. i].nameTxt:setString(data.name)
			else
				self.rankCon["rank" .. i]:setVisible(false)
			end
		end
	end
end

