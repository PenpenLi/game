module(..., package.seeall)
setmetatable(_M, {__index = Control}) 
local OpenLvConfig = require("src/config/OpenLvConfig").Config
local ItemCmd = require("src/modules/bag/ItemCmd")

function new(id)
    local ctrl = Control.new(require("res/common/NewFuncSkin"),{"res/common/NewFunc.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init(id)
    return ctrl
end

function uiEffect()
	return UIManager.FIRST_TEMP_RAW
end

function init(self,ids)
	local id = ids[#ids]
	local cfg = OpenLvConfig[id]
	local function onClose(self,event,target)
		if event.etype == Event.Touch_ended then
			local child = self:getTouchedChild(event.p)
			UIManager.removeUI(self)
			table.remove(ids,#ids)
			if #ids > 0 then
				UIManager.addUI("src/ui/NewFuncUI",ids)
			end
			if child and child.name == "go" then
				if self.btn then
					self.btn.ani:removeFromParent()
					self.btn.ani = nil
				end
				if ItemCmd[cfg.link] then
					ItemCmd[cfg.link]()
				end
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_ARENA, step = 1})
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_WEAPON, step = 1})
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_TRIAL, step = 2})
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_EXPEDITION, step = 2})
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_OROCHI, step = 2})
				GuideManager.dispatchEvent(GuideDefine.GUIDE_REMOVE_MASK, {groupId = GuideDefine.GUIDE_PEAK, step = 2})
			end
		end
	end
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.go, step = 1, groupId = GuideDefine.GUIDE_ARENA})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.go, step = 1, groupId = GuideDefine.GUIDE_WEAPON})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.go, step = 2, groupId = GuideDefine.GUIDE_TRIAL})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.go, step = 2, groupId = GuideDefine.GUIDE_EXPEDITION})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.go, step = 2, groupId = GuideDefine.GUIDE_OROCHI})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_REGISTER_COMPONENT, {component=self.go, step = 2, groupId = GuideDefine.GUIDE_PEAK})

	self:removeEventListener(Event.TouchEvent,onClose)
	self:addEventListener(Event.TouchEvent,onClose)
	self.desc:setString(string.format("恭喜！你开启了【%s】",cfg.cname))
	Common.setLabelCenter(self.desc2)
	self.desc2:setString(cfg.desc)
	if cfg.pic ~= "" then
		local mainbg2Buildings = {
			["boss"] = 1,
			["orochi"] = 1,
			["expedition"] = 1,
			["adverture"] = 1,
			["arena"] = 1,
		}
		local sprite
		if mainbg2Buildings[cfg.pic] then
			sprite = Sprite.createWithSpriteFrameName("MainBg2.btn_"..cfg.pic)
		else
			sprite = Sprite.createWithSpriteFrameName("MainBg.btn_"..cfg.pic)
		end
		if sprite then
			sprite:setPositionX(self.pic:getPositionX()+self.pic:getContentSize().width/2)
			sprite:setPositionY(self.pic:getPositionY()+self.pic:getContentSize().height/2)
			sprite:setAnchorPoint(0.5,0.5)
			sprite:setScale(0.8)
			self:addChild(sprite,-1)
		end
		if Stage.currentScene.name == "main" then
			if mainbg2Buildings[cfg.pic] then
				local mainBg2 = Stage.currentScene.bg2:getChild("MainBg2")
				if mainBg2 then
					mainBg2[cfg.pic].ani = Common.setBtnAnimation(mainBg2[cfg.pic]._ccnode,"BuildBlink",1)
					self.btn = mainBg2[cfg.pic]
				end
			else
				local mainBg = Stage.currentScene.bg1:getChild("MainBg")
				if mainBg then
					mainBg[cfg.pic].ani = Common.setBtnAnimation(mainBg[cfg.pic]._ccnode,"BuildBlink",1)
					self.btn = mainBg[cfg.pic]
				end
			end
		end
	end

	self.pic:setVisible(false)
end

function clear(self)
	Control.clear(self)
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_ARENA})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 1, groupId = GuideDefine.GUIDE_WEAPON})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_TRIAL})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_EXPEDITION})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_OROCHI})
	GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_COMPONENT, {step = 2, groupId = GuideDefine.GUIDE_PEAK})
end
