module("Dot",package.seeall)
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local Hero = require("src/modules/hero/Hero")
local PartnerData = require("src/modules/partner/PartnerData")
local BagData = require("src/modules/bag/BagData")
local ChainConfig = require("src/config/PartnerChainConfig").Config
local FlowerData = require("src/modules/flower/FlowerData")
local LotteryConfig = require("src/config/LotteryConfig")
local AchieveData = require("src/modules/achieve/AchieveData")
local TaskLogic = require("src/modules/task/TaskLogic")
local MailData = require("src/modules/mail/MailData")
local VipData = require("src/modules/vip/VipData")
local Weapon = require("src/modules/weapon/Weapon")
local GiftLogic = require("src/modules/gift/GiftLogic")
local Chapter = require("src/modules/chapter/Chapter")
local SkillLogic = require("src/modules/skill/SkillLogic")
local NewOpenData = require("src/modules/newopen/NewOpenData")
local NewOpenConfig = require("src/config/NewOpenConfig").Config
local MailDefine = require("src/modules/mail/MailDefine")
local PublicLogic = require("src/modules/public/PublicLogic")
local GuildData = require("src/modules/guild/GuildData")
local PaperData = require("src/modules/guild/paper/PaperData")
local GuildDefine = require("src/modules/guild/GuildDefine")
local nodeCache = {}

function add(node)
	if not node._dot then
		local res = "res/common/icon/dot/red.png"
		local dot = cc.Sprite:create(res)
		--local width = node._ccnode:getContentSize().width * 0.9
		--local height = node._ccnode:getContentSize().height * 0.9
		--local width = node:getContentSize().width - dot:getContentSize().width
		--local height = node:getContentSize().height - dot:getContentSize().height
		local width = node:getContentSize().width - 10
		local height = node:getContentSize().height -10
		dot:setPosition(width,height)
		node._ccnode:addChild(dot,100)
		node._dot = dot
	end
end

function remove(node)
	if node._dot then
		node._dot:removeFromParent()
		node._dot = nil
	end
end

function check(node,mod,...)
	local func = _M[mod]
	if func then
		local ret = func(...)
		if ret then
			add(node)
		else
			remove(node)
		end
		return ret
	end
end

function setDotScale(node,scale)
	if node._dot then
		node._dot:setScale(scale)
	end
end

--adjust={x=10,y=10}//靠近中心的距离
function setDotAlignment(node,align,adjust)
	if node._dot then
		local width = 10
		local height = 10
		local x = 0
		local y = 0
		if adjust then
			x = adjust.x or x
			y = adjust.y or y
		end
		local adjustX = 10 + x
		local adjustY = 10 + y
		if align == "rBottom" then
			width = node:getContentSize().width - adjustX
			height = adjustY
		elseif align == "rTop" then
			width = node:getContentSize().width - adjustX
			height = node:getContentSize().height - adjustY
		elseif align == "lBottom" then
			width = adjustX
			height = adjustY
		elseif align == "lTop" then
			width = adjustX
			height = node:getContentSize().height - adjustY
		end
		node._dot:setPosition(width,height)
	end
end

function addNodeToCache(node,mod)
	nodeCache[mod] = node
end

function clearNodeToCache(mod)
	nodeCache[mod] = nil
end

function checkToCache(mod,...)
	local node = nodeCache[mod]
	if node and node.alive then
		check(node,mod,...)
	end
end

function setPosFromCache(mod, offset)
	local node = nodeCache[mod]
	if node and node._dot then
		local posX,posY = node._dot:getPosition()
		node._dot:setPosition(cc.p(posX + offset.x, posY + offset.y))
	end
end

function strengthGrid(state)
	if state == StrengthDefine.GRID_STATE.canCompose or
		state == StrengthDefine.GRID_STATE.canActive then
		return true
	else
		return false
	end
end

function activityDot(actId)
	local Activity = require('src/modules/activity/Activity')
	local ret =  Activity.isActivityValid(actId)
	return ret
end


function giftHero(hero)
	return GiftLogic.checkDot(hero)
