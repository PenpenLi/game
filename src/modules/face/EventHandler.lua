module(...,package.seeall)
local FaceDefine = require("src/modules/face/FaceDefine")
local FaceData = require("src/modules/face/FaceData")

function onGCFaceBuy(ret,data)
	if ret == FaceDefine.Face_BUY_RET.kOk then
		local FacePanel = Stage.currentScene:getUI():getChild("Face")
		if FacePanel then
			FacePanel:refreshBuy({data})
		else
			local curUI = UIManager.getCurrentUI()
			if curUI then
				local panel = curUI:getChild("Face")
				if panel then
					panel:refreshBuy({data})
				end
			end
		end
	else
		local content = FaceDefine.Face_BUY_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCFaceBuyTen(ret,data)
	if ret == FaceDefine.Face_BUY_TEN_RET.kOk then
		local FacePanel = Stage.currentScene:getUI():getChild("Face")
		if FacePanel then
			FacePanel:refreshBuy(data)
		else
			local curUI = UIManager.getCurrentUI()
			if curUI then
				local panel = curUI:getChild("Face")
				if panel then
					panel:refreshBuy(data)
				end
			end
		end
	else
		local content = FaceDefine.Face_BUY_TEN_RET_TIPS[ret]
		Common.showMsg(content)
	end
end

function onGCFaceBuyQuery(cnt)
	FaceData.setData(cnt)
	local FacePanel = Stage.currentScene:getUI():getChild("Face")
	if FacePanel then
		FacePanel:refreshInfo(cnt)
	else
		local curUI = UIManager.getCurrentUI()
		if curUI then
			local panel = curUI:getChild("Face")
			if panel then
				panel:refreshInfo(cnt)
			end
		end
	end
end
