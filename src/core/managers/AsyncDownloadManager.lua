module("AsyncDownloadManager",package.seeall)
setmetatable(AsyncDownloadManager, {__index = EventDispatcher}) 

local cUtil = Common.cUtil()
local userDefault = cc.UserDefault:getInstance()
local fileUtils = cc.FileUtils:getInstance()


MAX_FAIL_TRY_NUM = 10		--尝试重新下载的次数

KEY_VERSION = "KEY_VERSION"
KEY_HAD_DOWNLOADED = "KEY_HAD_DOWNLOADED"
KEY_FILE_LIST = "KEY_FILE_LIST"


Event = {
	--更新事件
	needUpdate = "needUpdate",
	checkVersion = "checkVersion",		--版本检查
	checkFile = "checkFile",		--文件比对
	newVersion = "newVersion",		--新版本号
	--加载事件
	onLoad = "onLoad",
	loading = "loading",
	finishFile  = "finishFile",
	finishAll = "finishAll"
}

Status = {
	lostConnect = "lostConnect",
	lastestVer = "lastestVer",
	needUpCore = "needUpdate",
	error = "error"
}

local instance = nil

function getInstance()
	local tb = instance
	if not tb then
		tb = {
			isWorking = false,
			downloader = nil,
			newVersion = nil,

			downloadedPath = "",		--资源临时目录
			releasePath = "",			--资源更新目录
			downloadUrl = "",

			totalSize = 0,
			downloadedSize = 0,
			totalFileSize = 0,			
			hadDownloadSize = 0,		--已下载的文件总大小
			loadQueue = {},				--
			loadedIndex = 0,			--
			queueCount = 0,
			failCount = 0,		--下载失败的次数
		}
		setmetatable(tb, {__index = AsyncDownloadManager})
		tb:init()
		instance = tb
	end
	return tb 
end

function destroyInstance()
	if instance then
		MX.Downloader:destroyInstance()
	end
	instance = nil
end

function init(self)
	self.downloadedPath = Config.DownloadPath 
	self.releasePath = Config.ReleasePath 
	self:addEventListener(Event.needUpdate,onUpdate,self)
	self:addEventListener(Event.onLoad,onFinishAll,self)
end

function start(self)
	cUtil:createDirectory(self.downloadedPath)
	cUtil:createDirectory(self.releasePath)
	local downloader = MX.Downloader:getInstance()
	downloader:setTimeoutForConnect(30)
	downloader:setTimeoutForRead(600)
	downloader:setFileDestPath(self.downloadedPath)
	downloader:registerScriptHandler(onLoad)
	self.downloader = downloader

	self.isWorking = true
	self:checkVersion(true)
end

function checkVersion(self,isCheckFile)
	--判断底包
	if Config.CoreVersion then
		if Device.getCoreVersion() ~= Config.CoreVersion then
			self:dispatchNeedUpdate(false,Status.needUpCore)
			return
		end
	end
	--热更新资源
	local tmpVersion = tonumber(Config.NewVersion)
	print("checkVersion====>",tmpVersion)
	if not tmpVersion then
		self:dispatchNeedUpdate(false,Status.error)
		return
	elseif tmpVersion == 0 or tmpVersion <= self:getOldVersion() then
		--特殊版本号0，不更新
		self:dispatchNeedUpdate(false,Status.lastestVer)
		return
	else
		self.newVersion = tmpVersion 
		self.downloadUrl = Config.ResourceURL
		if isCheckFile then
			self:checkFile()
		else
			self:dispatchEvent(Event.needUpdate,{etype=Event.newVersion})
			return
		end
	end
end

function checkFile(self)
	local fileMapUrl = string.format("%s/%s/%s",self.downloadUrl,self.newVersion,Config.ResourceMapFile)
	print("checkFile===>",fileMapUrl)
	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 100
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", fileMapUrl)
	xhr:registerScriptHandler(function() 
		print(xhr.status)
		if xhr.status ~= 200 then
			self:dispatchNeedUpdate(false,Status.lostConnect)
			return
		end
		self.filelistStr = xhr.response
		local downlist = Json.decode(xhr.response)
        local needDownload = false
		local oldFileList = ""
		if self:getOldVersion() ~= 0 then
			oldFileList = userDefault:getStringForKey(KEY_FILE_LIST,"")
		--else
			--覆盖安装时由底层把版本号置为0
		end
		local oldFileTb = Json.decode(oldFileList)
		self.newFileTb = {}
        for fileUrl,v in pairs(downlist) do
			if type(v) ~= "table" or not v[1] or not v[2] then
				self:dispatchNeedUpdate(false,Status.error)
				return
			end
			local file = fileUrl
			if fileUrl:find("/") then
				--文件url带版本号
				file = fileUrl:sub(fileUrl:find("/")+1)
			else
				fileUrl = self.newVersion .. "/" .. fileUrl
			end
			local md5 = v[1]
			local size = tonumber(v[2]) or 0
			self.newFileTb[file] = {md5,size}
			local downloadedPath = self.downloadedPath .. file
			--if md5 ~= cUtil:getFileMD5(file) and md5 ~= cUtil:getFileMD5(downloadedPath) then
			if md5 ~= cUtil:getFileMD5(downloadedPath) then
				local oldMd5 = ""
				if oldFileTb and oldFileTb[file] then
					oldMd5 = oldFileTb[file][1]
				else
					oldMd5 = cUtil:getFileMD5(file)
				end
				if oldMd5 ~= md5 then
					needDownload = true
					self.totalSize = self.totalSize + size 
					self.loadedIndex = self.loadedIndex + 1
					self:pushFile(file,self.downloadUrl .. "/" .. fileUrl)
				end
            end
        end
		--下载完毕则把文件挪过来
		if not needDownload then
			cUtil:moveDirectory(self.downloadedPath,self.releasePath)
			self:setVersion(self.newVersion)
			self:setFileList()
		end
		self:dispatchNeedUpdate(needDownload)
	end)
	xhr:send()
	self:dispatchEvent(Event.needUpdate,{etype=Event.checkFile})
