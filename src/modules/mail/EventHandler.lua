module(...,package.seeall)
local MailData = require("src/modules/mail/MailData")
local MailDefine = require("src/modules/mail/MailDefine")

function onGCAskMailList(mailList)
	--print("onGCAskMailList")
	--Common.printR(mailList)
	MailData.setData(mailList)
	local mailPanel = Stage.currentScene:getUI():getChild("MailList")
	if mailPanel then
		mailPanel:refresh()
	end
	if Stage.currentScene.name == "main" and Stage.currentScene.bg1 then
		local mainBg = Stage.currentScene.bg1:getChild("MainBg")
		if mainBg then
			local building = mainBg:getChild("mail")
			Dot.check(building,"mailCheck")
			Dot.setDotAlignment(building,"rTop",{x=60,y=30})
			Dot.setDotScale(building,1.25)
		end
	end
end

function onGCDelMail(ret)
	local content = MailDefine.DEL_MAIL_RET_TIPS[ret]
	Common.showMsg(content)
end

function onGCNewMail()
	Common.showMsg("你收到了新邮件")
	if Stage.currentScene.name == "main" and Stage.currentScene.bg1 then
		local mainbg = Stage.currentScene.bg1:getChild("MainBg")
		if mainbg then
			local building = mainbg:getChild("mail")
			Dot.check(building,"paint")
			Dot.setDotAlignment(building,"rTop",{x=60,y=30})
			Dot.setDotScale(building,1.25)
		end
	end
end

function onGCAskMailDetail(id,content,attach)
	MailData.setDetail(id,content,attach)
	local mailPanel = Stage.currentScene:getUI():getChild("MailList")
	if mailPanel then
		mailDetail = mailPanel:getChild("MailDetail")
		if mailDetail then
			mailDetail:refreshInfo()
		end
	end
end

function onGCReadMail(id,ret)
	local mailList = MailData.getData()
	for k,v in pairs(mailList) do
		if v.id == id then
			v.status = MailDefine.MAIL_STATUS_READED
		end
	end
	if Stage.currentScene.name == "main" and Stage.currentScene.bg1 then
		local mainBg = Stage.currentScene.bg1:getChild("MainBg")
		local building = mainBg:getChild("mail")
		Dot.check(building,"mailCheck")
		Dot.setDotAlignment(building,"rTop",{x=60,y=30})
		Dot.setDotScale(building,1.25)
	end
end
