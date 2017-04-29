module(..., package.seeall)
setmetatable(_M, {__index = Control})
local Hero = require("src/modules/hero/Hero")
local Data = require("src/modules/crazy/Data")
local CrazyDefine = require("src/config/CrazyDefineConfig").Defined
local MonsterConfig = require("src/config/MonsterConfig").Config
local Define = require("src/modules/crazy/Define")
local Def = require("src/modules/hero/HeroDefine")

Instance = nil 
function new()
	local ctrl = Control.new(require("res/crazy/CrazySkin"),{"res/crazy/Crazy.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function clear(self)
	Instance = nil
	Control.clear(self)
end

function init(self)
	self.back:addEventListener(Event.TouchEvent,onClose,self)
	self.shuoming:addEventListener(Event.TouchEvent,onRule,self)
	self.otherRankBtn:addEventListener(Event.Click, onClickOtherRank, self)

	self.openCon.fight:addEventListener(Event.Click,onFight,self)
	self:updateInfo()
	self:openTimer()
	self:addEventListener(Event.Frame,onFrame,self)

	Network.sendMsg(PacketID.CG_CRAZY_QUERY)
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function onFrame(self,event)
	self:updateCD()
end

function onClose(self,event)
	if event.etype == Event.Touch_ended then
		UIManager.removeUI(self)
	end
end

function onRule(self,event)
	if event.etype == Event.Touch_ended then
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleScrollUI.Crazy)
	end
end

function onClickOtherRank(self, evt)
	UIManager.addChildUI("src/modules/crazy/ui/CrazyRankUI")
end

function updateCD(self)
	local leftTime = Common.getCronEventLeftTime(CrazyDefine.startTimeId)
	self.closeCon.countDownTxt:setString(string.format("%02d:%02d:%02d",math.floor(leftTime/3600),math.floor(leftTime%3600/60),leftTime%60))
	
	local openTime = Common.getCronEventHMStr(CrazyDefine.startTimeId)
	self.closeCon.txtkqsj:setString(openTime)
end

function updateInfo(self)
	local data = Data.getData()
	if Data.isOpen() then
		self.closeCon:setVisible(false)
		self.openCon:setVisible(true)
	else
		self.closeCon:setVisible(true)
		self.openCon:setVisible(false)
	end

	local boss = data.boss
	self.openCon.txtbossname:setString("")
	local hasBossName = false
	for k = 1,Define.MaxBoss do
		if (boss[k] and boss[k].isDie) then
			self.hero["crazyhero" .. k]:shader(Shader.SHADER_TYPE_GRAY)
		else
			self.hero["crazyhero" .. k]:shader()
			if not hasBossName then
				self.openCon.txtbossname:setString(Def.DefineConfig[MonsterConfig[CrazyDefine.monsters[k]].name].cname)
				hasBossName = true
			end
		end
	end

	self.myCon.myHurtTxt:setString(data.harm)

	if #data.rank > 0 then
		self.noRankTipTxt:setVisible(false)
		self.rankCon:setVisible(true)
		for k = 1,3 do
			local ctrl = self.rankCon["rank" .. k]
			if data.rank[k] then
				ctrl:setVisible(true)
				ctrl.nameTxt:setString(data.rank[k].name)
			else
				ctrl:setVisible(false)
			end
		end
	else
		self.noRankTipTxt:setVisible(true)
		self.rankCon:setVisible(false)
	end
end

function onFight(self,event)
	if not Data.isOpen() then
		Common.showMsg("活动已结束")
		return
	end
	local index = Data.getBossIndex()
	if index == -1 then
		Common.showMsg("你已经完成挑战，请下次再来!")
		return
	end
	UIManager.addUI("src/modules/crazy/ui/CrazyFightUI")
end
