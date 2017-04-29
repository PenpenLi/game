module(...,package.seeall)

mailList = mailList or {}

function setData(list)
	table.sort(list,function(a,b)
		if a.sendtime == b.sendtime then
			return a.id > b.id
		else
			return a.sendtime > b.sendtime 
		end
	end)
	mailList = list 
end

function getData()
	return mailList
end

function setDetail(id,content,attach)
	for k,v in pairs(mailList) do
		if v.id == id then
			v.content = content
			v.attachment = attach
			break
		end
	end
end
