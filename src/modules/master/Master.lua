module("Master",package.seeall)
setmetatable(Master, {__index = EventDispatcher}) 

local MasterDefine = require("src/modules/master/MasterDefine")

local function new()
	local master  = {
		connected = false,			--连接状态
		account = "",				--
		pAccount = "",		--渠道userId
		name = "",
		ip = "",
		port = "",
		timerList = {},
		_events = {},
		sdkInfo = "",
		authKey = "",
		lastMsg = {},
		loginCo = {},
		--default start
		settings   = {
			music = 0,
			effect = 0,
		},--设置

		--relogin
		isRelogin = false,
		stopTime = os.time(),	--掉进后台
		token = "",
		isTryRelogin = false,
		tryReLoginCounter = 0,
		connectTimer = false,
		
	}
	setmetatable(master, {__index = Master,__newindex=function(t,k,v) assert(false,"not exist key===========>" .. k) end})
	master:init()
	return master
end

local instance = nil
function getInstance()
	if instance == nil then
		instance = new()
	end
	return instance
end

-- ostime = os.time

function getServerTime()
	local master = getInstance()
	if not master.servTime or master.servTime == 0 then
		return os.time()
	end
	return master.servTime + os.time() - master.cliTime
end



function init(self)
	--require("src/modules/push/Logic").init(self)
end

function release(self)
	self:stopTimer()
	self:disconnect()
	instance = nil
end

