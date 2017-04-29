module(...,package.seeall)

UserData = {
	{"id",		"string",	"用户id"},
	{"name",	"string",	"用户名"},
	{"lv",		"int",	"用户等级"},
	{"fighting","int",	"战斗力"},
	{"icon",	"int",	"用户图标"},
	{"isOnline", "int", "是否在线"}
}

EnemyHeroData ={
    {"name",      		"string",  			"名字"},
    {"exp",				"int",				"经验"},
    {"quality",			"int",				"品质"},
    {"lv",				"int",				"等级"},
}

EnemyData = {
	{"name",		"string",		"战队名称"},
	{"lv",			"int",		"战队等级"},
	{"icon",		"int",			"战队图标"},
	{"rank",		"int",		"排名"},
	{"guild",		"string",		"公会名"},
	{"win",			"int",			"胜场数"},
	{"fightVal",	"int",			"战斗力"},
	{"flowerCount",				"int",					"鲜花数"},
	{"fightList",	EnemyHeroData,	"出战阵容",		"repeated"},
}


UserInfoData = {
	{"id",		"string",	"用户id"},
	{"name",	"string",	"用户名"},
	{"lv",		"int",	"用户等级"},
	{"fighting","int",	"战斗力"},
	{"icon",	"int",	"用户图标"},
	{"isOnline", "int", "是否在线"},
	{"arena", EnemyData, "用户信息"},
}

GCRecommendList = {
	{"recommendlist",	UserData,	"推荐列表", "repeated"}
}

CGRecommendList = {
}

GCFaceQuery = {
	{"user",	UserData,	"查询"}
}

CGFaceQuery = {
	{"name",	"string",	"玩家名字"},
}

GCFaceList = {
	{"friendlist",	UserInfoData,	"好友列表","repeated"}
}

CGFaceList = {
}

GCApplyList = {
	{"applylist",	UserData,	"申请列表","repeated"}
}

CGApplyList = {
}

CGFaceAdd = {
	{"id", "string","Account"}
}

GCFaceAdd = {
	{"status",	"int",	"添加返回码"}
}

CGFaceAccept = {
	{"id", "string","Account"}
}

GCFaceAccept = {
	{"status",	"int",	"同意返回码"}
}

CGFaceDel = {
	{"id", "string","Account"}
}

GCFaceDel = {
	{"status",	"int",	"删除返回码"}
}

GCFaceReject = {
	{"status",	"int",	"拒绝返回码"}
}

CGFaceReject = {
	{"id", "string","Account"}
}


GCFaceMes = {
	
}
