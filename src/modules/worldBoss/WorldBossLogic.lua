module(..., package.seeall)

function startBattle()
	addBossHpDecEvent()
end

function addBossHpDecEvent()
	if Stage.currentScene:hasEventListener(Event.FightHarm, onHurt) == false then
		Stage.currentScene:addEventListener(Event.FightHarm, onHurt)
	end
end

function onHurt(listener, evt)
	if evt.name == "heroB" then
		Network.sendMsg(PacketID.CG_WORLD_BOSS_HURT_HP, evt.harm)
	end
end

function refreshBossHp(hp)
	if Stage.currentScene["setHeroBHp"] ~= nil then
    	local heroB = Stage.currentScene.heroB
		if heroB ~= nil then
			Stage.currentScene:setHeroBHp(hp)
		end
	end
end

function endBattle()
	if Stage.currentScene:hasEventListener(Event.FightHarm, onHurt) == true then
		Stage.currentScene:removeEventListener(Event.FightHarm, onHurt)
	end
end