end

function giftTeam()
	for k,v in pairs(Hero.heroes) do
		local flag = giftHero(v)
		if flag then
			return true
		end
	end
	return false
end

function strengthHero(hero)
	local strength = hero.strength
	if not strength then
		return false
	end
	for i = 1,#strength.cells do
		local cell = strength.cells[i]
		local cfg = StrengthLogic.getStrengthConfig(hero.name,i)
		local need 
		if cfg and cell.lv <= strength.transferLv and not StrengthLogic.isMaxLv(strength,i) then
			if cfg.lvCfg[cell.lv + 1] then
				need = cfg.lvCfg[cell.lv+1].need
				for j = 1,#need do
					local state = StrengthLogic.checkGridState(hero,cell.grids[j].id,need[j])
					local flag = strengthGrid(state)
					if flag then
						return true
					end
				end
			end
		end
	end
	return false
end




function starHero(hero)
	if hero:isStarUpEnabled(true) then
		return true
	end
end

function chapterUIBox(chapterId,difficulty)
	return Chapter.isBoxAvailable(chapterId,difficulty)
end


function strengthTeam()
	for k,v in pairs(Hero.heroes) do
		local flag = strengthHero(v)
		if flag then
			return true
		end
	end
	return false
end

function lotteryCommon(commonfree,commonFreeTimes)
	local commonDayCnt = LotteryConfig.ConstantConfig[1].commonDayCnt
	local cnt = commonDayCnt - commonFreeTimes
	if cnt > 0 and commonfree <= 0 then
		return true
	end
	return false
end

function lotteryRare(rarefree)
	if rarefree <= 0 then
		return true
	end
	return false
end

function friend(data)
	if #data > 0 then
		return true
	end
	return false
end

function mailCheck()
	local data = MailData.getData()
	for i = 1,#data do
		if data[i].status == MailDefine.MAIL_STATUS_UNREAD then
			return true
		end
	end
	return false
end

function partnerTeam()
	--local chainList = PartnerData.getSortChainList()
	--for i = 1,#chainList do
	--	local chainId = chainList[i].id
	--	local flag = partnerChain(chainId)
	--	if flag then
	--		return true
	--	end
	--end
	--return false
	if not PublicLogic.isModuleOpened("partner") then
		return false
	end
	for k,v in pairs(Hero.heroes) do
		local flag = partnerHero(v.name)
		if flag then
			return true
		end
	end
	return false
end

function partnerHero(name)
	local cfg = PartnerData.getHero2PartnerCfg()[name]
	if not cfg then
		return false
	end
	local chainList = cfg.chain
	if not chainList then
		return false
	end
	for k,v in pairs(chainList) do
		local flag = partnerChain(v)
		if flag then
			return true
		end
	end
	return false
end

function partnerChain(chainId)
	if PartnerData.hasPartner(chainId,chainId) then
		return false
	end
	local chainCfg = ChainConfig[chainId]
	for k,v in pairs(chainCfg.group) do
		local num = BagData.getItemNumByItemId(k)
		if num < v then
			return false
		end
	end
	return true
end

function partnerGrid(chainId,partnerId)
	if not PartnerData.hasPartner(chainId,partnerId) then
		local num = BagData.getItemNumByItemId(partnerId)
		if num > 0 then
			return true
		end
	end
	return false
end

function isStarUpEnabled(heroName)
	local hero = Hero.getHero(heroName)
	if hero and hero:isStarUpEnabled(true) then
		return true
	else
		return false
	end
end

function isBreakThroughEnabled(heroName)
	local hero = Hero.getHero(heroName)
	if hero and hero:isBreakThroughEnabled() then
		return true
	else
		return false
	end
end

function flowerRefresh()
	local isRefresh = FlowerData.getInstance():getFlowerRefresh()
	if isRefresh == nil then
		return false
	end
	return isRefresh
end

function targetRefresh()
	if TaskLogic.hasFinishTask() or AchieveData.getInstance():getAchieveRefresh() or TaskLogic.hasTimeConJoinTask() or TaskLogic.hasTimeFinishTask() then
		return true
	end
	return false
