module("HttpClient",package.seeall)

local HttpRequest = HttpRequest or {}
function HttpRequest:new()
	trace("new>>>>request")
	local o = {
		oReal = CCHttpRequest:new(),
		callback = nil,
		onComplete = function(response) 
            Common.removeWaitingAction()
            --[[
			local code = response:getResponseCode()
			if not response:isSucceed() then
				local errormsg = response:getErrorBuffer()
			else
				trace("request tag>>>>>>>" .. response:getHttpRequest():getTag())
				trace("response code>>>>>" .. code)
				local d = response:getResponseData()
				local str = Common.getStringFromTable(d:size(),d)
				self:doCallBack(code,str)
			end
            --]]
		end,
	}
	setmetatable(o,{__index=self})
	return o
end

function HttpRequest:doCallBack(code,str) 
	trace(type(self.callback)) 
	self.callback(code,str)
end

function HttpRequest:setUrl(url)
	self.oReal:setUrl(url)
end

function HttpRequest:setRequestType(type)
	self.oReal:setRequestType(type)
end

function HttpRequest:registerHandler(callback)
	self.callback = callback
	self.oReal:registerScriptHandler(self.onComplete)
	trace(type(self.callback)) 
end

local Instance = Instance or nil

function HttpClient:instance()
	local o = Instance
	if o then return o end
	o = {
		oClient = CCHttpClient:getInstance(),
	}
	setmetatable(o,{__index=self})
	Instance = o
	return o
end

function HttpClient:getCallback(response,url,callback,noWaiting,cancleCallback)
    if not noWaiting and not response:isSucceed() then
        local code = response:getResponseCode()
        if code == -1 or code == 500 or code == 504 then
            local tipPanel = require("script/common/TipsPanel").showTip("连接服务器超时，是否重试?",function() self:get(url,callback,noWaiting,cancleCallback) end)
            if cancleCallback then
                tipPanel:addEventListener(Event.Panel_close,function(httpCode) 
                    cancleCallback(httpCode)
                end,code)
            else
                response:retain()
                tipPanel:addEventListener(Event.Panel_close,function(response) 
                    callback(response) 
                    response:release()
                end,response)
            end
            return
        end
    end
    callback(response)
end

function HttpClient:get(url,callback,noWaiting,cancleCallback)
	local request = KbHttpRequest:new()
	request:setUrl(url)
	request:setRequestType(CCHttpRequest.kHttpGet)
    request:registerScriptHandler(function(response)
    	if not noWaiting then
        	Common.removeWaitingAction()
    	end
        self:getCallback(response,url,callback,noWaiting,cancleCallback)
    end)
	self:call(request)
	if not noWaiting then
    	Common.createWaitingAction()
	end
end

function HttpClient:downloadGet(filename,url)
	local request = DownloadHttpRequest:new()
	--request:setTag("get")
	request:setUrl(url)
	request:setRequestType(CCHttpRequest.kHttpGet)
    request:setFilename(filename)
	Downloader:getInstance():send(request)
	--self:call(request)
	--request:release()
end

function HttpClient:postCallback(response,url,postData,callback,noWaiting,cancleCallback)
    if not noWaiting and not response:isSucceed() then
        local code = response:getResponseCode()
        if code == -1 or code == 500 or code == 504 then
            local tipPanel = require("script/common/TipsPanel").showTip("连接服务器超时，是否重试?",function() self:post(url,postData,callback,noWaiting,cancleCallback) end)
            if cancleCallback then
                tipPanel:addEventListener(Event.Panel_close,function(httpCode) 
                    cancleCallback(httpCode)
                end,code)
            else
                response:retain()
                tipPanel:addEventListener(Event.Panel_close,function(response) 
                    callback(response) 
                    response:release()
                end,response)
            end
            return
        end
    end
    callback(response)
end

function HttpClient:post(url,postData,callback,noWaiting,cancleCallback)
	local request = KbHttpRequest:new()
	request:setUrl(url)
	request:setRequestType(CCHttpRequest.kHttpPost)
	request:setRequestData(postData,postData:len())
    request:registerScriptHandler(function(response) 
        Common.removeWaitingAction()
        self:postCallback(response,url,postData,callback,noWaiting,cancleCallback)
    end)
	self:call(request)
	if not noWaiting then
    	Common.createWaitingAction()
	end
end

function HttpClient:call(request)
	self.oClient:send(request)
end

function HttpClient:setTimeout(connectTimeout,readTimeout)
	self.oClient:setTimeoutForConnect(connectTimeout)
	self.oClient:setTimeoutForRead(readTimeout)
end
