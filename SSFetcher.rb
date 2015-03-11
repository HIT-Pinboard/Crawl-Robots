require 'PBRobot'
require './SSExtractor.rb'

class SSFetcher < PBRobot::Fetcher

	def get_extractor(config_hash)
		SSExtractor.new(config_hash)
	end

	private :get_extractor

end