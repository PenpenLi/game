module(...,package.seeall)

local Define = require("src/modules/chat/ChatDefine")
local SensitiveFilter = require("src/modules/public/SensitiveFilter")

function getChatList()
	local master = Master.getInstance()
	local chatList = master.chat
	--private cache
	local chatbox = getChatBox(Define.TYPE_PRIVATE)
	chatList[Define.TYPE_PRIVATE] = chatbox
	return chatList
end

function sendChat(chatType,content,targetName,targetAccount)
	local master = Master.getInstance()
	targetName = targetName or ""
	if chatType == Define.TYPE_PRIVATE then
		if targetName:len() < 1 then
			Common.showMsg("请先选择私聊对象")
			return
		end
		addChat(chatType,master.name,master.account,content,targetName,master.lv,os.time(),master.guildName,master.bodyId)
	end
	if targetName ~= master.name then
		local repContent = content
		if string.find(string.lower(repContent), "gm") == nil then
			repContent = SensitiveFilter.filterSensitiveWord(content)
		end
    	Network.sendMsg(PacketID.CG_CHAT,chatType,repContent,targetAccount)
	end
	if content == "gm_leak" then
		local scene = require("src/scene/LeakScene").new()
		Stage.replaceScene(scene)
	end
end

function addChat(chatType,senderName,senderAccount,content,receiverName,lv,time,guildName,bodyId) 
	local chatList = getChatList()
	local item = {
		chatType = chatType,
		senderName = senderName,
		senderAccount = senderAccount,
		lv = lv or 1,
		guildName = "",
		content = content,
		receiverName = receiverName,
		time = time,
		guildName = guildName,
		bodyId = bodyId,
	}
	chatList[chatType] = chatList[chatType] or {}
	local list = chatList[chatType] 
	if #list >= Define.MAX_LINE then
		table.remove(list,1)
	end
	list[#list + 1] = item
	--render ui
	local ui = UIManager.getUI("Chat")
	if ui then
		ui:addChat(chatType,item)
		--ui:refresh(chatType)
	end
	--cache
	if chatType == Define.TYPE_PRIVATE then
		local master = Master.getInstance()
		local chatbox = getChatBox(Define.TYPE_PRIVATE)
		if #chatbox >= 50 then
			table.remove(chatbox,1)
		end
		chatbox[#chatbox+1] = item 
		local key = string.format("chatbox_%d",Define.TYPE_PRIVATE)
		master:setDBStrVal("chat",key,Json.encode(chatbox))
	end
end

function getChatBox(chatType)
	local master = Master.getInstance()
	local key = string.format("chatbox_%d",chatType)
	local chatbox = Json.decode(master:getDBStrVal("chat",key))
	if not chatbox or type(chatbox) ~= "table" then
		chatbox = {}
	end
	return chatbox
end

function getChatByType(chatType)
	local chatList = getChatList()
	chatList[chatType] = chatList[chatType] or {}
	return chatList[chatType]
end





