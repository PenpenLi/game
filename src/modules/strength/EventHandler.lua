module(...,package.seeall)
local StrengthLogic = require("src/modules/strength/StrengthLogic")
local StrengthDefine = require("src/modules/strength/StrengthDefine")
local StrengthTips = require("src/modules/strength/ui/StrengthTips")
local StrengthTransferConfig = require("src/config/StrengthTransferConfig").Config
local StrengthConfig = require("src/config/StrengthConfig").Config
local Hero = require("src/modules/hero/Hero")

function onGCStrengthQuery(heroName,transferLv,cells)
	StrengthLogic.setData(heroName,transferLv,cells)
	--local StrengthUI = Stage.currentScene:getUI():getChild("Strength")
	--if StrengthUI then
	--	StrengthUI:refreshStrength(heroName)
	--end
	--local HeroInfoUI = Stage.currentScene:getUI():getChild("HeroInfo")
	local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
	if HeroInfoUI then
		HeroInfoUI:refreshStrength(heroName)
	end
end

function onGCStrengthAll(data)
	for i = 1,#data do
		local heroName = data[i].name
		local transferLv = data[i].transferLv
		local cells = data[i].cells
		StrengthLogic.setData(heroName,transferLv,cells)
	end
end

function onGCStrengthLvUp(retCode,heroName,cellPos)
	if retCode == StrengthDefine.STRENGTH_LV_UP_RET.kOk then
		local tips = UIManager.addChildUI("src/modules/strength/ui/StrengthTips")
		local hero = Hero.heroes[heroName]
		local strength = hero.strength
		local cell = strength.cells[cellPos]
		local cfg = StrengthLogic.getStrengthConfig(heroName,cellPos)
		local attrName = ""
		local attrVal = 0
		for k,v in pairs(cfg.lvCfg[cell.lv].attr) do
			attrName = k
			attrVal = v
			break
		end
		local val = hero.dyAttr[attrName]
		local attrTxt = Hero.getAttrCName(attrName)
		local content = string.format("%s:%d→%d",attrTxt,math.max(0,val-attrVal),val)
		tips:refreshLabel({content})
	else
		Common.showMsg(StrengthDefine.STRENGTH_LV_UP_RET_TIPS[retCode])
	end
end

function onGCStrengthTransfer(retCode,heroName)
	if retCode == StrengthDefine.STRENGTH_TRANSFER_RET.kOk then
		local function lvUpCallback()
			local hero = Hero.heroes[heroName]
			local strength = hero.strength
			local cfg = StrengthTransferConfig[strength.transferLv]
			local attrs = {}
			for k,v in pairs(cfg.attr) do
				table.insert(attrs,{name=k,src=hero.dyAttr[k]-v,dst=hero.dyAttr[k]})
			end
			local ui = require("src/ui/LvUpUI").new(heroName,attrs,"transfer")
			Stage.currentScene:addChild(ui)
			UIManager.playMusic("lvUp")
			local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
			if HeroInfoUI and HeroInfoUI.name == heroName then
				HeroInfoUI:refreshStrength(heroName)
			end
			local mainui = Stage.currentScene:getUI()
			mainui:onCheckHeroBtn()
		end
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI then
			local x = HeroInfoUI.strength.bg:getPositionX()
			local y = HeroInfoUI.strength.bg:getPositionY()
			local bone = Common.setBtnAnimation(HeroInfoUI.strength._ccnode,"TransferLvUp","成功转职")
			bone:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
				lvUpCallback()
			end)
		end
		Bag.getInstance():dispatchEvent(Event.BagRefresh,{etype=Event.BagRefresh})
	else
		Common.showMsg(StrengthDefine.STRENGTH_TRANSFER_RET_TIPS[retCode])
	end
end

function showHeroAttrChange(HeroInfoUI,heroName,cellPos,gridPos)
	local cfg = StrengthLogic.getStrengthConfig(heroName,cellPos)
	local hero = Hero.heroes[heroName]
	local strength = hero.strength
	local cell = strength.cells[cellPos]
	local attrName = ""
	local attrVal = 0
	for k,v in pairs(cfg.lvCfg[cell.lv].append) do
		attrName = k
		attrVal = v
		break
	end
	local attrTxt = Hero.getAttrCName(attrName)
	UIManager.playMusic("attrTips")
	local strength = HeroInfoUI.strength
	local cell = HeroInfoUI.strength["cell"..cellPos]
	local x = strength:getPositionX() + cell:getPositionX() + cell:getContentSize().width/2
	local y = strength:getPositionY() + cell:getPositionY() + cell:getContentSize().height
	Common.addAttrTips(attrTxt,attrVal,HeroInfoUI,{x=x,y=y})
end

function onGCStrengthEquip(heroName,cellPos,gridPos,retCode)
	if retCode == StrengthDefine.STRENGTH_EQUIP_RET.kOk then
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI then
			local panel = HeroInfoUI:getChild("StrengthOperate")
			if panel then
				UIManager.removeUI(panel)
			end
			HeroInfoUI:refreshStrength()
			function onCB() 
				showHeroAttrChange(HeroInfoUI,heroName,cellPos,gridPos)
			end
			local cell = HeroInfoUI.strength["cell"..cellPos]
			UIManager.playMusic("equip")
			Common.setBtnAnimation(cell._ccnode,"StrengthEquip","equip",{y=-10})
			Common.setBtnAnimation(HeroInfoUI.strength._ccnode,"Complete","active")
			HeroInfoUI:addTimer(onCB,0.5,1,self)
		end
	else
		Common.showMsg(StrengthDefine.STRENGTH_EQUIP_RET_TIPS[retCode])
	end
end

function onGCMaterialCompose(retCode)
	if retCode == StrengthDefine.MATERIAL_COMPOSE_RET.kOk then
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI then
			HeroInfoUI:refreshStrength()
			local operatePanel = HeroInfoUI:getChild("StrengthOperate")
			if operatePanel then
				operatePanel:playEffect()
				operatePanel:refreshComposeView()
				operatePanel:refreshAccessView()
				--operatePanel:refreshOperateView()
			end
		end
	end
	Common.showMsg(StrengthDefine.MATERIAL_COMPOSE_RET_TIPS[retCode])
end

function onGCStrengthFragCompose(retCode)
	if retCode == StrengthDefine.MATERIAL_COMPOSE_RET.kOk then
	else
	  Common.showMsg(StrengthDefine.FRAG_COMPOSE_RET_TIPS[retCode])
	end
end

function onGCStrengthQuickEquip(heroName,ret,arr)
	if ret == StrengthDefine.STRENGTH_QUICK_EQUIP_RET.kOk then
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI then
			function onCB() 
				for k,v in pairs(arr) do
					showHeroAttrChange(HeroInfoUI,heroName,v.cell,v.grid)
				end
			end
			UIManager.playMusic("equip")
			--HeroInfoUI:refreshStrength()
			for k,v in pairs(arr) do
				local cell = HeroInfoUI.strength["cell"..v.cell]
				Common.setBtnAnimation(cell._ccnode,"StrengthEquip","equip",{y=-10})
			end
			Common.setBtnAnimation(HeroInfoUI.strength._ccnode,"Complete","active")
			HeroInfoUI:addTimer(onCB,0.5,1,self)
		end
	else
		local content = StrengthDefine.STRENGTH_QUICK_EQUIP_RET_TIPS[ret]
		Common.showMsg(content)
	end
end
