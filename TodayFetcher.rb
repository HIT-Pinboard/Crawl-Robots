require 'PBRobot'
require './TodayExtractor.rb'

class TodayFetcher < PBRobot::Fetcher

	def get_extractor(config_hash)
		TodayExtractor.new(config_hash)
	end

	private :get_extractor

end