end

function timeTaskRefresh()
	if TaskLogic.hasTimeConJoinTask() or TaskLogic.hasTimeFinishTask() then
		return true
	end
	return false
end

function taskRefresh()
	if TaskLogic.hasFinishTask() then
		return true
	end
	return false
end

function achieveRefresh()
	local isRefresh = AchieveData.getInstance():getAchieveRefresh()
	if isRefresh == nil then
		return false
	end
	return isRefresh
end

function weaponRefresh()
	local isRefresh = Weapon.weaponRefresh and PublicLogic.isModuleOpened("weapon")
	if isRefresh == nil then
		return false
	end
	return isRefresh
end

function signInRefresh()
	return require("src/modules/signIn/SignIn").dotRefresh()
end

function vipRefresh()
	return VipData.getInstance():getHasDaily()
end

function transferTeam()
	for k,v in pairs(Hero.heroes) do
		local flag = transferHero(v)
		if flag then
			return true
		end
	end
	return false
end

function transferHero(hero)
	local strength = hero.strength
	if not strength then
		return false
	end
	return StrengthLogic.checkCanTransfer(strength)
end

function mainUIHero()
	for name,h in pairs(Hero.heroes) do
		if starHero(h) then
			return true
		end
	end
end

function checkHeroIcon()
	if strengthTeam() or transferTeam() or mainUIHero() then
		return true
	else
		return false
	end
end

function checkNewOpenTask(day)
	local data = TaskLogic.getTaskList(1,day)
	for i = 1,#data do
		if TaskLogic.isFinishWay(data[i].taskId,1,day) then
			return true
		end
	end
	return false
end

function checkNewOpenRestTask(day)
	local data = TaskLogic.getTaskList(2,day)
	for i = 1,#data do
		if TaskLogic.isFinishWay(data[i].taskId,2,day) then
			return true
		end
	end
	return false
end

function checkNewOpenDiscount(day)
	local data = NewOpenData.getData()
	if data.rewards then
		local rewards = data.rewards[day]
		if rewards.discountGet == 0 then
			local cfg = NewOpenConfig[day]
			if cfg.limit - rewards.discountNum > 0 then
				return true
			else
				return false
			end
		else 
			return false
		end
	end
	return false
end

function checkNewOpen()
	for i = 1,7 do
		if checkNewOpenDay(i) then
			return true
		end
	end
	return false
end

function checkNewOpenDay(day)
	local data= NewOpenData.getData()
	if day > (data.day or 1) then
		return false
	end
	if checkNewOpenWelfare(day) 
		or checkNewOpenDiscount(day)
		or checkNewOpenTask(day)
		or checkNewOpenRestTask(day) then
		return true
	end
	return false
end

function checkNewOpenWelfare(day)
	local data = NewOpenData.getData()
	if data.rewards then
		local cfg = NewOpenConfig[day]
		local rewards = data.rewards[day]
		if rewards.loginGet == 1 then
			return true
		elseif rewards.rechargeNum >= cfg.rechargeNum and rewards.rechargeGet == 0 then
			return true
		else
			return false
		end
	end
	return false
end

--技能
function skill(targetHero,ctype)
	for k,hero in pairs(Hero.heroes) do
		if not targetHero or hero == targetHero then
			if SkillLogic.checkCanOpenSkill(hero,ctype) then
				return true
			end
		end
	end
	return false
end
function guildApplyCheck()
	local list = GuildData.getApplyList()
	if #list > 0 then
		local pos = GuildData.getGuildPos()
		if pos ~= GuildDefine.GUILD_LEADER and
			pos ~= GuildDefine.GUILD_SENIOR  then
			return false
		else
			return true
		end
	else
		return false
	end
end
function guildPaperCheck()
	local list = PaperData.getData()
	for k,v in pairs(list) do
		if v.get == 0 then
			return true
		end
	end
	return false
end

function paint()
	return true
end

function mop()
	return false
end


return Dot
