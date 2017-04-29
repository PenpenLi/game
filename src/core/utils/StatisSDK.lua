module("StatisSDK", package.seeall) 

--local StatisSDK = "com/mxgame/sdk/UmengSDK"
local SDKClass = "com.mxgame.lib.sdk.MXStatis"

Account_type_any = 1		--匿名账号
Account_type_register = 2		--注册账号
Gender_male = 1 	--男性

Event_Login = "login"
Event_LoginOK = "loginOK"
Event_InitSDK = "initSDK"
Event_InitSDKOK = "initSDKOK"
Event_OpenSDK = "openSDK"
Event_LoginSDKOK = "loginSDKOK"

function init(appkey,from,isDebug)
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(SDKClass, "init" ,{appkey,from,isDebug})
		----@sdk android 要求先调用onResume
		--LuaJ.callStaticMethod(SDKClass, "onResume" )
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("SDKClass","initStatis",{appId=appId,appkey=appkey,from=from,ver=ver})
	end
end

function setPlayerInfo(suid,name,accountType,lv,age,gender,serverName)
	if Device.platform == "android" then
        local info = {tostring(suid),tostring(name),tonumber(accountType),tonumber(lv),tonumber(age),tonumber(gender),tostring(serverName)}
		LuaJ.callStaticMethod(SDKClass, "setPlayerInfo",info)
	elseif Device.platform == "ios" then
        local info = {suid=tostring(suid),name=tostring(name),accountType=tonumber(accountType),lv=tonumber(lv),age=tonumber(age),gender=tonumber(gender),serverName=tostring(serverName)}
		LuaOC.callStaticMethod("MXStatis","setPlayerInfo",info)
	end
end

function setPlayerLevel(level)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "setPlayerLevel",{tonumber(level)})
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("MXStatis","setPlayerLevel",{lv=tonumber(level)})
	end
end

--进入关卡
function startLevel(level)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "startLevel",{tostring(level)})
	elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXStatis","startLevel",{level=tostring(level)})
	end
end

--挑战失败
function failLevel(level)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "failLevel",{tostring(level)})
	elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXStatis","failLevel",{level=tostring(level)})
	end
end

--挑战成功
function finishLevel(level)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "finishLevel",{tostring(level)})
	elseif Device.platform == "ios" then
        LuaOC.callStaticMethod("MXStatis","finishLevel",{level=tostring(level)})
	end
end

-- 10元钱 购买了 1000 个金币,通过支付宝
function pay(money,coin,source)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "pay",{tonumber(money),tonumber(coin),tonumber(source)})
	elseif Device.platform == "ios" then
		LuaJ.callStaticMethod("MXStatis", "pay",{money=tonumber(money),coin=tonumber(coin),source=tonumber(source)})
	end
end

--使用金币购买了1个头盔，一个头盔价值 1000 金币
function buy(item,number,price)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "buy",{tostring(item),tonumber(number),tonumber(price)})
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("MXStatis", "buy",{item=tostring(item),number=tonumber(number),price=tonumber(price)})
	end
end

--使用了2瓶魔法药水,每个需要50个虚拟币
function use(item,number,price)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "use",{tostring(item),tonumber(number),tonumber(price)})
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("MXStatis", "use",{item=tostring(item),number=tonumber(number),price=tonumber(price)})
	end
end

--连续5天登陆游戏奖励1000金币
function reward(coin,reason)
	if Device.platform == "android" then
		LuaJ.callStaticMethod(SDKClass, "bonus",{tonumber(coin),tostring(reason)})
	elseif Device.platform == "ios" then
		LuaOC.callStaticMethod("MXStatis", "reward",{coin=tonumber(coin),reason=tostring(reason)})
	end
end

function onEvent(eventName)
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(SDKClass, "onEvent",{tostring(eventName)})
	elseif Device.platform == "ios" then
	end
end

function onEventBegin(eventName)
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(SDKClass, "onEventBegin",{tostring(eventName)})
	elseif Device.platform == "ios" then
	end
end

function onEventEnd(eventName)
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(SDKClass, "onEventEnd",{tostring(eventName)})
	elseif Device.platform == "ios" then
	end
end

function onEventWithLabel(eventName,label)
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(SDKClass, "onEventWithLabel",{tostring(eventName),tostring(label)})
	elseif Device.platform == "ios" then
	end
end

function flush()
	if Device.platform == "android" then
		--LuaJ.callStaticMethod(SDKClass, "flush")
	elseif Device.platform == "ios" then
		--LuaOC.callStaticMethod("SDKClass","reportLogin")
	end
end






