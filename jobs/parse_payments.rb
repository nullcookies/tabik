require_relative './requires'
require 'colorize'
require 'csv'

logger = CronLogger.new
# DB.logger = logger

bot = Bot[548]



DB.disconnect
logger.noise "Finished."
