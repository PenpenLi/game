module(...,package.seeall)
local GoldDefine = require("src/modules/gold/GoldDefine")
local GoldData = require("src/modules/gold/GoldData")

function onGCGoldBuy(ret,data)
	if ret == GoldDefine.GOLD_BUY_RET.kOk then
		local goldPanel = Stage.currentScene:getUI():getChild("Gold")
		if goldPanel then
			goldPanel:refreshBuy({data})
		else
			local curUI = UIManager.getCurrentUI()
			if curUI then
				local panel = curUI:getChild("Gold")
				if panel then
					panel:refreshBuy({data})
				end
			end
		end
	else
		local content = GoldDefine.GOLD_BUY_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCGoldBuyTen(ret,data)
	if ret == GoldDefine.GOLD_BUY_TEN_RET.kOk then
		local goldPanel = Stage.currentScene:getUI():getChild("Gold")
		if goldPanel then
			goldPanel:refreshBuy(data)
		else
			local curUI = UIManager.getCurrentUI()
			if curUI then
				local panel = curUI:getChild("Gold")
				if panel then
					panel:refreshBuy(data)
				end
			end
		end
	else
		local content = GoldDefine.GOLD_BUY_TEN_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCGoldBuyQuery(cnt)
	GoldData.setData(cnt)
	local goldPanel = Stage.currentScene:getUI():getChild("Gold")
	if goldPanel then
		goldPanel:refreshInfo(cnt)
	else
		local curUI = UIManager.getCurrentUI()
		if curUI then
			local panel = curUI:getChild("Gold")
			if panel then
				panel:refreshInfo(cnt)
			end
		end
	end
end
