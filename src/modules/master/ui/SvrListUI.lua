module(..., package.seeall)
setmetatable(_M, {__index = Control})

SecNum = 10
TagMap = {
	[1] = "snew",	--新服
	[2] = "snormal",	--正常
	[3] = "shot",		--火爆
}

Instance = nil
function show()
	if not Instance then
		Instance = new()
		Stage.currentScene:getUI():addChild(Instance)
	end
	Instance:setVisible(true)
end

function new()
	local ctrl = Control.new(require("res/master/SvrListSkin"),{"res/master/SvrList.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function clear(self)
	Control.clear(self)
	Instance = nil
end

function init(self)
	self.master = Master.getInstance()
	self.back:addEventListener(Event.Click,function() self:setVisible(false) end,self)
	self.svrGroup = {}
	for i,v in ipairs(Config.SvrList) do
		local pos = math.floor((i-1)/SecNum)+1
		self.svrGroup[pos] = self.svrGroup[pos] or {}
		local group = self.svrGroup[pos]
		group[#group+1] = v
	end
	--Common.printR(self.svrGroup)
	self.tag:setVisible(false)	--标签
	self.menu:setBgVisiable(false)
	self.section.svrList:setBgVisiable(false)
	self.section.svrList:setTopSpace(0)
	self:setHistory()
	self:createMenu()
end

function setHistory(self)
	local svr = MasterLoginUI.Instance:getHistorySvr()
	if not svr  then
		--无历史服务器
		self.history.title:setString("推荐服务器")
	else
		svr = Config.SvrList[svr.sid]
	end
	if not svr then
		--推荐最新服务器
		svr = Config.SvrList[#Config.SvrList]
	end
	self.history.svr:addEventListener(Event.Click,onSelectSvr,self)
	self:setSvrItem(self.history.svr,svr)
end

function createMenu(self)
	for i=#self.svrGroup,1,-1 do 
		local v = self.svrGroup[i]
		local item = self.menu:getItemByNum(self.menu:addItem())
		item.section.sName:setString(string.format("%03s--%03s区",v[1].sid,v[#v].sid))
		item.section:addEventListener(Event.TouchEvent,function(self,event,target) 
			if self.lastBtn then
				self.lastBtn:setState("normal")
			end
			target:setState("down", true)
			self.lastBtn = target
			if event.etype == Event.Touch_ended then
				self:onSelectMenu(i)
			end
		end,self)
	end
	--select first one
	local lastItem = self.menu:getItemByNum(1).section
	self.lastBtn = lastItem
	lastItem:setState("down",true)
	self:onSelectMenu(#self.svrGroup)
end

function setSvrItem(self,btn,svr)
	btn.svrName:setString(string.format("%d区 %s",svr.sid,svr.name))
	btn.sid = svr.sid
	if not svr.tag or not TagMap[svr.tag] then return end
	local tag = Image.new(self.tag[TagMap[svr.tag]]:getSkin())
	tag:setPosition(170,15)
	btn:addChild(tag)
end

function onSelectMenu(self,pos)
	local group = self.svrGroup[pos]
	self.section.sName:setString(string.format("服务器 %03s--%03s",group[1].sid,group[#group].sid))
	local list = self.section.svrList
	list:removeAllItem()
	list:setItemNum(math.ceil(#group/2))
	for k,v in ipairs(group) do
		local item = list:getItemByNum(math.floor((k-1)/2)+1)
		local btn = item["svr" .. ((k-1)%2+1)]
		btn:addEventListener(Event.Click,onSelectSvr,self)
		self:setSvrItem(btn,v)
	end
	--多余的item
	local item = list:getItemByNum(math.ceil(#group/2))
	if #group%2 ~=0 then
		item.svr2:setVisible(false)
	end
end

function onSelectSvr(self,event,target)
	local svr = Config.SvrList[target.sid] 
	MasterLoginUI.Instance:setSvr(svr)
	self:setVisible(false)
end






