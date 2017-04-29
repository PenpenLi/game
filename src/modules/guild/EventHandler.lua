module(...,package.seeall)
local GuildDefine = require("src/modules/guild/GuildDefine")
local GuildData = require("src/modules/guild/GuildData")
local GuildConstConfig = require("src/config/GuildConstConfig").Config
local FightControl = require("src/modules/fight/FightControl")
local FightDefine = require("src/modules/fight/Define")
local Hero = require("src/modules/hero/Hero")
local Enemy = require("src/modules/hero/Enemy")
local TexasDefine = require("src/modules/guild/texas/TexasDefine")
local GuildShopDefine = require("src/modules/guild/shop/GuildShopDefine")
local KickDefine = require("src/modules/guild/kick/KickDefine")
local WineDefine = require("src/modules/guild/wine/WineDefine")
local PaperDefine = require("src/modules/guild/paper/PaperDefine")
local GuildBossDefine = require("src/modules/guild/boss/GuildBossDefine")
local KickData = require("src/modules/guild/kick/KickData")
local GuildShop = require("src/modules/guild/shop/GuildShop")
local WineLogic = require("src/modules/guild/wine/WineLogic")
local PaperData = require("src/modules/guild/paper/PaperData")
local GuildBossLogic = require("src/modules/guild/boss/GuildBossLogic")
local GuildBossData = require("src/modules/guild/boss/GuildBossData")
local Monster = require("src/modules/hero/Monster")

function onGCGuildSearch(guildlist)
	GuildData.setGuildSearch(guildlist)
	local GuildUI = Stage.currentScene:getUI():getChild("Guild")
	if GuildUI then
		GuildUI:refreshSearchView()
	end
end

function onGCGuildCreate(ret)
	local content = GuildDefine.GUILD_CREATE_TIPS[ret]
	if ret == GuildDefine.GUILD_CREATE_RET.kNotLv then
		local lv = GuildConstConfig[1].lv
		content = string.format(content,lv)
	end
	if content then
		Common.showMsg(content)
	end
	if ret == GuildDefine.GUILD_CREATE_RET.kOk then
		local GuildUI = Stage.currentScene:getUI():getChild("Guild")
		if GuildUI then
			UIManager.removeUI(GuildUI)
		end
		--UIManager.addUI("src/modules/guild/ui/GuildInfoUI")
	end
end

function onGCGuildQuery(guildlist)
	table.sort(guildlist,function(a,b) return a.lv > b.lv end )
	GuildData.setGuildJoin(guildlist)
	local GuildUI = Stage.currentScene:getUI():getChild("Guild")
	if GuildUI then
		GuildUI:refreshJoinView()
	end
	if searchGuild then
		local list = {}
		for k,v in pairs(guildlist) do
			if v.id == searchGuild.id then
				table.insert(list,v)
				break
			end
		end
		onGCGuildSearch(list)
	end
end

function onGCGuildApplyCancel(guildId,ret)
	local content = GuildDefine.GUILD_APPLY_CANCEL_RET_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
	if ret == GuildDefine.GUILD_APPLY_CANCEL_RET.kOk then
		local GuildUI = Stage.currentScene:getUI():getChild("Guild")
		if GuildUI then
			GuildUI:refreshGuildApplyState(guildId,"applyJoin")
			local guild = GuildData.getGuildSearch()
			if guild and guild.id == guildId then
				guild.apply = GuildDefine.GUILD_NOTAPPLY
				GuildData.setGuildSearch({guild})
				GuildUI:refreshSearchView()
			end
		end
	end
end

function onGCGuildApply(guildId,ret)
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
	GuildData.setApplyList(applyerList)
	local MemberListUI = Stage.currentScene:getUI():getChild("MemberList")
	if MemberListUI then
		MemberListUI:refreshApplyInfo(applyerList)
	end
	if Stage.currentScene.name == "main" and Stage.currentScene.bg1 then
		local guildBg = Stage.currentScene.bg1:getChild("GuildBg")
		if guildBg then
			local building = guildBg:getChild("guild")
			Dot.check(building,"guildApplyCheck")
			Dot.setDotAlignment(building,"rTop",{x=260,y=200})
			Dot.setDotScale(building,1.25)
		end
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
end

function onGCGuildAccept()
end

function onGCGuildMemOperate(ret)
	local content = GuildDefine.GUILD_MEM_OPERATE_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
end

function onGCGuildAccept(ret)
	local content = GuildDefine.GUILD_ACCEPT_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
end

