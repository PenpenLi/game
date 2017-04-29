module(..., package.seeall)
local Helper = require("src/modules/fight/KofHelper")
local Define = require("src/modules/fight/Define")
local Hero = require("src/modules/fight/Hero")
local Ai = require("src/modules/fight/Ai")
local FightReport = require("src/modules/fight/FightReport")

function new(heroA,heroB)
	local o = {
		isPause = true,
		heroA = heroA,
		heroB = heroB,
		aiState = Ai.AI_STATE_NONE,
		--report = FightReport.new(),
		report = nil,
		hitState = Ai.HIT_STATE_START,
		rangeMin = 0,
		rangeMax = 0,
		performCfg = nil,
		aiData = {
			callbacks = {},
		},
	}
	setmetatable(o,{__index = _M})
	o:init()
	return o
end

function init(self)
	if self.heroA:hasEventListener(Event.PlayEnd,onPlayEnd) then
		self.heroA:removeEventListener(Event.PlayEnd,onPlayEnd)
	end
	self.heroA:addEventListener(Event.PlayEnd,onPlayEnd,self)
	if self.heroB:hasEventListener(Event.PlayEnd,onPlayEnd) then
		self.heroB:removeEventListener(Event.PlayEnd,onPlayEnd)
	end
	self.heroB:addEventListener(Event.PlayEnd,onPlayEnd,self)
end

function setReport(self,report)
	self.report = report
end

function onPlayEnd(self,event,target)
    --self:dispatchEvent(Event.PlayEnd, {etype = Event.PlayEnd,isFinish = false,stateName = self.curState.name,playId = self.playId})
	--print('-----------------------------------------playId:',event.playId,self.aiData.callbacks[event.playId])
	if self.aiData.callbacks[event.playId] then
		print('--------------------name,isFinish:',event.stateName,event.isFinish,event.playId)
		self.aiData.callbacks[event.playId](self,target,event.stateName,event.isFinish)--fight,hero,动作名,isFinish
		self.aiData.callbacks[event.playId] = nil
	end
end

function changeAiState(self,state)
	if state == Ai.AI_STATE_START then
		--
	elseif state == Ai.AI_STATE_END then
		--
	elseif state == Ai.AI_STATE_HIT then
		--self.hitState = self.hitState + 1
		--[[
		if self.hitState == Ai.HIT_STATE_START then
			self.hitState = Ai.HIT_STATE_PERFORM
		elseif self.hitState == Ai.HIT_STATE_PERFORM then
			self.hitState = Ai.HIT_STATE_REAL
		elseif self.hitState == Ai.HIT_STATE_REAL then
			--self.hitState = Ai.HIT_STATE_START
		end
		--]]
	end
	self.aiState = state
	self.aiData = {
		callbacks = {}
	}
end

function start(self)
	self.isPause = false
	self:changeAiState(Ai.AI_STATE_START)
end

function update(self,delay)
	if not self.isPause then
		Ai.doAi(self,delay)
	end
	--[[
	if self.assistA or self.assistB then
		Ai.checkAssist(self,delay)
	end
	--]]
end

function power(self)
	self.comboA = nil
	self.comboB = nil
	self:changeAiState(Ai.AI_STATE_POWER)
	self.aiData.sender = self.heroA
	self.aiData.reciever = self.heroB
end

function timeOver(self)
	self.isTimeOver = true
end

function assist(self)
	--self:changeAiState(Ai.AI_STATE_ASSIST)
	self.newAssistA = true
	Ai.doAssist(self)
end

function combo(self)
	if self.comboA then
		self.comboA = nil
		self:changeAiState(Ai.AI_STATE_COMBO)
		self.aiData.sender = self.heroA
		self.aiData.reciever = self.heroB
	end
end
