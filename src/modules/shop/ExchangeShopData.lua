module(...,package.seeall)

exchangeShop = exchangeShop or {
		shopData = {},
		refreshTimes = 0,
}

function setShopData(shopData,refreshTimes)
	exchangeShop = {
		shopData = shopData,
		refreshTimes = refreshTimes
	}
end

function getRefreshTimes()
	return exchangeShop.refreshTimes
end
