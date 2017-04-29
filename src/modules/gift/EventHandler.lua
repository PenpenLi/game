module(...,package.seeall)
local GiftLogic = require("src/modules/gift/GiftLogic")
local Hero = require("src/modules/hero/Hero")
--local GiftDefine

function onGCGiftQuery(gift)
	Common.printR(gift)
	local GiftUI = require("src/modules/gift/ui/GiftUI").Instance
	for _,data in ipairs(gift) do
		local hero = Hero.getHero(data.name)
		hero.gift = data.id
		if GiftUI and data.name == GiftUI:getHero().name then
			GiftUI:updateHero()
		end
	end
	local mainUI = require("src/modules/master/ui/MainUI").Instance
	if mainUI then
		Dot.check(mainUI.right.rdown.gift,"giftTeam")
	end
end

function onGCGiftActivate(ret)
	--提示成功否？
	--Common.showMsg("激活天赋成功")
	local GiftUI = require("src/modules/gift/ui/GiftUI").Instance
	if GiftUI then
		GiftUI:addArmatureFrame("res/common/effect/complete/Complete.ExportJson") 
		--Common.setBtnAnimation(GiftUI.info.activate._ccnode,"Complete","active")
		Common.setBtnAnimation(GiftUI._ccnode,"Complete","active")
	end
end
