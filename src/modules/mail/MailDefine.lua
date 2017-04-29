module(...,package.seeall)

MAIL_TYPE_SYSTEM = 1
MAIL_TYPE_PRIVATE = 2

MAIL_STATUS_UNREAD   = 1  --未读
MAIL_STATUS_READED   = 2  --已读

DEL_MAIL_RET = {
	kDelOk = 1,		--删除成功
	kGetOk = 2,		--提取成功
	kBagFull = 3,	--背包满
	kDataErr = 4,	--数据错误
}

DEL_MAIL_RET_TIPS = {
	[1] = "删除成功",
	[2] = "提取成功",
	[3] = "背包已满",
	[4] = "数据错误",
}

READ_MAIL_RET = {
	kOk = 1,
	kDataErr = 2,
}