function addTimer(self,timer)
	self.timerList[#self.timerList+1] = timer 
end

function stopTimer(self)
	for _,timer in pairs(self.timerList) do
		Stage.delTimer(timer)
	end
end

function setPAccount(self,pAccount)
	self.pAccount = pAccount
end
function setAccount(self,account)
	self.account = account
end

--主动断开
function disconnect(self)
	Network.disconnect()
	self.connected = false
end


--被动断开
function onDisconnect(self,reason)
	print("onDisconnect===============>")
	self.connected = false
	--@todo token有效期
	if reason == Network.DISCONNECT_REASON_SERVER_CLOSE then
		--CG_RE_LOGIN失败，可能被挤下线、被T或token失效
		--直接重连
		self.isRelogin = true
		self:login()
	else
		--send msg==>send < 0，recv < 0
		if self.tryReLoginCounter < 3 then
			self:tryReLogin()
		else
			--默默的重连
			--[[
			--local tipUI = TipsUI.showTips("网络异常，是否重试?")
			local tipUI = TipsUI.showTopTips("网络异常，是否重试?")
			tipUI:addEventListener(Event.Confirm,function(self,event) 
				if event.etype == Event.Confirm_yes then
					self:tryReLogin()
				end
			end,self)
			--]]
		end
	end
end

--断线重连
function tryReLogin(self,lastMsg)	
	Stage.delTimer(self.connectTimer)
	self.tryReLoginCounter = self.tryReLoginCounter + 1
	local tryCnt = 6	--
	local interval = 0.2
	local tipUI,waitUI
	if lastMsg then
		WaittingUI.cleanup()
		waitUI = WaittingUI.create(-1,tryCnt * interval)
	end
	self.connectTimer = Stage.addTimer(function()
		tryCnt = tryCnt - 1
		local ret = self:connect(self.ip,self.port)
		if ret or tryCnt < 1 then
			Stage.delTimer(self.connectTimer)
			if waitUI and waitUI.alive then waitUI:removeFromParent() end
			if tipUI and tipUI.alive then tipUI:removeFromParent() end
		end
		if ret then
			self.isTryRelogin = true
			self:doLogin(true)
			if lastMsg then 
				self.lastMsg = lastMsg
			end
		elseif lastMsg and tryCnt < 1 then
			tipUI = TipsUI.showTopTips("网络连接失败，是否重试?")
			tipUI:addEventListener(Event.Confirm,function(self,event) 
				if event.etype == Event.Confirm_yes then
					self:tryReLogin(lastMsg)
				elseif event.etype == Event.Confirm_no then
					if Stage.currentScene.name == "fight" then
						local scene = require("src/scene/MainScene").new()
						Stage.replaceScene(scene)
					end
				end
			end,self)
			if Stage.currentScene.name == "fight" then
				tipUI:setBtnName("重试","退出")
			end
		end
	end,interval,tryCnt)	
	--auto release
	self:addTimer(self.connectTimer)
end

function onReLogin(self)
	print("onReLogin=================success")
	self.tryReLoginCounter = 0
	self.isTryRelogin = false
	if self.lastMsg.packetId then
		Network.sendMsg(self.lastMsg.packetId,unpack(self.lastMsg.params))
		self.lastMsg.packetId = nil
	end
end

function connect(self,ip,port)
	print("connect>>>>>>>>>>>>>>>>>>>>",ip,port,self.connected)
	if self.connected  then
		return true
	end
	if not ip or not port then
		return false
	end
	if type(ip) ~= "string" or type(port) ~= "number" then
		return false
	end
	local ret =  Network.connect(ip,port)
	self.connected = ret
	return ret 
end

function login(self,ip,port)
	self.ip = ip or self.ip
	self.port = port or self.port
	if not self:connect(self.ip,self.port) then
		return false
	end
	self:doLogin()
	return true
end

function doLogin(self,isRelogin)
	local co = coroutine.create(function() 
		--local svrName = string.format("[%s]",Config.SvrName)
		local svrName = Config.SvrName
		local pAccount = Common.urlEncode(self.pAccount)
		local channelId = tonumber(Config.ChannelId)
		local timestamp = os.time()
		local sign = svrName .. pAccount .. channelId .. timestamp
		if isRelogin then
			local token = self.token or  ""
			sign = sign .. token
			Network.sendMsg(PacketID.CG_LOGIN_AUTH,sign,self.sdkInfo)
			coroutine.yield()
			Network.sendMsg(PacketID.CG_RE_LOGIN,svrName,pAccount,channelId,self.authKey,token,timestamp)
		else
			--WaittingUI.create(PacketID.GC_ASK_LOGIN)
			print("=========> doLogin")
			Network.sendMsg(PacketID.CG_LOGIN_AUTH,sign,self.sdkInfo)
			coroutine.yield()
			print("=======>",Device.getIMEI())
			Network.sendMsg(PacketID.CG_ASK_LOGIN,svrName,pAccount,channelId,self.authKey,timestamp,Device.getIMEI())
		end
	end)
	self.loginCo = co
	return coroutine.resume(co)
end

function onLogin(self,result,account,name,token)
	self.account = account
	self.name = name
	self.token = token
	self:dispatchEvent(Event.LoginSuccess,{etype=Event.LoginSuccess})
end


function refreshInfo(self,info)
	if info then
		if info.lv and info.lv ~= self.lv and info.lv > 1 and self.lv ~=0 then
			self:markLvUp(self.lv)
			StatisSDK.setPlayerLevel(info.lv)
			self.lv = info.lv
			UserSDK.levelChange()
			self:dispatchEvent(Event.TeamLvUp,{etype=Event.TeamLvUp})
		end
		for k,v in pairs(info) do
			print(k,"======>",v)
			if k == "physics" then
				self.lastPhysics = self.physics
			elseif k == "recharge" then
				v = v / 100
			end
			self[k] = v
		end
		-- 更新时间变量
		if info.timeServer and info.timeServer > 0 then
			self.servTime = info.timeServer
			self.cliTime = os.time()
		end
		
	end
	self:showLvUp()
	self:dispatchEvent(Event.MasterRefresh,{etype=Event.MasterRefresh})
end

function enterForeground(self)
	if self.connected then
	end
end

function enterBackground(self)
	self.stopTime = os.time()
end

function setMusicOn(self,isOn)
	AudioEngine.setMusicOn(isOn)
	self.settings.music = isOn
end

function setEffectOn(self,isOn)
	AudioEngine.setEffectOn(isOn)
	self.settings.effect = isOn 
end

function isMusicON(self)
	return self.settings.music
end

function isEffectON(self)
	return self.settings.effect
end

function getPushSettings(self)
	return self.settings.pushSettings
end

function setPushSetting(self,id,isOpen)
	self.settings.pushSettings[id] = isOpen
end

function getPushSettingById(self,id)
	local isOpen = self.settings.pushSettings[id]
	if isOpen == nil then
		--默认开启
		isOpen = true
	end
	return isOpen
end

function getDBStrVal(self,modName,key)
	local key = self.account .. '_' .. modName .. '_' .. key
	key = Common.cUtil():MD5(key)
	local userDefault = cc.UserDefault:getInstance()
	return userDefault:getStringForKey(key)
end

function setDBStrVal(self,modName,key,val)
	local key = self.account .. '_' .. modName .. '_' .. key
	--必须处理key,否则特殊字符可能导致存xml失败
	key = Common.cUtil():MD5(key)
	local userDefault = cc.UserDefault:getInstance()
	userDefault:setStringForKey(key,val)
	userDefault:flush()
end

function getDBIntVal(self,modName,key)
	local key = self.account .. '_' .. modName .. '_' .. key
	key = Common.cUtil():MD5(key)
	local userDefault = cc.UserDefault:getInstance()
	return userDefault:getIntegerForKey(key,0)
end

function setDBIntVal(self,modName,key,val)
	local key = self.account .. '_' .. modName .. '_' .. key
	--必须处理key,否则特殊字符可能导致存xml失败
	key = Common.cUtil():MD5(key)
	local userDefault = cc.UserDefault:getInstance()
	userDefault:setIntegerForKey(key,tonumber(val))
	userDefault:flush()
end

function setSDKInfo(self,sdkInfo)
	self.sdkInfo = Json.encode(sdkInfo)
end




