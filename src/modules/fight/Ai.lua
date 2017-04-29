module(..., package.seeall)
local AiConfig = require("src/config/hero/AiConfig").Config
local CommonAiConfig = require("src/config/hero/CommonAiConfig").Config
local AutoAiConfig = require("src/config/hero/AutoAiConfig").Config
local Helper = require("src/modules/fight/KofHelper")
local Define = require("src/modules/fight/Define")
local Hero = require("src/modules/fight/Hero")
local FightLogic = require("src/modules/fight/FightLogic")
local SkillLogic = require("src/modules/skill/SkillLogic")
local SkillDefine = require("src/modules/skill/SkillDefine")
local SoundManager = require("src/modules/fight/SoundManager")
local GiftDefine = require("src/modules/gift/GiftDefine")
local GiftLogic = require("src/modules/gift/GiftLogic")

function createAiConfig()
	local o = {}
	for k,v in pairs(AiConfig) do
		o[v.name] = o[v.name] or {}
		--o[v.nameA][v.nameB] = o[v.nameA][v.nameB] or {}
		table.insert(o[v.name],{skillA = v.skillA,skillB = v.skillB,rangeMin = v.rangeMin,rangeMax = v.rangeMax,id=k})

		--[[
		o[v.nameB] = o[v.nameB] or {}
		o[v.nameB][v.nameA] = o[v.nameB][v.nameA] or {}
		table.insert(o[v.nameB][v.nameA],{skillA = v.skillB,skillB = v.skillA,rangeMin = v.rangeMin,rangeMax = v.rangeMax,id=k})
		--]]
	end
	return o
end

function createCommonAiConfig()
	local o = {}
	for k,v in pairs(CommonAiConfig) do
		o[v.type] = o[v.type] or {}
		table.insert(o[v.type],v.actionList)
	end
	return o
end
aiConfig = createAiConfig()
commonAiConfig = createCommonAiConfig()

AI_STATE_NONE	  = -1	
AI_STATE_START	  = 0	--开场
AI_STATE_CLOSE_TO = 1	--靠近 
AI_STATE_FAR_AWAY = 2	--远离
AI_STATE_SWAP     = 3   --交换位置 
AI_STATE_HIT	  = 4	--击打
AI_STATE_END	  = 5	--结束
AI_STATE_COMBO	  = 6	--接招
AI_STATE_POWER	  = 7	--大招
AI_STATE_ASSIST   = 8	--援助

function useBreak(fight,heroA,heroB)
	local state = fight.aiState
	if state <= AI_STATE_START
		or state > AI_STATE_COMBO
		or fight.heroA:getInfo():isDie() 
		or fight.heroB:getInfo():isDie() 
		or fight.comboA
		or fight.comboB then
		return false
	end
	--if heroB:isHiting() and heroA:getInfo():canUsePower(Define.breakPower) then
	if heroA:isBeBeat() and heroA:getInfo():canUsePower(Define.breakPower) then
		local cfg = AutoAiConfig[heroA:getAi()]
		if math.random(0,99) < cfg.breakPower then
			heroA:getInfo():decPower(Define.breakPower)
			fight:changeAiState(AI_STATE_POWER)
			fight.aiData.sender = heroA
			fight.aiData.reciever = heroB
			return true
		end
	end
	return false
end

function usePower(fight,heroA,heroB)
	--[[
	do
		return false
	end
	--]]
	local state = fight.aiState
	if state <= AI_STATE_START
		or state > AI_STATE_END 
		or fight.heroA:getInfo():isDie() 
		or fight.heroB:getInfo():isDie() 
		or fight.comboA
		or fight.comboB then
		return false
	end
	if not heroA:isBeBeat() and heroA:getInfo():canUsePower(Define.powPower) then
		local p = heroA:getInfo():getPower()
		local cfg = AutoAiConfig[heroA:getAi()]
		for k,v in ipairs(cfg.pow) do
			if p <= v[1] then
				if math.random(0,99) >= v[2] then
					return false
				else
					break
				end
			end
		end

		--[[
		if p < 150 then
			--10
			if math.random(0,99) >= 10 then
				return false
			end
		elseif p < 200 then
			--20
			if math.random(0,99) >= 20 then
				return false
			end
		elseif p < 275 then
			--50
			if math.random(0,99) >= 50 then
				return false
			end
		else
		end
		--]]
		heroA:getInfo():decPower(Define.powPower)
		fight:changeAiState(AI_STATE_POWER)
		fight.aiData.sender = heroA
		fight.aiData.reciever = heroB
		return true
	end
	return false
end

function useCombo(fight,heroA,heroB)
	--[[
	do
		return false
	end
	--]]
	local cfg = AutoAiConfig[heroA:getAi()]
	if math.random(0,100) < cfg.combo then
		heroA:getInfo():decPower(Define.comboPower)
		fight:changeAiState(AI_STATE_COMBO)
		fight.aiData.sender = heroA
		fight.aiData.reciever = heroB
		fight.comboA = nil
		fight.comboB = nil
		return true
	end
	return false
