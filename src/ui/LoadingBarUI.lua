--[[
--
-- 加载进度条
--]]
module(..., package.seeall)
setmetatable(_M, {__index = Control})

UpdateEnded = "updateEnded"

local DEvent = AsyncDownloadManager.Event

function new()
	local ctrl = Control.new(require("res/common/LoadingbarSkin"),{"res/common/Loadingbar.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	local labelBgSize = self.loadLabelBg:getContentSize()
	local labelSkin = {
		name="loadLabel",type="Label",
		x=self.loadLabelBg:getPositionX() + labelBgSize.width/2,y=self.loadLabelBg:getPositionY() + labelBgSize.height/2,
		width=0,height=labelBgSize.height,
		normal={txt="test",font="SimSun",size=20,bold=false,italic=false,color={255,255,255}}
	}
	self.loadLabel = Label.new(labelSkin)
	self.loadLabel:setDimensions(0,0)
	self.loadLabel:setAnchorPoint(0.5,0.5)
	self:addChild(self.loadLabel)

	--加菊花
	local fb = Common.getRotateFlower()
	fb:setPositionY(self.loadLabel:getPositionY())
	self.flower = fb
	self._ccnode:addChild(fb)
end

function addStage(self)
	self:setWinCenter()
end

function clear(self)
    Control.clear(self)
    AsyncDownloadManager.destroyInstance()
end

function startUpdate(self)
	self.oldSize = 0
	self.newSize = 0
	self.oldTime = os.time()
	self.speed = 0
	self:setBarString("正在检查更新...")

	if Config.CheckVersion then 
		local downer = AsyncDownloadManager.getInstance()
		local totalSize = 0
		downer:addEventListener(DEvent.needUpdate,checkNeedUpdate,self)
		downer:addEventListener(DEvent.onLoad,onLoad,self)
		downer:start()
	else
		self:dispatchEvent(UpdateEnded,{needUp=false})
	end
end

function setBarString(self,val)
	self.loadLabel:setString(val)
	local x = self.loadLabel:getPositionX() - self.loadLabel:getContentSize().width/2 - 20
	self.flower:setPositionX(x)
end

function setPercent(self,val)
	if val < 97 then
		self.loadLight:setVisible(false)
	else
		self.loadLight:setVisible(true)
	end
	self.loadingBar:setPercent(val)
end


function checkNeedUpdate(self,event)
	if event.etype == DEvent.needUpdate then
		if event.ret then
			self.totalSize = event.totalSize
			self.startTime = os.time()
			self:setBarString("有新版本需要更新,大小" .. b2MB(event.totalSize))
		else
			if event.status == AsyncDownloadManager.Status.needUpCore then
				self:setBarString("需要下载最新游戏包")
				local tipsUI = TipsUI.showTopTipsOnlyConfirm("请先下载最新游戏包")
				tipsUI:addEventListener(Event.Confirm,function(target,event) 
					if event.etype == Event.Confirm_known then
						restartGame()
					end
				end)
				return
			elseif event.status == AsyncDownloadManager.Status.lostConnect then
				self:setBarString("网络异常")
			else
				self:setBarString("当前已是最新版本")
			end
			self:dispatchEvent(UpdateEnded,{needUp=false})
		end
	elseif event.etype == DEvent.checkVersion then
		self:setBarString("正在检查版本...")
	elseif event.etype == DEvent.checkFile then
		self:setBarString("正在检查文件列表...")
	end
end

function onLoad(self,event)
	if event.etype == DEvent.loading or event.etype == DEvent.finishFile then
		self.newSize = event.downloadedSize
		if (os.time() - self.oldTime) >= 1 then
			self.speed = self.newSize - self.oldSize
			self.oldSize = self.newSize
			self.oldTime = os.time()
		end
		local str = string.format("正在下载%.2f/%.2fMB,速度：%.1f kb/s",b2MB(event.downloadedSize),b2MB(self.totalSize),self.speed/1024)
		self:setBarString(str)
		self:setPercent(event.downloadedSize/self.totalSize * 100)
	elseif event.etype == DEvent.finishAll then
		--self:setBarString("更新完成")
		self:setBarString(string.format("更新完成，平均速度%.2f kb/s",(self.totalSize/(os.time()-self.startTime))/1024))
		self:dispatchEvent(UpdateEnded,{needUp=true})
	end
end

function b2MB(val)
	return val/1048576
end



