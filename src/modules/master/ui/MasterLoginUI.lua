module("MasterLoginUI", package.seeall)
setmetatable(MasterLoginUI, {__index = Control})

--require("src/ui/WaittingUI")
require("src/modules/master/Master")

DB_KEY_SVR = "HISTORY_SVR"

Instance = nil
function new()
	local ctrl = Control.new(require("res/master/LoginSkin"),{"res/master/Login.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl.name = "MasterLogin"
	ctrl:init()
	Instance = ctrl
	return ctrl
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

function addStage(self)
	self:setScale(Stage.uiScale)
end

function init(self)
	self.master = Master.getInstance()
	self:openTimer()
end

function start(self)
	self.wxLogin:setVisible(false)
	self.telLogin:setVisible(false)
	self:initEditBox()
	self:getServerList(function() 
		self:initSvrList()
		self:setSvr()
		self.server.server:setString(Config.SvrName)
		self.server.showServer:addEventListener(Event.TouchEvent,onShowServer,self)
		self:showLogin()
		self.login:addEventListener(Event.TouchEvent,onLogin,self)
	end)
end

function initSvrList(self)
	self.serverList:setItemNum(#Config.SvrList);
	for k,v in ipairs(Config.SvrList) do
		local item = self.serverList:getItem(k,"serverIP")
		item:setString(v.name)
		self.serverList:getItemByNum(k):addEventListener(Event.TouchEvent, function(self,event)
			if event.etype == Event.Touch_ended then
				self:setSvr(v)
				self.server.server:setString(v.name)
				self.serverList:setVisible(false)
			end

		end,self)
	end
	self.serverList:setVisible(false)
end

function initEditBox(self)
	--输入框
	self.lastChatTxt = ""
	self.editBox = Common.createEditBox(self.account.account,function(eventType) self:onEditInput(eventType) end)
	self.account.account:setVisible(true)
	self.account.account:setString("")
	--self.editBox:setMaxLength(20)
    --self.editBox:setReturnType(cc.KEYBOARD_RETURNTYPE_SEND)
	self.editBoxSize = self.editBox:getContentSize() 
	self.editBoxPosX = self.editBox:getPositionX()
	self.account._ccnode:addChild(self.editBox)
end

function setHistorySvr(self,svr)
	local userDefault = cc.UserDefault:getInstance()
	local val = Json.encode(svr)
	userDefault:setStringForKey(DB_KEY_SVR,val)
	userDefault:flush()
end
function getHistorySvr(self)
	local userDefault = cc.UserDefault:getInstance()
	local svr = userDefault:getStringForKey(DB_KEY_SVR)
	return Json.decode(svr)
end

function setSvr(self,svr)
	if not svr then
		--历史服务器
		svr = self:getHistorySvr()
		if svr and svr.sid and Config.SvrList[svr.sid] then
			svr = Config.SvrList[svr.sid]
		else
			svr = nil
		end
	end
	if not svr or not next(svr)  then
		--推荐服务器
		svr = Config.SvrList[#Config.SvrList]
	end
	print("=================svr name=========>",svr.name)
	self.svr = svr
	Config.SId = svr.sid
	Config.SvrId = svr.serverId 
	Config.SvrName = svr.name
	Config.ServerIP = svr.ip
	Config.ServerPort = svr.port
	if svr.resourceURL then
		Config.ResourceURL = svr.resourceURL
	else
		Config.ResourceURL = Config.GlobalResourceURL
	end
	print("========>set resourceURL===>",Config.ResourceURL)
	--版本号局部优先
	if svr.version and svr.version > 0 then
		Config.NewVersion = svr.version
	else
		Config.NewVersion = Config.GlobalVersion
	end
	print("========>set version===>",Config.NewVersion)
	if svr.coreVersion then
		Config.CoreVersion = svr.coreVersion
	else
		Config.CoreVersion = Config.GlobalCoreVersion
	end
	print("========>set coreVersion===>",Config.CoreVersion)
	--[[
	local sdkBlock = self.sdk
	sdkBlock.select.svrName:setString(string.format("%d区 %s",svr.sid,svr.name))
	--]]
end

function getServerList(self,callback)
	do
		callback()
		return
	end
	if Device.platform == "windows" and Config.SvrList and next(Config.SvrList) then
		if callback then
			callback()
		end
		return 
	end
	print("getServerList=======>")
	local timeout = 7
	local waitUI = WaittingUI.create(-1,timeout)	
	local xhr = cc.XMLHttpRequest:new()
	local url = Config.ServerURL .. "?t=" .. os.time()
	xhr.timeout = timeout
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	print("Get==>",url)
	xhr:open("GET", url)
	xhr:registerScriptHandler(function() 
		print(xhr.response)
		print(xhr.status)
		if waitUI.alive then
			waitUI:removeFromParent()
		end
		if xhr.status ~= 200 then
			local tipsUI = TipsUI.showTipsOnlyConfirm("网络不太好哦,请重试")
			tipsUI:addEventListener(Event.Confirm,function(target,event) 
				if event.etype == Event.Confirm_known then
					tipsUI:removeFromParent()
					self:getServerList(callback)
				end
			end)
			return
		end
		local res = Json.decode(xhr.response)
		Config.SvrList = res.svrList
		Config.GlobalResourceURL = res.resourceURL
		--Config.ResourceURL = res.resourceURL
		Config.GlobalVersion = res.newVersion
		--Config.NewVersion = res.newVersion
		Config.GlobalCoreVersion = res.coreVersion
		--Config.CoreVersion = res.coreVersion
		print("Config=>newVersion==>",Config.NewVersion)
		if callback then
			callback()
		end
	end)
	xhr:send()
end

function showLogin(self)
	--[[
	local sdkBlock = self.sdk
	local hasSDK = Config.UseUserSDK and Device.platform ~= "windows"
	if hasSDK then
		self.account:setVisible(false)
		sdkBlock.login:addEventListener(Event.Click,onSDKLogin,self)	--登陆账号
		--自动登陆SDK
		self:addTimer(onSDKLogin,0.1,1,self)
	else
		self.account:setVisible(true)
		local input = self.account
		self.input = input
		input.actInput = Common.createEditBox(input.account.accountLabel)
		input.actInput:setMaxLength(6)
		input.account._ccnode:addChild(input.actInput)
		sdkBlock.login:addEventListener(Event.Click,onLogin,self)	--登陆账号
	end
	self:setLoginStatus()
	sdkBlock.start:addEventListener(Event.Click,checkVersion,self)	--开始游戏
	sdkBlock.select:addEventListener(Event.Click,function() 
		require("src/modules/master/ui/SvrListUI").show()
	end,self)
	self.logout:addEventListener(Event.Click,UserSDK.logout,self)	
	UserSDK._events = {}
	UserSDK:addEventListener(UserSDK.Event_Logout,function(target,event) 
		--UserSDK.login()
		restartGame()
	end)
	--]]
end

--[[
function onLogin(self)
	local account = self.input.actInput:getText()
	self.master:setPAccount(account)
	self.master:setSDKInfo({sid=Config.UserSID})
	self:checkVersion()
end
--]]

function setLoginStatus(self)
	local sdkBlock = self.sdk
	local hadLogin = self.master.pAccount:len() > 0
	sdkBlock.start:setVisible(hadLogin)
	sdkBlock.login:setVisible(not hadLogin)
	--sdkBlock.login:setVisible(false)
end

function onSDKLogin(self)
	local waitUI = WaittingUI.create(-1,5)	--自动清除
	--waitUI:addEventListener(WaittingUI.Event.Timeout,function()
	--	Common.showMsg("初始化失败，请重试")
	--end)
	UserSDK:addEventListener(UserSDK.Event_Login,function(target,event)
		if event.ret == UserSDK.RET_OK then
			local userInfo = event.data   
			Config.ChannelId = tonumber(userInfo.channelId)
			Config.ChannelName = userInfo.channelLabel
			self.master:setPAccount(userInfo.pAccount)
			self.master:setSDKInfo(userInfo)
			--UserSDK.enterGamerServer("1")
			--UserSDK.createRole("1")
			--UserSDK.levelChange("foo",1)
			--UserSDK.pay("foooo")
			self:setLoginStatus()
			--自动登录
			--self:addTimer(checkVersion,0.2,1,self)
		else
			--未知错误
			--Common.showMsg(event.data)
			--waitUI:removeFromParent()
		end
		waitUI:removeFromParent()
	end)
    if UserSDK.isInitOK() then
        UserSDK.login()
    else
        UserSDK:addEventListener(UserSDK.Event_InitOK,function(target,event)
            UserSDK.login()
        end)
    end

	--local Push = require("src/core/utils/Push")
	--Push.init(638739407)
	--Push.cancelAlarmTimer(0)
	--Push.cancelAlarmTimer(1)
	--Push.stopAlarmTimer(0,"koftest","koftest",15,23)
end

function checkVersion(self)
	if self.svr.state == 2 and not Config.Debug then
		local tipsUI = TipsUI.showTipsOnlyConfirm("服务器维护中")
		tipsUI:addEventListener(Event.Confirm,function(target,event) 
			if event.etype == Event.Confirm_known then
				tipsUI:removeFromParent()
				self:getServerList()
			end
		end)
		return
	end
	self:setHistorySvr(self.svr)
	self:setVisible(false)
	local loadingBarUI = require("src/ui/LoadingBarUI").new()
	Stage.currentScene:addChild(loadingBarUI)
	loadingBarUI:addEventListener(loadingBarUI.UpdateEnded,function(bar,event) 
		if event.needUp then
			--restartGame()
			UserSDK.logout()
		else
			self:addTimer(function() 
				collectgarbage( "stop" ) 
				require("src/modules/init")
				require("src/ui/init")
				collectgarbage( "restart" ) 
				loadingBarUI:removeFromParent()
				self:doLogin()
			end,0.2,1)
		end
	end)
	loadingBarUI:startUpdate()
end

function doLogin(self)
	print("doLogin=================>")
	--StatisSDK.onEvent(StatisSDK.Event_Login)
	local res = self.master:login(Config.ServerIP, Config.ServerPort)
	if not res then
		--[[
		local tipsUI = TipsUI.showTopTips("网络不太好哦,是否重试")
		tipsUI:addEventListener(Event.Confirm,function(target,event) 
			if event.etype == Event.Confirm_yes then
				tipsUI:removeFromParent()
				self:doLogin()
			elseif event.etype == Event.Confirm_no then
				local scene = require("src/scene/LoginScene").new()
				Stage.replaceScene(scene)
			end
		end)
		--]]
	end
end

function onReset(self)
	self.input.actInput:setText('')
	self.input.pwdInput:setText('')
end

function onShowServer(self,event)
    if event.etype == Event.Touch_ended then
		self.serverList:setVisible(not self.serverList:isVisible())
	end
end

function onEditInput(self,eventType)
	--@fix editbox控件会重新调整contentsize
    if eventType == "began" then
		self.editBox:setText(self.lastChatTxt)
	elseif eventType == "ended" then
		self.lastChatTxt = self.editBox:getText()
	elseif eventType == "return" then
		self.account.account:setString(self.editBox:getText())
		self.editBox:setText("")
    end
end

function onLogin(self,event)
    if event.etype == Event.Touch_ended then
		if self.account.account:getString() ~= "" then
			self:doLogin()
		end
	end
end

return MasterLoginUI