end

local callAssistTime = 0
function callAssist(fight,hero,assist,callType)
	--print('=======================callAssistTime:',callAssistTime)
	local state = fight.aiState
	if state <= AI_STATE_START
		or fight.heroA:getInfo():isDie() 
		or fight.heroB:getInfo():isDie()  then
		--or fight.comboA
		--or fight.comboB then
		return false
	end
	if not hero:getInfo():canUseAssist() or hero:getAssist() then
		return false
	end
	local fightModel = Stage.currentScene.fightModel
	if fight.heroA == hero then
		if fightModel ~= Define.FightModel.autoA_autoB and fightModel ~= Define.FightModel.autoA_handB then
			return false
		end
	else
		if fightModel ~= Define.FightModel.handA_autoB and fightModel ~= Define.FightModel.autoA_autoB then
			return false
		end
	end
	local skill = SkillLogic.getSkillGroup(assist,SkillDefine.TYPE_ASSIST):getSkillObjList()[1]
	local assistType = skill:getAssistType()
	local ret = false
	local cfg = AutoAiConfig[hero:getAi()]
	if callType == "time" then
		if callAssistTime < 3 then
			return false
		end
		callAssistTime = 0
		if assistType == "atkBuf" or assistType == "hp" or assistType == "hpR" or assistType == "atk"  then
			local p = hero:getInfo():getHpPercent()
			for k,v in ipairs(cfg.assist[assistType]) do
				if p <= v[1] then
					if math.random(0,99) >= v[2] then
						return false
					else
						break
					end
				end
			end
		else
			return false
		end
	elseif callType == "hiting" then
		if assistType == "defD" or assistType == "rageD" then
			if math.random(0,99) >= cfg.assist[assistType] then
				return false
			end
		else
			return false
		end
	elseif callType == "beBeat" then
		if assistType == "rageA" then
			if math.random(0,99) >= cfg.assist[assistType] then
				return false
			end
		else
			return false
		end
	end

	hero:getInfo():decAssist()
	if fight.heroA == hero then
		fight.newAssistA = true
	else
		fight.newAssistB = true
	end
	doAssist(fight)
	return true
end

function doAi(fight,delay)
	callAssistTime = callAssistTime + delay
	--[[
	if fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
		doEnd(fight,delay)
		return
	end
	--]]
	local state = fight.aiState
	if state ~= AI_STATE_END then
		--print('=-=============================aiState:',state,fight.hitState)
		local fightModel = Stage.currentScene.fightModel
		if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB then
			if usePower(fight,fight.heroA,fight.heroB) then
				--print('------------------------return 1')
				return
			end
			if callAssist(fight,fight.heroA,Stage.currentScene.fightControl:getAssistA(),"time") then
				--print('------------------------return 2')
				return
			end
		end

		if fightModel == Define.FightModel.handA_autoB or fightModel == Define.FightModel.autoA_autoB then
			if usePower(fight,fight.heroB,fight.heroA) then
					--print('------------------------return 3')
				return
			end
			if callAssist(fight,fight.heroB,Stage.currentScene.fightControl:getAssistB(),"time") then
					--print('------------------------return 4')
				return
			end
		end
		if fight.comboA and fight.heroA:getInfo():canUsePower(Define.comboPower) and not fight.aiData.comboA then
			--能接招------就                  等
			--有50%的概率接招
			if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB then
				if useCombo(fight,fight.heroA,fight.heroB) then
					return
				end
				fight.aiData.comboA = true
			end
		end
		if fight.comboB and fight.heroB:getInfo():canUsePower(Define.comboPower) and not fight.aiData.comboB then
			if fightModel == Define.FightModel.handA_autoB or fightModel == Define.FightModel.autoA_autoB then
				if useCombo(fight,fight.heroB,fight.heroA) then
					return
				end
				fight.aiData.comboB = true
			end
			return
		end
	end

	if state == AI_STATE_CLOSE_TO then
		doCloseTo(fight,delay)
	elseif state == AI_STATE_FAR_AWAY then
		doFarAway(fight,delay)
	elseif state == AI_STATE_SWAP then
		doSwap(fight,delay)
	elseif state == AI_STATE_HIT then
		doHit(fight,delay)
	elseif state == AI_STATE_COMBO then
		doCombo(fight,delay)
	elseif state == AI_STATE_START then
		doStart(fight,delay)
	elseif state == AI_STATE_END then
		doEnd(fight,delay)
	elseif state == AI_STATE_POWER then
		doPower(fight,delay)
	end
end

function checkState(fight)
	if not fight.heroA:isJump() and not fight.heroB:isJump()  then
		local dis = Helper.heroDistance(fight.heroA,fight.heroB)
		if dis < fight.rangeMin then
			return AI_STATE_FAR_AWAY 
		elseif dis > fight.rangeMax then
			return AI_STATE_CLOSE_TO
		else
			return AI_STATE_HIT
		end
	end
	if fight.heroA:getInfo():isDie() and not fight.heroB:isJump() then
		return AI_STATE_HIT
	end
	if fight.heroB:getInfo():isDie() and not fight.heroA:isJump() then
		return AI_STATE_HIT
	end
	--return false
