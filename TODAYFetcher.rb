require './PBBaseFetcher.rb'
require './TODAYExtractor.rb'

class TodayFetcher < PBBaseFetcher

	def get_extractor(config_hash)
		TodayExtractor.new(config_hash)
	end

	private :get_extractor

end
