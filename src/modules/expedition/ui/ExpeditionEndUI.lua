module(..., package.seeall)
setmetatable(_M, {__index = Control})

local expeditionData = require("src/modules/expedition/ExpeditionData").getInstance()
local Define = require("src/modules/expedition/ExpeditionDefine")
local Config = require("src/config/ExpeditionConfig").Config

function new()
	local ctrl = Control.new(require("res/expedition/ExpeditionEndSkin"), {"res/expedition/ExpeditionEnd.plist", "res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init() 
	return ctrl
end

function init(self)
	self.lose.qd:addEventListener(Event.Click, onCloseLoseUI, self)
	self.lose:setVisible(false)

	self.vin.qd:addEventListener(Event.Click, onCloseSuccessUI, self)
	self.vin.next:addEventListener(Event.Click, onNextCopy, self)
	if expeditionData:getCurId() > Define.COPY_NUM then
		self.vin.next:setVisible(false)
	end
	self.vin:setVisible(false)

	self.lose.hero:addEventListener(Event.Click, onShowHero, self)
	self.lose.skill:addEventListener(Event.Click, onShowSkill, self)
end

function addStage(self)
	local back = LayerColor.new("backgroud",0,0,0,200,Stage.width,Stage.height)
	back.touchEnabled = false
	self:addChild(back,-99)
end

function onCloseLoseUI(self)
	self:hideAll()
end

function onCloseSuccessUI(self)
	self:hideAll()
end

function onNextCopy(self)
	local scene = require("src/scene/MainScene").new()
	Stage.replaceScene(scene)
	scene:addEventListener(Event.InitEnd, function()
		UIManager.addUI("src/modules/expedition/ui/ExpeditionUI")
		Network.sendMsg(PacketID.CG_EXPEDITION_CHALLANGE, Define.NEXT_YES)
	end)
end

function showSuccessUI(self)
	local config = Config[expeditionData:getCurId()]
	if config ~= nil then
		self.vin.txtxgk:setString(config.copyName)
		self.vin:setVisible(true)
	end
end

function showFailUI(self)
	local config = Config[expeditionData:getCurId()]
	if config ~= nil then
		self.lose.copyName:setString(config.copyName)
		self.lose:setVisible(true)
	end
end

function onShowHero(self, evt)
	local scene = require("src/scene/MainScene").new()
	Stage.replaceScene(scene)
	scene:addEventListener(Event.InitEnd, function()
		UIManager.replaceUI("src/modules/hero/ui/HeroNormalListUI")
	end)
end

function onShowSkill(self, evt)
	local scene = require("src/scene/MainScene").new()
	Stage.replaceScene(scene)
	scene:addEventListener(Event.InitEnd, function()
		UIManager.replaceUI("src/modules/skill/ui/SkillHeroUI")
	end)
end

function hideAll(self)
	self:removeFromParent()

	local scene = require("src/scene/MainScene").new()
	Stage.replaceScene(scene)
	scene:addEventListener(Event.InitEnd, function()
		UIManager.replaceUI("src/modules/expedition/ui/ExpeditionUI")
	end)
end
