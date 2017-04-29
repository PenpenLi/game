module("PokerSmallUI",package.seeall)
setmetatable(_M,{__index = Control})
local CardLogic = require("src/modules/guild/texas/CardLogic")

function new(num)
	local ctrl = Control.new(require("res/guild/PokerSmallSkin"),{"res/guild/PokerSmall.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(num)
	return ctrl
end

function init(self,num)
	self.redjoker:setVisible(false)
	self.blackjoker:setVisible(false)
	self:setPokerNum(num)
end

function initPoker(self)
	for i = 1,2 do
		for j = 1,13 do
			self["num"..i]["c"..i.."n"..j]:setVisible(false)
		end
		self["num"..i]:setVisible(false)
	end
	for i = 1,4 do
		self["d"..i]:setVisible(false)
	end
end

function setPokerNum(self,num)
	self:initPoker()
	local digit,color = CardLogic.num2DigitColor(num)
	local black = color%2 == 1 and 1 or 2
	self["num"..black]:setVisible(true)
	self["num"..black]["c"..black.."n"..digit]:setVisible(true)
	self["d"..color]:setVisible(true)
end

return PokerSmallUI
