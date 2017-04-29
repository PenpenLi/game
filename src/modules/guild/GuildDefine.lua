module(...,package.seeall)

GUILD_LEADER = 1	--会长
GUILD_SENIOR = 2	--长老
GUILD_NORMAL = 3	--帮众

GUILD_POS = {
	[1] = "会长",
	[2] = "长老",
	[3] = "帮众",
}

MEMBER_TAG = 1
APPLY_TAG = 2

GUILD_CREATE_RET = {
	kOk = 1,		--创建成功
	kNameExist = 2,	--公会名已经存在
	kHasGuild = 3,	--已经在公会中
	kNotLv = 4,		--等级不够
	kNotRmb = 5,		--金币不够
	kNameInVaild = 6,	--名字无效
}

GUILD_CREATE_TIPS = {
	[1] = "公会创建成功",
	[2] = "公会名已经存在",
	[3] = "你已经是公会成员",
	[4] = "创建公会等级要求%d级",
	[5] = "钻石不够",
	[6] = "非法名字",
	[7] = "公会名称不能超过8个字",
}

GUILD_APPLY_RET = {
	kOk = 1,		--申请成功
	kHasGuild = 2,	--已经在公会中
	kNotExist = 3,	--公会不存在
	kGuildCD = 4,	--加入公会冷却中
	kHasApply = 5, --已经申请过
}

GUILD_APPLY_TIPS = {
	[1] = "公会申请成功",
	[2] = "你已经是公会成员",
	[3] = "公会不存在",
	[4] = "加入公会冷却中",
	[5] = "已经申请过",
}

GUILD_APPLY_CANCEL_RET = {
	kOk = 1,		--取消申请成功
	kNotExist = 2,	--公会不存在
	kHasGuild = 3,	--已经在公会中
}
GUILD_APPLY_CANCEL_RET_TIPS = {
	[1] = "取消申请成功",
	[2] = "公会不存在",
	[3] = "你已经是公会成员",
}

GUILD_APPLY_QUERY = {
	kOk = 1,		--查询成功
	kNotGuild = 2,	--不在公会中
	kNoAuth = 3,	--没有权限
}

GUILD_MEMBER_QUERY = {
	kOk = 1,		--查询成功
	kNotGuild = 2,	--不在公会中
}

GUILD_ACCEPT = {
	kAgree = 1,		--同意
	kReject= 2,		--拒绝
}

GUILD_ACCEPT_TIPS = {
	[1] = "操作成功",
	[2] = "没有公会",
	[3] = "不是公会成员",
	[4] = "你没有权限",
	[5] = "公会成员已满",
	[6] = "对方已经有公会",
}

GUILD_MEM_OPERATE = {
	kAppoint = 1,		--任命长老
	kPassto  = 2,		--转交会长
	kKickoff = 3,		--踢出公会 
	kRemove = 4,		--卸任长老
}

GUILD_MEM_OPERATE_TIPS = {
	[1] = "操作成功",
	[2] = "没有公会",
	[3] = "不是公会成员",
	[4] = "你没有权限",
	[5] = "不能对自己操作",
	[6] = "达到长老最大数量",
}

GUILD_QUIT = {
	kOk = 1,
}

GUILD_QUIT_TIPS = {
	[1] = "操作成功",
	[2] = "没有公会",
	[3] = "公会不存在",
	[4] = "不是公会成员",
	[5] = "会长不能退出公会",
}

GUILD_DESTROY = {
	kOk = 1,
}

GUILD_DESTROY_TIPS = {
	[1] = "操作成功",
	[2] = "没有公会",
	[3] = "公会不存在",
	[4] = "不是公会成员",
	[5] = "只有会长能解散公会",
	[6] = "不可解散公会",
}

GUILD_MOD_ANNOUNCE_RET = {
	kOk = 1,			--操作成功
	kFail = 2,			--操作失败
	kSensitive = 3,			--有敏感词
}

GUILD_MOD_ANNOUNCE_RET_TIPS = {
	[1] = "修改成功",
	[2] = "修改失败",
	[3] = "有敏感词，请重新输入",
}

NO_AUTH_TIPS = "你没有权限"

GUILD_APPLYING = 1
GUILD_NOTAPPLY = 2

GUILD_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,
}

MEMBER_QUERY_RET = {
	kOk = 1,
	kNoGuild = 2,
}
