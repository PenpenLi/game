local Weapon = require("src/modules/weapon/Weapon")

Bag.getInstance():addEventListener(Event.BagRefresh, Weapon.refreshDot)
