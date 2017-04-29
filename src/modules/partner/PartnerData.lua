module(...,package.seeall)
local PartnerConfig = require("src/config/PartnerConfig").Config
local Hero = require("src/modules/hero/Hero")
local ChainConfig = require("src/config/PartnerChainConfig").Config
ChainList = ChainList or {}
PartnerData = PartnerData or {}
SortChainList = SortChainList or {}
Hero2PartnerCfg = Hero2PartnerCfg or nil

function setData(data)
	for i = 1,#data do
		local chainId = data[i].chainId
		PartnerData[chainId] = PartnerData[chainId] or {}
		for j = 1,#data[i].partnerIds do
			local partnerId = data[i].partnerIds[j]
			PartnerData[chainId][partnerId] = true
		end
	end
	refreshCache(data)
end

function getData()
	return PartnerData
end

function hasPartner(chainId,partnerId)
	return PartnerData[chainId] and PartnerData[chainId][partnerId]
end

function checkChainActive(chainId)
	--local chainCfg = ChainConfig[chainId]
	--for i = 1,#chainCfg.group do
	--	local partnerId = chainCfg.group[i]
	--	if not hasPartner(chainId,partnerId) then
	--		return false
	--	end
	--end
	if not hasPartner(chainId,chainId) then
		return false
	end
	return true
end

function addHero(heroName)
	--local cfg = getHero2PartnerCfg()[heroName]
	--if not cfg or not cfg.chain then
	--	return 
	--end
	--for i = 1,#cfg.chain do
	--	local chainId = cfg.chain[i]
	--	ChainList[chainId] = {}
	--	local chainCfg = ChainConfig[chainId]
	--	for j = 1,#chainCfg.group do
	--		local partnerId = chainCfg.group[j]
	--		if hasPartner(chainId,partnerId) then
	--			table.insert(ChainList[chainId],{id = partnerId,isActive = true})
	--		else
	--			table.insert(ChainList[chainId],{id = partnerId,isActive = false})
	--		end
	--	end
	--end
	--sortChainList()
end

function refreshCache(data)
	for i = 1,#data do
		local chainId = data[i].chainId
		if ChainList[chainId] then
			for j = 1,#ChainList[chainId] do
				local pId = ChainList[chainId][j].id
				--local isOwn = table.foreachi(data[i].partnerIds,function(k,v) if v == pId then return true end end)
				local isOwn = true
				ChainList[chainId][j].isActive = isOwn and true or false
			end
		end
	end
	sortChainList()
end

function getChainList()
	return ChainList
end

function getSortChainList()
	return SortChainList
end

function sortChainList()
	SortChainList = {}
	for k,v in pairs(ChainList) do
		table.insert(SortChainList,{id = k,partner = v})
	end
	--table.sort(SortChainList)
end

function getHero2PartnerCfg()
	if not Hero2PartnerCfg then
		initHero2PartnerCfg()
	end
	return Hero2PartnerCfg
end

function initHero2PartnerCfg()
	Hero2PartnerCfg = {}
	for k,v in pairs(PartnerConfig) do
		Hero2PartnerCfg[v.hero] = Hero2PartnerCfg[v.hero] or {}
		Hero2PartnerCfg[v.hero].partner = v.id
	end
	for k,v in pairs(ChainConfig) do
		for id,num in pairs(v.group) do
			if PartnerConfig[id] then
				local name = PartnerConfig[id].hero
				Hero2PartnerCfg[name] = Hero2PartnerCfg[name] or {}
				Hero2PartnerCfg[name].chain = Hero2PartnerCfg[name].chain or {}
				table.insert(Hero2PartnerCfg[name].chain,k)
			end
		end
	end
	--print("Hero2PartnerCfg")
	--Common.printR(Hero2PartnerCfg)
end

initHero2PartnerCfg()
