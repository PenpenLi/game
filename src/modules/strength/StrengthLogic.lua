module(...,package.seeall)
local Hero = require("src/modules/hero/Hero")
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local StrengthCell = require("src/modules/strength/StrengthCell")
local BagData = require("src/modules/bag/BagData")
local StrengthConfig = require("src/config/StrengthConfig").Config
local MaterialConfig = require("src/config/StrengthMaterialConfig").Config
local BagDefine = require("src/modules/bag/BagDefine")
local ItemConfig = require("src/config/ItemConfig").Config
local FragConfig = nil

function init(hero)
	local strength = {}
	strength.transferLv = 0
	strength.cells = {}
	for i = 1,StrengthDefine.kMaxStrengthCellCap do
		strength.cells[i] = StrengthCell.new()
	end
	return strength
end

function setData(heroName,transferLv,cells)
	local hero = Hero.getHero(heroName)
	local strength = hero.strength
	strength.transferLv = transferLv
	strength.cells = cells
	judgeUp(cells)
end

function judgeUp(cells)
	local hasUp = true
	for _,v in pairs(cells) do
		local grid = v.grids[1]
		if grid.id == 0 then
			hasUp = false
			break
		end
	end
	if hasUp == true then
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI")
		if HeroInfoUI.Instance then
			GuideManager.dispatchEvent(GuideDefine.GUIDE_START, {groupId = GuideDefine.GUIDE_TRANSFER}) 
		end
	end
end

function checkLvUp(strength,hero,pos)
	local cell = strength.cells[pos]
	local cfg = getStrengthConfig(hero.name,pos)
	local need = cfg.lvCfg[cell.lv+1].need
	local canLvUp = true
	for i = 1,#need do
		local state = checkGridState(hero,cell.grids[i].id,need[i])
		if state ~= StrengthDefine.GRID_STATE.active then
			canLvUp = false
			break
		end
	end
	return canLvUp
end

function isMaxLv(strength,pos)
	return strength.cells[pos].lv >= StrengthDefine.kMaxStrengthLv
end

function isFirstLv(strength,pos)
	return strength.cells[pos].lv <= 0
end

function isMaxTransfer(strength)
	return strength.transferLv >= StrengthDefine.kMaxTransferLv
end

function checkCanTransfer(strength)
	local canTransfer = true
	for i = 1,#strength.cells do
		if strength.cells[i].lv <= strength.transferLv then
			canTransfer = false
			break
		end
	end
	return canTransfer
end

function checkGridState(hero,gridId,id)
	--已经激活
	if gridId == id then
		return StrengthDefine.GRID_STATE.active
	end
	return checkMaterialState(hero,id)
end

function checkMaterialState(hero,id)
	--可激活
	--可合成
	--无激活
	--未激活
	local state = 0
	if BagData.getItemNumByItemId(id) > 0 then
		local cfg = ItemConfig[id]
		if hero.lv >= cfg.lv then
			state = StrengthDefine.GRID_STATE.canActive
		else
			state = StrengthDefine.GRID_STATE.noActive
		end
	else 
		if checkCanCompose(id,1) then
			state = StrengthDefine.GRID_STATE.canCompose
		else
			state = StrengthDefine.GRID_STATE.notActive
		end
	end
	return state
end

function getStrengthConfig(name,pos)
	if not StrengthConfig[name] then
		return nil
	end
	if not StrengthConfig[name][pos] then
		return nil
	end
	local cfg = {}
	for k,v in pairs(StrengthConfig[name][pos]) do
		cfg.id = k
		cfg.lvCfg = v
		appendStrengthConfig(cfg.lvCfg)
		break
	end
	return cfg
end

function appendStrengthConfig(lvCfg)
	for k,v in pairs(lvCfg) do
		local append = {}
		local need = lvCfg[k].need
		for j = 1,#need do
			local itemId = need[j]
			local cfg = MaterialConfig[itemId]
			if cfg then
				for attr,val in pairs(cfg.attr) do
					append[attr] = (append[attr] or 0) + val
				end
			end
		end
		lvCfg[k].append = append
	end
end

function checkCanCompose(id,num)
	if not MaterialConfig[id] then
		return false
	end
	local canCompose = true
	local need = MaterialConfig[id].need
	if need and next(need) then
		for k,v in pairs(need) do
			if k == id then
				assert(false,"strength materialconf id.need error===>id =" .. id)
			end
			if BagData.getItemNumByItemId(k) < v*num then
				local ownNum = BagData.getItemNumByItemId(k)
				if not checkCanCompose(k,v*num -ownNum) then
					canCompose = false
					break
				end
			end
		end
	else
		canCompose = false
	end
	return canCompose
end

function getFragConfig()
	if not FragConfig then
		FragConfig = {}
		for k,v in pairs(MaterialConfig) do
			for id,num in pairs(v.need) do
				--if BagData.getItemType(id) == BagDefine.ITEM_TYPE.kStrengthFrag then
					FragConfig[id] = {destId = k,num = num,cost = v.cost}
				--end
			end
		end
	end
	return FragConfig
end