function onGCGuildQuit(ret)
	local content = GuildDefine.GUILD_QUIT_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
	if ret == GuildDefine.GUILD_QUIT.kOk then
		GuildData.clearGuildData()
		local SettingUI = Stage.currentScene:getUI():getChild("Setting")
		if SettingUI then
			SettingUI:refreshGuildInfo()
		end
	end
end

function onGCGuildDestroy(ret)
	local content = GuildDefine.GUILD_DESTROY_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
	if ret == GuildDefine.GUILD_DESTROY.kOk then
		GuildData.clearGuildData()
		local SettingUI = Stage.currentScene:getUI():getChild("Setting")
		if SettingUI then
			SettingUI:refreshGuildInfo()
		end
	end
end

function onGCGuildModAnnounce(txt,ret)
	local content = GuildDefine.GUILD_MOD_ANNOUNCE_RET_TIPS[ret]
	if content then
		Common.showMsg(content)
	end
	if ret == GuildDefine.GUILD_MOD_ANNOUNCE_RET.kOk then
		local GuildInfoUI = Stage.currentScene:getUI():getChild("GuildInfo")
		if GuildInfoUI then
			GuildInfoUI:refreshAnnounce(txt)
		end
	end
end

function onGCTexasQuery(lv,exp,cnt,topCards,curCards,isRefresh)
	local TexasUI = Stage.currentScene:getUI():getChild("Texas")
	if TexasUI then
		TexasUI:refreshInfo(lv,exp,cnt,topCards,curCards,isRefresh)
	end
end

function onGCTexasStart(ret)
	if ret == TexasDefine.TEXAS_START_RET.kOk then
	else
		local content = TexasDefine.TEXAS_START_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCTexasRank(rankData)
	local TexasUI = Stage.currentScene:getUI():getChild("Texas")
	if TexasUI then
		TexasUI:refreshRankInfo(rankData)
	end
end

function onGCKickGuild(guildData,cnt,fightList)
	local KickUI = Stage.currentScene:getUI():getChild("GuildKick")
	KickData.setFightList(fightList)
	if KickUI then
		KickUI:refreshInfo(guildData,cnt)
	end
end

function onGCKickRecord(recordData)
	local KickUI = Stage.currentScene:getUI():getChild("GuildKick")
	if KickUI then
		KickUI:refreshRecord(recordData)
	end
end

function onGCKickMember(memberData)
	for i = 1,#memberData do
		local data = memberData[i]
		KickData.setEnemyFightList(data.guildId,data.memberId,data.fightList)
	end
	local KickUI = Stage.currentScene:getUI():getChild("GuildKick")
	if KickUI then
		KickUI:refreshGuildMember(memberData)
	end
end

function onGCKickBegin(retCode,guildId,memberId,fightList,enemy)
	if retCode == KickDefine.KICK_BEGIN_RET.kOk then
		KickData.setFightList(fightList)
		local myHeroList = {}
		for i = 1,#fightList do
			table.insert(myHeroList,Hero.heroes[fightList[i].name])
		end
		local enemyHeroList = {}
		for k,v in pairs(enemy.fightList) do
			local hero = Enemy.new(v.name,v.exp,v.lv,v.quality,os.time(),v.dyAttr,v.skillGroupList,v.gift)
			table.insert(enemyHeroList,hero)
		end
		local fightControl = FightControl.new(myHeroList, enemyHeroList)
		local scene = require("src/scene/FightScene").new(fightControl,FightDefine.FightModel.autoA_autoB,FightDefine.FightType.guild)
		scene:addEventListener(Event.FightEnd,function(self,event)
			if event.winer == 'A' then
				Network.sendMsg(PacketID.CG_KICK_END,KickDefine.KICK_WIN,guildId,memberId)
			else
				Network.sendMsg(PacketID.CG_KICK_END,KickDefine.KICK_LOSE,guildId,memberId)
			end
		end,self)
		Stage.replaceScene(scene)
	else
		local content = KickDefine.KICK_BEGIN_RET_TIPS[retCode]
		Common.showMsg(content)
	end
end

function onGCKickEnd(result)
	UIManager.addUI('src/modules/guild/kick/ui/SettlementUI',result)
end

function onGCGuildShopQuery(shopData,refreshTimes)
	GuildShop.setRefreshTimes(refreshTimes)
	--local GuildShopUI = Stage.currentScene:getUI():getChild("GuildShopUI")
	local GuildShopUI = require("src/modules/guild/shop/ui/GuildShopUI").Instance
	if GuildShopUI then
		GuildShopUI:refreshShopData(shopData)
		GuildShopUI:refreshTimes()
	end
end

function onGCGuildShopRefresh(retCode)
	local content = GuildShopDefine.GUILD_REFRESH_RET[retCode]
	Common.showMsg(content)
