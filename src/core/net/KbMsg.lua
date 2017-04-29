--[[**************************************************************************** 
example:
function testNet()
	local function onComplete(res)
		local rMsg = KbMsg:instance():decode(res)
		Common.print_r(rMsg)
	end
	local msg = {name="xx"}
	KbMsg:instance():get(API.user.info,msg,onComplete)
end

****************************************************************************]] 
module("KbMsg",package.seeall)

local Instance = Instance or nil

local API2Url = API2Url or {}

API = API or {}

function InitAPI2Url()
	for mod,ac in pairs(API) do
		for a,id in pairs(ac) do
			API2Url[id] = string.format("%s/%s",mod,a)
		end
	end
end

function KbMsg:instance()
	local o = Instance
	if o then return o end
	o = {
		host = "",
		oClient = HttpClient:instance(),
	}
	setmetatable(o,{__index=self})
	InitAPI2Url()
	Instance = o
	return o
end

function KbMsg:setHost(host)
	self.host = host
end

function KbMsg:get(apiId,msg,callback,noWaiting,cancleCallback)
	self:send(apiId,msg,callback,false,noWaiting,cancleCallback)
end

function KbMsg:post(apiId,postData,callback,noWaiting,cancleCallback)
	self:send(apiId,postData,callback,true,noWaiting,cancleCallback)
end

function KbMsg:send(apiId,msg,callback,isPost,noWaiting,cancleCallback)
	msg.token = Hero:instance():getToken()
	msg.time  = os.time()
	local url = "http://" .. self.host .. "/" .. API2Url[apiId]
	local sig = self:signature(apiId,msg,isPost)
	local params = self:encodeCallParam(msg)
	params = params .. 'sig=' .. sig
	trace("send msg>>>>>" .. url .. ">>param>>>" .. params)
	if isPost then
		self.oClient:post(url,params,callback,noWaiting,cancleCallback)
	else
		self.oClient:get(url .. '?' .. params,callback,noWaiting,cancleCallback)
	end
end

function KbMsg:signature(apiId,msg,isPost)
	local sig = ''
	if isPost then
		sig = 'post&'
	else
		sig = 'get&'
	end
	local url = API2Url[apiId]:lower()
	sig = sig .. url .. '&'
	--按字典序排列
	local keyTb = {}
	for k,v in pairs(msg) do
		keyTb[#keyTb+1] = k
	end
	table.sort(keyTb)
	for _,k in ipairs(keyTb) do
		if type(msg[k]) == 'table' then
			msg[k] = Json.encode(msg[k])
		end
		if type(msg[k]) == 'string' then
			msg[k] = msg[k]:lower()
		end
		sig = sig .. (msg[k])
	end
	--加key
	sig = sig .. Config.APIKey
	sig = Common.cUtil():_MD5(sig)
	return sig 
end

function KbMsg:encodeCallParam(msg)
	local params = ''
	for k,v in pairs(msg) do
		params = params .. string.format("%s=%s&",k,v)
	end
	return params
end

function KbMsg:decode(response)
	if not response:isSucceed() then
		trace("response not succeed")
		local code = response:getResponseCode()
		self:handleErrorCode(code)	
		local errormsg = response:getErrorBuffer()
		trace(errormsg)
		return false
	else
		trace("request tag>>>>>>>" .. response:getHttpRequest():getTag())
		local d = response:getResponseData()
		local str = Common.getStringFromTable(d:size(),d)
		trace("response str>>>>" .. str)
		if type(str) == 'string' and str:len() > 0 then
			return Json.decode(str)
		else
			return str
		end
	end
end

function KbMsg:decoded(response,notShowTip)
	if not response:isSucceed() then
		trace("response not succeed")
		local code = response:getResponseCode()
		--print("错误代码:" .. code)
		local errorMsg = self:handleErrorCode(code,notShowTip)	
		--local errormsg = response:getErrorBuffer()
		return false,errorMsg
	else
		trace("request tag>>>>>>>" .. response:getHttpRequest():getTag())
		local d = response:getResponseData()
		local str = Common.getStringFromTable(d:size(),d)
		trace("response str>>>>" .. string.sub(str,1,500))
		if type(str) == 'string' and str:len() > 0 then
			return true,Json.decode(str)
		else
			return true,str
		end
	end
end

--返回错误编号及错误提示
function KbMsg:getCodeData(response,notShowTip)
	if not response:isSucceed() then
		trace("response not succeed")
		local code = response:getResponseCode()
		--print("错误代码:" .. code)
		local errorMsg = self:handleErrorCode(code,notShowTip)	
		--local errormsg = response:getErrorBuffer()
		return false,code,errorMsg
	else
		trace("request tag>>>>>>>" .. response:getHttpRequest():getTag())
		local d = response:getResponseData()
		local str = Common.getStringFromTable(d:size(),d)
		trace("response str>>>>" .. str)
		if type(str) == 'string' and str:len() > 0 then
			return true,Json.decode(str)
		else
			return true,1,str
		end
	end
end


--不成功 返回失败的原因
function KbMsg:handleErrorCode(code,notShowTip)
	local msg = HttpCode.Msg[code]
	if msg then
		trace("HTTP Code>>>" .. code .. ">>>msg>>>" .. msg)
		if notShowTip then
			return msg
		else
			local reLogin = function()
				local needReLoginCode = {600,601,602}
				for _,v in ipairs(needReLoginCode) do
					if code == v then
						Stage.currentScene:showRegisterPanel()
						break
					end
				end
			end
			local tipPanel = require("script/common/TipsPanel").showTip(msg,reLogin)
			tipPanel:addEventListener(Event.Panel_close,reLogin)
			return msg
		end
	else
		trace("HTTP code>>>>>" .. code)
		return "error code:" .. code
	end
end




