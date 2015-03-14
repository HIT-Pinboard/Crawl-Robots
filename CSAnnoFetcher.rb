require 'PBRobot'
require './CSAnnoExtractor.rb'

class CSAnnoFetcher < PBRobot::Fetcher

	def get_extractor(hash)
		CSAnnoExtractor.new(hash)
	end

	private :get_extractor

end