require './PBBaseFetcher.rb'
require './CSNewsExtractor.rb'

class CSNewsFetcher < PBBaseFetcher

	def get_extractor(config_hash)
		CSNewsExtractor.new(config_hash)
	end

	private :get_extractor

end