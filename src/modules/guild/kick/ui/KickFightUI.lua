module(..., package.seeall)
local HeroFightListUI = require("src/ui/HeroFightListUI")
setmetatable(_M, {__index = HeroFightListUI}) 
local KickData = require("src/modules/guild/kick/KickData")

function new(guildId,memberId)
	local list = KickData.getEnemyFightList(guildId,memberId)
    local ctrl = HeroFightListUI.new(list)
    setmetatable(ctrl,{__index = _M})
    ctrl:init(guildId,memberId)
    return ctrl
end

function init(self,guildId,memberId)
	HeroFightListUI.init(self)
	local expedition = {}
	local fightList = KickData.getFightList()
	for i = 1,#fightList do
		table.insert(expedition,fightList[i].name)
	end
	self:resetHeroFightList(expedition)
	self.guildId = guildId
	self.memberId = memberId
end

function addStage(self)
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function onFight(self,event,target)
	if self:canFight() then
		local heroFightList = self.heroFightList
		local heroList = {}
		for i=1,4 do
			local name = heroFightList[i]
			if not name then
				name = ""
			end
			heroList[#heroList+1] = {name = name}
		end
		Network.sendMsg(PacketID.CG_KICK_BEGIN,self.guildId,self.memberId,heroList)
	end
end

--function onFightEnd(self,event)
--	if event.winer == "A" then
--		res = Define.FIGHT_SUCCESS 
--	else
--		res = Define.FIGHT_FAIL
--	end
--	Network.sendMsg(PacketID.CG_OROCHI_FIGHT_END,res,self.levelId)
--end
