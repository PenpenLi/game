module(...,package.seeall)
local BagData = require("src/modules/bag/BagData")
local BagDefine = require("src/modules/bag/BagDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local Weapon = require("src/modules/weapon/Weapon")
local USE_ITEM = BagDefine.USE_ITEM
local Def = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
local PublicLogic = require("src/modules/public/PublicLogic")
local BaseMath = require("src/modules/public/BaseMath")
local ShopUI = require("src/modules/shop/ui/ShopUI")
local ShopDefine = require("src/modules/shop/ShopDefine")
local WineLogic = require("src/modules/guild/wine/WineLogic")
local ThermaeData = require("src/modules/thermae/Data")
local CrazyData = require("src/modules/crazy/Data")


function useItem(itemId,cnt)
	local cfg = ItemConfig[itemId]
	if not cfg then
		return true,USE_ITEM.kItemNotExist
	end
	if not next(cfg.clientCmd) and not next(cfg.cmd) then
		return true,USE_ITEM.kItemCanNotUse
	end
	local ret = false
	local err
	for k,v in ipairs(cfg.clientCmd) do
		for kk,vv in pairs(v) do
			if _M[kk] then
				ret,err = _M[kk](vv,cnt)
			end
		end
	end
	return ret,err
end

function checkUse(itemId)
	local cfg = ItemConfig[itemId]
	if not cfg then
		return false
	end
	if not next(cfg.clientCmd) and not next(cfg.cmd) then
		return false
	end
	for k,v in ipairs(cfg.clientCmd) do
		for kk,vv in pairs(v) do
			if _M[kk.."Check"] then
				ret = _M[kk.."Check"](vv)
				if not ret then
					return false
				end
			end
		end
	end
	return true
end

function oHeroLvup(args)
	local url = "src/modules/hero/ui/HeroMedicineListUI"
	local itemId = args[1]
	UIManager.addUI(url,itemId)
	return true
end

function oGift(args)
	local url = "src/modules/gift/ui/GiftHeroUI"
	UIManager.addUI(url)
	return true
end

function oWeaponExp(args)
	if PublicLogic.checkModuleOpen("weapon") then
		local url = "src/modules/weapon/ui/WeaponPanel"
		UIManager.addUI(url)
		return true
	else
		return false
	end
end
function oWeaponExpCheck(args)
	if PublicLogic.isModuleOpened("weapon") then
		if #Weapon.weps > 0 then
			return true
		end
	end
	return false
end

function oWeaponActiveCheck(args)
	if PublicLogic.isModuleOpened("weapon") then
		return true
	else
		return false
	end
end

function oWeaponActive(args)
	local url = "src/modules/weapon/ui/WeaponPanel"
	local ui = UIManager.addUI(url)
	local wepId = args[1]
	ui:changeToWep(wepId)
	return true
end
--function oWeaponActiveCheck(args)
--	print("oWeaponActiveCheck")
--	if #Weapon.weps > 0 then
--		return true
--	end
--	return false
--end

function oSkillHero(args)
	local url = "src/modules/skill/ui/SkillHeroUI"
	UIManager.addUI(url,1)
	return true
end

function oSkillHeroCareerCheck(args)
	local career = args[1] ~= 0 and args[1] or nil
	if career then
		for k,v in pairs(Hero.heroes) do
			if v.career == career then
				return true
			end
		end
		return false
	end
	return true
end

function oSkillHeroCareer(args)
	local career = args[1]
	local url = "src/modules/skill/ui/SkillHeroUI"
	UIManager.addUI(url,1,career)
	return true
end

function oSkillList(args)
	local url = "src/modules/skill/ui/SkillListUI"
	local name = args[1]
	UIManager.addUI(url,name)
	return true
end

function oHeroInfo(args)
	local name = args[1]
	local hero = Hero.getHero(name)
	if hero then
		local status = args[2]
		local url = "src/modules/hero/ui/HeroInfoUI"
		UIManager.addUI(url,name,status)
	else
		local url = "src/modules/hero/ui/HeroNormalListUI"
		UIManager.addUI(url,"unrecruited")
	end
	return true
end

function oHeroInfoCheck(args)
	local name = args[1]
	local hero = Hero.getHero(name)
	if hero then
		return true
	else
		local fragId = Def.DefineConfig[name].fragId
		--local need = Def.DefineConfig[name].fragment
		local need = BaseMath.getHeroRecruitFrag(name)
		local num = BagData.getItemNumByItemId(fragId)
		if num >= need then
			return true
		end
	end
	return false
end

function oPartnerChainCheck(args)
	if PublicLogic.isModuleOpened("train") then
		return true
	else
		return false
	end
end

function oPartnerChain(args)
	local name = args[1]
	local hero = Hero.getHero(name)
	if hero then
		local url = "src/modules/partner/ui/PartnerChainUI"
		UIManager.addUI(url,name)
	else
		local url = "src/modules/partner/ui/PartnerHeroUI"
		UIManager.addUI(url)
	end
	return true
end

function oShop(args)
	local url = "src/modules/shop/ui/ShopUI"
	UIManager.addUI(url)
	return true
end

function oLottery(args)
	local url = "src/modules/shop/ui/LotteryUI"
	UIManager.addUI(url)
	return true
end

function oTrial(args)
	if PublicLogic.checkModuleOpen("trial") then
		local url = "src/modules/trial/ui/TrialUI"
		UIManager.addUI(url)
		return true
	else
		return false
	end
end

function oThermae(args)
	if ThermaeData.isOpen() then
		local url = "src/modules/thermae/ui/ThermaeUI"
		UIManager.addUI(url)
		return true
	else
		Common.showMsg("未到开放时间")
		return false
	end
end

function oCrazy(args)
	if CrazyData.isOpen() then
		local url = "src/modules/crazy/ui/CrazyUI"
		UIManager.addUI(url)
		return true
	else
		Common.showMsg("未到开放时间")
		return false
	end
end

function oArena(args)
	if PublicLogic.checkModuleOpen("arena") then
		local url = "src/modules/arena/ui/ArenaUI"
		UIManager.addUI(url)
		return true
	else
		return false
	end
end

function oChapter(args)
	local url = "src/modules/chapter/ui/ChapterUI"
	UIManager.addUI(url)
	return true
end

function oExpedition(args)
	if PublicLogic.checkModuleOpen("expedition") then
		local url = "src/modules/expedition/ui/ExpeditionUI"
		UIManager.addUI(url)
		return true
	else
		return false
	end
	
end

function oBoss(args)
	local url = "src/modules/worldBoss/ui/WorldBossUI"
	UIManager.addUI(url)
	return true
end

function oTreasure(args)
	Network.sendMsg(PacketID.CG_TREASURE_MAP_INFO)
	return true
end

function oGuild(args)
	local url = "src/modules/guild/ui/GuildUI"
	UIManager.addUI(url)
	return true
end

function oOrochi(args)
	if PublicLogic.checkModuleOpen("orochi") then
		local url = "src/modules/orochi/ui/OrochiUI"
		UIManager.addUI(url)
		return true
	else
		return false
	end
	
end

function oRank(args)
	local url = "src/modules/rank/ui/RankUI"
	UIManager.addUI(url)
	return true
end

function oStrength(args)
	local name = Hero.expedition[1]
	if name then
		local url = "src/modules/hero/ui/HeroInfoUI"
		UIManager.addUI(url,name,"diamond")
	else
		UIManager.addUI("src/modules/hero/ui/HeroNormalListUI")
	end
end

function oFlower(args)
	local url = "src/modules/flower/ui/FlowerPersonalUI"
	UIManager.addUI(url)
	return true
end


function oGold(args)
	local url = "src/modules/gold/ui/GoldUI"
	UIManager.addUI(url)
	return true
end

function oPhy(args)
	ShopUI.virBuy(ShopDefine.K_SHOP_VIRTUAL_PHY_ID)
	return true
end

function oActivity2(args)
	local url = "src/modules/activity/ui/Activity2UI"
	UIManager.addUI(url)
	return true
end

function oWine(args)
	local id = args[1]
	local data = WineLogic.getData()
	if #data > 0 then
		return true,USE_ITEM.kItemWineOwn
	else
		return false
	end
end

function oBoxOpen(args,cnt)
	local boxId = args[1]
	local keyId = args[2]
	local ret = false
	if cnt == 10 then
		ret = true
	end
	if BagData.getItemNumByItemId(boxId) < cnt then
		local cfg = ItemConfig[boxId]
		Common.showMsg(string.format("%s数量不足",cfg.name))
		return ret
	elseif BagData.getItemNumByItemId(keyId) < cnt then
		local cfg = ItemConfig[keyId]
		Common.showMsg(string.format("%s数量不足",cfg.name))
		return ret
	else
		return ret,USE_ITEM.kItemBoxOpen
	end
end

function oPeak(args)
	local url = "src/modules/peak/ui/ArenaListUI"
	UIManager.addUI(url)
	return true
end
