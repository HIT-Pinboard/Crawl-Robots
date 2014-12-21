require './PBBaseFetcher.rb'
require './CSAnnoExtractor.rb'

class CSAnnoFetcher < PBBaseFetcher

	def get_extractor(config_hash)
		CSAnnoExtractor.new(config_hash)
	end

	private :get_extractor

end