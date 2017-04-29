module("AsyncLoader",package.seeall)
setmetatable(AsyncLoader, {__index = EventDispatcher}) 

Event = {
	Load = "load",
	OnLoad = "onLoad",
	Finish = "finish",
}

function new()
	local tb = {
		imgLoader = MX.AsyncImageLoader:getInstance(),
		loader = ccs.ArmatureDataManager:getInstance(),
		loadQueue = {},
		resIndex = 0,
		loadedIndex = 0,
		armatureFileList = {},
	}
	setmetatable(tb, {__index = AsyncLoader})
	tb:init()
	return tb
end

function init(self)
	self.imgLoader:registerScriptHandler(function(texture) self:onLoad(texture) end)
end

function addArmatureFileInfo(self,exportJson)
	self.resIndex = self.resIndex + 1
	self.loadQueue[self.resIndex] = self.loadQueue[self.resIndex] or {}
	self.loadQueue[self.resIndex].armatureFile = exportJson
	--self.armatureFileList[#self.armatureFileList+1] = exportJson
	self.armatureFileList[exportJson] = (self.armatureFileList[exportJson] or 0) + 1
end

function removeArmatureFileInfo(self,exportJson)
	if not Control.gArmatureCache[exportJson] then
		ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(exportJson)
	end
end

function removeAllArmatureFileInfo(self)
	for k,v in pairs(self.armatureFileList) do
		self:removeArmatureFileInfo(k)
		--ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(v)
	end
end

function addResource(self,png,param)
	self.resIndex = self.resIndex + 1
	self.loadQueue[self.resIndex] = self.loadQueue[self.resIndex] or {}
	self.loadQueue[self.resIndex].pngFile = png
	self.loadQueue[self.resIndex].param = param
end

function removeAllResouce(self)
	for _,v in pairs(self.loadQueue) do
		if v.pngFile then
			cc.Director:getInstance():getTextureCache():removeTextureForKey(v.pngFile)
		end
	end
end

function start(self)
	if self.resIndex > 0 and self.resIndex > self.loadedIndex then
		self.loadedIndex = self.loadedIndex + 1
		self:doLoad(self.loadedIndex)
	end
end

function doLoad(self,index)
	local q = self.loadQueue[index]
	if q then
		if q.pngFile then
			self.imgLoader:addImage(q.pngFile)
		elseif q.armatureFile then
			local exportJson = q.armatureFile
			self.loader:addArmatureFileInfoAsync(exportJson, function(percent) 
				--if percent >= 1 then
					--finish
					self:onLoad()
				--end
			end)
		end
	end
end

function onLoad(self)
	self.loadedIndex = self.loadedIndex + 1
	local q = self.loadQueue[self.loadedIndex-1]
	if self.loadedIndex > self.resIndex then
		print("finish=======>", self.loadedIndex, self.resIndex)
		self:dispatchEvent(Event.Load,{etype=Event.Finish,pngFile=q.pngFile,armatureFile=q.armatureFile})
		self:resetQueue()
	else
		print("loading=======>", self.loadedIndex, self.resIndex,q.pngFile)
		self:doLoad(self.loadedIndex)
		self:dispatchEvent(Event.Load,{etype=Event.OnLoad,pngFile=q.pngFile,armatureFile=q.armatureFile,loadedIndex=self.loadedIndex,resIndex=self.resIndex,param=q.param})
	end
end

function resetQueue(self)
	self.loadQueue = {}
	self.resIndex = 0
	self.loadedIndex  = 0
end

