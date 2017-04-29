module(...,package.seeall)

Cnt = Cnt or 0

function setData(cnt)
	Cnt = cnt
end

function getData()
	return Cnt
end
