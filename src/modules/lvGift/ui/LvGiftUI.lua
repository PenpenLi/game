module(..., package.seeall)
setmetatable(_M, {__index = Control})
local LevelActConfig = require("src/config/LevelActivityConfig").Config
local LvGiftLogic = require("src/modules/lvGift/LvGiftLogic")

function new()
	local ctrl = Control.new(require("res/lvGift/LevelGiftSkin"),{"res/lvGift/LevelGift.plist","res/common/an.plist"})
	setmetatable(ctrl,{__index = _M})
	ctrl:init(index)
	return ctrl
end

function uiEffect()
	return UIManager.THIRD_TEMP
end

function init(self)
	self.touch = Common.outSideTouch
	self.libaodengji2:setVisible(false)
	self.lv:setVisible(false)
	local lv = Master.getInstance().lv
	local cfg = LvGiftLogic.getNextLvGiftCfg(lv)
	if cfg then
		local diff = cfg.lv - lv
		self.libaodengji1.txtsm:setString(string.format("还差%d级即可领取",diff))
		local label = cc.LabelAtlas:_create("0123456789", "res/common/gkNumb.png", 26, 29 , string.byte('0'))
		label:setPosition(cc.p(self.lv:getPositionX(),self.lv:getPositionY()))
		--label:setAnchorPoint(0.5,0)
		label:setString(tostring(cfg.lv))
		label:setScale(0.8)
		self._ccnode:addChild(label)
		local index = 1
		for k,v in pairs(cfg.reward) do
			CommonGrid.bind(self.libaodengji1.group["grid"..index],"tips")
			self.libaodengji1.group["grid"..index]:setItemIcon(k)
			self.libaodengji1.group["grid"..index]:setItemNum(v)
			index = index + 1
			if index > 6 then
				break
			end
		end
	end
end
