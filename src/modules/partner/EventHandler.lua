module(...,package.seeall)
local PartnerDefine = require("src/modules/partner/PartnerDefine")
local PartnerData = require("src/modules/partner/PartnerData")

function onGCPartnerQuery(chain)
	PartnerData.setData(chain)
	local PartnerChainUI = Stage.currentScene:getUI():getChild("PartnerChain")
	if PartnerChainUI then
		--PartnerChainUI:refreshChainList("refresh")
		PartnerChainUI:refreshChainInfo()
		PartnerChainUI:refreshGuide()
		--local ComposeUI = PartnerChainUI:getChild("PartnerCompose")
		--if ComposeUI then
		--	ComposeUI:refreshInfo()
		--end
	end
end

function onGCPartnerCompose(ret)
	if ret == PartnerDefine.COMPOSE_RET.kOk then
		local PartnerChainUI = Stage.currentScene:getUI():getChild("PartnerChain")
		if PartnerChainUI then
			PartnerChainUI:playEffect("compose")
			UIManager.playMusic("partnerCompose")
			--local ComposeUI = PartnerChainUI:getChild("PartnerCompose")
			--if ComposeUI then
			--	ComposeUI:playEffect()
			--end
		end
	else
		local content = PartnerDefine.COMPOSE_RET_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end

function onGCPartnerEquip(ret,chainId,partnerId)
	if ret == PartnerDefine.EQUIP_RET.kOk then
		local PartnerChainUI = Stage.currentScene:getUI():getChild("PartnerChain")
		if PartnerChainUI then
			PartnerChainUI:playEffect("active")
		end
		if PartnerData.checkChainActive(chainId) then
			UIManager.addChildUI("src/modules/partner/ui/ChainActiveUI",chainId)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_SUB_COMPONENT)
		end
	else
		local content = PartnerDefine.EQUIP_RET_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end

function onGCPartnerActive(ret,chainId,attrs)
	if ret == PartnerDefine.ACTIVE_RET.kOk then
		local PartnerChainUI = Stage.currentScene:getUI():getChild("PartnerChain")
		if PartnerChainUI then
			PartnerChainUI:playEffect("active")
			PartnerChainUI:refreshChainList("refresh")
		end
		if PartnerData.checkChainActive(chainId) then
			UIManager.addChildUI("src/modules/partner/ui/ChainActiveUI",chainId,attrs)
			GuideManager.dispatchEvent(GuideDefine.GUIDE_UNREGISTER_SUB_COMPONENT)
		end
	else
		local content = PartnerDefine.ACTIVE_RET_TIPS[ret]
		Common.showMsg(string.format(content))
	end
end
