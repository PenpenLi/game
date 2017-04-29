module(...,package.seeall)
local GuildDefine = require("src/modules/guild/GuildDefine")
guildJoin = guildJoin or {}
guildSearch = guildSearch or {}
memberData = memberData or {}
position = position or GuildDefine.GUILD_NORMAL
guildName = guildName or "暂无公会"
applyList = applyList or {}

function setGuildJoin(list)
	guildJoin = list
end

function getGuildJoin()
	return guildJoin
end

function setGuildSearch(list)
	guildSearch = list[1]
end

function getGuildSearch()
	return guildSearch
end

function setMemberData(id,list)
	local mem = table.foreachi(list,function(k,v)if v.id == id then return v end end)
	memberData.mem = mem
	memberData.list = list
end

function getMemberData()
	return memberData.mem,memberData.list
end

function setGuildPos(pos)
	position = pos
end

function getGuildPos()
	return position
end

function setGuildName(name)
	guildName = name
end

function getGuildName()
	if Master.getInstance().guildId == 0 then
		guildName = "暂无公会"
	end
	return guildName
end

function clearGuildData()
	position = GuildDefine.GUILD_NORMAL
	guildName = "暂无公会"
end

function setApplyList(list)
	applyList = list
end

function getApplyList()
	return applyList
end
