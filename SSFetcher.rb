require './PBBaseFetcher.rb'
require './SSExtractor.rb'

class SSFetcher < PBBaseFetcher

	def get_extractor(config_hash)
		SSExtractor.new(config_hash)
	end

	private :get_extractor

end