end

function playCommonAi(hero,cfg)
	local v = cfg.cfg[cfg.index]
	hero:play(v[1],true)
	if v[1] == "stand" or v[1] == "stand_heavy_defense" or v[1] == "stand_light_defense" then
		cfg.nextTime = v[2] 
	elseif v[1] == "forward" or v[1] == "forward_run" or v[1] == "back" then
		cfg.nextTime = v[2] / math.abs(hero.curState.speedX)
	end
end

function checkCommonAi(hero,cfg)
	if hero.curState.lock > Define.AttackLock.defense then
		return false
	end
	local v = cfg.cfg[cfg.index]
	if v[1] == "stand" or v[1] == "stand_heavy_defense" or v[1] == "stand_light_defense" or v[1] == "forward" or v[1] == "forward_run" or v[1] == "back" then
		if cfg.time >= cfg.nextTime then 
			return true
		end
		--[[
	elseif v[1] == "forward" or v[1] == "forward_run" or v[1] == "back" then
		if cfg.frame >= cfg.nextFrame then
			return true
		end
		--]]
	else
		return hero.curState.name == "stand"
	end
	return false
end

function doCommonAi(fight,delay,hero,state)
	if fight.aiData[hero] then
		local cfg = fight.aiData[hero]
		cfg.frame = cfg.frame + 1
		cfg.time = cfg.time + delay
		if checkCommonAi(hero,cfg) then
			cfg.time = 0
			cfg.frame = 0
			cfg.index = cfg.index + 1
			if not cfg.cfg[cfg.index] then
				fight.aiData[hero] = nil
			else
				playCommonAi(hero,cfg)
			end
		end
	else
		if hero:canForward() then
			local cfg = getRandomCommonAi(state)
			fight.aiData[hero] = {
				cfg = cfg,
				time = 0,
				frame = 0,
				index = 1,
			}
			playCommonAi(hero,fight.aiData[hero])
		end
	end
end

function doCloseTo(fight,delay)
	local state = checkState(fight)
	---[[
	if state and (fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie()) then
		fight:changeAiState(AI_STATE_END)
		return
	end
	--]]
	if state == AI_STATE_HIT then
		fight:changeAiState(AI_STATE_HIT)
		return
	elseif state == AI_STATE_FAR_AWAY then
		fight:changeAiState(AI_STATE_FAR_AWAY)
		return
	end

	doCommonAi(fight,delay,fight.heroA,AI_STATE_CLOSE_TO)
	doCommonAi(fight,delay,fight.heroB,AI_STATE_CLOSE_TO)
end

function doFarAway(fight,delay)
	local state = checkState(fight)
	---[[
	if state and (fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie()) then
		fight:changeAiState(AI_STATE_END)
		return
	end
	--]]
	if state == AI_STATE_HIT then
		fight:changeAiState(AI_STATE_HIT)
		return
	elseif state == AI_STATE_CLOSE_TO then
		fight:changeAiState(AI_STATE_CLOSE_TO)
		return
	end

	doCommonAi(fight,delay,fight.heroA,AI_STATE_FAR_AWAY)
	doCommonAi(fight,delay,fight.heroB,AI_STATE_FAR_AWAY)
end

function doSwap(fight)
	if fight.heroA.curState.lock ~= Define.AttackLock.normal or fight.heroB.curState.lock ~= Define.AttackLock.normal then
		return
	end
	if fight.aiData.notFirst then
		return
	end
	fight.aiData.notFirst = true
	--[[
	local playId
	if math.random(1,2) == 1 then
		playId = fight.heroA:play("jump_forward",true) 
		fight.heroB:play("forward_run",true)
	else
		playId = fight.heroB:play("jump_forward",true) 
		fight.heroA:play("forward_run",true)
	end
	fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
		fight:changeAiState(AI_STATE_HIT)
	end
	--]]
	local xa = fight.heroA:getPositionX()
	local xb = fight.heroB:getPositionX()
	if (xa < xb and fight.heroA:getDirection() == Hero.DIRECTION_RIGHT) or (xa > xb and fight.heroA:getDirection() == Hero.DIRECTION_LEFT) then
		playId = fight.heroA:play("back_run",true) 
		fight.heroB:play("forward_run",true)
	else
		playId = fight.heroB:play("back_run",true) 
		fight.heroA:play("forward_run",true)
	end
	fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
		fight:changeAiState(AI_STATE_HIT)
	end
end

