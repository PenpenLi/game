module(...,package.seeall)

local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillDefine = require("src/modules/skill/SkillDefine")
local Hero = require("src/modules/hero/Hero")
local SkillListUI = require("src/modules/skill/ui/SkillListUI")
local SkillEquipUI = require("src/modules/skill/ui/SkillEquipUI")

function onGCSkillQuery(heroName,skillGroupList)
	SkillLogic.updateSkillGroupList(Hero.getHero(heroName),skillGroupList)
end

function onGCSkillUpgrade(ret,heroName,skillGroupList)
	local hero = Hero.getHero(heroName)
	if hero and skillGroupList then
		SkillLogic.updateSkillGroupList(hero,skillGroupList)
		local groupId = skillGroupList[1].groupId 
		local ui = SkillListUI.Instance
		if ui and ui.heroName == heroName then
			if ret == 0 then
				ui:onUpgradeSucceed(groupId)
			end
			--ui:refresh(heroName)
		end
	end
	if ret ~= 0 then
		Common.showMsg(SkillDefine.ERROR_CONTENT[ret] or "升级失败")
	end
end

function onGCSkillEquip(ret,heroName,skillGroupList)
	if ret == 0 then
		local hero = Hero.getHero(heroName)
		SkillLogic.updateSkillGroupList(hero,skillGroupList)
		local ui = SkillEquipUI.Instance
		if ui and ui.heroName == heroName then
			ui:onEquipSucceed(skillGroupList)
		end
	else
		Common.showMsg(SkillDefine.ERROR_CONTENT[ret])
	end
end

function onGCSkillUnload(ret,heroName,skillGroupList)
	if ret == 0 then
		local hero = Hero.getHero(heroName)
		SkillLogic.updateSkillGroupList(hero,skillGroupList)
		local ui = SkillListUI.Instance
		if ui and ui.heroName == heroName then
			ui:refreshEquipGroup()
		end
		Common.showMsg("成功卸下")
	else
		Common.showMsg(SkillDefine.ERROR_CONTENT[ret])
	end
end


function onGCSkillExpUp(ret,heroName,groupId,hasLvUp,lv,exp)
	if ret == 0 then
		if hasLvUp == 1 then
			hasLvUp = true
		else
			hasLvUp = false
		end
		local hero = Hero.getHero(heroName)
		local group = SkillLogic.getSkillGroupById(hero,groupId)
		if group then
			group:setLv(lv)
			group.exp = exp
		end
		local ui = SkillListUI.Instance
		if ui then
			ui:onExpUpSucceed(hasLvUp)
		end
	else
		Common.showMsg(SkillDefine.ERROR_CONTENT[ret])
	end
end

function onGCSkillAll(list)
	--Common.printR(list)
	for _,v in pairs(list) do
		SkillLogic.updateSkillGroupList(Hero.getHero(v.heroName),v.skillGroupList)
	end
end

function onGCSkillReset()
	local ui = SkillListUI.Instance
	if ui then
		ui:onResetSucceed()
	end
end

--开启技能
function onGCSkillOpen(ret,heroName,groupId)
	if ret == 0 then
		local hero = Hero.getHero(heroName)
		local group = SkillLogic.getSkillGroupById(hero,groupId)
		group:open()
		local ui = SkillEquipUI.Instance
		if ui and ui.heroName == heroName then
			ui:refresh(false,true)
		end
		Common.showMsg("成功激活")
	else
		Common.showMsg(SkillDefine.ERROR_CONTENT[ret])
	end
end



