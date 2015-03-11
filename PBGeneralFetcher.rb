require 'PBRobot'
require './PBGeneralExtractor.rb'

class PBGeneralFetcher < PBRobot::Fetcher

	def get_extractor(config_hash)
		PBGeneralExtractor.new(config_hash)
	end

	private :get_extractor

end