function doCombo(fight,delay)
	if not fight.aiData.run then
		fight.aiData.run = true
		fight.aiData.sender:play("forward_run",true)
		fight.aiData.sender.speedX = 960
		fight.aiData.sender:displayComboEffect()
		if fight.aiData.sender == fight.heroA then
			Stage.currentScene:displayPowerTips("Combo")
		end
		return
	end
	if fight.aiData.combo then
		return
	end
	fight.comboA = nil
	fight.comboB = nil
	fight.aiData.comboTips = (fight.aiData.sender == fight.heroA)


	local skill = fight.aiData.sender:getComboSkill()
	--print('==============================comboSkill:',skill,skill.actionId,fight.aiData.sender.config[skill.actionId])
	local rangeMin,rangeMax = fight.aiData.sender.config[skill.actionId].rangeMin,fight.aiData.sender.config[skill.actionId].rangeMax
	local dis = Helper.heroDistance(fight.aiData.sender,fight.aiData.reciever)
	if dis <= rangeMax then
		fight.aiData.combo = true
		fight.aiData.sender:setCurSkill(skill)

		Stage.currentScene.ui:displaySkillNameEffect(fight.aiData.sender,skill:getGroupName())
		fight.aiData.sender:displayCareer()
		GiftLogic.checkGift(fight.aiData.sender,GiftDefine.ConditionType.useCombo)

		if fight.heroA == fight.aiData.sender then
			callAssist(fight,fight.heroA,Stage.currentScene.fightControl:getAssistA(),"hiting")
			callAssist(fight,fight.heroB,Stage.currentScene.fightControl:getAssistB(),"beBeat")
		else
			callAssist(fight,fight.heroA,Stage.currentScene.fightControl:getAssistA(),"beBeat")
			callAssist(fight,fight.heroB,Stage.currentScene.fightControl:getAssistB(),"hiting")
		end

		local playId = fight.aiData.sender:play(skill.actionId,true,true)
		fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
			if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
				fight:changeAiState(AI_STATE_END)
				return
			end
			local fightModel = Stage.currentScene.fightModel
			if (fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB) and hero == fight.heroB then
				if useBreak(fight,fight.heroA,fight.heroB) then
					return
				end
			end

			if (fightModel == Define.FightModel.handA_autoB or fightModel == Define.FightModel.autoA_autoB) and hero == fight.heroA then
				if useBreak(fight,fight.heroB,fight.heroA) then
					return
				end
			end
			local t = fight.isComboStop and 99999 or 0.5
			if hero == fight.heroA then
				fight.comboA = true
				if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB then 
					t = 0.05
				end
			else
				fight.comboB = true
				if fightModel == Define.FightModel.handA_autoB or fightModel == Define.FightModel.autoA_autoB then
					t = 0.05
				end
			end
			Stage.currentScene:addTimer(function() 
				if fight.comboA or fight.comboB then
					--fight.canCombo = nil
					fight.comboA = nil
					fight.comboB = nil
					doAfterRound(fight)
				end
			 end,t,1)
			--doAfterRound(fight)
			Stage.currentScene:dispatchEvent(Event.FightCombo, {etype=Event.FightCombo,heroAIndex = Stage.currentScene.fightControl.heroAIndex,heroBIndex = Stage.currentScene.fightControl.heroBIndex,hero = hero})
		end
	end
	
		--fight.aiData.sender:setCurSkill(skill)
end

HIT_STATE_START = 1	--回合开始
HIT_STATE_PERFORM = 2	--进入表演阶段
HIT_STATE_REAL = 3		--真实有效阶段
HIT_STATE_POWER = 4		--爆气

function getRange(fight)
	local skillId = fight.report:getCurrentSkillId()
	local isAHit = fight.report:isAHit()
	print('------------------------skillId,isAHit:',skillId,isAHit)
	if isAHit then
		return fight.heroA.config[skillId].rangeMin,fight.heroA.config[skillId].rangeMax
	else
		return  fight.heroB.config[skillId].rangeMin,fight.heroB.config[skillId].rangeMax
	end
end

function getName(fight)
	return fight.heroA.heroName,fight.heroB.heroName
	--[[
	local isAHit = fight.report:isAHit()
	if isAHit then
		return fight.heroB.heroName,fight.heroA.heroName
	else
		return fight.heroA.heroName,fight.heroB.heroName
	end
	--]]
end

function hitToRun(fight)
	local dis = Helper.heroDistance(fight.heroA,fight.heroB)
	if dis > fight.rangeMax then
		fight:changeAiState(AI_STATE_CLOSE_TO)
	elseif dis < fight.rangeMin then
		fight:changeAiState(AI_STATE_FAR_AWAY)
	else
		fight:changeAiState(AI_STATE_HIT)
	end
end

function canHit(fight)
	local skillId = fight.report:getCurrentSkillId()
	if fight.report:isAHit() then
		return fight.heroA:canHit(skillId)	
	else
		return fight.heroB:canHit(skillId)
	end
end

function doAfterRound(fight)
	fight.rangeMin = math.random(100,200)
	fight.rangeMax = fight.rangeMin + 1000
	fight.hitState = HIT_STATE_START
	fight:changeAiState(AI_STATE_FAR_AWAY)
	fight.heroA:doAfterRound()
	fight.heroB:doAfterRound()
	Stage.currentScene.ui:removeSkillNameEffect(fight.heroA)
	Stage.currentScene.ui:removeSkillNameEffect(fight.heroB)
end

