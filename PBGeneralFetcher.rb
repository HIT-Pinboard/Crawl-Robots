require 'PBRobot'
require './PBGeneralExtractor.rb'

class PBGeneralFetcher < PBRobot::Fetcher

	def get_extractor(hash)
		PBGeneralExtractor.new(hash)
	end

	private :get_extractor

end