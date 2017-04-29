module(...,package.seeall)
local Friends = require("src/modules/friends/FriendsData")
local FriendsDefine = require("src/modules/friends/FriendsDefine")
--推荐列表
function onGCRecommendList(recommendList)
 	-- body
 	print("客户端接受请求")

 	Friends.setUserList(recommendList);
 	local FriendUI = Stage.currentScene:getUI():getChild("Friend")
 	if FriendUI then 
 		 FriendUI:refreshRecommendList();
 	end 
end 

function onGCFriendList(friendList)
 	Friends.setUserList(friendList);
 	local FriendUI = Stage.currentScene:getUI():getChild("Friend")
 	if FriendUI then 
 		FriendUI:refreshFriendList();
 	end
end 

function onGCFriendQuery(data)
	Friends.setUserInfo(data)
 	local FriendUI = Stage.currentScene:getUI():getChild("Friend")
 	if FriendUI then 
		FriendUI:queryFriend(Friends.getUserInfo());
	end 
 	-- body
end 

function onGCFriendMes()
	if Stage.currentScene.name == 'main' then
		local mainui = Stage.currentScene:getUI()
		Dot.check(mainui.mainBtn2.friend,"paint")
	end
end

function onGCApplyList(applyList)
	print("onGCApplyList")
	local FriendUI = Stage.currentScene:getUI():getChild("Friend")
	if FriendUI ~= nil then 
		local FriendMesUI = FriendUI:getChild("FriendMes")
		Dot.check(FriendUI.sq.tzzr,"friend",applyList)
		Friends.setUserList(applyList);
		if FriendMesUI ~= nil then
 			FriendMesUI:refreshApplyList();
		end
	end
	if Stage.currentScene.name == 'main' then
		local mainui = Stage.currentScene:getUI()
		Dot.check(mainui.mainBtn2.friend,"friend",applyList)
	end
end

function onGCFriendAdd(ret)
	print("onGCFriendAdd======",ret)
	local content = FriendsDefine.ADD_STATUS_TIPS[ret]
	Common.showMsg(string.format(content))
	Network.sendMsg(PacketID.CG_RECOMMEND_LIST)
end

function onGCFriendAccept(ret)
	print("onGCFriendAccept======",ret)
	local content = FriendsDefine.OP_STATUS_TIPS[ret]
	Network.sendMsg(PacketID.CG_APPLY_LIST) 
	Network.sendMsg(PacketID.CG_FRIEND_LIST) 
	Common.showMsg(string.format(content))
end

function onGCFriendReject(ret)
	print("onGCFriendReject======",ret)
	local content = FriendsDefine.OP_STATUS_TIPS[ret]
	Network.sendMsg(PacketID.CG_APPLY_LIST) 
end

function onGCFriendDel(ret)
	print("onGCFriendDel======",ret)
	local content = FriendsDefine.DEL_STATUS_TIPS[ret]
	Network.sendMsg(PacketID.CG_FRIEND_LIST) 
	Common.showMsg(string.format(content))
end


--[[function onGCGuildApply(guildId,ret)
	local content = GuildDefine.GUILD_APPLY_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
	if ret == GuildDefine.GUILD_APPLY_RET.kOk then
		local GuildUI = Stage.currentScene:getUI():getChild("Guild")
		if GuildUI then
			GuildUI:refreshGuildApplyState(guildId)
			local guild = GuildData.getGuildSearch()
			if guild and guild.id == guildId then
				guild.apply = GuildDefine.GUILD_APPLYING
				GuildData.setGuildSearch({guild})
				GuildUI:refreshSearchView()
			end
		end
	end
end

function onGCGuildApplyQuery(retCode,applyerList)
	local MemberListUI = Stage.currentScene:getUI():getChild("MemberList")
	if MemberListUI then
		MemberListUI:refreshApplyInfo(applyerList)
	end
end

function onGCGuildMemberQuery(retCode,id,memberList)
	table.sort(memberList,function(a,b) return a.pos < b.pos end )
	GuildData.setMemberData(id,memberList)
	local MemberListUI = Stage.currentScene:getUI():getChild("MemberList")
	if MemberListUI then
		MemberListUI:refreshMemberInfo()
	end
end

function onGCGuildInfoQuery(id,name,lv,icon,announce,num,active,pos)
	GuildData.setGuildPos(pos)
	GuildData.setGuildName(name)
	local GuildInfoUI = Stage.currentScene:getUI():getChild("GuildInfo")
	if GuildInfoUI then
		GuildInfoUI:refreshInfo(id,name,lv,icon,announce,num,active)
	end
	local SettingUI = Stage.currentScene:getUI():getChild("Setting")
	if SettingUI then
		SettingUI:refreshGuildInfo()
	end
--]]
