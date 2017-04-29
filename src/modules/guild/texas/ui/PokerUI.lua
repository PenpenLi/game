module("PokerUI",package.seeall)
setmetatable(_M,{__index = Control})
local CardLogic = require("src/modules/guild/texas/CardLogic")

function new(num)
	local ctrl = Control.new(require("res/guild/PokerSkin"),{"res/guild/Poker.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(num)
	return ctrl
end

function onPokerClick(self,event,target)
	if event.etype == Event.Touch_ended then
		if self.num > 0 then
			self:setPokerFront(true)
			local TexasUI = Stage.currentScene:getUI():getChild("Texas")
			if TexasUI then
				TexasUI:onPokerClick()
			end
		end
	end
end

function init(self,num)
	self.front.redJoke:setVisible(false)
	self.front.blackJoke:setVisible(false)
	self:setPokerNum(num)
	self:setPokerFront(false)
	self.back:addEventListener(Event.TouchEvent,onPokerClick,self)
end

function initPoker(self)
	for i = 1,2 do
		for j = 1,13 do
			self.front["num"..i]["c"..i.."n"..j]:setVisible(false)
		end
		self.front["num"..i]:setVisible(false)
	end
	for i = 1,4 do
		self.front.small["ssign"..i]:setVisible(false)
	end
	for i = 1,4 do
		self.front.big["bsign"..i]:setVisible(false)
	end
	self.front.pokerbg:setVisible(false)
end

function setPokerFront(self,front)
	self.front:setVisible(false)
	self.back:setVisible(false)
	if front then
		self.front:setVisible(true)
	else
		self.back:setVisible(true)
	end
end

function setPokerNum(self,num)
	self:initPoker()
	local digit,color = CardLogic.num2DigitColor(num)
	local black = color%2 == 1 and 1 or 2
	self.front["num"..black]:setVisible(true)
	self.front["num"..black]["c"..black.."n"..digit]:setVisible(true)
	self.front.small["ssign"..color]:setVisible(true)
	self.front.big["bsign"..color]:setVisible(true)
	self.front.pokerbg:setVisible(true)
end

return PokerUI
