module(..., package.seeall)
setmetatable(_M, {__index = Control})

local NetWork = require("src/core/net/Network")
local Common = require("src/core/utils/Common")
local worldBossData = require("src/modules/worldBoss/WorldBossData").getInstance()
local RankUI = require("src/modules/worldBoss/ui/WorldBossRankUI")
local Define = require("src/modules/worldBoss/WorldBossDefine")

function new()
	local ctrl = Control.new(require("res/worldBoss/WorldBossSkin"), {"res/worldBoss/WorldBoss.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end

function init(self)
	self.startTime = 0
	self.openBossTimer = nil
	self.closeBossTimer = nil
	self.openCon:setVisible(false)
	self.rankCon:setVisible(false)
	self:refreshClose()
	self.closeCon.countDownTxt:setPositionY(self.closeCon.countDownTxt:getPositionY() - 3)
	self:addDescTxt()
	self:addBg()
	self:addListener()
end

function addDescTxt(self)
	--self.descTxt = RichText.new(RichText.UI_RICH_TEXT_DEFAULT_SKIN)
	--self.descTxt:setVerticalSpace(6)
	--self.descTxt:setContentSize(cc.size(300, 0))
	--self.descTxt:setPosition(self.txttz1:getPosition())
	--self:addChild(self.descTxt)
	--self.descTxt:setString("<p size='18'><font color='255,255,255'>挑战</font><font color='78,217,229'>大蛇</font><font color='255,247,184'>可获得大量声望和碎片</font></p>。<p size='18'><font color='255,255,255'>伤害</font><font color='154,187,52'>前三名以及击杀者</font><font color='255,255,255'>获得碎片。</font></p><p size='18'><font color='255,255,255'>其他排名玩家有几率获得碎片。</font></p>")
end

function addBg(self)
	local spr = cc.Sprite:create('res/worldBoss/worldBossBg.png')
	spr:setPosition(cc.p(self._skin.width/2, self._skin.height/2))
	spr:setLocalZOrder(-1)
	self._ccnode:addChild(spr)
end

function addListener(self)
	local function onRule(self,evt)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleScrollUI.WorldBoss)
	end
	self.shuoming:addEventListener(Event.Click,onRule,self)
	self.back:addEventListener(Event.Click, onClose, self)
	self.openCon.challangeBtn:addEventListener(Event.Click, onChallange, self)
	self.otherRankBtn:addEventListener(Event.Click, onClickOtherRank, self)
end

function onClose(self, evt)
	UIManager.removeUI(self)
end

function onChallange(self, evt)
	if self.startTime == 0 then
		return
	end
	UIManager.addUI("src/modules/worldBoss/ui/WorldBossFightUI")
end

function onClickOtherRank(self, evt)
	UIManager.addChildUI("src/modules/worldBoss/ui/WorldBossRankUI")
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
	self:adjustTouchBox(0,Stage.uiBottom,0,2*Stage.uiBottom)
	self.openCon.coolTimeTxt:setString("00:00:00")
	self.closeCon.countDownTxt:setString("00:00:00")

	--定时刷新排行
	self:openTimer()
	
	Network.sendMsg(PacketID.CG_WORLD_BOSS_QUERY)
	Network.sendMsg(PacketID.CG_WORLD_BOSS_RANK)
end

function refreshOpen(self)
	self.closeCon:setVisible(false)
	self.openCon:setVisible(true)
	self.myCon:setVisible(true)
	self.myCon.myHurtTxt:setString(worldBossData:getMyHurt())
	self.myCon.reputationTxt:setString(worldBossData:getReputationByHurt(worldBossData:getMyHurt()))

	self:removeTimer()
	self.startTime = os.time()
	self.openBossTimer = self:addTimer(onRefreshOpen, 1, -1, self)

	self:refreshCoolTime()
end

function onRefreshOpen(self, evt)
	--self:sendRankMsg()
	self:refreshCoolTime()
end

function sendRankMsg(self)
	if (os.time() - self.startTime) % Define.BOSS_RANK_SORT_TIME == 0 then
		Network.sendMsg(PacketID.CG_WORLD_BOSS_RANK)
	end
end

function refreshCoolTime(self)
	if self.openCon:isVisible() == true then
		local leftTime = worldBossData:getCoolTime() - (os.time() - self.startTime)
		if leftTime > 0 then
			self.openCon.coolTimeTxt:setString(Common.getDCTime(leftTime))
			self.openCon.coolTimeTxt:setVisible(true)
			self.openCon.txttz:setVisible(true)
			self.openCon.challangeBtn:setState(Button.UI_BUTTON_DISABLE, false, true)
			self.openCon.challangeBtn:setEnabled(false)
		else
			worldBossData:setCoolTime(0)
			self.openCon.txttz:setVisible(false)
			self.openCon.coolTimeTxt:setString("00:00:00")
			self.openCon.coolTimeTxt:setVisible(false)
			self.openCon.challangeBtn:setState(Button.UI_BUTTON_NORMAL, false, true)
			self.openCon.challangeBtn:setEnabled(true)
		end	
	end
end

function refreshRank(self)
	local dataList = worldBossData:getRankList()
	--前3
	for i=1,3 do
		if #dataList == 0 then
			self.rankCon:setVisible(false)
			self.noRankTipTxt:setVisible(true)
		else
			self.rankCon:setVisible(true)
			self.noRankTipTxt:setVisible(false)
			local data = dataList[i]
			local isShow = false
			if data ~= nil then
				isShow = true
				self.rankCon["rank" .. i].nameTxt:setString(data.name)
				--self.rankCon["hurtTxt" .. i]:setString(data.hurt)
			end
			self.rankCon["rank" .. i]:setVisible(isShow)
		end
	end
end

function refreshClose(self)
	self.openCon:setVisible(false)
	self.closeCon:setVisible(true)
	self.myCon:setVisible(false)

	self:removeTimer()
	self.startTime = os.time()
	self.closeBossTimer = self:addTimer(onRefreshClose, 1, -1, self)
	self:onRefreshClose()
end

function onRefreshClose(self)
	if self.closeCon:isVisible() == true then
		local leftTime = worldBossData:getCountDownTime() - (os.time() - self.startTime)
		if leftTime > 0 then
			self.closeCon.countDownTxt:setString(Common.getDCTime(leftTime))
		else
			self:removeTimer()
			worldBossData:setCountDownTime(0)
			self:refreshOpen()
		end
	end
end

function removeTimer(self)
	if self.openBossTimer ~= nil then
		self:delTimer(self.openBossTimer)
		self.openBossTimer = nil
	end
	if self.closeBossTimer ~= nil then
		self:delTimer(self.closeBossTimer)
		self.closeBossTimer = nil
	end
end

function clear(self)
	--self:removeTimer()

	Control.clear(self)
end
