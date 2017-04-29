module(...,package.seeall)
local TrainData = require("src/modules/train/TrainData")
local TrainDefine = require("src/modules/train/TrainDefine")
local PublicLogic = require("src/modules/public/PublicLogic")

function onGCTrainQuery(name,base,current)
	TrainData.setData(name,base,current)
	local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
	if HeroInfoUI then
		HeroInfoUI:refreshTrainInfo()
	end
end

function onGCTrain(name,ret)
	if ret == TrainDefine.TRAIN_RET.kOk then
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI and HeroInfoUI.train then
			local train = HeroInfoUI.train
			--Common.setBtnAnimation(train._ccnode,"Complete","train")
			--for i = 1,5 do
			--	if train.up["nature"..i].backeffect then
			--		train.up["nature"..i].backeffect:getAnimation():play("经验条")
			--	else
			--		train.up["nature"..i].backeffect = Common.setBtnAnimation(train.up["nature"..i].back3._ccnode,"Train","经验条")
			--	end
			--end
		end
	elseif ret == TrainDefine.TRAIN_RET.kNoLv then
		local lv = PublicLogic.getOpenLv("train")
		local content = string.format(TrainDefine.TRAIN_RET_TIPS[ret],lv)
		Common.showMsg(content)
	else
		local content = string.format(TrainDefine.TRAIN_RET_TIPS[ret])
		Common.showMsg(content)
	end
end

function onGCTrainAdd(name,ret)
	if ret == TrainDefine.TRAIN_ADD_RET.kOk then
		local HeroInfoUI = require("src/modules/hero/ui/HeroInfoUI").Instance
		if HeroInfoUI and HeroInfoUI.train then
			local train = HeroInfoUI.train
			Common.setBtnAnimation(train._ccnode,"Complete","train")
			--for i = 1,5 do
			--	if train.up["nature"..i].backeffect then
			--		train.up["nature"..i].backeffect:getAnimation():play("经验条")
			--	else
			--		train.up["nature"..i].backeffect = Common.setBtnAnimation(train.up["nature"..i].back3._ccnode,"Train","经验条")
			--	end
			--end
		end
	else
		Common.showMsg(TrainDefine.TRAIN_ADD_RET_TIPS[ret])
	end
end

function onGCTrainQueryAll(group)
	for i = 1,#group do
		local data = group[i]
		TrainData.setData(data.name,data.base,data.current)
	end
end
