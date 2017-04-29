module("Config",package.seeall)
setmetatable(Config, {__index = require("src/ConfigBase")}) 


return Config

