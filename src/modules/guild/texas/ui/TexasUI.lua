module(..., package.seeall)
setmetatable(_M, {__index = Control})
local PokerUI = require("src/modules/guild/texas/ui/PokerUI")
local PokerSmallUI = require("src/modules/guild/texas/ui/PokerSmallUI")
local TexasConfig = require("src/config/TexasConfig").Config
local CardLogic = require("src/modules/guild/texas/CardLogic")
local TexasLvConfig = require("src/config/TexasLvConfig").Config
local TexasDefine = require("src/modules/guild/texas/TexasDefine")
local WeekTop = WeekTop or {}
local OriginalPos = OriginalPos or {}

function new()
	local ctrl = Control.new(require("res/guild/TexasSkin"),{"res/guild/Texas.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	return ctrl
end

function addStage(self)
	self:setPositionY(Stage.uiBottom)
end

function uiEffect()
	return UIManager.FIRST_TEMP_FULL
end

function addBg(self)
	local bg = Sprite.new('TexasScene','res/guild/Texasbg.jpg')
	bg.touchEnabled = false
	self.bg = bg
	self:addChild(bg,-1)
	bg:setPositionY(-Stage.uiBottom)
end

function init(self)
	self:addArmatureFrame("res/guild/effect/texas/Texas.ExportJson")
	self:addBg()
	self.first = true
	function onClose(self,event,target)
		UIManager.removeUI(self)
	end
	function onRank(self,event,target)
		--self.rank:setVisible(true)
		ActionUI.show(self.rank,"scale")
		Network.sendMsg(PacketID.CG_TEXAS_RANK)
	end
	function onRankClose(self,event,target)
		--self.rank:setVisible(false)
		ActionUI.hide(self.rank,"scaleHide")
	end
	function onStart(self,event,target)
		local flag = true
		for i = 1,5 do
			if self["pkbg"..i].card.back:isVisible() and
				self["pkbg"..i].card.num > 0 then
				flag = false
				break
			end
		end
		if flag then
			Network.sendMsg(PacketID.CG_TEXAS_START)
		else
			Common.showMsg("请先翻牌")
		end
	end
	function onRule(self,event,target)
		local ui = UIManager.addChildUI("src/ui/RuleScrollUI")
		ui:setId(RuleUI.Texas)
	end
	self:openTimer()
	self:addEventListener(Event.Frame, addRankByFrame)
	self.rule:addEventListener(Event.Click,onRule,self)
	self.rule:setPositionY(-Stage.uiBottom)
	self.back:addEventListener(Event.Click,onClose,self)
	self.rank:setVisible(false)
	self.rankBtn:addEventListener(Event.Click,onRank,self)
	self.rankBtn:setPositionY(-Stage.uiBottom)
	--self.rank.close:addEventListener(Event.Click,onRankClose,self)
	self.start:addEventListener(Event.Click,onStart,self)
	for i = 1,5 do
		self["pkbg"..i]:setVisible(false)
		local card = PokerUI.new(1)
		self["pkbg"..i]:addChild(card)
		self["pkbg"..i].card = card
		self["pkbg"..i].card:setVisible(false)
		card.num = 0
	end
	self.bcdj:setString("")
	self.bcjy:setString("")
	self.jrcs:setString("")
	for i = 1,5 do
		self.bzzg["spk"..i]:setVisible(false)
		OriginalPos[i] = {
			x = self["pkbg"..i]:getPositionX(),
			y = self["pkbg"..i]:getPositionY()
		}
	end
	self.bzzg.toptxt:setAnchorPoint(1,0)
	self.cardsbg:setVisible(false)
	self.cardsPos= {x = self.cardsbg:getPositionX(),y = self.cardsbg:getPositionY()}
	Network.sendMsg(PacketID.CG_TEXAS_QUERY)
end

function refreshInfo(self,lv,exp,cnt,weekTop,curCards,isRefresh)
	self.curCards = curCards
	self.bcdj:setString("德州等级:"..lv)
	local maxExp = TexasLvConfig[#TexasLvConfig].exp 
	if lv < #TexasLvConfig then
		maxExp =  TexasLvConfig[lv+1].exp
	end
	self.bcjy:setString(string.format("德州经验:%d/%d",exp,maxExp))
	local cnt = TexasDefine.TEXAS_DAYCNT - cnt
	self.jrcs:setString("今日次数:"..cnt)
	for i = 1,5 do
		local card = self["pkbg"..i].card
		local num = curCards[i] or 0
		print("TexasUI:refreshInfo:num:"..num)
		card:setPokerNum(num)
		card.num = num
		if isRefresh == 0 and num >0 then
			card:setPokerFront(true)
		else
			card:setPokerFront(false)
		end
	end
	if isRefresh == 0 then
		self.cardsbg:setScale(1.2)
		self.cardsbg:setPosition(self.pkbg3:getPosition())
		self.cardsbg:setVisible(true)
		self:refreshWeekTop(weekTop)
	else
		WeekTop = weekTop
		self:dealStart()
	end
end

function refreshWeekTop(self,weekTop)
	if next(weekTop.cards) then
		local charName = weekTop.name
		local lv = CardLogic.getCardLv(weekTop.cards)
		local cardName = TexasConfig[lv].name
		self.bzzg.toptxt:setString(string.format("本周最高：%s %s",charName,cardName))
		for i = 1,5 do
			local num = weekTop.cards[i]
			if self.bzzg["card"..i] then
				self.bzzg["card"..i]:setPokerNum(num)
			else
				local card = PokerSmallUI.new(num)
				card.name = "PokerSmallUI"..i
				card:setPosition(self.bzzg["spk"..i]:getPosition())
				self.bzzg:addChild(card)
				self.bzzg["card"..i] = card
			end
		end
	else
		self.bzzg.toptxt:setString(string.format("本周最高：暂无"))
	end
end

function refreshRankInfo(self,rankData)
	local list = self.rank.jrrank
	list:removeAllItem()
	self.sortedRank = rankData
	--local list = self.rank.jrrank
	--local rows = #rankData
	--list:removeAllItem()
	--list:setItemNum(rows)
	--for i = 1,rows do
	--	local data = rankData[i]
	--	local ctrl = list:getItemByNum(i)
	--	ctrl.txtmingzi:setString(i.."."..data.name)
	--	local lv = CardLogic.getCardLv(data.cards)
	--	local cfg = TexasConfig[lv]
	--	ctrl.txtpx:setPositionX(ctrl.Poker1:getPositionX()-5)
	--	ctrl.txtpx:setAnchorPoint(1,0)
	--	ctrl.txtpx:setString(cfg.name)
	--	for i = 1,5 do
	--		local num = data.cards[i]
	--		local card = PokerSmallUI.new(num)
	--		card.name = "PokerSmallUI"..i
	--		card:setPosition(ctrl["Poker"..i]:getPosition())
	--		ctrl:addChild(card)
	--	end
	--end
end

function addRankByFrame(self,event)
	local frameRate = 1
	if self.sortedRank and #self.sortedRank > 0 then
		for i = 1,frameRate do
			if self.sortedRank[1] then
				local rank = self.sortedRank[1]
				table.remove(self.sortedRank,1)
				self:addRankToList(rank)
			else
				break
			end
		end
	end
end
function addRankToList(self,data)
	local no = self.rank.jrrank:addItem()
	local ctrl = self.rank.jrrank.itemContainer[no]
	ctrl.txtmingzi:setString(no .. "." .. data.name)
	local lv = CardLogic.getCardLv(data.cards)
	local cfg = TexasConfig[lv]
	ctrl.txtpx:setPositionX(ctrl.Poker1:getPositionX()-5)
	ctrl.txtpx:setAnchorPoint(1,0)
	ctrl.txtpx:setString(cfg.name)
	for i = 1,5 do
		local num = data.cards[i]
		local card = PokerSmallUI.new(num)
		card.name = "PokerSmallUI"..i
		card:setPosition(ctrl["Poker"..i]:getPosition())
		ctrl:addChild(card)
	end
end

function onPokerClick(self)
	local lastCard = true
	for i = 1,5 do
		if self["pkbg"..i].card.back:isVisible() then
			lastCard = false
		end
	end
	if lastCard then
		local curCards = self.curCards 
		local lv = CardLogic.getCardLv(curCards)
		local layer = UIManager.newGrayLayer()
		if not self:getChild("gray_layer") then
			layer:setPositionY(-Stage.uiBottom)
			self:addChild(layer)

			self.ani = Common.setBtnAnimation(self._ccnode,"Texas",tostring(lv))
			self.ani:getAnimation():setFrameEventCallFunc(function(bonep,evt,originFrameIndex,currentFrameIndex) 
				layer:removeFromParent()
				local cfg = TexasConfig[lv]
				local cardName = cfg.name
				local rewards = {}
				for k,v in pairs(cfg.rewards) do
					local title = string.format("您获得牌型:%s",cardName)
					table.insert(rewards,{title=title,id=v[1],num=v[2]})
				end
				RewardTips.show(rewards)
				self:refreshWeekTop(WeekTop)
			end)
		end
	end
end

function dealStart(self)
	for i = 1,5 do
		local card = self["pkbg"..i].card
		card:setVisible(false)
		local cardbg = self["pkbg"..i]
		local x = self.cardsPos.x
		local y = self.cardsPos.y + 6
		cardbg:setPosition(x,y)
		cardbg:setScaleX(0.7)
		cardbg:setScaleY(0.75)
		cardbg:setVisible(false)
	end
	self.cardsbg:setVisible(false)

	local function cardMove(curId)
		local cardbg = self["pkbg"..curId]
		local callBackFuc = function()
			cardbg:setScale(1)
			if curId >= 5 then
				self:dealEnd()
			else
				cardMove(curId+1)
			end
		end
		local moveto = cc.MoveTo:create(0.1,cc.p(OriginalPos[curId].x,OriginalPos[curId].y))
		local callBack=cc.CallFunc:create(callBackFuc)
		cardbg:runAction(cc.Sequence:create({moveto,callBack}))
	end
	local function setCardsVisible(flag)
		for i = 1,5 do
			local cardbg = self["pkbg"..i]
			cardbg:setVisible(flag)
		end
	end
	if self.first then
		self.first = false
		local callBack = function()
			setCardsVisible(true)
			cardMove(1)
		end
		local moveto = cc.MoveTo:create(0.3,cc.p(self.cardsPos.x,self.cardsPos.y))
		local sineOut = cc.EaseSineOut:create(moveto)
		local scale = cc.ScaleTo:create(0.3,1)
		local spawn = cc.Spawn:create(sineOut,scale)
		self.cardsbg:setVisible(true)
		self.cardsbg:runAction(cc.Sequence:create({spawn,cc.CallFunc:create(callBack)}))
	else
		setCardsVisible(true)
		cardMove(1)
	end
end

function dealEnd(self)
	self.cardsbg:setVisible(false)
	for i = 1,5 do
		local card = self["pkbg"..i].card
		card:setVisible(true)
	end
end
