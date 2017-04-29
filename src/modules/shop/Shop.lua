module("Shop",package.seeall)
local ShopConfig = require("src/config/ShopConfig").Config
local VipLogic = require("src/modules/vip/VipLogic")
local ShopVirtual = require("src/config/ShopVirtualConfig").Config
local LotteryConfig = require("src/config/LotteryConfig")
local MysteryShopConfig= require("src/config/MysteryShopConfig").Config
local ExpeditionShopConfig = require("src/config/ExpeditionShopConfig").Config
local GuildShopConfig = require("src/config/GuildShopConfig").Config
local ArenaShopConfig = require("src/config/ArenaShopConfig").Config
local ShopTagConfig = {}
local RareTimes = 0
local ShopUICache = {}
local ShopBuy = {}
local DotCache = 0
local ShopSrc = {}

function getShopConfigById(id)
	return ShopConfig[id]
end

function getConfigByTag(tags)
	if not next(ShopTagConfig) then
		initShopTagConfig()
	end
	return ShopTagConfig[tags] or {}
end

function initShopTagConfig()
	for k,v in pairs(ShopConfig) do
		ShopTagConfig[v.tags] = ShopTagConfig[v.tags] or {}
		local cfg = getShopConfigById(v.id)
		table.insert(ShopTagConfig[v.tags],cfg)
	end
	for k,v in pairs(ShopTagConfig) do
		table.sort(v,function(a,b) return a.sortId < b.sortId end)
	end
end

function getRareTimes()
	return RareTimes
end

function setRareTimes(times)
	RareTimes = times
end

function setBuyCnt(shopCnt)
	for k,v in pairs(shopCnt) do
		ShopBuy[v.shopId] = v.cnt
	end
end

function getBuyCnt(shopId)
	return ShopBuy[shopId] or 0
end

function getBuyCntLeft(shopId)
	local cnt = getBuyCnt(shopId)
	local cfg = ShopConfig[shopId] and ShopConfig[shopId] or ShopVirtual[shopId]
	if cfg.daylimited >= 0 then
		local append = 0
		if cfg.vipAppend and cfg.vipAppend ~= "" then
			append = VipLogic.getVipAddCount(cfg.vipAppend)
		end
		return math.max(0,cfg.daylimited + append - cnt)
	else
		return -1
	end
end

function cntQuery(shopIds)
	Network.sendMsg(PacketID.CG_SHOP_QUERY,shopIds)
end

function getPriceByTimes(shopId,cnt)
	local cfg = ShopVirtual[shopId]
	local price = 0
	if cfg then
		for i = #cfg.price,1,-1 do
			if cnt >= cfg.price[i][1] then
				price = cfg.price[i][2]
				break
			end
		end
	end
	return price
end

function onLotteryAddDot()
	DotCache = 1
	if Stage.currentScene.name == "main" then
		local mainBg = Stage.currentScene.bg1:getChild("MainBg")
		if mainBg then
			local building = mainBg:getChild("lottery")
			if building then
				addDotPic(building)
			end
		end
	end
end

function onLotteryRemoveDot()
	DotCache = 0
	if Stage.currentScene.name == "main" then
		local mainBg = Stage.currentScene.bg1:getChild("MainBg")
		if mainBg then
			local building = mainBg:getChild("lottery")
			if building then
				Dot.remove(building)
			end
		end
	end
end

function addDotPic(ctrl)
	Dot.add(ctrl)
	Dot.setDotAlignment(ctrl,"rTop",{x=130,y=30})
	Dot.setDotScale(ctrl,1.25)
end

function onLotteryCheckDot(ctrl)
	if DotCache > 0 then
		addDotPic(ctrl)
	end
end

function addDot(commonfree,rarefree,commonFreeTimes)
	local commonDayCnt = LotteryConfig.ConstantConfig[1].commonDayCnt
	local cnt = commonDayCnt - commonFreeTimes
	if rarefree <= 0 then
		onLotteryAddDot()
	else
		if cnt > 0 then
			if commonfree > 0 then
				if Shop.timer then
					Stage.delTimer(Shop.timer)
					Shop.timer = nil
				end
				Shop.timer = Stage.addTimer(onLotteryAddDot,commonfree,1)
				onLotteryRemoveDot()
			else
				onLotteryAddDot()
			end
		else
			onLotteryRemoveDot()
		end
	end
end

function getShopListById(id)
	if not next(ShopSrc) then
		for k,v in pairs(MysteryShopConfig) do
			ShopSrc[v.itemId] = ShopSrc[v.itemId] or {}
			table.insert(ShopSrc[v.itemId],"shop")
		end
		for k,v in pairs(ArenaShopConfig) do
			ShopSrc[v.itemId] = ShopSrc[v.itemId] or {}
			table.insert(ShopSrc[v.itemId],"arenaShop")
		end
		for k,v in pairs(GuildShopConfig) do
			ShopSrc[v.itemId] = ShopSrc[v.itemId] or {}
			table.insert(ShopSrc[v.itemId],"guildShop")
		end
		for k,v in pairs(ExpeditionShopConfig) do
			ShopSrc[v.itemId] = ShopSrc[v.itemId] or {}
			local isExist = false
			for kk,vv in pairs(ShopSrc[v.itemId]) do
				if vv == 'expedition' then
					isExist = true
				end
			end
			if isExist == false then
				table.insert(ShopSrc[v.itemId],"expedition")
			end
		end
		for k,v in pairs(LotteryConfig.NormalConfig) do
			ShopSrc[v.id] = ShopSrc[v.id] or {}
			table.insert(ShopSrc[v.id],"lottery")
		end
		for k,v in pairs(LotteryConfig.RareConfig) do
			ShopSrc[v.id] = ShopSrc[v.id] or {}
			table.insert(ShopSrc[v.id],"lottery")
		end
	end
	return ShopSrc[id] or {}
end

return Shop