function swapPosition(fight)
	fight.rangeMin = 40
	fight.rangeMax = 1000
	fight.hitState = HIT_STATE_START
	fight:changeAiState(AI_STATE_SWAP)
end

function doHit(fight,delay)
	local isAHit = fight.report:isAHit()
	if isAHit then
		if not fight.heroA:isReadyToBeat() then
				--print('------------------------return 5')
			return
		end
	else
		if not fight.heroB:isReadyToBeat() then
				--print('------------------------return 6')
			return
		end
	end
	if fight.aiData.notFirst then
		return
	end
	fight.aiData.notFirst = true
	if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
		fight:changeAiState(AI_STATE_END)
		return
	end
	if fight.hitState == HIT_STATE_START then
		doHitStart(fight)
	elseif fight.hitState == HIT_STATE_PERFORM then
		doHitPerform(fight)
	elseif fight.hitState == HIT_STATE_REAL then
		doHitReal(fight)
	elseif fight.hitState == HIT_STATE_POWER then
		doHitPower(fight)
	end
end

local lastAiName = ""
local lastAiIndex = -1

function getRandomAi(name)
	local skillList = aiConfig[name]
	--local skillList = heroList[nameB]
	if skillList then
		local index = math.random(1,#skillList)
		local cnt = 0
		while lastAiName == name  and lastAiIndex == index do
			index = math.random(1,#skillList)
			cnt = cnt + 1
			if cnt > 10 then
				break
			end
		end
		lastAiName = name
		lastAiIndex = index

		local v = skillList[index]
		--print('----------------------------Ai,英雄A,英雄B,下标:',nameA,nameB,v.id,v.skillA,v.skillB)
		return v
	end
end

local lastCommonAiType = -1
local lastCommonAiIndex = -1
function getRandomCommonAi(t)
	 local actionList = commonAiConfig[t]
	 if actionList then
		 local cnt = 1
		 local index = math.random(1,#actionList)
		 while lastCommonAiType == t and index == lastCommonAiIndex do
			   index = math.random(1,#actionList)
			   cnt = cnt + 1
			   if cnt > 10 then 
				   break
			   end
		 end
		 print('-------------------------common ai 类型，位置:',t,index)
		 lastCommonAiType = t
		 lastCommonAiIndex = index
		return actionList[index]
	 end
end

local defTable = {"jump_defense","stand_heavy_defense","stand_light_defense"}
function doHitStart(fight)
	if fight.report:isDef() then
		local playIdA = fight.heroA:play(defTable[math.random(1,3)],true)
		local playIdB = fight.heroB:play(defTable[math.random(1,3)],true)
		fight.heroA:setNoHold(true)
		fight.heroB:setNoHold(true)

		local cnt = 0
		local callback = function(fight,hero,stateName,isFinish)
			cnt = cnt + 1 
			if cnt < 2 then
				return
			end
			fight.report:nextRound()
			fight:changeAiState(AI_STATE_HIT)
		end
		fight.aiData.callbacks[playIdA] = callback
		fight.aiData.callbacks[playIdB] = callback
		return
	end
	local skillId = fight.report:getCurrentSkillId()
	local nameA,nameB = getName(fight)
	local cfg --= getRandomAi(nameA,nameB)
	if math.random(1,100) > 50 then
		cfg = getRandomAi(nameA)
		fight.performA = true
	else
		cfg = getRandomAi(nameB)
		fight.performA = false
	end
	if not cfg then
		fight.rangeMin,fight.rangeMax = getRange(fight)
		fight.hitState = HIT_STATE_REAL
		hitToRun(fight)
		return
	end
	fight.performCfg = cfg
	fight.rangeMin = cfg.rangeMin
	fight.rangeMax = cfg.rangeMax
	fight.hitState = HIT_STATE_PERFORM
	hitToRun(fight)
end

function doHitPerform(fight)
	--assert('距离在范围内呀')
	--[[
	local isAHit = fight.report:isAHit()
	local playId
	if isAHit then
		fight.heroB:play(fight.performCfg.skillB)
		playId = fight.heroA:play(fight.performCfg.skillA)
	else
		fight.heroA:play(fight.performCfg.skillB)
		playId = fight.heroB:play(fight.performCfg.skillA)
	end
	--]]
		--40%--0
		--35%--1
		--16%--2
		--9%--3
	local performTimes = {
		[0] = 50,30,20
	}
	if not fight.performCnt or fight.performCnt <= 0 then
		local r = math.random(0,99) 
		local performCnt = 0
		for k=0,3 do
			if r < performTimes[k] then
				performCnt = k
				break
			end
			r = r - performTimes[k]
		end
		------------------------------------test-----------
		--performCnt = 0
		-------------------------------------------------------
		fight.performCnt = performCnt
		if performCnt <= 0 then
			fight.rangeMin,fight.rangeMax = getRange(fight)
			fight.hitState = HIT_STATE_REAL
			hitToRun(fight)
			return
		else
			fight.hitState = HIT_STATE_START
			hitToRun(fight)
		end
	else
		local skillA,skillB = fight.performCfg.skillA,fight.performCfg.skillB
		if not fight.performA then
			skillA,skillB = skillB,skillA
		end
		local playIdA = fight.heroA:play(skillA,true)
		local playIdB = fight.heroB:play(skillB,true)

		local cnt = 0
		local callback = function(fight,hero,stateName,isFinish)
			cnt = cnt + 1 
			if cnt < 2 then
				return
			end
			--是不是要随机几次表演的
			fight.performCnt = fight.performCnt - 1
			if fight.performCnt <= 0 then
				fight.rangeMin,fight.rangeMax = getRange(fight)
				fight.hitState = HIT_STATE_REAL
				hitToRun(fight)
			else
				fight.hitState = HIT_STATE_START
				hitToRun(fight)
			end
		end
		fight.aiData.callbacks[playIdA] = callback
		fight.aiData.callbacks[playIdB] = callback
	end
end

function doHitReal(fight)
	--local skillId = fight.report:getCurrentSkillId()
	local skill = fight.report:getCurrentSkill()
	local isAHit = fight.report:isAHit()
	local isFirstSkill = fight.report:isFirstSkill()
	local isLastSkill = fight.report:isLastSkill()
	local playId
	if isAHit then
		fight.heroB:changeToBeBeat(fight.heroA:getBeBeatState(skill.actionId))
		fight.heroA:setCurSkill(skill)
		playId = fight.heroA:play(skill.actionId,true,true)
		if isFirstSkill then
			Stage.currentScene.ui:displaySkillNameEffect(fight.heroA,skill:getGroupName())
			fight.heroA:displayCareer()
			callAssist(fight,fight.heroA,Stage.currentScene.fightControl:getAssistA(),"hiting")
			callAssist(fight,fight.heroB,Stage.currentScene.fightControl:getAssistB(),"beBeat")
			GiftLogic.checkGift(fight.heroA,GiftDefine.ConditionType.useSkill,skill.groupId)
		end
		if isLastSkill then
			fight.aiData.comboTips = true
		end
	else
		fight.heroA:changeToBeBeat(fight.heroB:getBeBeatState(skill.actionId))
		fight.heroB:setCurSkill(skill)
		playId = fight.heroB:play(skill.actionId,true,true)
		if isFirstSkill then
			Stage.currentScene.ui:displaySkillNameEffect(fight.heroB,skill:getGroupName())
			fight.heroB:displayCareer()
			callAssist(fight,fight.heroA,Stage.currentScene.fightControl:getAssistA(),"beBeat")
			callAssist(fight,fight.heroB,Stage.currentScene.fightControl:getAssistB(),"hiting")
			GiftLogic.checkGift(fight.heroB,GiftDefine.ConditionType.useSkill,skill.groupId)
		end
	end

	fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
		Stage.currentScene:dispatchEvent(Event.FightHit, {etype=Event.FightHit,heroAIndex = Stage.currentScene.fightControl.heroAIndex,heroBIndex = Stage.currentScene.fightControl.heroBIndex,hero = hero,comboIndex=fight.report.comboIndex})
		if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
			fight:changeAiState(AI_STATE_END)
			return
		end
		--[[
		--例如被援助打断
		if not isFinish then
			fight.report:nextRound()
			doAfterRound(fight)
			return
		end
		if fight.needNextRound then
			fight.needNextRound = nil
			fight.report:nextRound()
			doAfterRound(fight)
			return
		end
		--]]
		local ret = fight.report:nextCombox()
		--[[
		if not ret and Stage.currentScene:inCorner(fight.report:isAHit()) then
			swapPosition(fight)
			return
		end
		--]]
		--一个回合不接下一个回合
		local fightModel = Stage.currentScene.fightModel
		if ret then	--看能不能继续连击
			--破招逻辑
			if (fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB) and hero == fight.heroB then
				if useBreak(fight,fight.heroA,fight.heroB) then
					return
				end
			end

			if (fightModel == Define.FightModel.handA_autoB or fightModel == Define.FightModel.autoA_autoB) and hero == fight.heroA then
				if useBreak(fight,fight.heroB,fight.heroA) then
					return
				end
			end
			fight:changeAiState(AI_STATE_HIT)
		else
			local t = fight.isComboStop and 99999 or 0.5
			if hero == fight.heroA then
				fight.comboA = true
				if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB then 
					t = 0.05
				end
			else
				fight.comboB = true
				if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.handA_autoB then 
					t = 0.05
				end
			end
			Stage.currentScene:addTimer(function() 
				if fight.comboA or fight.comboB then
					--fight.canCombo = nil
					fight.comboA = nil
					fight.comboB = nil
					if Stage.currentScene:inCorner(fight.report:isAHit()) then
						swapPosition(fight)
					else
						doAfterRound(fight)
					end
				end
			 end,t,1)
		end
	end
end

function doStart(fight,delay)
	if fight.aiData.notFirst then
		return
	end
	fight.aiData.notFirst = true
	local playIdA = fight.heroA:play("start",true)
	local playIdB = fight.heroB:play("start",true)
	local cnt = 0
	local callback = function(fight,hero,stateName,isFinish)
		cnt = cnt + 1 
		if cnt < 2 then
			return
		end

		local scene = Stage.currentScene
		--scene:displayFightAttr(function() 
			scene:displayRound(scene.fightControl:getRoundNum(),function() 
				scene:displayReadyGo(function()
					scene.ui:startCD()
					fight:changeAiState(AI_STATE_HIT)
				end)
			end)
		--end)
	end
	--fight.aiData.callbacks[playIdA] = callback
	--fight.aiData.callbacks[playIdB] = callback
	---[[
	--Stage.currentScene:displayFightAttr(function() 
		local scene = Stage.currentScene
		scene:displayRound(scene.fightControl:getRoundNum(),function() 
			scene:displayReadyGo(function()
				scene.ui:startCD()
				fight:changeAiState(AI_STATE_HIT)
			end)
		end)
	--end)
	--]]

end

function doEnd(fight,delay)
	if fight.isFinish == true then
		return
	end
	if fight.heroA:getInfo():getHp() >= fight.heroB:getInfo():getHp() then
		if --[[not fight.heroB:getInfo():isDie() and--]] not fight.heroB.curState.lock == Define.AttackLock.normal then
			--B没死且动作没播完
			return
		end
	else
		if --[[not fight.heroA:getInfo():isDie() and--]] not fight.heroA.curState.lock == Define.AttackLock.normal then
			return
		end
	end

	if fight.aiData.notFirst then
		return
	end
	fight.aiData.notFirst = true
	if fight.heroA.curState.lock == Define.AttackLock.normal then
		fight.heroA:play("stand",true)
	end

	if fight.heroB.curState.lock == Define.AttackLock.normal then
		fight.heroB:play("stand",true)
	end
	local callback = function() 
		local playId
		local winer
		if fight.heroA:getInfo():getHp() >= fight.heroB:getInfo():getHp() then
			playId = fight.heroA:play("succeed",true)
			if fight.heroB:getInfo():isDie() then
			else
				fight.heroB:play("fail",true)
			end
			winer = "A"
			if not Stage.currentScene.fightControl:hasNextHeroB() then
				SoundManager.stopMusic(true)
				SoundManager.playEffect("common/Success.mp3")
			end
			GiftLogic.checkGift(fight.heroA,GiftDefine.ConditionType.win)
			GiftLogic.checkGift(fight.heroB,GiftDefine.ConditionType.lost)
		else
			playId = fight.heroB:play("succeed",true)
			if fight.heroA:getInfo():isDie() then
			else
				fight.heroA:play("fail",true)
			end
			winer = "B"
			if not Stage.currentScene.fightControl:hasNextHeroA() then
				--fail
				SoundManager.stopMusic(true)
				SoundManager.playEffect("common/Fail.mp3")
			end
			GiftLogic.checkGift(fight.heroB,GiftDefine.ConditionType.win)
			GiftLogic.checkGift(fight.heroA,GiftDefine.ConditionType.lost)
		end
		fight.winer = winer
		fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
			fight.isFinish = true
		end
		GiftLogic.checkGift(fight.heroA,GiftDefine.ConditionType.roundEnd)
		GiftLogic.checkGift(fight.heroB,GiftDefine.ConditionType.roundEnd)
	end

	Stage.currentScene.ui:stopCD()
	Stage.currentScene.ui:removeSkillNameEffect(fight.heroA)
	Stage.currentScene.ui:removeSkillNameEffect(fight.heroB)
	Stage.currentScene:removePowerAfter()
	if fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
		Stage.currentScene:displayKO(callback)
	else
		Stage.currentScene:displayTimeOver(callback)
	end
	
end

function doPower(fight,delay)
	if fight.aiData.notFirst then
		return
	end
	fight.aiData.notFirst = true

	--local beHiting = false
	--[[
	if fight.aiData.reciever:isHiting() then
		beHiting = true
	end
	--]]
	local beHiting = fight.aiData.sender:isBeBeat()

	local callback1 = function()
		--if fight.aiData.sender:isJump() or fight.aiData.reciever:isJump() then
			fight.aiData.sender:play("stand",true)
			fight.aiData.reciever:play("stand",true)
			fight.aiData.sender:setPositionY(Define.heroBottom)
			fight.aiData.reciever:setPositionY(Define.heroBottom)
		--end
		Stage.currentScene:displayPower(fight.aiData.sender)
	end
	local callback2 = function()
		--fight.aiData.sender:resume()
		--fight.aiData.reciever:resume()
		if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
			fight:changeAiState(AI_STATE_END)
			return
		end
		local playId = fight.aiData.sender:play("break_heat",true)
		fight.aiData.sender:setNextStateTime(0.2)
		fight.aiData.reciever:play("hit_heavy_b",true)
		Stage.currentScene:displayEffect("重受击",fight.aiData.reciever:getPositionX(),Define.heroBottom + 100,fight.aiData.reciever:getDirection())
		Stage.currentScene:shockHash(3)

		Stage.currentScene:displayEffect("大招定人",fight.aiData.sender:getPositionX(),fight.aiData.sender:getPositionY(),fight.aiData.sender:getDirection())
		Stage.currentScene:displayPowerAfter(fight.aiData.reciever:getPositionX())

		fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
			if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
				fight:changeAiState(AI_STATE_END)
				return
			end

			local skill = fight.aiData.sender:getPowerSkill()
			--fight.aiData.reciever:changeToBeBeat(fight.aiData.sender:getBeBeatState(skill.actionId))
			Stage.currentScene.ui:displaySkillNameEffect(fight.aiData.sender,skill:getGroupName())
			fight.aiData.sender:displayCareer()
			fight.aiData.sender:setCurSkill(skill)

			fight.aiData.comboTips = (fight.aiData.sender == fight.heroA)

			local playId = fight.aiData.sender:play(skill.actionId,true,true)
			fight.aiData.callbacks[playId] = function(fight,hero,stateName,isFinish)
				Stage.currentScene:removePowerAfter()
				if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
					fight:changeAiState(AI_STATE_END)
				else
					local fightModel = Stage.currentScene.fightModel
					local t = fight.isComboStop and 99999 or 0.5
					if hero == fight.heroA then
						fight.comboA = true
						if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.autoA_handB then 
							t = 0.05
						end
					else
						fight.comboB = true
						if fightModel == Define.FightModel.autoA_autoB or fightModel == Define.FightModel.handA_autoB then 
							t = 0.05
						end
					end
					Stage.currentScene:addTimer(function() 
						if fight.comboA or fight.comboB then
							--fight.canCombo = nil
							fight.comboA = nil
							fight.comboB = nil
							doAfterRound(fight)
						end
					 end,t,1)
					--doAfterRound(fight)
				end
				Stage.currentScene:dispatchEvent(Event.FightPower, {etype=Event.FightPower})
			end
		end

	end
	fight.hitState = HIT_STATE_START
	if beHiting then
		local isAHit = fight.report:isAHit()
		if (isAHit and fight.aiData.sender == fight.heroB) or (not isAHit and fight.aiData.sender == fight.heroA) then
			fight.report:nextRound()
		end
		fight.comboA = nil
		fight.comboB = nil
		GiftLogic.checkGift(fight.aiData.sender,GiftDefine.ConditionType.useBreak)
		local playIdB = fight.aiData.reciever:play("hit_fly_a",true)
		fight.aiData.sender:setPositionY(Define.heroBottom)
		fight.aiData.sender:displayBreakEffect()
		local playIdA = fight.aiData.sender:play("break_heat",true)
		--fight.aiData.reciever:decHp(fight.aiData.sender.hero.breakRate * fight.aiData.sender.hero.dyAttr.atk * 2000 / (2000 + fight.aiData.reciever.hero.dyAttr.def))
		fight.aiData.reciever:decHp(fight.aiData.sender:getBreakHarm())
		fight.aiData.callbacks[playIdA] = function(fight,hero,stateName,isFinish)
			if fight.isTimeOver or fight.heroA:getInfo():isDie() or fight.heroB:getInfo():isDie() then
				fight:changeAiState(AI_STATE_END)
			else
				doAfterRound(fight)
			end
		end
		--fight.aiData.sender:displayFightEffect("break","fe_pz","")
		--Stage.currentScene:displayBreakPower(fight.aiData.sender)
		if fight.aiData.sender == fight.heroA then
			Stage.currentScene:displayPowerTips("BreakPower")
		end
	else
		fight.aiData.sender:stopAllActions()
		fight.aiData.reciever:stopAllActions()
		--fight.aiData.sender:pause()
		--fight.aiData.reciever:pause()
		--Stage.currentScene:offOn(0.1,callback1,callback2,1.3)
		fight.aiData.sender:play("stand",true)
		fight.aiData.reciever:play("stand",true)
		fight.aiData.sender:setPositionY(Define.heroBottom)
		fight.aiData.reciever:setPositionY(Define.heroBottom)
		Stage.currentScene:displayPower(fight.aiData.sender,callback2)
		GiftLogic.checkGift(fight.aiData.sender,GiftDefine.ConditionType.usePow)
	end
end

function doAssist(fight)
	if fight.newAssistA then
		fight.newAssistA = nil
		local assist = Stage.currentScene:addAssistA()
		assist:startAssist()
	end

	if fight.newAssistB then
		fight.newAssistB = nil
		local assist = Stage.currentScene:addAssistB()
		assist:startAssist()
	end
end

function checkAssist(fight,delay)
	if fight.assistA then
		if fight.assistA:getEnemyDis() < 200  and not fight.firstAssistA then
			local playId = fight.assistA:play("break_heat",true)
			fight.firstAssistA = true
		end
	end

	if fight.assistB then
		if fight.assistB:getEnemyDis() < 200  and not fight.firstAssistB then
			local playId = fight.assistB:play("break_heat",true)
			fight.firstAssistB = true
		end
	end
end
