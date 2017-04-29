module(...,package.seeall)

local HeroDefine = require("src/modules/hero/HeroDefine")
local Hero = require("src/modules/hero/Hero")
function onGCHeroAttr(name,exp,lv,quality,ctime,btLv,status,dyAttr,exchange)
	local hero = Hero.heroes[name]
	if hero then
		--local temp = Hero.processDyAttr(dyAttr)
		--showHeroAttrChange(hero,temp)
		hero:freshAttr(exp,lv,quality,ctime,btLv,status,dyAttr,exchange)
	else
		Hero.heroes[name] = Hero.new(name,exp,lv,quality,ctime,btLv,status,dyAttr,exchange)
	end
	-- local LvUpUI = UIManager.getUI("Herolvup")
	-- if LvUpUI then
	-- 	LvUpUI:refreshHeroList(name)
	-- end
	local HeroInfoUI = UIManager.getUI("HeroInfo")
	if HeroInfoUI then
		HeroInfoUI:refreshLvUp(name)
	end
end
function onGCHeroAddExp(name,exp,oldLv,newLv)
	local hero = Hero.heroes[name]
	local msg = ""
	if hero and exp > 0 then
		msg = hero.cname .. " 增加 "..exp.." 经验值"
	end
	
	msg = msg .. " 等级提升至 "..newLv.." 级"
	local HeroLvUpUI = require("src/modules/hero/ui/HerolvupUI").Instance
	if HeroLvUpUI then
		HeroLvUpUI:refreshLvUp()
		if oldLv and newLv and oldLv ~= newLv then
			HeroLvUpUI:showLvUp(true)
		else
			HeroLvUpUI:showLvUp()
		end
		
	end
	local HeroMedicineListUI = require("src/modules/hero/ui/HeroMedicineListUI").Instance
	if HeroMedicineListUI then
		if oldLv and newLv and oldLv ~= newLv then
			HeroMedicineListUI:showLvUp(name,true)
		else
			HeroMedicineListUI:showLvUp(name)
		end
	end
	local SettlementUI = require("src/ui/SettlementWinUI").Instance
	if SettlementUI then
		if oldLv and newLv and oldLv ~= newLv then
			SettlementUI:onHeroLvUp(name)
		else
			SettlementUI:setHeroes(SettlementUI.expedition,SettlementUI.rewardExp)
		end
	end
	local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
	if HeroInfoUI then
		HeroInfoUI:refreshBase()
	end
	
	if oldLv ~= newLv then
		GuideManager.dispatchEvent(GuideDefine.GUIDE_REFRESH_HERO_LV, newLv)
	end

	require("src/modules/equip/EquipLogic").onHeroLvUp(name, oldLv, newLv)
	--暂时屏蔽
	--Common.showMsg(msg)
end
function onGCAllHeroAttr(heroes)
	if Hero.heroes == nil then Hero.heroes = {} end
	for i,hero in ipairs(heroes) do
		local hh = Hero.heroes
		local h = Hero.heroes[hero.name]
		if h then
			h:refreshHero(hero.name,hero.exp,hero.lv,hero.quality,hero.ctime,hero.btLv,hero.status,hero.dyAttr,hero.exchange)
		else
			Hero.heroes[hero.name] = Hero.new(hero.name,hero.exp,hero.lv,hero.quality,hero.ctime,hero.btLv,hero.status,hero.dyAttr,hero.exchange)
		end
	end
end

--断线
function onGCHeroCompose(name,result,quality)
	local msg = ''
	local cname = HeroDefine.DefineConfig[name].cname
	if result == HeroDefine.RET_OK then
		msg = cname ..' 招募成功！'
		UIManager.setUIStatus({name})
		local ui = UIManager.addUI("src/modules/hero/ui/HeroRecruitEffect",name,quality)
		ui:playEffect()
	elseif result == HeroDefine.RET_NOSUCH_HERO then
		msg = name ..' 招募失败：没有这个英雄'
		Common.showMsg(msg)
	elseif result == HeroDefine.RET_FRAG_NOTENOUGH then
		msg = name ..' 招募失败：英雄碎片不足'
		Common.showMsg(msg)
	else
		msg = name ..' 招募失败：原因未知'
		Common.showMsg(msg)
	end
	
	local HeroListUI = UIManager.getUI('HeroList')
	if HeroListUI and result == HeroDefine.RET_OK then
		-- HeroListUI:refresh()
	end
end


function onGCHeroRecruit(name,result)

end


