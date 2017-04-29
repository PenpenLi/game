module("UserSDK", package.seeall) 
setmetatable(UserSDK, {__index = EventDispatcher}) 

IsInit = false
Event_Init = "init"
Event_Login = "login"
Event_Logout = "logout"
Event_InitOK = "initOK"

RET_OK = "0"
RET_LOGIN_FAIL = "1" 	--登陆失败
RET_PAY_OK = "0"		--充值成功
RET_PAY_CANCEL = "1" 	--取消充值
RET_PAY_ERROR = "2"		--充值未知错误

local SDKProxy = require("src/core/utils/SDKProxy").getInstance()
--local SDKProxy
--if MX.SDKProxy then
--	--SDKProxy = MX.SDKProxy:getInstance()
--end
ActionCode = {
	kLoginSuccess = 0,
	kLoginFailed = 1,
	kLogout = 2,
	kPaySuccess = 3,
	kPayFailed = 4,
	kExit = 5,
	kExitNo3rd = 6,
    kInitOK = 7,
}
function onActionListener(code, msg , customParam)
	print("on user action listener.===>",code,msg,customParam)
	if code == ActionCode.kLoginSuccess then
		local userInfo = msg
		userInfo.pAccount = msg.channelUserId		--渠道的userId
		UserSDK:dispatchEvent(Event_Login,{etype=Event_Login,ret=RET_OK,data=userInfo})
	elseif code == ActionCode.kLoginFailed then
		UserSDK:dispatchEvent(Event_Login,{etype=Event_Login,ret=RET_LOGIN_FAIL,data=msg})
	elseif code == ActionCode.kLogout then
		UserSDK:dispatchEvent(Event_Logout,{etype=Event_Logout,ret=RET_OK,data=msg})
	elseif code == ActionCode.kPaySuccess then
		--不是所有渠道都会回调
	elseif code == ActionCode.kPayFailed then
		--不是所有渠道都会回调
	elseif code == ActionCode.kExit then
		SDKProxy:releaseResource()
		cc.Director:getInstance():endToLua()
	elseif code == ActionCode.kExitNo3rd then
		local tips = TipsUI.showTopTips("确定退出游戏?")
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				SDKProxy:releaseResource()
				cc.Director:getInstance():endToLua()
			end
		end)
    elseif code == ActionCode.kInitOK then
        UserSDK:dispatchEvent(Event_InitOK,{etype=Event_InitOK,ret=ret})
	end
end

function isInitOK()
    return SDKProxy:isInitOK()
end

function init()
    SDKProxy:registerScriptHandler(onActionListener)
    if Device.platform == "android" then
        UserSDK:dispatchEvent(Event_InitOK,{etype=Event_InitOK,ret=ret})
    end
end

function login() 
	print("UserSDK===login=======>")
    SDKProxy:login("")
end

local function createRoleData()
	local master = Master.getInstance()
	local roleData = {}
	roleData.roleId = master.pAccount
	roleData.roleName = master.name
	roleData.roleLevel = master.lv
	roleData.zoneId = Config.SId
	roleData.zoneName = Config.SvrId
	roleData.balance = master.rmb
	roleData.vip = master.vipLv
	roleData.partyName = require("src/modules/guild/GuildData").getGuildName()
	return roleData
end

function enterGamerServer()
	print("UserSDK==>enterGamerServer=========>")
	local roleData = createRoleData()
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(classsName, "enterGamerServer",{tostring(sid)} )
		roleData._id = "enterServer"
		SDKProxy:setExtRoleData(Json.encode(roleData))
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("StatisSDK","op",{state=false})
	end
end

function createRole()
	print("UserSDK==>createRole=========>")
	local roleData = createRoleData()
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(classsName, "createRole",{tostring(roleName)})
		roleData._id = "createRole"
		SDKProxy:setExtRoleData(Json.encode(roleData))
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("StatisSDK","setAccount",{account=account})
	end
end

function levelChange(roleName)
	local roleData = createRoleData()
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(classsName, "levelChange",{tostring(roleName),tonumber(level)} )
		roleData._id = "levelUp"
		SDKProxy:setExtRoleData(Json.encode(roleData))
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("StatisSDK","setAccount",{account=""})
	end
end

--[[
--payInfo:
--示例:
local master = Master.getInstance()
local payInfo = {}
--payInfo.serverId = master.svrName 
payInfo.serverId = "1" 
payInfo.roleId = master.account		--uid唯一标记
payInfo.name = master.name
payInfo.productId = "1"
payInfo.extra = "1000101"	--额外参数，会被平台带回
UserSDK.charge(productName,price,count,function(ret) 
	if ret == UserSDK.RET_PAY_OK then
		Common.showMsg("充值成功")
	end
end)
--]]
--商品名、单价(分),数量
function charge(productName,price,count,payInfo)
		print("pay===========>",payInfo)
		--payInfo = Json.encode(payInfo)
		--LuaJ.callStaticMethod(classsName, "pay" ,{payInfo,payCallback} )
		local customParam = Json.encode({
            serverCode = tostring(Config.SId),
			uid = payInfo.roleId,
            item1 = payInfo.productId,
            num1 = count,
			--rolename = payInfo.name,
			--productId = payInfo.productId,
			--app_param = payInfo.extra,
			--time = os.time(),
		}) 
		SDKProxy:charge(productName,price,count,customParam,"http://pay.qhqz.gop.yy.com/pay.php")
end

function logout()
    SDKProxy:logout("")
end

function exit()
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(classsName, "exit" )
		SDKProxy:exitSDK()
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("StatisSDK","reportTimesEvent",{eid=eid,label=label})
	else
		local tips = TipsUI.showTopTips("确定退出游戏?")
		tips:addEventListener(Event.Confirm,function(self,event) 
			if event.etype == Event.Confirm_yes then
				cc.Director:getInstance():endToLua()
			end
		end)
	end
end

function getMetaData(key)
	if Device.platform == "android" then
		return SDKProxy:getAndroidManifestMeta(key)
	end
end

function getChannel()
	if Device.platform == "android" then
		return SDKProxy:getChannelLabel()
	else
		return Config.PlatformName
	end
end

return UserSDK


