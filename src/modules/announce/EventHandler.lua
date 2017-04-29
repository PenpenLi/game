module(..., package.seeall)
local GuildData = require("src/modules/guild/GuildData")
local Announce = require("src/modules/announce/Announce")

function onGCAnnounceQuery(list)
	Announce.setAnnounceList(list)
end

function onGCAnnounceAdd(list)
	Announce.addAnnounceList(list)
end

function onGCAnnounceDel(id)
	Announce.delAnnounce(id)
end

