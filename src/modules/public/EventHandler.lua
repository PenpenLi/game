module(...,package.seeall)
local PublicLogic = require("src/modules/public/PublicLogic")
local Define = require("src/modules/public/PublicDefine")

function onGCReturnCode(retCode)
	if retCode == Define.ERR_CODE.LV_NOT_ENOUGH then
		TipsUI.showTipsOnlyConfirm('战队'..PublicLogic.getOpenLv('treasure').."级开放本系统")
	else
		Common.showMsg(Define.ERR_TXT[retCode] or "操作失败")
	end
end


