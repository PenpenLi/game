module(...,package.seeall)

arenaShop = arenaShop or {
		shopData = {},
		refreshTimes = 0,
}

function setShopData(shopData,refreshTimes)
	arenaShop = {
		shopData = shopData,
		refreshTimes = refreshTimes
	}
end

function getRefreshTimes()
	return arenaShop.refreshTimes
end
