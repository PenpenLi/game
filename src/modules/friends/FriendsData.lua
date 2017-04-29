module(...,package.seeall)
userList = {
}

userInfo = {}

function setUserList(list)
	userList = list;
end

function getUserList()
	return userList
end

function setUserInfo( user )
	userInfo = user
end

function getUserInfo( )
	return userInfo
end