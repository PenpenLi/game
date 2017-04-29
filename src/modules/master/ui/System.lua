module(..., package.seeall)
setmetatable(_M, {__index = Control}) 

local MasterDefine = require("src/modules/master/MasterDefine")
local SensitiveFilter = require("src/modules/public/SensitiveFilter")
local Announce = require("src/modules/announce/Announce")

local PushConfig = require("src/config/PushConfig").Config
local PushLogic = require("src/modules/push/Logic")
local Name2Id = {}
for k,v in pairs(PushConfig) do
	Name2Id[v.btn] = Name2Id[v.btn] or {}
	Name2Id[v.btn][#Name2Id[v.btn]+1] = v.id
end

function new()
    local ctrl = Control.new(require("res/master/SystemSkin"),{"res/master/System.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function uiEffect(self)
	return UIManager.THIRD_TEMP
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

local btnMap = {"music","sound","fphy","phy","shop","boss"}
function init(self)
	_M.touch = Common.outSideTouch
	--self.close:addEventListener(Event.Click,function() UIManager.removeUI(self) end,self)
	self.close:setVisible(false)
	self.master = Master.getInstance()
	local pushSettings = self.master:getPushSettings()
	Common.printR(self.master.settings.pushSettings)
	for _,btnName in pairs(btnMap) do
		local btn = self[btnName][btnName]
		btn:adjustTouchBox(20)
		btn.onTouchEvent = self.onTouchBtn
		btn.name = btnName
		btn:addEventListener(Event.Click,onSelectBtn,self)
		local pushIds = Name2Id[btnName]
		btn.pushIds = pushIds
		if pushIds then
			for _,pushId in pairs(pushIds) do
				local isOpen = self.master:getPushSettingById(pushId)
				local state = isOpen and "normal" or "down"
				btn:setState(state)
			end
		end
	end
	local state = self.master:isMusicON() and "normal" or "down"
	self.music.music:setState(state)
	state = self.master:isEffectON() and "normal" or "down"
	self.sound.sound:setState(state)
end

function onTouchBtn(btn,event)
	print("bt onTouchEvent ".. event.etype)
	if btn._image._state == "disable" then 
		return
	end
	if event.etype == Event.Touch_ended then
		if btn.name == 'fphy' then
			Common.showMsg("暂时无效")
			return 
		end
		local state = btn._image._state
		if state == "down" then
			btn:setState("normal")
			btn.isOpen = true
		else
			btn:setState("down")
			btn.isOpen = false
		end
	end
end

function onSelectBtn(self,event,target)
	local isOpen = target.isOpen
	if target.name == "music" then
		self.master:setMusicOn(isOpen)
	elseif target.name == "sound" then
		self.master:setEffectOn(isOpen)
	else
		--push setting
		local pushIds = target.pushIds 
		if pushIds then
			for _,pushId in pairs(pushIds) do
				self.master:setPushSetting(pushId,isOpen)
			end
		end
	end
end

function updateSettings(self)
	local music = self.master:isMusicON() and 1 or 0
	local effect = self.master:isEffectON() and 1 or 0
	local pushSettings = self.master:getPushSettings()
	local ps = {}
	for id,isOpen in pairs(pushSettings) do
		ps[#ps+1] = {id=id,isOpen = isOpen and 1 or 0}
	end
	print("sendMsg")
	Network.sendMsg(PacketID.CG_SETTINGS,music,effect,ps)
	print("addLocalPush")
	PushLogic.addLocalPush()
end

function clear(self)
	Control.clear(self)
	self:updateSettings()
end





