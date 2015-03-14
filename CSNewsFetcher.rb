require 'PBRobot'
require './CSNewsExtractor.rb'

class CSNewsFetcher < PBRobot::Fetcher

	def get_extractor(hash)
		CSNewsExtractor.new(hash)
	end

	private :get_extractor

end