end


function pushFile(self,file,url)
	self.loadedIndex = self.loadedIndex + 1
	self.queueCount = self.queueCount + 1
	self.loadQueue[#self.loadQueue + 1] = {file,url}
	self.downloader:pushFile(file,url)
end

function onLoad(loadStatus)
	local self = getInstance()
	local status = loadStatus.status
	local etype
	local filename
	local fileSize
	self.downloadedSize = loadStatus.downloadedSize
	if status == 0 then
		etype = Event.loading
	else
		filename = loadStatus.filename
		self.loadedIndex = self.loadedIndex + 1
		self.queueCount = self.queueCount - 1
		if loadStatus.ret  then
			etype = Event.finishFile
			fileSize = loadStatus.size
			self.totalFileSize = self.totalFileSize + fileSize
			--self:setHadDownloadedSize(self.totalFileSize)
		else
			self.failCount = self.failCount + 1
		end
		--[[
		else
			--@todo 下载失败的处理
			--继续尝试可能会死循环
			print("down fail file>>>>>>>>>",filename,loadStatus.ret)
			if self.failCount > MAX_FAIL_TRY_NUM then
				self.loadedIndex = self.loadedIndex + 1
				self.queueCount = self.queueCount - 1
			else
				self.failCount = self.failCount + 1
				self:pushFile(filename,self.downloadUrl .. filename)
			end
		end
		--]]
	end
	if self.queueCount == 0 then
		etype = Event.finishAll
	end
	self:dispatchEvent(Event.onLoad,{etype=etype,loadedIndex=self.loadedIndex,queueCount=self.queueCount,
							  downloadedSize=self.downloadedSize,filename=filename,fileSize=fileSize})
end

function onUpdate(self,event)
	if event.etype == Event.needUpdate and event.ret then
		self.downloader:start()
	end
end

function onFinishAll(self,event)
	if event.etype == Event.finishAll  then
		print("onFinishAll>>>>>destroyInstance==>",self.failCount)
		if self.newVersion and self.failCount == 0 then
			self:setVersion(self.newVersion)
			self:setFileList()
		end
		--self:setHadDownloadedSize(0)
		destroyInstance()
		cUtil:moveDirectory(self.downloadedPath,self.releasePath)
	end
end

function getOldVersion(self)
	local ver = userDefault:getIntegerForKey(KEY_VERSION,0)
	if ver == 0 then
		local bundleVersion = Device.getBundleVersion()
		local verTb = Common.split(bundleVersion,"%.")
		ver = verTb[3] or 0
	end
	return tonumber(ver)
end

function setVersion(self,version)
	return userDefault:setIntegerForKey(KEY_VERSION,version)
end

function setFileList(self)
	local filelistStr = Json.encode(self.newFileTb)
	userDefault:setStringForKey(KEY_FILE_LIST,filelistStr)
	userDefault:flush()
end

--[[
function getHadDownloadedSize(self)
	return tonumber(userDefault:getIntegerForKey(KEY_HAD_DOWNLOADED))
end

function setHadDownloadedSize(self,size)
	userDefault:setIntegerForKey(KEY_HAD_DOWNLOADED,tonumber(size))
	userDefault:flush()
end
--]]

function dispatchNeedUpdate(self,ret,status)
	print("dispatchNeedUpdate===>",ret,status)
	--self:dispatchEvent(Event.needUpdate,{etype=Event.needUpdate,totalSize=self.totalSize-self.hadDownloadSize,ret=ret,status=status})
	self:dispatchEvent(Event.needUpdate,{etype=Event.needUpdate,totalSize=self.totalSize,ret=ret,status=status})
end





