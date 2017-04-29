module("FriendsUI",package.seeall)
setmetatable(_M,{__index = Control})
local FriendsData = require("src/modules/friends/FriendsData")
local FriendsDefine = require("src/modules/friends/FriendsDefine")
local FriendConfig = require("src/config/FriendConfig").FriendConfig
local FlowerDefine = require("src/modules/flower/FlowerDefine")

function new()
	local ctrl = Control.new(require("res/friends/FriendSkin.lua"),{"res/friends/Friend.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.FIRST_TEMP_LABEL
end
function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function init(self)
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end

	self.back:addEventListener(Event.Click,onClose,self)
	self.sq.tzzr:addEventListener(Event.Click,onOpenFriendApply,self)
	self.tuijianhaoy.shuaxin:addEventListener(Event.Click,sendRecommendList,self)
	self.tuijianhaoy.qkss:addEventListener(Event.Click,sendRecommendList,self)
	self.search.search:addEventListener(Event.Click,sendFriendList,self)

	--self.editBoxSize = self.search.guildName:getContentSize() 
	self.search.editBox = Common.createEditBox(self.search.guildName)
	self.search.editBox:setPlaceHolder("请输入玩家昵称")
	self.search.editBox:setMaxLength(200)
	self.search._ccnode:addChild(self.search.editBox)

	for i = 1,2 do
		self.friend["region"..i]:addEventListener(Event.Click,onSelectOption,self)
		self.friend['region'..i].regionId = i
	end
	self.friend['region1']:setSelected(true)
	self.tuijianhaoy:setVisible(false)
	self.search:setVisible(false)
	self.task:setVisible(false)
	self.sq:setVisible(true)
	self.myfriend:setVisible(true)
	Network.sendMsg(PacketID.CG_APPLY_LIST)
	Network.sendMsg(PacketID.CG_FRIEND_LIST)
	self.myfriend.friendlist:setBgVisiable(false)
	self:openTimer()
	self:addEventListener(Event.Frame, onRefreshList, self)
end

function refresh(self)
	self.myfriend.friendlist:removeAllItem()
	self.dataList = FriendsData.getUserList()
	self.dataLen = #self.dataList
	self.curIndex = 1
end


function onRefreshList( self )
	if self.dataLen and self.curIndex <= self.dataLen then
		local data = self.dataList[self.curIndex]
		self:refreshFriendItem(data)
		self.curIndex = self.curIndex + 1
	end
end

function refreshFriendItem( self,data )
	local list = self.myfriend.friendlist
	local item = list:getItemByNum(list:addItem())
	item.txtzdlsz:setString(string.format("%d",data.fighting));	
	item.txtnum:setString(string.format("lv.%d",data.lv));	
	item.guildName:setString(string.format("%s",data.name));	
	local content = FriendsDefine.ONLINE_STATUS_TIPS[data.isOnline]
	item.txtonline:setString(string.format("%s",content))

	if not item.talk:hasEventListener(Event.Click,onSendMes) then
		item.talk:addEventListener(Event.Click,onSendMes,self)
	end
	item.talk.name = data.name
	item.talk.id = data.id

	if not item.delt:hasEventListener(Event.Click,onDeltfriend) then
		item.delt:addEventListener(Event.Click,onDeltfriend,self)
	end
	item.delt.id = data.id
	CommonGrid.bind(item.itembg2)
	item.itembg2:setBodyIcon(data.icon,0.9)
	item.itembg2:addEventListener(Event.TouchEvent, onShowInfo, data)
end

function onOpenFriendApply(self,event,target)
	local ui = UIManager.addChildUI("src/modules/friends/ui/FriendsMesUI")
	Network.sendMsg(PacketID.CG_APPLY_LIST)
end

function onSelectOption(self,event,target)
	if target.regionId == 1 then 
		self.tuijianhaoy:setVisible(false)
		self.search:setVisible(false)
		self.sq:setVisible(true)
		self.myfriend:setVisible(true)
		Network.sendMsg(PacketID.CG_FRIEND_LIST)
	else 
		self.tuijianhaoy:setVisible(true)
		self.search:setVisible(true)
		self.sq:setVisible(false)
		self.myfriend:setVisible(false)
		Network.sendMsg(PacketID.CG_RECOMMEND_LIST)
	end
end

function sendRecommendList(self,event,target)
		print("客户端发送请求")
		self.search.editBox:setText("")
		Network.sendMsg(PacketID.CG_RECOMMEND_LIST)
end

function refreshRecommendList(self)
	-- body
	local data = FriendsData.getUserList()
	local rows = math.ceil(#data)
	local list = self.tuijianhaoy.levelrank
	list:setBgVisiable(false)
	list:setItemNum(rows)
	for i = 1,rows do
		local item = list:getItemByNum(i)
		item.txtzdlsz:setString(string.format("%d",data[i].fighting));	
		item.txtnum:setString(string.format("lv.%d",data[i].lv));	
		item.guildName:setString(string.format("%s",data[i].name));	
		if not item.addfriend:hasEventListener(Event.Click,onAddfriend) then
			item.addfriend:addEventListener(Event.Click,onAddfriend,self)
		end
		

		item.addfriend.index = 100+i
		CommonGrid.bind(item.itembg2)
		item.itembg2:setBodyIcon(data[i].icon,0.9)
	end
end

function onShowInfo(data,event)
	if event.etype == Event.Touch_ended then
		local enemy = data.arena
		local ui = UIManager.addChildUI("src/ui/TeamTipsUI")
		enemy.index = data.id
		ui:refreshInfo(enemy, FlowerDefine.FLOWER_FROM_TYPE_ACC)
	end
end

function refreshFriendList( self )
	self:refresh()
	self.sq.dqhy:setString(string.format("当前好友：%d/%d",self.dataLen,FriendConfig[1].numMax))
end

function sendFriendList(self)
	if self.search.editBox:getText() == "" then 
		return
	end 
	if self.search.editBox:getText() == Master.getInstance().name then 
		Common.showMsg("不能添加自己为好友")
		return
	end
	Network.sendMsg(PacketID.CG_FRIEND_QUERY,self.search.editBox:getText())
	-- body
end

function queryFriend(self,data)
	local list = self.tuijianhaoy.levelrank
	if data.lv == 0 then 
		Common.showMsg("当前玩家不存在")
		list:setItemNum(0)
		return
	end

	list:setBgVisiable(false)
	list:setItemNum(1)
	for i = 1,1 do
		local item = list:getItemByNum(i)
		item.txtzdlsz:setString(string.format("%d",data.fighting));	
		item.txtnum:setString(string.format("lv.%d",data.lv));	
		item.guildName:setString(string.format("%s",data.name));
		if not item.addfriend:hasEventListener(Event.Click,onAddfriend) then
			item.addfriend:addEventListener(Event.Click,onAddfriend,self)
		end	
		item.addfriend.index = 100
		CommonGrid.bind(item.itembg2)
		item.itembg2:setBodyIcon(data.icon,0.9)
	end
end

function onAddfriend(self,event,target)
	local index = target.index - 100
	local  data = {}
	if index == 0 then 
		data = FriendsData.getUserInfo()
	else
		data = FriendsData.getUserList()[index]
	end
	Network.sendMsg(PacketID.CG_FRIEND_ADD,data.id)
end

function addFriend( id )
print(id)
	Network.sendMsg(PacketID.CG_FRIEND_ADD,id)
end

function onSendMes( self,event,target )
	UIManager.reset()
	UIManager.setChatUI(true)
	local ChatUI = Stage.currentScene:getUI():getChild("Chat")
	ChatUI:doShow()
	ChatUI.setTarget(target.id,target.name)
	ChatUI:onChat()
end

function onDeltfriend(self,event,target )
	local tipsUI = TipsUI.showTips("确定删除该好友？")
	tipsUI.yes.skillzi:setString("确定")
	tipsUI.no.skillzi:setString("取消")
	tipsUI:addEventListener(Event.Confirm,function(self, event)
		if event.etype == Event.Confirm_yes then				
			local id = target.id
			Network.sendMsg(PacketID.CG_FRIEND_DEL,id)
		end
	end,self)
end
--[[function refreshRestTask(self)
	print("refreshRestTask")
	local data = TaskLogic.getTaskList(2,self.selectDay);
	table.sort(data, function(a,b) return a.taskId<b.taskId end )
	Common.printR(data);
	
	local list = self.task.zhuxian
	list:removeAllItem()
	local rows = math.ceil(#data)
	list:setItemNum(rows)

	if rows < 1 then
		self.task.zhuxian:setVisible(false);
		self.task.nullText:setVisible(true);
	else 
		self.task.zhuxian:setVisible(true);
		self.task.nullText:setVisible(false);
	end

	for i = 1,rows do
		local conf =  TaskConfig[data[i].taskId]
		local item = list:getItemByNum(i)
		local reward = conf.reward
		local x = 1
		for k,v in pairs(reward) do
			if type(k) == "number" then
				CommonGrid.bind(item["grid"..x],"tips")
				item["grid"..x]:setItemIcon(k)
				item["grid"..x]:setItemNum(v[1])
				x=x+1;
			end
		end
		item.txtljcz:setString(string.format("%s(%d/%d)",conf.content,data[i].objNum,conf.objNum));	
		setItemProgress(self,item,data[i].taskId,TaskLogic.isFinishWay(data[i].taskId,2,self.selectDay));
	end
end]]

return FriendsUI
 
