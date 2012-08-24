require("heroku/client")
require("#{File.dirname(__FILE__)}/lib/ext/heroku/client")

require("heroku/command/addons")
require("#{File.dirname(__FILE__)}/lib/ext/heroku/command/addons")

require("heroku/command/pg")
require("#{File.dirname(__FILE__)}/lib/ext/heroku/command/pg")

require("heroku/helpers/heroku_postgresql")
require("#{File.dirname(__FILE__)}/lib/ext/heroku/helpers/heroku_postgresql")
