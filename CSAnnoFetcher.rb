require 'PBRobot'
require './CSAnnoExtractor.rb'

class CSAnnoFetcher < PBRobot::Fetcher

	def get_extractor(config_hash)
		CSAnnoExtractor.new(config_hash)
	end

	private :get_extractor

end