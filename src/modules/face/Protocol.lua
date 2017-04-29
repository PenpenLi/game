module(...,package.seeall)

CostInfo = {
	{"gold",	"int",	"消耗钻石"},
	{"money",	"int",	"获得金币"},
	{"rate",	"int",	"暴击倍数"},
}

CGFaceBuy = {
}

GCFaceBuy = {
	{"ret",		"int",	"返回码"},
	{"costInfo",	CostInfo,	"获得钱币信息"},
}

CGFaceBuyTen = {
	{"cnt",		"int",	"购买次数"},
}

GCFaceBuyTen = {
	{"ret",		"int",	"返回码"},
	{"costInfo",	CostInfo,	"获得钱币信息",		"repeated"},
}

CGFaceBuyQuery = {
}

GCFacedBuyQuery = {
	{"cnt",		"int",	"购买次数"},
}