end

function onGCGuildShopBuy(id,ret)
	local content = GuildShopDefine.GUILD_BUY_RET[ret]
	Common.showMsg(content)
	if ret == GuildShopDefine.GUILD_BUY.kOk then
		--local GuildShopUI = Stage.currentScene:getUI():getChild("GuildShopUI")
		local GuildShopUI = require("src/modules/guild/shop/ui/GuildShopUI").Instance
		if GuildShopUI then
			GuildShopUI:setShopItemBuyState(id,Button.UI_BUTTON_DISABLE)
		end
	end
end

function onGCWineQuery(lv,exp,cnt)
	local WineUI = Stage.currentScene:getUI():getChild("Wine")
	if WineUI then
		WineUI:refreshInfo(lv,exp,cnt)
	end
end

function onGCWineStart(ret,rewards)
	if ret == WineDefine.WINE_START_RET.kOk then
		local WineUI = Stage.currentScene:getUI():getChild("Wine")
		if WineUI then
			WineUI:playEffect(rewards)
		end
	else
		local content = WineDefine.WINE_START_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCWineDonate(ret)
	local content = WineDefine.WINE_DONATE_RET_TIPS[ret]
	Common.showMsg(content)
end

function onGCWineBuffQuery(wineBuff)
	WineLogic.setData(wineBuff)
	if Stage.currentScene.name == "main" then
		local mainui = Stage.currentScene:getUI()
		mainui:setWineTime()
	end
end

function onGCPaperQuery(group)
	PaperData.setData(group)
	local PaperUI = Stage.currentScene:getUI():getChild("Paper")
	if PaperUI then
		PaperUI:refreshInfo()
	end
	if Stage.currentScene.name == 'main' then
		local mainui = Stage.currentScene:getUI()
		Dot.check(mainui.hongbao,"guildPaperCheck")
	end
end

function onGCSendPaper(ret)
	local content = PaperDefine.PAPER_SEND_RET_TIPS[ret]
	Common.showMsg(content)
end

function onGCGetPaper(id,ret,num)
	local PaperUI = Stage.currentScene:getUI():getChild("Paper")
	if PaperUI then
		PaperUI:refreshItem(id,num)
	end
end

function onGCNewPaper()
	Common.showMsg("公会有人发红包，快去抢啦！")
	Network.sendMsg(PacketID.CG_PAPER_QUERY)
end

function onGCGuildBossQuery(hasStart,coolTime,hurt,heroList)
	local panel = Stage.currentScene:getUI():getChild("GuildBossUI")
	if panel then
		panel:refreshInfo(hasStart,coolTime,hurt,heroList)
	end
end

function onGCGuildBossEnter(ret,bossId,hp)
	if ret == GuildBossDefine.BOSS_ENTER_RET.kOk then
		local panel = Stage.currentScene:getUI():getChild("GuildBossFightUI")
		if panel then
			local monster = Monster.new(bossId)
			monster.fightAttr = {hp = hp}
			local list = {}
			table.insert(list, monster)
			panel.enemyFightList = list
			panel:doTeamFight()
			GuildBossLogic.start()
		end
	else
		local content = GuildBossDefine.BOSS_ENTER_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCGuildBossEnterQuery(ret)
	if ret == GuildBossDefine.BOSS_ENTER_QUERY_RET.kOk then
		local GuildBossUI = Stage.currentScene:getUI():getChild("GuildBossUI")
		if GuildBossUI then
			local ui = UIManager.addUI("src/modules/guild/boss/ui/GuildBossFightUI")
			ui:resetHeroFightList(GuildBossUI.heroList)
		end
	else
		local content = GuildBossDefine.BOSS_ENTER_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCGuildBossLeave()
end

function onGCGuildBossHurt(hp)
	print("onGCGuildBossHurt")
	print(hp)
	GuildBossLogic.refreshBossHp(hp)
end

function onGCGuildBossStart()
end
function onGCGuildBossEnd()
end

function onGCGuildBossRank(list)
	GuildBossData.setRankList(list)
	local GuildBossUI = Stage.currentScene:getUI():getChild("GuildBossUI")
	if GuildBossUI then
		GuildBossUI:refreshRank(list)
	end
end

function onGCGuildBossCheckTeam(rank,fighting,flowerCount,heroList)
	local panel = Stage.currentScene:getUI():getChild("GuildBossUI")
	if panel then
		local rankPanel = panel:getChild("GuildBossRankUI")
		if rankPanel then
			rankPanel:showTeamUI(rank, fighting, flowerCount, heroList)
		end
	end

end
