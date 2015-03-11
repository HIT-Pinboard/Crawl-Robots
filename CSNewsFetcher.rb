require 'PBRobot'
require './CSNewsExtractor.rb'

class CSNewsFetcher < PBRobot::Fetcher

	def get_extractor(config_hash)
		CSNewsExtractor.new(config_hash)
	end

	private :get_extractor

end