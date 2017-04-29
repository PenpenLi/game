module(...,package.seeall)


local Handbook = require("src/modules/handbook/Handbook")
local Def = require("src/modules/handbook/HandbookDefine")


function onGCHandbookInfo(info)
	Handbook.addHandbookInfo(info)
end

function onGCHandbookReward(result,name,id)
	if result == Def.RET_OK then
		local ui = UIManager.getUI("HandbookReward")
		if ui then
			ui:showReward(name)
		end
	end

end

function onGCHandbookItemlib(lib)
	Handbook.setItemlib(lib)
	UIManager.replaceUI("src/modules/handbook/ui/HandbookUI",'item')
end