module("FriendsMesUI",package.seeall)
setmetatable(_M,{__index = Control})
local FriendsData = require("src/modules/friends/FriendsData")

function new()
	local ctrl = Control.new(require("res/friends/FriendMesSkin.lua"),{"res/friends/FriendMes.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function uiEffect(self)
	return UIManager.THIRD_TEMP
end

function init(self)
	_M.touch = Common.outSideTouch
	self.list:setVisible(false)
end

function refreshApplyList(self)
	local data = FriendsData.getUserList()
	print("refreshApplyList",#data)
	if FriendsData.getUserList() == nil then 
		return
	end 

	local rows = math.ceil(#data)
	local list = self.list
	list:setVisible(true)
	list:setBgVisiable(false)
	list:setItemNum(rows)
	for i = 1,rows do
		local item = list:getItemByNum(i)
		item.txttime:setVisible(false)
		item.txtzdlsz:setString(string.format("战斗力：%d",data[i].fighting));	
		item.txtnum:setString(string.format("lv.%d",data[i].lv));	
		item.heroName:setString(string.format("%s",data[i].name));	
		if not item.agree:hasEventListener(Event.Click,onAcceptfriend) then
			item.agree:addEventListener(Event.Click,onAcceptfriend,self)
		end
		item.agree.id = data[i].id

		if not item.delt:hasEventListener(Event.Click,onDeltfriend) then
			item.delt:addEventListener(Event.Click,onDeltfriend,self)
		end
		item.delt.id = data[i].id

		CommonGrid.bind(item.itembg2)
		item.itembg2:setBodyIcon(data[i].icon,0.9)
	end
end

function onAcceptfriend(self,event,target )
	local id = target.id
	Network.sendMsg(PacketID.CG_FRIEND_ACCEPT,id)
end

function onDeltfriend(self,event,target )
	local id = target.id
	Network.sendMsg(PacketID.CG_FRIEND_REJECT,id)
end

return FriendsMesUI