function onGCHeroQualityUp(name,result,quality)
	local hero = Hero.getHero(name)
	local msg = ""
	local cname = HeroDefine.DefineConfig[name].cname
	if hero and result == HeroDefine.RET_OK then
		hero.quality = quality
		--msg = cname.." 升阶成功"
		--local ui = UIManager.getUI("HeroInfo")
		local ui = require("src/modules/hero/ui/HeroInfoUI").Instance
		if ui then
			ui:showQualityUpPanel()
			-- ui:refreshHero(name)
			-- --ui:showQualityUpPanel(quality)
			-- local attrs = {
			-- 	{name="star",src=quality-1,dst=quality},
			-- 	{name="atkSpeed",src=ui.oldAtkSpeed,dst=ui.hero.dyAttr.atkSpeed},
			-- 	{name="maxHp",src=ui.oldHp,dst=ui.hero.dyAttr.maxHp},
			-- 	{name="atk",src=ui.oldAtk,dst=ui.hero.dyAttr.atk},
			-- 	{name="def",src=ui.oldDef,dst=ui.hero.dyAttr.def},
			-- }
			-- UIManager.addChildUI("src/ui/LvUpUI",name,attrs)
		end
	elseif result == HeroDefine.RET_NOSUCH_HERO then
		msg = cname.." 升阶失败：没有这个英雄"
	elseif result == HeroDefine.RET_FRAG_NOTENOUGH then
		msg = cname .. " 升阶失败：英雄碎片不足"
	elseif result == HeroDefine.RET_MONEY_NOTENOUGH then
		msg = cname .." 升阶失败：金币不足"
	elseif result == HeroDefine.RET_MAXLIMIT then
		msg = cname .." 已达到最高品阶，无法再升阶"
	else
		msg = cname .." 升阶失败"
	end
	if msg ~= "" then
		Common.showMsg(msg)
	end
end

-- function onGCHeroLvUp(name,result,lv)
-- 	local hero = Hero.getHero(name)
-- 	if hero and result == HeroDefine.RET_OK then
-- 		hero.lv = lv
-- 		Common.showMsg(name.." lv = "..lv)
-- 	end
-- end
function showHeroAttrChange(hero,dyAttr)
	local temp = {}
	for k,v in pairs(dyAttr) do
		if hero.dyAttr[k] then
			local attr = k
			local val = math.floor(dyAttr[k] - hero.dyAttr[k])
			if val ~= 0 then
				table.insert(temp,{attr = k,diff = val})
			end
		end
	end
	local len = #temp
	local i = 0
	function onShowTips()
		i = i + 1
		if temp[i] then
			local attrName = Hero.getAttrCName(temp[i].attr)	
			local diff = temp[i].diff
			Common.addAttrTips(attrName,diff)
		end
	end
	onShowTips()
	if len > 1 then
		Stage.addTimer(onShowTips, 0.35, len-1)
	end
end

function onGCHeroDyattr(name,dyAttr)
	local hero = Hero.getHero(name)
	if hero then
		dyAttr = Hero.processDyAttr(dyAttr)
		--showHeroAttrChange(hero,dyAttr)
		hero.dyAttr = dyAttr
	end
end

function onGCHeroExpedition(name)
	Hero.expedition = name
end

function onGCHeroBreakthrough(name,result,lv)
	if result == HeroDefine.RET_NOSUCH_HERO then
		Common.showMsg("此英雄不存在")
	elseif result == HeroDefine.RET_HEROLV then
		Common.showMsg("英雄等级不足")
	elseif result == HeroDefine.RET_HEROSTAR then
		Common.showMsg("英雄星级不足")
	elseif result == HeroDefine.RET_FRAG_NOTENOUGH then
		Common.showMsg("突破石不足")
	elseif result == HeroDefine.RET_MONEY_NOTENOUGH then
		Common.showMsg("金币不足")
	else
		local ui = require("src/modules/hero/ui/HeroInfoUI").Instance
		if ui then
			ui:refreshHero(name)
			ui:showBreakSuccess(name,lv)
			Dot.check(ui.heroinforbg.bt,"isBreakThroughEnabled",name)
		end
	end
end

function onGCHeroTopLvup(result,name)
	local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
	if HeroInfoUI then
		HeroInfoUI:refreshBase()
	end
	local HerolvupUI = require("src/modules/hero/ui/HerolvupUI").Instance
	if HerolvupUI then
		HerolvupUI:refreshUseButton()
	end
end

function onGCHeroStarAttr(result,name,star,dyAttr)
	local ui = require("src/modules/hero/ui/HeroInfoUI").Instance
	if ui then
		local child = ui:getChild("HeroStarPreview")
		if child then
			child:setAttr(name,star,dyAttr)
		end
	end
end

function onGCHeroExchange(retCode,name,star,frag)
	if retCode ==  HeroDefine.RET_OK then
		local hero = Hero.getHero(name)
		hero.exchange[star] = frag
		Common.showMsg("兑换碎片成功")
		local ui = require("src/modules/hero/ui/HeroInfoUI").Instance
		if ui then
			ui:refreshStar()
		end
	elseif retCode == HeroDefine.RET_FRAG_NOTENOUGH then
		Common.showMsg("兑换积分不足")
	elseif retCode == HeroDefine.RET_NOSUCH_HERO then
		Common.showMsg("英雄不存在")
	elseif retCode == HeroDefine.RET_MAXLIMIT then
		Common.showMsg("兑换积分不足")
	end

end