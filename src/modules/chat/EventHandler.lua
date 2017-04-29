module(...,package.seeall)


--local Broadcast = require("common.Broadcast")

local Define = require("src/modules/chat/ChatDefine")
local ChatLogic = require("src/modules/chat/ChatLogic")
local Protocol = require("src/modules/chat/Protocol")



function onGCChat(ret,chatType,senderName,senderAccount,content,receiverName,lv,time,guildName,bodyId)
	if ret ~= 0 then
		Common.showMsg(Define.ERR_TXT[ret] or "操作失败")
	else
		ChatLogic.addChat(chatType,senderName,senderAccount,content,receiverName,lv,time,guildName,bodyId)
	end
end

function onGCChatBox(chatBox)
	for _,item in ipairs(chatBox) do
		local chat = {}
		for k,v in ipairs(Protocol.ChatItem) do
			chat[#chat+1] = item[v[1]]
		end
		if not Master.getInstance().isRelogin then
			ChatLogic.addChat(unpack(chat))
		end
	end
end


