module(..., package.seeall)
local Json = require("core.utils.Json")
local CommonDefine = require("core.base.CommonDefine")
local Util = require("core.utils.Util")
local PacketID = require("PacketID")
local Msg = require("core.net.Msg")
local Sha1 = require("core.utils.SHA1")

local ForbidManager = require("modules.admin.ForbidManager")
local RechargeLogic = require("modules.recharge.RechargeLogic")
--http请求总入口

SvrId = Config.SVRNAME:sub(2,Config.SVRNAME:len()-1)
StatPayAPI = "http://login.qhqz.gop.yy.com/stat/pay"

function MakeHttpRequest(oJsonInput, otherParam)
	local ret = "/admin?"
	local bFirst = true
	for k, v in pairs(oJsonInput) do
		if bFirst then
			bFirst = false
		else
			ret = ret .. "&"
		end
		ret = ret .. k .. "=" .. v
	end
	if otherParam then
		ret = ret .. otherParam
	end
	return ret
end

function checkSign(kvTb,...)
	if Config.ISTESTCLIENT then return true end
	local str = ""  
	for _,v in ipairs({...}) do
		str = str .. v
	end
	str = str .. kvTb.ts
	return kvTb.sign == Sha1.hmac(Config.ADMIN_KEY,str)
end

DayRegister = DayRegister or 0
LastRegisterDay = LastRegisterDay or 0
function incDayRegister()
	if os.date("%d") ~= LastRegisterDay then
		DayRegister = 0
		LastRegisterDay = os.date("%d")
	end
	DayRegister = DayRegister + 1
end


------------------------------------------------------------------------------------
-- 管理后台相关函数 begin
------------------------------------------------------------------------------------


local ParamErrRet={}

local OprOKRet= "{\"code\":1,\"message\":\"ok\"}"
local Timeout = "{\"code\":-2,\"message\":\"timeout\"}"
local SighFail = "{\"code\":-3,\"message\":\"sign error\"}"
local UserNotExist= "{\"code\":-4,\"message\":\"User is not exist\"}"

local oResult = {code=1,message="ok"}
local helpMsg = {
	"q=online:请求当前在线人数",
	"q=getPlayer&name=xx:请求玩家信息",
}


function help()
	return Json.Encode(helpMsg)
end


function hotup(kvTb)
	print("hotup============>")
	package.loaded["RenewAll"] = nil
	require("RenewAll")
	return OprOKRet
end

--模拟验证登录
function auth(kvTb)
	return "true"
end

-- 获取在线人数接口
function online(kvTb)
	if not checkSign(kvTb) then
		return SighFail
	end
	oResult.online = HumanManager.countOnline(true)
	oResult.top = 0
	oResult.low = 0
	return Json.Encode(oResult)
end


------------------------------------------------------------------------------------
-- 管理后台相关函数 end
------------------------------------------------------------------------------------
