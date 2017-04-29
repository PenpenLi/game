module(..., package.seeall)
setmetatable(_M, {__index = Control})

local TipConfig = require("src/config/FightTipConfig").Config
local Define = require("src/modules/fightTip/FightTipDefine")

function new()
	local ctrl = Control.new(require("res/fightTip/FightTipSkin"), {"res/fightTip/FightTip.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init()
	return ctrl
end

function init(self)
	self.descTxt:setHorizontalAlignment(Label.Alignment.Center)
end

function show(self)
	local id = math.random(1, Define.MAX_ID)
	local config = TipConfig[id]
	if config then
		self.descTxt:setString(config.content)
	end
	self:doAction()
end

function doAction(self)
	self:setPosition(Stage.width, Stage.height - 200)

	local inAction = cc.MoveTo:create(Define.IN_TIME,	cc.p(Stage.width - self._skin.width, Stage.height - 200))
	local fadeIn = cc.FadeIn:create(Define.IN_TIME)
	local delayAction = cc.DelayTime:create(Define.DELAY_TIME)
	local outAction = cc.MoveTo:create(Define.OUT_TIME, cc.p(Stage.width, Stage.height - 200))
	local fadeOut = cc.FadeOut:create(Define.OUT_TIME) 
	self:runAction(
		cc.Sequence:create(
			cc.Spawn:create(inAction, fadeIn),
			delayAction,
			cc.Spawn:create(outAction, fadeOut)
		)
	)
end

