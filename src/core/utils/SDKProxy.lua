module(..., package.seeall) 

local instance = nil
local MXSDK = "com.mxgame.lib.sdk.MXSDK"
local MXUser = "com.mxgame.lib.sdk.MXUser"
local MXPay = "com.mxgame.lib.sdk.MXPay"
function getInstance()
	local tb = instance
	if not tb then
		tb = {
			handler = nil,
		}
		setmetatable(tb, {__index = _M})
		tb:init()
		instance = tb
	end
	return tb
end

function onActionCallback(msg)
	print("SDKProxy onActionCallback=========>",msg)
	local cbInfo = Json.decode(msg)
	local code = UserSDK.ActionCode[cbInfo.code] or tonumber(cbInfo.code)
	local msg = ""
	if cbInfo.msg then
		msg = Json.decode(cbInfo.msg)
	end
	instance.handler(code,msg,cbInfo.customParam)
end

function init(self)
end

function registerScriptHandler(self,handler)
	self.handler = handler
    if Device.platform == "android" then
        LuaJ.callStaticMethod(MXSDK, "setActionListener",{onActionCallback} )
    elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXSDK","setActionListener",{luaCb=onActionCallback})
    end
end

function login(self)
    if Device.platform == "android" then
        LuaJ.callStaticMethod(MXUser, "login",{} )
    elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXUser","login")
    end
end

function logout(self)
    if Device.platform == "android" then
        LuaJ.callStaticMethod(MXUser, "logout",{} )
    elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXUser","logout")
    end
end

function setExtRoleData(self,roleData)
	LuaJ.callStaticMethod(MXUser, "setExtRoleData",{tostring(roleData)} )
end

function releaseResource(self)
	LuaJ.callStaticMethod(MXSDK, "releaseResource",{} )
end

function exitSDK(self)
	LuaJ.callStaticMethod(MXUser, "exitSDK",{} )
end

function charge(self,productName,price,count,customParam,callbackUrl)
	print("======charge===>",productName,price,count,customParam,callbackUrl)
    if Device.platform == "android" then
        LuaJ.callStaticMethod(MXPay, "charge",{productName,tonumber(price),tonumber(count),customParam,callbackUrl} )
    elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXPay", "charge",
        {unitName=productName,unitPrice=tonumber(price),defaultNum=tonumber(count),callBackInfo=customParam,callbackUrl=callbackUrl} )
    end

end

function getAndroidManifestMeta(self,name) 
end

function getChannelLabel(self)
	local setLabel = function(name)
		self.channelLabel = name
	end
	LuaJ.callStaticMethod(MXSDK, "getChannel",{setLabel} )
	return self.channelLabel
end

function isInitOK(self)
    if Device.platform == "android" then
        return true
    elseif Device.platform == "ios" then
        local ret = LuaOC.callStaticMethod("MXSDK","getIsInitOK",{})
        return ret == "1"
    end
end

