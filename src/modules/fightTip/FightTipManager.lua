module(..., package.seeall)

local Define = require("src/modules/fightTip/FightTipDefine")

local hasShow = false
local timer = nil
local isShowTip = true

function init()
	Master.getInstance():addEventListener(Event.EnterScene, onEnterFightScene)
end

function onEnterFightScene()
	if Stage.currentScene.name == 'fight' and isShowTip == true then
		Stage.currentScene:addEventListener(Event.FightStart, onFightStart)
		Stage.currentScene:addEventListener(Event.FightEnd, onFightEnd)
		Stage.currentScene:addEventListener(Event.FightHarm, onFightHarm)
	end
end

function onFightStart()
	hasShow = false
	timer = Stage.currentScene:addTimer(onRefreshShow, 2, -1)
end

function onRefreshShow()
	local v = math.random(1, 100)
	if v == 50 then
		showTip()
	end
end

function onFightEnd()
	removeUI()
	timer = nil
end

function onFightHarm(listener,event)
	local curHp = event.curHp
	local maxHp = event.maxHp
	local percent = curHp / maxHp
	if percent >= 0.5 then
		showTip()	
	end
end

function showTip()
	if hasShow == false and Master.getInstance().lv <= Define.LIMIT_LV then
		removeUI()
		local ui = require("src/modules/fightTip/ui/FightTipUI").new()
		Stage.currentScene:addChild(ui)
		ui:show()
		hasShow = true
	end
end

function removeUI()
	local ui = Stage.currentScene:getChild("FightTip")
	if ui then
		hasShow = false
		ui:stopAllActions()
		ui:removeFromParent()
	end
end

function setIsShowTip(val)
	isShowTip = val
end

init()
