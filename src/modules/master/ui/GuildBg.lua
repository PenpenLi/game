module("GuildBg", package.seeall)
setmetatable(GuildBg, {__index = Control})

function new()
    local ctrl = Control.new(require("res/master/GuildBgSkin"),{"res/master/GuildBg.plist","res/common/an.plist"})
    setmetatable(ctrl,{__index = _M})
    ctrl:init()
    return ctrl
end

function init(self)
	self.kick:addEventListener(Event.Click,function(self,evt)
		selectPanel(self,"src/modules/guild/kick/ui/KickUI")
	end,self)
	self.texas:addEventListener(Event.Click,function(self,evt)
		selectPanel(self,"src/modules/guild/texas/ui/TexasUI")
	end,self)
	self.shop:addEventListener(Event.Click,function(self,evt)
		selectPanel(self,"src/modules/guild/shop/ui/GuildShopUI")
	end,self)
	self.shop:adjustTouchBox(0,0,0,-140)
	self.wine:addEventListener(Event.Click,function(self,evt)
		selectPanel(self,"src/modules/guild/wine/ui/WineUI")
	end,self)
	self.guild:addEventListener(Event.Click,function(self,evt)
		selectPanel(self, "src/modules/guild/ui/GuildInfoUI")
	end,self)
	Network.sendMsg(PacketID.CG_GUILD_APPLY_QUERY)
	Network.sendMsg(PacketID.CG_PAPER_QUERY)

	self.boss:setVisible(false)
	--self.boss:addEventListener(Event.Click,function(self,evt)
	--	local scene = require("src/scene/MainScene").new()
	--	Stage.replaceScene(scene)
	--	scene:addEventListener(Event.InitEnd, function()
	--		scene:setSceneRight()
	--	end)
	--end,self)
end

function selectPanel(self, url,...)
	UIManager.replaceUI(url,...)
end

return GuildBg
